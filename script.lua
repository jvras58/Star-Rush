--[[
*** STAR - RACE ***
Experimento de Cooperacao
]]

-- Configuracoes basicas
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAfkDeath(true)

local mapas = {"@5451839", "@5445849", "@6599901", "@6682692", "@6399897"}
local starList = {}
local starID = 0
local radius = 35^2
local bagPublic = {}
local bagPrivate = {}
local pot = 0
local scarcity = 1.0
local eventName = ""
local roundNumber = 0
local maxRounds = 6
local isGameOver = false
local isMapReady = false
local events = {"Seca", "Aurora", "Fiscalizacao", "VazamentoPrivado", "Doacao"}

-- 📊 Dados
local gameData = {}
local playerStats = {}
local roomCooperation = 0

-- 🗺️ Mapa
local mapGrounds = {}
local mapDecorations = {}
local validSpawnAreas = {}

function analyzeMapXML()
    mapGrounds, mapDecorations, validSpawnAreas = {}, {}, {}
    if not tfm.get.room.xmlMapInfo or not tfm.get.room.xmlMapInfo.xml then return false end
    local xml = tfm.get.room.xmlMapInfo.xml
    local mapWidth, mapHeight = tfm.get.room.xmlMapInfo.width or 800, tfm.get.room.xmlMapInfo.height or 400
    xml:gsub('<S(.-)/>', function(a)
        local g={x=tonumber(a:match('X="([^"]*)"'))or 0,y=tonumber(a:match('Y="([^"]*)"'))or 0,w=tonumber(a:match('L="([^"]*)"'))or 10,h=tonumber(a:match('H="([^"]*)"'))or 10,t=tonumber(a:match('T="([^"]*)"'))or 0}
        if g.t~=1 and g.t~=2 then table.insert(mapGrounds,{x=g.x,y=g.y,width=g.w,height=g.h}) end
    end)
    xml:gsub('<D(.-)/>', function(a) table.insert(mapDecorations,{x=tonumber(a:match('X="([^"]*)"'))or 0,y=tonumber(a:match('Y="([^"]*)"'))or 0}) end)
    generateValidSpawnAreas(mapWidth, mapHeight)
    return true
end

function generateValidSpawnAreas(mapWidth, mapHeight)
    validSpawnAreas = {}
    local gridSize = 40
    for x = 50, mapWidth - 50, gridSize do
        for y = 50, mapHeight - 50, gridSize do if isValidSpawnPosition(x, y) then table.insert(validSpawnAreas, {x=x,y=y}) end end
    end
    if #validSpawnAreas == 0 then
        for i=1,8 do table.insert(validSpawnAreas,{x=math.random(80,mapWidth-80),y=math.random(80,mapHeight-80)}) end
    end
end

function isValidSpawnPosition(x, y)
    local isOnPlatform = false
    for _, g in pairs(mapGrounds) do
        if x>g.x-g.width/2 and x<g.x+g.width/2 and y>g.y-g.height/2-40 and y<g.y-g.height/2+10 then isOnPlatform=true; break end
    end
    if not isOnPlatform then return false end
    for _, d in pairs(mapDecorations) do if math.abs(x-d.x)<25 and math.abs(y-d.y)<25 then return false end end
    return true
end

function isDistantFromOtherStars(x, y)
    for _, star in pairs(starList) do local dx,dy=x-star.x,y-star.y; if dx*dx+dy*dy<40^2 then return false end end
    return true
end

function findNearestOppositeType(targetX, targetY, targetType)
    local nearestIndex, minDistance = nil, 80^2
    for i, star in ipairs(starList) do
        if star.public~=targetType then
            local dx,dy=targetX-star.x,targetY-star.y; local dist=dx*dx+dy*dy
            if dist<minDistance then minDistance,nearestIndex=dist,i end
        end
    end
    return nearestIndex
end

function getMaxStarsPerRound() return math.min(4 + (roundNumber - 1) * 2, 12) end

function init()
    for name in pairs(tfm.get.room.playerList) do eventNewPlayer(name) end
    pot, roundNumber, isGameOver = 0, 0, false
    newRound()
end

