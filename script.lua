--[[
*** SHARE-CHEESE ***
Experimento de Cooperacao
]]

-- Configuracoes basicas
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAfkDeath(true)

local mapas = {"@5451839", "@5445849", "@6599901", "@6682692", "@6399897"}
local cheeseList = {} -- {id, x, y, public}
local cheeseID = 0
local radius = 30^2
local bagPublic = {}
local bagPrivate = {}
local pot = 0
local scarcity = 1.0
local nextSpawn = 0
local eventName = ""
local roundNumber = 0
local maxRounds = 12 -- Limite de rodadas
local events = {"Seca", "Aurora", "Fiscalizacao", "VazamentoPrivado", "Doacao", "Queijofuracao"}

-- 📊 Sistema de coleta de dados
local gameData = {}
local playerStats = {}
local roomCooperation = 0

-- 🏆 Sistema de ranking
local playerScores = {}

-- 📊 Sistema de logging comportamental
function logPlayerAction(player, action, data)
    if not gameData[player] then gameData[player] = {} end
    local logEntry = {
        player = player,
        round = roundNumber,
        action = action,
        cheese_type = data.cheese_type or nil,
        position = data.position or nil,
        pot_state = pot,
        event = eventName,
        timestamp = os.time()
    }
    table.insert(gameData[player], logEntry)
end

