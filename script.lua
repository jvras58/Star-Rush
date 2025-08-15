--[[
*** STAR - RACE ***
Experimento de Cooperacao
]]

-- Configuracoes basicas
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAfkDeath(true)

local mapas = {"@5451839", "@5445849", "@6599901", "@6682692", "@6399897"}
local starList = {} -- {id, x, y, public}
local starID = 0
local radius = 35^2 -- Raio de coleta dos itens
local bagPublic = {}
local bagPrivate = {}
local pot = 0
local scarcity = 1.0
local nextSpawn = 0
local eventName = ""
local roundNumber = 0
local maxRounds = 6 -- Limite de rodadas
local isGameOver = false -- Variavel de controle para o fim de jogo
local events = {"Seca", "Aurora", "Fiscalizacao", "VazamentoPrivado", "Doacao", "ChuvaDeEstrelas"}

-- 📊 Sistema de coleta de dados
local gameData = {}
local playerStats = {}
local roomCooperation = 0

-- 🗺️ Sistema de análise de mapa
local mapGrounds = {}
local mapDecorations = {}
local validSpawnAreas = {}

-- 🔍 Função para extrair e analisar XML do mapa
function analyzeMapXML()
    mapGrounds = {}
    mapDecorations = {}
    validSpawnAreas = {}

    if not tfm.get.room.xmlMapInfo or not tfm.get.room.xmlMapInfo.xml then
        return false
    end

    local xml = tfm.get.room.xmlMapInfo.xml
    local mapWidth = tfm.get.room.xmlMapInfo.width or 800
    local mapHeight = tfm.get.room.xmlMapInfo.height or 400

    -- Extrai grounds (pisos) do XML
    xml:gsub('<S(.-)/>', function(attributes)
        local ground = {}
        ground.x = tonumber(attributes:match('X="([^"]*)"')) or 0
        ground.y = tonumber(attributes:match('Y="([^"]*)"')) or 0
        ground.width  = tonumber(attributes:match('L="([^"]*)"')) or 10
        ground.height = tonumber(attributes:match('H="([^"]*)"')) or 10
        ground.type   = tonumber(attributes:match('T="([^"]*)"')) or 0
        -- Considera somente alguns tipos como sólidos (ignora água/ácido, etc.)
        if ground.type ~= 1 and ground.type ~= 2 then
            table.insert(mapGrounds, ground)
        end
    end)

    -- Extrai decorações
    xml:gsub('<D(.-)/>', function(attributes)
        local decoration = {}
        decoration.x = tonumber(attributes:match('X="([^"]*)"')) or 0
        decoration.y = tonumber(attributes:match('Y="([^"]*)"')) or 0
        table.insert(mapDecorations, decoration)
    end)

    -- Gera áreas válidas para spawn
    generateValidSpawnAreas(mapWidth, mapHeight)
    return true
end

-- 🎯 Gera áreas válidas para spawn de Estrelas
function generateValidSpawnAreas(mapWidth, mapHeight)
    local gridSize = 40 -- tamanho da malha de amostragem
    for x = 50, mapWidth - 50, gridSize do
        for y = 50, mapHeight - 50, gridSize do
            if isValidSpawnPosition(x, y) then
                table.insert(validSpawnAreas, { x = x, y = y })
            end
        end
    end

    -- fallback de segurança
    if #validSpawnAreas == 0 then
        -- Isso pode acontecer em mapas sem plataformas ou com XML malformado
        for i = 1, 8 do
            table.insert(validSpawnAreas, {
                x = math.random(80, mapWidth - 80),
                y = math.random(80, mapHeight - 80)
            })
        end
    end
end

