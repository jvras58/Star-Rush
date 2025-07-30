--[[
🧀 PUBLICQUEIJO

]]

-- ⚙️ Configurações básicas
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
local events = {"Seca", "Aurora", "Fiscalização", "VazamentoPrivado", "Doação", "Queijofuracão"}

-- 🔢 Limite variável de queijos por rodada
function getMaxCheesePerRound()
    return math.min(4 + (roundNumber - 1) * 2, 12)
end

-- 🟢 Inicialização
function init()
    for name in pairs(tfm.get.room.playerList) do
        system.bindKeyboard(name, 81, true, true)
        bagPublic[name] = 0
        bagPrivate[name] = 0
    end
    newRound()
end

-- 🔁 Nova rodada
function newRound()
    cheeseList = {}
    cheeseID = 0
    pot = 0
    roundNumber = roundNumber + 1

    tfm.exec.newGame(mapas[math.random(#mapas)])
    nextSpawn = 0
    eventName = events[math.random(#events)]
    applyEvent(eventName)
    tfm.exec.setGameTime(30)
    updateUI()
end

-- 🧀 Spawna queijos como objetos decorativos com partículas
function spawnCheese()
    if not tfm.get.room.xmlMapInfo then return end
    local mapWidth = tfm.get.room.xmlMapInfo.width or 800
    local mapHeight = tfm.get.room.xmlMapInfo.height or 400

    local targetCheeses = getMaxCheesePerRound()
    while #cheeseList < targetCheeses do
        local x = math.random(50, mapWidth - 50)
        local y = math.random(50, mapHeight - 50)
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
    end
end

-- 🧲 Verifica coleta
function tryPickCheese(name, x, y)
    if not x or not y then return end
    for i = #cheeseList, 1, -1 do
        local c = cheeseList[i]
        local dx = x - c.x
        local dy = y - c.y
        if dx * dx + dy * dy <= radius then
            if c.public then
                bagPublic[name] = bagPublic[name] + 1
                pot = pot + 1 * scarcity
            else
                bagPrivate[name] = bagPrivate[name] + 1
            end
            tfm.exec.removePhysicObject(10000 + c.id)
            table.remove(cheeseList, i)
            updateUI()
            break
        end
    end
end

-- ⌨️ Entrada
function eventMouse(name, x, y)
    tryPickCheese(name, x, y)
end

function eventKeyboard(name, key, down)
    if key == 81 then
        local p = tfm.get.room.playerList[name]
        if p then
            tryPickCheese(name, p.x, p.y)
        end
    end
end

-- 🎲 Evento aleatório
function applyEvent(name)
    if name == "Seca" then
        scarcity = math.max(0.5, scarcity - 0.1)
    elseif name == "Aurora" then
        scarcity = scarcity + 0.2
    elseif name == "Fiscalização" then
        for player in pairs(tfm.get.room.playerList) do
            bagPrivate[player] = math.floor(bagPrivate[player] * 0.5)
        end
    elseif name == "VazamentoPrivado" then
        for player in pairs(tfm.get.room.playerList) do
            pot = pot + bagPrivate[player] * 0.25
        end
    elseif name == "Doação" then
        for player in pairs(tfm.get.room.playerList) do
            pot = pot + 2
        end
    elseif name == "Queijofuracão" then
        -- já incluso na progressão
    end
end

-- ⏱️ Loop
function eventLoop(current, remaining)
    if current > nextSpawn then
        spawnCheese()
        nextSpawn = current + 500
    end
    if remaining <= 0 then
        endRound()
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
        end
    else
        scarcity = math.max(0.5, scarcity - 0.1)
        pot = 0
    end
    newRound()
end

-- 🧾 Interface
function updateUI()
    local text = "<p align='center'><font size='12'><b>🌎 PublicQueijo</b>  "
    text = text .. string.format("<v>%s</v>  <n>| Rodada: <j>%d</j>  | 🏺 Pote: <j>%d</j>\n", eventName, roundNumber, pot)
    text = text .. "<font size='11'>"

    for name in pairs(tfm.get.room.playerList) do
        local pub = bagPublic[name] or 0
        local pri = bagPrivate[name] or 0
        text = text .. string.format("<n>%s: <vp>%d Público   <o>%d Privado\n", name, pub, pri)
    end

    ui.addTextArea(0, text, nil, 10, 28, 780, nil, 0x1A1A1A, 0x1A1A1A, 0.8, true)
    tfm.exec.setUIMapName("<font size='11'><j>PublicQueijo</j> ~ <v>" .. eventName .. "</v>")
end

-- 👤 Novos jogadores
function eventNewPlayer(name)
    bagPublic[name] = 0
    bagPrivate[name] = 0
    system.bindKeyboard(name, 81, true, true)
    updateUI()
end

-- ▶️ Início
init()