function showTutorial()
    if roundNumber<=2 then
        local text="<p align='center'><font size='14'><b>=== TUTORIAL ===</b></font>\n\n<font size='12'>"
        if roundNumber==1 then text=text .. "<j>★ VERDES:</j> para o pote\n<o>★ AMARELAS:</o> para você\n\n<v>Pressione Q!</v>"
        else text=text .. "<j>★ POTE ★:</j> 20 estrelas = bônus!\n<r>! DILEMA:</r> Cooperar ou competir?\n" end
        text=text .. "\n\n<font size='10'><r>+ ESC para fechar +</r></font></font></p>"
        ui.addTextArea(999, text, nil, 100, 100, 600, 220, 0x1A1A1A, 0x7F7F7F, 0.9, true)
    end
end

function newRound()
    if isGameOver then return end
    for i=1,starID do tfm.exec.removePhysicObject(10000+i); ui.removeTextArea(20000+i,nil) end
    starList, starID, isMapReady = {}, 0, false
    roundNumber = roundNumber + 1
    ui.removeTextArea(999, nil)
    tfm.exec.newGame(mapas[math.random(#mapas)])
    eventName = events[math.random(#events)]
    applyEvent(eventName)
    tfm.exec.setGameTime(30)
end

function eventLoop(current, remaining)
    if isGameOver then return end
    if remaining <= 0 then
        if roundNumber >= maxRounds then
            endGame()
        else
            newRound()
        end
    end
end

function endGame()
    if isGameOver then return end
    isGameOver = true
    for _, star in pairs(starList) do tfm.exec.removePhysicObject(10000+star.id); ui.removeTextArea(20000+star.id,nil) end
    starList = {}
    local scores={}
    for n in pairs(tfm.get.room.playerList) do scores[n]=calculatePlayerScore(n) end
    local winner,maxScore,coop,maxCoop,ind,minCoop="*Ninguém*",-1,"",-1,"",2
    for name,score in pairs(scores) do
        if score > maxScore then maxScore,winner=score,name end
        local pub,pri=bagPublic[name]or 0,bagPrivate[name]or 0; local total=pub+pri
        if total>0 then local ratio=pub/total; if ratio>maxCoop then maxCoop,coop=ratio,name end; if ratio<minCoop then minCoop,ind=ratio,name end end
    end
    announceWinner(winner,maxScore,coop,ind,scores)
    tfm.exec.setGameTime(20)
end

function createStar(x,y,isPublic)
    local sym,col="★",isPublic and 0x55FF55 or 0xFFDD00; starID=starID+1
    tfm.exec.addPhysicObject(10000+starID,x,y,{type=12,width=35,height=35,foreground=true,friction=0.3,restitution=0.2,angle=0,color=0x000000,alpha=0.01})
    ui.addTextArea(20000+starID,"<p align='center'><font size='20' color='#"..string.format("%06X",col).."'><b>"..sym.."</b></font></p>",nil,x-17,y-17,35,35,0,0,0,false)
    table.insert(starList,{id=starID,x=x,y=y,public=isPublic})
end

function spawnAllStarsForRound()
    if not isMapReady or isGameOver or #starList>0 then return end
    local mapW,mapH=tfm.get.room.xmlMapInfo.width or 800,tfm.get.room.xmlMapInfo.height or 400
    local target=#validSpawnAreas>0 and getMaxStarsPerRound() or 6
    if #validSpawnAreas>0 then
        local shuffled={}; for _,a in ipairs(validSpawnAreas) do table.insert(shuffled,a) end
        for i=#shuffled,2,-1 do local j=math.random(i); shuffled[i],shuffled[j]=shuffled[j],shuffled[i] end
        local idx=1
        while #starList<target and idx<=#shuffled do
            local area=shuffled[idx]; local x,y=area.x+math.random(-20,20),area.y+math.random(-20,20)
            if isDistantFromOtherStars(x,y) then createStar(x,y,math.random()<0.6) end
            idx=idx+1
        end
    end
end

function eventKeyboard(name, key, down)
    if key == 81 then local p=tfm.get.room.playerList[name]; if p then tryPickStar(name,p.x,p.y) end
    elseif key == 72 and down then showHelp(name)
    elseif key == 27 and down then ui.removeTextArea(999,name); ui.removeTextArea(995,name) end
end

function showHelp(name)
    local text = "<p align='center'><font size='12'><b>[== AJUDA ==]</b></font>\n\n<font size='10'>"
    text=text .. "<j>★ VERDES:</j> 2pts (pote)\n<o>★ AMARELAS:</o> 1pt (você)\n\n"
    text=text .. "<b>OBJETIVO:</b> Maior pontuação\n<b>POTE:</b> 20 estrelas = bônus geral!\n\n"
    text=text .. "<b>CONTROLES:</b> [Q] Coletar | [H] Ajuda\n\n"
    text=text .. "<v>Rodada: "..roundNumber.."/"..maxRounds.."</v></font></p>"
    ui.addTextArea(995, text, name, 100, 80, 600, 240, 0x1A1A1A, 0x7F7F7F, 0.9, true)
end

function applyEvent(name)
    local pCount=0; for _ in pairs(tfm.get.room.playerList) do pCount=pCount+1 end
    if name=="Aurora" then scarcity=math.max(0.5,scarcity-0.1)
    elseif name=="Seca" then scarcity=scarcity+(0.2*math.min(pCount/4,1))
    elseif name=="Fiscalizacao" then for p in pairs(tfm.get.room.playerList) do bagPrivate[p]=math.floor(bagPrivate[p]*0.5) end
    elseif name=="VazamentoPrivado" then for p in pairs(tfm.get.room.playerList) do pot=pot+(bagPrivate[p]*0.25) end
    elseif name=="Doacao" then pot=pot+(2*math.max(1,pCount/2)) end
end

function tryPickStar(name, x, y)
    if not x or not y or isGameOver then return end
    local pickedIdx, oppositeIdx = nil, nil
    for i=#starList,1,-1 do
        local c=starList[i]
        if c then local dx,dy=x-c.x,y-c.y; if dx*dx+dy*dy<=radius then pickedIdx=i; break end end
    end
    if pickedIdx then
        local pickedStar = starList[pickedIdx]
        oppositeIdx = findNearestOppositeType(pickedStar.x,pickedStar.y,pickedStar.public)
        logPlayerAction(name,"collect_star",{star_type=pickedStar.public and "public" or "private"})
        if playerStats[name] then playerStats[name].totalActions=playerStats[name].totalActions+1 end
        if pickedStar.public then bagPublic[name]=bagPublic[name]+1; pot=pot+1*scarcity else bagPrivate[name]=bagPrivate[name]+1 end
        tfm.exec.removePhysicObject(10000+pickedStar.id); ui.removeTextArea(20000+pickedStar.id,nil)
        if oppositeIdx and starList[oppositeIdx] then
            local oppositeStar = starList[oppositeIdx]
            tfm.exec.removePhysicObject(10000+oppositeStar.id); ui.removeTextArea(20000+oppositeStar.id,nil)
        end
        if oppositeIdx then
            if pickedIdx>oppositeIdx then table.remove(starList,pickedIdx); table.remove(starList,oppositeIdx)
            else table.remove(starList,oppositeIdx); table.remove(starList,pickedIdx) end
        else table.remove(starList,pickedIdx) end
        calculateRoomCooperation(); updateUI()
        if pot>=20 then endGame() end
    end
end

function calculatePlayerScore(name)
    local pub,priv,bonus = bagPublic[name]or 0,bagPrivate[name]or 0,0
    if pot>=20 then local c=0; for _ in pairs(tfm.get.room.playerList) do c=c+1 end; if c>0 then bonus=math.floor((pot*1.5)/c) end end
    return(pub*2)+priv+bonus
end

function calculateRoomCooperation()
    local totPub,totPriv = 0,0
    for n in pairs(tfm.get.room.playerList) do totPub=totPub+(bagPublic[n]or 0); totPriv=totPriv+(bagPrivate[n]or 0) end
    roomCooperation = (totPub+totPriv)>0 and (totPub/(totPub+totPriv)*100) or 0
end

function logPlayerAction(player, action, data)
    if not gameData[player] then gameData[player]={} end
    table.insert(gameData[player],{p=player,r=roundNumber,a=action,st=data.star_type,pos=data.position,ps=pot,e=eventName,t=os.time()})
end

function announceWinner(winner, score, cooperative, individualistic, playerScores)
    local text="<p align='center'><font size='18'><b>*** FIM DE JOGO! ***</b></font>\n\n"
    if pot>=20 then text=text .. "<font size='14'><vp>META COOPERATIVA ATINGIDA!</vp></font>\n" end
    text=text .. "<font size='14'><b>* VENCEDOR: <j>"..tostring(winner).."</j> com <j>"..tostring(score).."</j> pts! *</b>\n\n"
    text=text .. "<font size='12'><b>* Mais Cooperativo:</b> <vp>"..tostring(cooperative).."</vp>\n"
    text=text .. "<b>+ Mais Individualista:</b> <o>"..tostring(individualistic).."</o>\n\n"
    
    text=text .. "<b>=== RANKING FINAL ===</b>\n"
    text=text .. "<font face='Consolas,Monospace'><n>#  | NOME          | PONTOS | ESTRELAS (V/A) | COOP.%</n>\n"

    local sortedPlayers, i = {}, 1
    for n in pairs(tfm.get.room.playerList) do table.insert(sortedPlayers,{name=n, score=playerScores[n] or 0}) end
    table.sort(sortedPlayers, function(a,b) return a.score > b.score end)

    for i, pData in ipairs(sortedPlayers) do
        local pub = bagPublic[pData.name] or 0
        local pri = bagPrivate[pData.name] or 0
        local total = pub + pri
        local coop = 0
        if total > 0 then coop = (pub / total) * 100 end
        
        local rankColor = (i==1 and "<j>") or (i==2 and "<vp>") or (i==3 and "<o>") or "<n>"
        
        local rankStr = tostring(i)
        local nameStr = string.sub(pData.name, 1, 12)
        local scoreStr = tostring(pData.score)
        local starsStr = string.format("<vp>%d</vp>/<o>%d</o>", pub, pri)
        local coopStr = string.format("%.1f%%", coop)

        local rankLine = string.format("%s%-3s| %-13s | %-6s | %-14s | %s</n>",
            rankColor,
            rankStr,
            nameStr,
            scoreStr,
            starsStr,
            coopStr
        )
        text = text .. rankLine .. "\n"
    end
    
    text=text.."</font>\n\n<v>= Coop. Geral: "..string.format("%.1f%%", roomCooperation).." =</v></font></p>"
    ui.addTextArea(996, text, nil, 50, 40, 700, 380, 0x1A1A1A, 0x7F7F7F, 0.95, true)
end

function updateUI()
    if isGameOver then return end
    local players={}; for n in pairs(tfm.get.room.playerList) do table.insert(players,{name=n,score=calculatePlayerScore(n)}) end
    table.sort(players,function(a,b) return a.score>b.score end)
    local ranks={}; for i,p in ipairs(players) do ranks[p.name]=i end
    local potVal=math.floor(pot)
    for n in pairs(tfm.get.room.playerList) do
        local rank,pub,pri,score=ranks[n]or 0,bagPublic[n]or 0,bagPrivate[n]or 0,calculatePlayerScore(n)
        local uiText = string.format("<p align='center'><font face='Verdana' size='11'>" ..
            "<n>Rodada:</n> <j>%d/%d</j> | <n>Pote:</n> <j>%d/20</j> | <n>Evento:</n> <j>%s</j> | <n>Rank:</n> <j>%dº</j> | <n>★:</n> <vp>%d</vp>/<o>%d</o> | <n>Pontos:</n> <j>%d</j>" ..
            "</font></p>",
            roundNumber, maxRounds, potVal, eventName, rank, pub, pri, score)
        ui.addTextArea(0, uiText, n, 0, 380, 800, 20, 0x1A1A1A, 0x1A1A1A, 0.8, true)
    end
end

function eventNewPlayer(name)
    bagPublic[name],bagPrivate[name]=0,0
    playerStats[name]={cooperationRatio=0,totalActions=0,reactionTimes={},spatialPreferences={}}
    system.bindKeyboard(name,81,true,true); system.bindKeyboard(name,72,true,true); system.bindKeyboard(name,27,true,true)
    updateUI()
end

function eventNewGame()
    if analyzeMapXML() then isMapReady=true; showTutorial(); spawnAllStarsForRound(); updateUI() end
end

init()