-- 🔍 Verifica se uma posição é válida (topo de plataforma / livre)
function isValidSpawnPosition(x, y)
    local isOnPlatform = false
    -- 1. Verifica se a posição (x, y) está em cima de alguma plataforma
    for _, ground in pairs(mapGrounds) do
        local gLeft = ground.x - ground.width / 2
        local gRight = ground.x + ground.width / 2
        local gTop = ground.y - ground.height / 2
        
        -- Verifica se o X está dentro dos limites horizontais do ground
        if x > gLeft and x < gRight then
            -- Verifica se o Y está ligeiramente acima da superfície do ground (numa "fatia" de 50 pixels)
            if y > gTop - 40 and y < gTop + 10 then
                isOnPlatform = true
                break -- Encontrou uma plataforma válida, pode parar de procurar
            end
        end
    end

    -- Se não encontrou nenhuma plataforma, a posição é inválida
    if not isOnPlatform then
        return false
    end

    -- 2. Se está numa plataforma, verifica se não colide com decorações
    for _, decoration in pairs(mapDecorations) do
        local dx = math.abs(x - decoration.x)
        local dy = math.abs(y - decoration.y)
        if dx < 25 and dy < 25 then
            return false -- Colide com decoração, posição inválida
        end
    end

    -- Passou por todas as verificações: está numa plataforma e longe de decorações
    return true
end


-- 🔍 Verifica se posição é válida para spawn
function isValidSpawnLocation(x, y)
    -- bordas
    if x < 50 or y < 50 then return false end
    if not tfm.get.room.xmlMapInfo then return true end

    local mapWidth = tfm.get.room.xmlMapInfo.width or 800
    local mapHeight = tfm.get.room.xmlMapInfo.height or 400
    if x > mapWidth - 50 or y > mapHeight - 50 then return false end

    -- distância mínima de outras Estrelas
    for _, star in pairs(starList) do
        local dx = x - star.x
        local dy = y - star.y
        if dx * dx + dy * dy < 40^2 then
            return false
        end
    end

    -- Prioriza áreas válidas do XML
    if #validSpawnAreas > 0 then
        for _, area in pairs(validSpawnAreas) do
            local dx = math.abs(x - area.x)
            local dy = math.abs(y - area.y)
            if dx < 60 and dy < 60 then
                return true
            end
        end
        return false
    end

    return true
end

-- 🔍 Encontra Estrela do tipo oposto mais próxima
function findNearestOppositeType(targetX, targetY, targetType)
    local nearestStar = nil
    local minDistance = math.huge

    for i, star in pairs(starList) do
        if star.public ~= targetType then
            local dx = targetX - star.x
            local dy = targetY - star.y
            local distance = dx * dx + dy * dy

            if distance < minDistance and distance <= (80^2) then -- Máximo 80 pixels
                minDistance = distance
                nearestStar = i
            end
        end
    end

    return nearestStar
end

-- 🔢 Limite variável de Estrelas por rodada
function getMaxStarsPerRound()
    return math.min(4 + (roundNumber - 1) * 2, 12)
end

-- 🟢 Inicialização
function init()
    for name in pairs(tfm.get.room.playerList) do
        system.bindKeyboard(name, 81, true, true) -- Q para coletar
        system.bindKeyboard(name, 72, true, true) -- H para ajuda
        system.bindKeyboard(name, 27, true, true) -- ESC para fechar
        bagPublic[name] = 0
        bagPrivate[name] = 0
        playerStats[name] = {
            cooperationRatio = 0,
            totalActions = 0,
            reactionTimes = {},
            spatialPreferences = {}
        }
    end
    
    pot = 0
    roundNumber = 0
    isGameOver = false -- Reseta o estado do jogo

    showTutorial()
    newRound()
end

-- Sistema de tutorial
function showTutorial()
    if roundNumber <= 2 then
        local tutorialText = "<p align='center'><font size='14'><b>=== TUTORIAL - Star Race ===</b></font>\n\n"
        tutorialText = tutorialText .. "<font size='12'>"
        if roundNumber == 1 then
            tutorialText = tutorialText .. "<j>★ ESTRELAS VERDES:</j> Beneficiam todos os jogadores (vao para o pote)\n"
            tutorialText = tutorialText .. "<o>★ ESTRELAS AMARELAS:</o> Apenas para voce (colecao privada)\n\n"
            tutorialText = tutorialText .. "<v>-> Pressione Q proximo a elas!</v>"
        else
            tutorialText = tutorialText .. "<j>★ SISTEMA DO POTE ★:</j> Se atingir 20 estrelas, todos ganham bonus e a partida acaba\n"
            tutorialText = tutorialText .. "<r>! DILEMA:</r> Cooperar ou ser individualista?\n\n"
            tutorialText = tutorialText .. "<v>-> Estrategia e fundamental!</v>"
        end
        tutorialText = tutorialText .. "\n\n<font size='10'><r>+ Pressione ESC para fechar este tutorial +</r></font>"
        tutorialText = tutorialText .. "</font></p>"

        ui.addTextArea(999, tutorialText, nil, 100, 100, 600, 220, 0x1A1A1A, 0x7F7F7F, 0.9, true)
    end