-- 🏆 Calcula pontuação do jogador
function calculatePlayerScore(name)
    local publicCheeses = bagPublic[name] or 0
    local privateCheeses = bagPrivate[name] or 0
    local potBonus = (pot >= 20) and (#tfm.get.room.playerList * 2) or 0
    return (publicCheeses * 2) + (privateCheeses * 1) + potBonus
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

-- 🔍 Verifica se posição é válida para spawn
function isValidSpawnLocation(x, y)
    -- Verificar distância mínima das bordas
    if x < 50 or y < 50 then return false end
    if not tfm.get.room.xmlMapInfo then return true end
    
    local mapWidth = tfm.get.room.xmlMapInfo.width or 800
    local mapHeight = tfm.get.room.xmlMapInfo.height or 400
    
    if x > mapWidth - 50 or y > mapHeight - 50 then return false end
    
    -- Verificar proximidade com outros queijos
    for _, cheese in pairs(cheeseList) do
        local dx = x - cheese.x
        local dy = y - cheese.y
        if dx * dx + dy * dy < 40^2 then -- Distância mínima entre queijos
            return false
        end
    end
    
    return true
end

-- 🔍 Encontra queijo do tipo oposto mais próximo
function findNearestOppositeType(targetX, targetY, targetType)
    local nearestCheese = nil
    local minDistance = math.huge
    
    for i, cheese in pairs(cheeseList) do
        if cheese.public ~= targetType then
            local dx = targetX - cheese.x
            local dy = targetY - cheese.y
            local distance = dx * dx + dy * dy
            
            if distance < minDistance and distance <= (80^2) then -- Máximo 80 pixels
                minDistance = distance
                nearestCheese = i
            end
        end
    end
    
    return nearestCheese
end

-- 🔢 Limite variável de queijos por rodada
function getMaxCheesePerRound()
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
    
    showTutorial()
    newRound()
end

-- Sistema de tutorial
function showTutorial()
    if roundNumber <= 2 then
        local tutorialText = "<p align='center'><font size='14'><b>=== TUTORIAL - SHARE CHEESE ===</b></font>\n\n"
        tutorialText = tutorialText .. "<font size='12'>"
        if roundNumber == 1 then
            tutorialText = tutorialText .. "<j>* QUEIJOS VERDES:</j> Beneficiam todos os jogadores (vao para o pote)\n"
            tutorialText = tutorialText .. "<o>* QUEIJOS AMARELOS:</o> Apenas para voce (colecao privada)\n\n"
            tutorialText = tutorialText .. "<v>-> Pressione Q proximo a eles!</v>"
        else
            tutorialText = tutorialText .. "<j>* SISTEMA DO POTE:</j> Se atingir 20 queijos, todos ganham bonus!\n"
            tutorialText = tutorialText .. "<r>! DILEMA:</r> Cooperar ou ser individualista?\n\n"
            tutorialText = tutorialText .. "<v>-> Estrategia e fundamental!</v>"
        end
        tutorialText = tutorialText .. "\n\n<font size='10'><r>+ Pressione ESC para fechar este tutorial +</r></font>"
        tutorialText = tutorialText .. "</font></p>"
        
        ui.addTextArea(999, tutorialText, nil, 100, 100, 600, 220, 0x1A1A1A, 0x7F7F7F, 0.9, true)
        
        -- Remove tutorial após 10 segundos automaticamente (sem alterar tempo do jogo)
    end
end

-- 🔁 Nova rodada
function newRound()
    cheeseList = {}
    cheeseID = 0
    pot = 0
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
    showTutorial() -- Mostra tutorial se necessário
    tfm.exec.setGameTime(30)
    updateUI()
end

-- 🧀 Spawna queijos estratégicos em pares próximos
function spawnCheese()
    if not tfm.get.room.xmlMapInfo then return end
    local mapWidth = tfm.get.room.xmlMapInfo.width or 800
    local mapHeight = tfm.get.room.xmlMapInfo.height or 400

    local targetCheeses = getMaxCheesePerRound()
    local attempts = 0
    
    while #cheeseList < targetCheeses and attempts < 100 do
        attempts = attempts + 1
        local x = math.random(80, mapWidth - 80)
        local y = math.random(80, mapHeight - 80)
        
        if isValidSpawnLocation(x, y) then
            -- Spawna par de queijos próximos
            local isPublic = math.random() < 0.6
            local color = isPublic and 0x55FF55 or 0xFFFF55
            local particle = isPublic and 3 or 13

            cheeseID = cheeseID + 1

            tfm.exec.addPhysicObject(10000 + cheeseID, x, y, {
                type = 12, width = 20, height = 20,
                foreground = true, friction = 0.3, restitution = 0.2,
                angle = 0, color = color
            })

            tfm.exec.displayParticle(particle, x, y, 0, 0, 0, 0.01)

            table.insert(cheeseList, {
                id = cheeseID,
                x = x,
                y = y,
                public = isPublic
            })
            
            -- Tenta spawnar queijo do tipo oposto próximo
            if #cheeseList < targetCheeses then
                local pairX = x + math.random(-60, 60)
                local pairY = y + math.random(-60, 60)
                
                -- Garante que o par esteja dentro dos limites
                pairX = math.max(80, math.min(mapWidth - 80, pairX))
                pairY = math.max(80, math.min(mapHeight - 80, pairY))
                
                if isValidSpawnLocation(pairX, pairY) then
                    local pairIsPublic = not isPublic
                    local pairColor = pairIsPublic and 0x55FF55 or 0xFFFF55
                    local pairParticle = pairIsPublic and 3 or 13

                    cheeseID = cheeseID + 1

                    tfm.exec.addPhysicObject(10000 + cheeseID, pairX, pairY, {
                        type = 12, width = 20, height = 20,
                        foreground = true, friction = 0.3, restitution = 0.2,
                        angle = 0, color = pairColor
                    })

                    tfm.exec.displayParticle(pairParticle, pairX, pairY, 0, 0, 0, 0.01)

                    table.insert(cheeseList, {
                        id = cheeseID,
                        x = pairX,
                        y = pairY,
                        public = pairIsPublic
                    })
                end
            end
        end
    end
end

-- ⌨️ Entrada
function eventMouse(name, x, y)
    tryPickCheese(name, x, y)
end

function eventKeyboard(name, key, down)
    if key == 81 then -- Q key
        local p = tfm.get.room.playerList[name]
        if p then
            tryPickCheese(name, p.x, p.y)
        end
    elseif key == 72 and down then -- H key para ajuda
        showHelp(name)
    elseif key == 27 and down then -- ESC key para fechar tutorial/ajuda
        ui.removeTextArea(999, name) -- Remove tutorial
        ui.removeTextArea(995, name) -- Remove ajuda
        -- Tutorial/Ajuda fechados
    end
end

-- 📋 Sistema de ajuda
function showHelp(name)
    local helpText = "<p align='center'><font size='12'><b>[== AJUDA - SHARE CHEESE ==]</b></font>\n\n"
    helpText = helpText .. "<font size='10'>"
    helpText = helpText .. "<j>* QUEIJOS VERDES:</j> Vao para o pote comum (2 pontos)\n"
    helpText = helpText .. "<o>* QUEIJOS AMARELOS:</o> Ficam so para voce (1 ponto)\n\n"
    helpText = helpText .. "<b>* OBJETIVO:</b> Maior pontuacao individual\n"
    helpText = helpText .. "<b>! POTE:</b> Se chegar a 20, todos ganham bonus!\n"
    helpText = helpText .. "<b>+ ESTRATEGIA:</b> Coletar um queijo remove o par oposto\n\n"
    helpText = helpText .. "<b>= CONTROLES:</b>\n"
    helpText = helpText .. "• <v>Clique</v> nos queijos ou pressione <v>[Q]</v> proximo\n"
    helpText = helpText .. "• <v>[H]</v> para mostrar esta ajuda\n"
    helpText = helpText .. "• <v>[ESC]</v> para fechar tutorial/ajuda\n\n"
    helpText = helpText .. "<v>-> Meta: " .. maxRounds .. " rodadas | Atual: " .. roundNumber .. " <-</v>\n"
    helpText = helpText .. "<font size='8'><n>[========================]</n></font>"
    helpText = helpText .. "</font></p>"
    
    ui.addTextArea(995, helpText, name, 100, 80, 600, 320, 0x1A1A1A, 0x7F7F7F, 0.9, true)
    
    -- Ajuda será removida automaticamente após 15 segundos
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
    elseif name == "Queijofuracao" then
        spawnCheese()
    end
    
    local potTarget = math.max(15, 20 + (playerCount - 4) * 2)
end

-- 🧲 Sistema de coleta estratégica com remoção automática
function tryPickCheese(name, x, y)
    if not x or not y then return end
    for i = #cheeseList, 1, -1 do
        local c = cheeseList[i]
        local dx = x - c.x
        local dy = y - c.y
        if dx * dx + dy * dy <= radius then
            -- Log da ação
            logPlayerAction(name, "collect_cheese", {
                cheese_type = c.public and "public" or "private",
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
            
            -- Remove o queijo coletado
            tfm.exec.removePhysicObject(10000 + c.id)
            table.remove(cheeseList, i)
            
            -- Busca e remove queijo do tipo oposto mais próximo
            local oppositeIndex = findNearestOppositeType(c.x, c.y, c.public)
            if oppositeIndex then
                local oppositeCheese = cheeseList[oppositeIndex]
                tfm.exec.removePhysicObject(10000 + oppositeCheese.id)
                table.remove(cheeseList, oppositeIndex)
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
        pot = math.floor(pot * 1.5)
        local count = 0
        for _ in pairs(tfm.get.room.playerList) do count = count + 1 end
        local div = math.floor(pot / count)
        for name in pairs(tfm.get.room.playerList) do
            bagPublic[name] = bagPublic[name] + div
            logPlayerAction(name, "pot_bonus", {bonus = div})
        end
    else
        scarcity = math.max(0.5, scarcity - 0.1)
        pot = 0
    end
    
    -- Atualiza rankings
    updatePlayerRankings()
    
    -- Inicia nova rodada diretamente
    newRound()
end



-- ⏱️ Loop principal do jogo
function eventLoop(current, remaining)
    if current > nextSpawn then
        spawnCheese()
        nextSpawn = current + 500
    end
    
    -- Remove tutorial automaticamente após 10 segundos
    if current % 10000 == 0 then
        ui.removeTextArea(999, nil) -- Remove tutorial
    end
    
    -- Remove ajuda após 15 segundos
    if current % 15000 == 0 then
        ui.removeTextArea(995, nil)
    end
    
    if remaining <= 0 then
        if roundNumber >= maxRounds then
            endGame()
        else
            endRound()
        end
    end
    
    -- Reinicia jogo automaticamente após fim
    if remaining <= -15 and roundNumber >= maxRounds then
        roundNumber = 0 -- Reset para reiniciar
        ui.removeTextArea(996, nil) -- Remove tela final
        init()
    end
end



-- 🏆 Atualiza rankings dos jogadores
function updatePlayerRankings()
    playerScores = {}
    for name in pairs(tfm.get.room.playerList) do
        playerScores[name] = calculatePlayerScore(name)
    end
end

-- 🎯 Fim do jogo
function endGame()
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
    finalText = finalText .. "<font size='14'><b>* VENCEDOR: <j>" .. winner .. "</j> *</b>\n"
    finalText = finalText .. "<b>-> Pontuacao: <j>" .. score .. "</j> <-</b>\n\n"
    finalText = finalText .. "<font size='12'>"
    finalText = finalText .. "<b>* Mais Cooperativo:</b> <vp>" .. cooperative .. "</vp>\n"
    finalText = finalText .. "<b>+ Mais Individualista:</b> <o>" .. individualistic .. "</o>\n\n"
    
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
    
    tfm.exec.setGameTime(15)
end

-- Interface com ranking em tempo real
function updateUI()
    local text = "<p align='center'><font size='12'><b>*** Share Cheese ***</b>  "
    local qntdIndividual = math.floor(pot / math.max(1, #tfm.get.room.playerList))
    
    -- Adiciona indicador visual do evento
    local eventIcon = ""
    if eventName == "Aurora" then eventIcon = "+"
    elseif eventName == "Seca" then eventIcon = "-"
    elseif eventName == "Fiscalizacao" then eventIcon = "!"
    elseif eventName == "VazamentoPrivado" then eventIcon = "~"
    elseif eventName == "Doacao" then eventIcon = "*"
    elseif eventName == "Queijofuracao" then eventIcon = "#"
    end
    
    text = text .. string.format("<v>%s %s</v>  <n>| Rodada: <j>%d/%d</j> | Pote: <j>%d</j>/20 | Individual: <j>%d</j>\n", 
                                eventIcon, eventName, roundNumber, maxRounds, pot, qntdIndividual)
    
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

    ui.addTextArea(0, text, nil, 10, 28, 780, nil, 0x1A1A1A, 0x1A1A1A, 0.8, true)
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
    
    -- Novo jogador adicionado com sucesso
end

-- ▶️ Início
init()