end

-- 🔁 Nova rodada (usa análise de XML do mapa)
function newRound()
    if isGameOver then return end

    -- Remove todos os símbolos ASCII da rodada anterior
    for i = 1, starID do
        ui.removeTextArea(20000 + i, nil)
    end
    
    starList = {}
    starID = 0
    roundNumber = roundNumber + 1

    -- Remove tutorial se existir
    ui.removeTextArea(999, nil)

    -- Verifica limite de rodadas
    if roundNumber > maxRounds then
        endGame()
        return
    end

    tfm.exec.newGame(mapas[math.random(#mapas)])

    nextSpawn = 0
    eventName = events[math.random(#events)]
    applyEvent(eventName)
    showTutorial()
    tfm.exec.setGameTime(30)
    updateUI()
end

-- Spawn de estrelas usando análise do mapa
function spawnStar()
    if not tfm.get.room.xmlMapInfo or isGameOver then return end

    local mapWidth  = tfm.get.room.xmlMapInfo.width  or 800
    local mapHeight = tfm.get.room.xmlMapInfo.height or 400
    local targetStars = getMaxStarsPerRound()
    local attempts = 0

    if #validSpawnAreas > 0 then
        -- Embaralha áreas
        local shuffled = {}
        for _, area in ipairs(validSpawnAreas) do
            table.insert(shuffled, area)
        end
        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end

        local idx = 1
        while #starList < targetStars and idx <= #shuffled do
            local area = shuffled[idx]
            local x = math.max(80, math.min(mapWidth - 80, area.x + math.random(-20, 20)))
            local y = math.max(80, math.min(mapHeight - 80, area.y + math.random(-20, 20)))

            if isValidSpawnLocation(x, y) then
                local isPublic = math.random() < 0.6
                local symbol = "★"
                local color = isPublic and 0x55FF55 or 0xFFDD00 

                starID = starID + 1
                tfm.exec.addPhysicObject(10000 + starID, x, y, {
                    type = 12, width = 35, height = 35,
                    foreground = true, friction = 0.3, restitution = 0.2,
                    angle = 0, color = 0x000000, alpha = 0.01
                })
                ui.addTextArea(20000 + starID, "<p align='center'><font size='20' color='#" .. string.format("%06X", color) .. "'><b>" .. symbol .. "</b></font></p>", nil, x-17, y-17, 35, 35, 0, 0, 0, false)
                table.insert(starList, { id = starID, x = x, y = y, public = isPublic })

                -- tenta spawnar o par do tipo oposto próximo (em outra área válida)
                if #starList < targetStars and idx < #shuffled then
                    idx = idx + 1
                    local pairArea = shuffled[idx]
                    local px = math.max(80, math.min(mapWidth - 80, pairArea.x + math.random(-20, 20)))
                    local py = math.max(80, math.min(mapHeight - 80, pairArea.y + math.random(-20, 20)))
                    if isValidSpawnLocation(px, py) then
                        local pairIsPublic = not isPublic
                        local pairSymbol = "★"
                        local pairColor = pairIsPublic and 0x55FF55 or 0xFFDD00

                        starID = starID + 1
                        tfm.exec.addPhysicObject(10000 + starID, px, py, {
                            type = 12, width = 35, height = 35,
                            foreground = true, friction = 0.3, restitution = 0.2,
                            angle = 0, color = 0x000000, alpha = 0.01
                        })
                        ui.addTextArea(20000 + starID, "<p align='center'><font size='20' color='#" .. string.format("%06X", pairColor) .. "'><b>" .. pairSymbol .. "</b></font></p>", nil, px-17, py-17, 35, 35, 0, 0, 0, false)
                        table.insert(starList, { id = starID, x = px, y = py, public = pairIsPublic })
                    end
                end
            end
            idx = idx + 1
        end
    else
        -- Fallback (mapa sem XML analisável ou sem plataformas)
        while #starList < targetStars and attempts < 100 do
            attempts = attempts + 1
            local x = math.random(80, mapWidth - 80)
            local y = math.random(80, mapHeight - 80)
            if isValidSpawnLocation(x, y) then
                local isPublic = math.random() < 0.6
                local symbol = "★"
                local color = isPublic and 0x55FF55 or 0xFFDD00

                starID = starID + 1
                tfm.exec.addPhysicObject(10000 + starID, x, y, {
                    type = 12, width = 35, height = 35,
                    foreground = true, friction = 0.3, restitution = 0.2,
                    angle = 0, color = 0x000000, alpha = 0.01
                })
                ui.addTextArea(20000 + starID, "<p align='center'><font size='20' color='#" .. string.format("%06X", color) .. "'><b>" .. symbol .. "</b></font></p>", nil, x-17, y-17, 35, 35, 0, 0, 0, false)
                table.insert(starList, { id = starID, x = x, y = y, public = isPublic })
            end
        end
    end
end

-- ⌨️ Entrada
function eventMouse(name, x, y)
    tryPickStar(name, x, y)
end

function eventKeyboard(name, key, down)
    if key == 81 then -- Q key
        local p = tfm.get.room.playerList[name]
        if p then
            tryPickStar(name, p.x, p.y)
        end
    elseif key == 72 and down then -- H key para ajuda
        showHelp(name)
    elseif key == 27 and down then -- ESC key para fechar tutorial/ajuda
        ui.removeTextArea(999, name) -- Remove tutorial
        ui.removeTextArea(995, name) -- Remove ajuda
    end
end

-- 📋 Sistema de ajuda
function showHelp(name)
    local helpText = "<p align='center'><font size='12'><b>[== AJUDA - Star Race ==]</b></font>\n\n"
    helpText = helpText .. "<font size='10'>"
    helpText = helpText .. "<j>★ ESTRELAS VERDES:</j> Vao para o pote comum (2 pontos)\n"
    helpText = helpText .. "<o>★ ESTRELAS AMARELAS:</o> Ficam so para voce (1 ponto)\n\n"
    helpText = helpText .. "<b>* OBJETIVO:</b> Maior pontuacao individual\n"
    helpText = helpText .. "<b>! POTE:</b> Se chegar a 20, o jogo acaba e todos ganham bonus!\n"
    helpText = helpText .. "<b>+ ESTRATEGIA:</b> Coletar um item remove o par oposto\n\n"
    helpText = helpText .. "<b>= CONTROLES:</b>\n"
    helpText = helpText .. "• <v>Pressione <v>[Q]</v> proximo\n"
    helpText = helpText .. "• <v>[H]</v> para mostrar esta ajuda\n"
    helpText = helpText .. "• <v>[ESC]</v> para fechar tutorial/ajuda\n\n"
    helpText = helpText .. "<v>-> Meta: " .. maxRounds .. " rodadas | Atual: " .. roundNumber .. " <-</v>\n"
    helpText = helpText .. "<font size='8'><n>[========================]</n></font>"
    helpText = helpText .. "</font></p>"

    ui.addTextArea(995, helpText, name, 100, 80, 600, 320, 0x1A1A1A, 0x7F7F7F, 0.9, true)
end

-- 🎲 Evento aleatório com balanceamento dinâmico
function applyEvent(name)
    local playerCount = 0
    for _ in pairs(tfm.get.room.playerList) do playerCount = playerCount + 1 end

    if name == "Aurora" then
        scarcity = math.max(0.5, scarcity - 0.1)
    elseif name == "Seca" then
        scarcity = scarcity + (0.2 * math.min(playerCount / 4, 1))
    elseif name == "Fiscalizacao" then
        for player in pairs(tfm.get.room.playerList) do
            bagPrivate[player] = math.floor(bagPrivate[player] * 0.5)
            logPlayerAction(player, "fiscalization_penalty", {lost = bagPrivate[player] * 0.5})
        end
    elseif name == "VazamentoPrivado" then
        for player in pairs(tfm.get.room.playerList) do
            local leaked = bagPrivate[player] * 0.25
            pot = pot + leaked
            logPlayerAction(player, "private_leak", {leaked = leaked})
        end
    elseif name == "Doacao" then
        local donation = 2 * math.max(1, playerCount / 2)
        for player in pairs(tfm.get.room.playerList) do
            pot = pot + donation
            logPlayerAction(player, "donation_received", {amount = donation})
        end
    elseif name == "ChuvaDeEstrelas" then
        spawnStar()
    end

    local potTarget = math.max(15, 20 + (playerCount - 4) * 2)
end

-- 🧲 Sistema de coleta estratégica com remoção automática
function tryPickStar(name, x, y)
    if not x or not y or isGameOver then return end
    for i = #starList, 1, -1 do
        local c = starList[i]
        local dx = x - c.x
        local dy = y - c.y
        if dx * dx + dy * dy <= radius then
            -- Log da ação
            logPlayerAction(name, "collect_star", {
                star_type = c.public and "public" or "private",
                position = {x = c.x, y = c.y}
            })

            -- Atualiza estatísticas do jogador
            if playerStats[name] then
                playerStats[name].totalActions = playerStats[name].totalActions + 1
                table.insert(playerStats[name].spatialPreferences, {x = c.x, y = c.y})
            end

            if c.public then
                bagPublic[name] = bagPublic[name] + 1
                pot = pot + 1 * scarcity
            else
                bagPrivate[name] = bagPrivate[name] + 1
            end

            -- Verifica a meta do pote e encerra o jogo
            if pot >= 20 then
                endGame()
                return
            end

            -- Remove a estrela coletada
            tfm.exec.removePhysicObject(10000 + c.id)
            ui.removeTextArea(20000 + c.id, nil) -- Remove símbolo ASCII
            table.remove(starList, i)

            -- Busca e remove estrela do tipo oposto mais próxima
            local oppositeIndex = findNearestOppositeType(c.x, c.y, c.public)
            if oppositeIndex then
                local oppositeStar = starList[oppositeIndex]
                tfm.exec.removePhysicObject(10000 + oppositeStar.id)
                ui.removeTextArea(20000 + oppositeStar.id, nil) -- Remove símbolo ASCII do par
                table.remove(starList, oppositeIndex)
            end
            
            calculateRoomCooperation()
            updateUI()
            break
        end
    end
end

-- 🏁 Fim da rodada
function endRound()
    if pot >= 20 then
        endGame()
        return
    end

    updatePlayerRankings()
    newRound()
end

-- ⏱️ Loop principal do jogo
function eventLoop(current, remaining)
    if isGameOver then return end

    if current > nextSpawn then
        spawnStar()
        nextSpawn = current + 500
    end

    if remaining <= 0 then
        -- Quando o tempo acaba, se ainda não atingiu o máximo de rodadas, inicia a próxima
        -- Se atingiu, encerra o jogo.
        if roundNumber >= maxRounds then
            endGame()
        else
            endRound()
        end
    end
end


-- 🏆 Atualiza rankings dos jogadores
function updatePlayerRankings()
    playerScores = {}
    for name in pairs(tfm.get.room.playerList) do
        playerScores[name] = calculatePlayerScore(name)
    end
end

-- 🏆 Calcula pontuação do jogador
function calculatePlayerScore(name)
    local publicStars = bagPublic[name] or 0
    local privateStars = bagPrivate[name] or 0
    
    local potBonus = 0
    if pot >= 20 then
        local count = 0
        for _ in pairs(tfm.get.room.playerList) do count = count + 1 end
        if count > 0 then
            potBonus = math.floor((pot * 1.5) / count)
        end
    end

    -- Pontuação: 2 pontos por estrela pública, 1 ponto por privada, mais bônus do pote
    return (publicStars * 2) + (privateStars * 1) + potBonus
end

-- 📈 Calcula cooperação da sala
function calculateRoomCooperation()
    local totalPublic = 0
    local totalPrivate = 0
    for name in pairs(tfm.get.room.playerList) do
        totalPublic = totalPublic + (bagPublic[name] or 0)
        totalPrivate = totalPrivate + (bagPrivate[name] or 0)
    end
    local total = totalPublic + totalPrivate
    roomCooperation = total > 0 and (totalPublic / total * 100) or 0
    return roomCooperation
end

-- 📊 Sistema de logging comportamental
function logPlayerAction(player, action, data)
    if not gameData[player] then gameData[player] = {} end
    local logEntry = {
        player = player,
        round = roundNumber,
        action = action,
        star_type = data.star_type or nil,
        position = data.position or nil,
        pot_state = pot,
        event = eventName,
        timestamp = os.time()
    }
    table.insert(gameData[player], logEntry)
end

-- 🎯 Fim do jogo
function endGame()
    -- Garante que a função só rode uma vez
    if isGameOver then return end
    isGameOver = true
    
    updatePlayerRankings()

    -- Encontra vencedor
    local winner = ""
    local maxScore = -1
    local mostCooperative = ""
    local maxCoopRatio = -1
    local mostIndividualistic = ""
    local minCoopRatio = 2

    for name in pairs(tfm.get.room.playerList) do
        local score = playerScores[name] or 0
        if score > maxScore then
            maxScore = score
            winner = name
        end

        local pub = bagPublic[name] or 0
        local pri = bagPrivate[name] or 0
        local total = pub + pri
        if total > 0 then
            local coopRatio = pub / total
            if coopRatio > maxCoopRatio then
                maxCoopRatio = coopRatio
                mostCooperative = name
            end
            if coopRatio < minCoopRatio then
                minCoopRatio = coopRatio
                mostIndividualistic = name
            end
        end
    end

    announceWinner(winner, maxScore, mostCooperative, mostIndividualistic)
end

-- Cerimônia de encerramento
function announceWinner(winner, score, cooperative, individualistic)
    local finalText = "<p align='center'><font size='18'><b>*** FIM DE JOGO! ***</b></font>\n\n"
    if pot >= 20 then
        finalText = finalText .. "<font size='14'><vp>META COOPERATIVA ATINGIDA!</vp></font>\n"
    end
    finalText = finalText .. "<font size='14'><b>* VENCEDOR: <j>" .. tostring(winner) .. "</j> *</b>\n"
    finalText = finalText .. "<b>-> Pontuacao: <j>" .. tostring(score) .. "</j> <-</b>\n\n"
    finalText = finalText .. "<font size='12'>"
    finalText = finalText .. "<b>* Mais Cooperativo:</b> <vp>" .. tostring(cooperative) .. "</vp>\n"
    finalText = finalText .. "<b>+ Mais Individualista:</b> <o>" .. tostring(individualistic) .. "</o>\n\n"

    finalText = finalText .. "<b>=== RANKING FINAL ===</b>\n"
    local sortedPlayers = {}
    for name in pairs(tfm.get.room.playerList) do
        table.insert(sortedPlayers, {name = name, score = playerScores[name] or 0})
    end

    table.sort(sortedPlayers, function(a, b) return a.score > b.score end)

    for i, player in ipairs(sortedPlayers) do
        local pub = bagPublic[player.name] or 0
        local pri = bagPrivate[player.name] or 0
        local medal = ""
        if i == 1 then medal = "<j>* </j>"
        elseif i == 2 then medal = "<vp>+ </vp>"
        elseif i == 3 then medal = "<o>- </o>"
        else medal = "<n>. </n>"
        end

        finalText = finalText .. string.format("%s%d. %s: %d pts (<vp>%d</vp>/<o>%d</o>)\n",
                                                medal, i, player.name, player.score, pub, pri)
    end

    finalText = finalText .. "\n<v>= Cooperacao da Sala: " .. string.format("%.1f", roomCooperation) .. "% =</v>\n"
    finalText = finalText .. "<font size='8'><n>===========================</n></font>"
    finalText = finalText .. "</font></p>"

    ui.addTextArea(996, finalText, nil, 50, 50, 700, 380, 0x1A1A1A, 0x7F7F7F, 0.95, true)
    
    -- Limpa as estrelas restantes do mapa
    for _, star in pairs(starList) do
        tfm.exec.removePhysicObject(10000 + star.id)
        ui.removeTextArea(20000 + star.id, nil)
    end
    starList = {}

    tfm.exec.setGameTime(15) -- Dá 15 segundos para os jogadores verem o resultado
end

-- Interface com ranking em tempo real
function updateUI()
    local text = "<p align='center'><font size='12'><b>*** Star Race ***</b>  "
    local qntdIndividual = 0
    local playerCount = 0
    for _ in pairs(tfm.get.room.playerList) do playerCount = playerCount + 1 end
    if playerCount > 0 then
        qntdIndividual = math.floor(pot / playerCount)
    end


    -- Adiciona indicador visual do evento
    local eventIcon = ""
    if eventName == "Aurora" then eventIcon = "+"
    elseif eventName == "Seca" then eventIcon = "-"
    elseif eventName == "Fiscalizacao" then eventIcon = "!"
    elseif eventName == "VazamentoPrivado" then eventIcon = "~"
    elseif eventName == "Doacao" then eventIcon = "*"
    elseif eventName == "ChuvaDeEstrelas" then eventIcon = "#"
    end

    text = text .. string.format("<v>%s %s</v>  <n>| Rodada: <j>%d/%d</j> | Pote: <j>%d</j>/20 | Individual: <j>%d</j>\n",
                                    eventIcon, eventName, roundNumber, maxRounds, math.floor(pot), qntdIndividual)

    -- Barra visual de cooperação
    local coopBars = math.floor(roomCooperation / 10)
    local coopVisual = ""
    for i = 1, 10 do
        if i <= coopBars then
            coopVisual = coopVisual .. "<vp>#</vp>"
        else
            coopVisual = coopVisual .. "<n>-</n>"
        end
    end
    text = text .. string.format("<n>Cooperacao: %s <v>%.1f%%</v>\n", coopVisual, roomCooperation)
    text = text .. "<font size='11'>"

    local players = {}
    for name in pairs(tfm.get.room.playerList) do
        local pub = bagPublic[name] or 0
        local pri = bagPrivate[name] or 0
        local score = calculatePlayerScore(name)
        table.insert(players, {
            name = name,
            public = pub,
            private = pri,
            score = score
        })
    end

    table.sort(players, function(a, b) return a.score > b.score end)

    for i, player in ipairs(players) do
        local medal = ""
        if i == 1 then medal = "<j>* </j>"
        elseif i == 2 then medal = "<vp>+ </vp>"
        elseif i == 3 then medal = "<o>- </o>"
        else medal = "<n>" .. i .. ". </n>"
        end

        -- Indicador de tendência comportamental
        local tendency = ""
        local total = player.public + player.private
        if total > 0 then
            local ratio = player.public / total
            if ratio > 0.7 then tendency = "<vp>*</vp>"
            elseif ratio < 0.3 then tendency = "<o>+</o>"
            else tendency = "<j>-</j>"
            end
        end

        text = text .. string.format("%s%s %s: <vp>%d Pub</vp> | <o>%d Pri</o> | <j>%d pts</j>\n",
                                        medal, tendency, player.name, player.public, player.private, player.score)
    end

    ui.addTextArea(0, text, name, 10, 30, 780, nil, 0x1A1A1A, 0x1A1A1A, 0.7, true)
end

-- 👤 Novos jogadores
function eventNewPlayer(name)
    bagPublic[name] = 0
    bagPrivate[name] = 0
    playerStats[name] = {
        cooperationRatio = 0,
        totalActions = 0,
        reactionTimes = {},
        spatialPreferences = {}
    }
    system.bindKeyboard(name, 81, true, true) -- Q para coletar
    system.bindKeyboard(name, 72, true, true) -- H para ajuda
    system.bindKeyboard(name, 27, true, true) -- ESC para fechar
    updateUI()
end

-- ▶️ Início do mapa (garante XML disponível)
function eventNewGame()
    -- Analisa o XML no início de cada mapa novo
    analyzeMapXML()
end

-- ▶️ Start
init()