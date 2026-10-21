-- ============================================================
--  Torn Rainmeter HUD — v1.0 Beta
--  Author : Sorbita_Mango
--  License: Free to use and modify. Credit appreciated.
-- ============================================================
local json = nil
local webParserMeasure = nil
local webParserFaction = nil
local lastJson = ""
local lastFacJson = ""
local fetchTime = 0
local dataReady = false
local api = {}
local maxHospitalTime = 0
local maxJailTime = 0
local lastState = ""

function Initialize()
    local luaDir = SKIN:GetVariable('@') .. 'Lua\\'
    json = dofile(luaDir .. 'json.lua')
    webParserMeasure = SKIN:GetMeasure('MeasureTornAPI_Child')
    webParserFaction = SKIN:GetMeasure('MeasureFactionAPI_Child')
    Bang('StatusRightText', 'LUA STARTED')
end

function FormatTimeDHMS(seconds)
    if seconds <= 0 then return "00:00" end
    local d = math.floor(seconds / 86400)
    local rem = seconds % 86400
    local h = math.floor(rem / 3600)
    local m = math.floor((rem % 3600) / 60)
    local s = rem % 60
    if d > 0 then
        return string.format("%dd %02dh %02dm", d, h, m)
    elseif h > 0 then
        return string.format("%02d:%02d:%02d", h, m, s)
    else
        return string.format("%02d:%02d", m, s)
    end
end

function FormatTimeHHMMSS(seconds)
    if seconds <= 0 then return "00:00:00" end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then
        return string.format("%02d:%02d:%02d", h, m, s)
    else
        return string.format("%02d:%02d", m, s)
    end
end

function FormatTimeHM(seconds)
    if seconds <= 0 then return "0m" end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    if h > 0 then return h .. "h " .. m .. "m" else return m .. "m" end
end

function FormatTimeMMSS(seconds)
    if seconds <= 0 then return "00:00" end
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%02d:%02d", m, s)
end

function Pct(cur, max)
    if max == nil or max == 0 then return 0 end
    return math.min(100, math.floor(((cur or 0) / max) * 100))
end

function FormatNumber(amount)
    local formatted = tostring(amount)
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then break end
    end
    return formatted
end

function Bang(var, val)
    SKIN:Bang('!SetVariable', var, tostring(val))
end

local function WriteCache(filename, content)
    local cachePath = SKIN:GetVariable('@') .. 'Cache\\' .. filename
    local file = io.open(cachePath, 'w')
    if file then
        file:write(content)
        file:close()
    end
end

function Update()
    if webParserMeasure == nil then return 0 end
    -- print('Lua Update called')
    local rawJson = webParserMeasure:GetStringValue()
    if rawJson ~= nil and rawJson ~= '' and rawJson ~= lastJson then
        lastJson = rawJson
        print('Torn JSON fetched! Length: ' .. #rawJson)
        ParseData(rawJson)
    end

    if webParserFaction ~= nil then
        local rawFac = webParserFaction:GetStringValue()
        if rawFac ~= nil and rawFac ~= '' and rawFac ~= lastFacJson then
            lastFacJson = rawFac
            print('Faction JSON fetched! Length: ' .. #rawFac)
            ParseFactionData(rawFac)
        end
    end

    if dataReady then Tick() end
    return 0
end

function ParseFactionData(rawJson)
    local ok, data = pcall(json.decode, rawJson)
    if not ok or data == nil then
        print('JSON Decode Failed. Raw length: ' .. tostring(rawJson and #rawJson or 0))
        return
    end
    if data.error then
        Bang('StatusTitleText', "API ERROR: " .. tostring(data.error.error))
        Bang('StatusTitleTextSmall', "API ERROR: " .. tostring(data.error.error))
        Bang('StatusTitleColor', '239,68,68,255')
        Bang('StatusTitleWeight', '700')
        Bang('StatusRightText', "")
        return
    end
    api.faction_id = data.ID or 0
    api.ranked_wars = data.ranked_wars or {}
    WriteCache('faction.json', rawJson)
end

function ParseData(rawJson)
    local ok, data = pcall(json.decode, rawJson)
    if not ok or data == nil then
        print('JSON Decode Failed. Raw length: ' .. tostring(rawJson and #rawJson or 0))
        return
    end
    if data.error then
        Bang('StatusTitleText', "API ERROR: " .. tostring(data.error.error))
        Bang('StatusTitleTextSmall', "API ERROR: " .. tostring(data.error.error))
        Bang('StatusTitleColor', '239,68,68,255')
        Bang('StatusTitleWeight', '700')
        Bang('StatusRightText', "")
        return
    end
    fetchTime = os.time()
    dataReady = true
    WriteCache('user.json', rawJson)
    api.energy = data.energy or {}
    api.nerve = data.nerve or {}
    api.happy = data.happy or {}
    api.life = data.life or {}
    api.travel = data.travel or {}
    api.cooldowns = data.cooldowns or {}
    api.notifications = data.notifications or {}
    api.state = (data.status and data.status.state) or "RESTING"
    api.state_desc = (data.status and data.status.description) or ""
    api.state_until = (data.status and data.status['until']) or 0
    api.money_onhand = data.money_onhand or 0
    api.player_name = data.name or ""
    api.player_level = tonumber(data.level) or 0
end

function Tick()
    local elapsed = math.max(0, os.time() - fetchTime)
    Bang('SyncAgoText', elapsed .. "s")
    if elapsed > 30 then
        Bang('SyncIconColor', '248,113,113,220')
        Bang('SyncTooltip', 'Sync warning: ' .. elapsed .. 's since last update#CRLF#Click to force sync API')
    else
        Bang('SyncIconColor', SKIN:GetVariable('TextMuted') or '71,85,105,255')
        Bang('SyncTooltip', 'Synced ' .. elapsed .. 's ago#CRLF#Click to force sync API')
    end

    -- Player identity
    Bang('PlayerName', api.player_name)
    Bang('PlayerLevel', "Lv." .. api.player_level)

    -- Cash
    local cash = tonumber(api.money_onhand) or 0
    Bang('CashOnHand', FormatNumber(cash))

    -- Ranked War
    local rwStart = 0
    local rwEnd = 0
    local ourScore = 0
    local theirScore = 0
    
    if api.ranked_wars then
        for k, v in pairs(api.ranked_wars) do
            if type(v) == "table" and v.war then
                rwEnd = tonumber(v.war['end']) or 0
                if rwEnd == 0 then
                    rwStart = tonumber(v.war.start) or 0
                    if v.factions then
                        for fid, fval in pairs(v.factions) do
                            if tostring(fid) == tostring(api.faction_id) then
                                ourScore = tonumber(fval.score) or 0
                            else
                                theirScore = tonumber(fval.score) or 0
                            end
                        end
                    end
                    break
                end
            end
        end
    end

    if rwStart > 0 then
        local rwLeft = rwStart - os.time()
        if rwLeft > 0 and rwLeft <= 259200 then
            Bang('RwText', "[\\x2694] " .. FormatTimeDHMS(rwLeft))
            Bang('DrugLink', 'https://www.torn.com/factions.php?step=your#/tab=armory')
        elseif rwLeft <= 0 then
            Bang('RwText', "[\\x2694] " .. FormatNumber(theirScore) .. " vs " .. FormatNumber(ourScore))
            Bang('DrugLink', 'https://www.torn.com/factions.php?step=your#/tab=armory')
        else
            Bang('RwText', "")
            Bang('DrugLink', 'https://www.torn.com/item.php')
        end
    else
        Bang('RwText', "")
        Bang('DrugLink', 'https://www.torn.com/item.php')
    end

    -- Status & Travel
        local travelLeft = 0
    local travelTotal = 1
    local travelPct = 0
    local dest = "UNKNOWN"

    if api.travel and api.travel.time_left then
        travelLeft = math.max(0, tonumber(api.travel.time_left) - elapsed)
        travelTotal = (tonumber(api.travel.timestamp) or 1) - (tonumber(api.travel.departed) or 0)
        if travelTotal <= 0 then travelTotal = 1 end
        travelPct = math.min(100, math.max(0, ((travelTotal - travelLeft) / travelTotal) * 100))
        dest = api.travel.destination or "UNKNOWN"
    end

    local state = string.upper(api.state)
    local stateUntil = tonumber(api.state_until) or 0
    local stateLeft = math.max(0, stateUntil - os.time())
    local isReturning = (dest == "Torn" or dest == "Torn City") and 1 or 0

    if state ~= lastState then
        if state == "HOSPITAL" then maxHospitalTime = stateLeft end
        if state == "JAIL" then maxJailTime = stateLeft end
        lastState = state
    end
    if state == "HOSPITAL" and stateLeft > maxHospitalTime then maxHospitalTime = stateLeft end
    if state == "JAIL" and stateLeft > maxJailTime then maxJailTime = stateLeft end

    if travelLeft > 0 then
        local timeStr = FormatTimeHHMMSS(travelLeft)
        local etaStr = os.date("%H:%M", os.time() + travelLeft)
        Bang('StatusTitleText', "Traveling to " .. dest .. "  " .. timeStr .. " (ETA: " .. etaStr .. ")")
        Bang('StatusTitleTextSmall', "Traveling to " .. dest .. "  " .. timeStr)
        Bang('StatusFontSize', '9')
        Bang('StatusY', '26')
        Bang('HideTravel', '0')
        Bang('HideTravelIcon', '0')
        Bang('HideNormal', '1')
        Bang('TravelPct', travelPct)
        Bang('TravelIsReturning', isReturning)
        Bang('BarBaseColor', '209,180,74,255')
        Bang('TravelColor', '209,180,74,255')
        Bang('StatusTitleColor', '209,180,74,255')
        Bang('StatusTitleWeight', '700')
        Bang('StatusRightText', "")
    elseif state == "HOSPITAL" and stateLeft > 0 then
        local hospPct = 0
        if maxHospitalTime > 0 then hospPct = (stateLeft / maxHospitalTime) * 100 end
        Bang('StatusTitleText', "+ In hospital for " .. FormatTimeHHMMSS(stateLeft))
        Bang('StatusTitleTextSmall', "+ In hospital for " .. FormatTimeHHMMSS(stateLeft))
        Bang('StatusFontSize', '11')
        Bang('StatusY', '31')
        Bang('HideTravel', '0')
        Bang('HideTravelIcon', '1')
        Bang('HideNormal', '1')
        Bang('TravelPct', hospPct)
        Bang('TravelIsReturning', 0)
        Bang('BarBaseColor', '239,68,68,255')
        Bang('TravelColor', '239,68,68,255')
        Bang('StatusTitleColor', '239,68,68,255')
        Bang('StatusTitleWeight', '700')
        Bang('StatusRightText', "")
    elseif state == "JAIL" and stateLeft > 0 then
        local jailPct = 0
        if maxJailTime > 0 then jailPct = (stateLeft / maxJailTime) * 100 end
        Bang('StatusTitleText', "In jail for " .. FormatTimeHHMMSS(stateLeft))
        Bang('StatusTitleTextSmall', "In jail for " .. FormatTimeHHMMSS(stateLeft))
        Bang('StatusFontSize', '11')
        Bang('StatusY', '31')
        Bang('HideTravel', '0')
        Bang('HideTravelIcon', '1')
        Bang('HideNormal', '1')
        Bang('TravelPct', jailPct)
        Bang('TravelIsReturning', 0)
        Bang('BarBaseColor', '102,128,20,255')
        Bang('TravelColor', '102,128,20,255')
        Bang('StatusTitleColor', '102,128,20,255')
        Bang('StatusTitleWeight', '700')
        Bang('StatusRightText', "")
    else
        local loc = "TORN CITY"
        local stateDesc = api.state_desc or ""
        if stateDesc:match("^In (.+)$") then
            loc = stateDesc:match("^In (.+)$")
        elseif stateDesc ~= "" and stateDesc ~= "Okay" then
            loc = stateDesc
        end
        Bang('StatusTitleText', "Okay // " .. string.upper(loc))
        Bang('StatusTitleTextSmall', "Okay // " .. string.upper(loc))
        Bang('StatusFontSize', '9')
        Bang('StatusY', '26')
        if state == "OKAY" or state == "RESTING" then
            Bang('StatusRightText', "")
        else
            Bang('StatusRightText', state)
        end
        Bang('HideTravel', '1')
        Bang('HideTravelIcon', '1')
        Bang('HideNormal', '0')
        Bang('TravelPct', 0)
        Bang('StatusTitleColor', '100,116,139,255')
        Bang('StatusTitleWeight', '400')
    end

    -- Energy
    local eCur = tonumber(api.energy.current) or 0
    local eMax = tonumber(api.energy.maximum) or 0
    local eLeft = math.max(0, (tonumber(api.energy.fulltime) or 0) - elapsed)
    Bang('EnergyPct', Pct(eCur, eMax))
    Bang('EnergyValStr', FormatNumber(eCur) .. " / " .. FormatNumber(eMax) .. (eCur > eMax and " OVER" or ""))
    Bang('EnergyFullText', (eCur >= eMax or eLeft <= 0) and "" or ("Full in " .. FormatTimeHM(eLeft)))
    
    local eColor = "180,180,180,100"
    if eCur >= eMax then
        eColor = "132,204,22,255"
    elseif eCur > (eMax / 2) then
        eColor = "31,41,30,255"
    end
    Bang('EnergyStatusColor', eColor)
    Bang('EnergyTooltip', (eCur >= eMax) and (FormatNumber(eCur) .. " / " .. FormatNumber(eMax)) or (FormatNumber(eCur) .. " / " .. FormatNumber(eMax) .. "#CRLF#Full in " .. FormatTimeHM(eLeft)))

    -- Nerve (no tick countdown)
    local nCur = tonumber(api.nerve.current) or 0
    local nMax = tonumber(api.nerve.maximum) or 0
    local nLeft = math.max(0, (tonumber(api.nerve.fulltime) or 0) - elapsed)
    
    Bang('NervePct', Pct(nCur, nMax))
    Bang('NerveValStr', FormatNumber(nCur) .. " / " .. FormatNumber(nMax))
    if nCur >= nMax then
        Bang('NerveFullText', "")
    else
        Bang('NerveFullText', "Full in " .. FormatTimeHM(nLeft))
    end
    
    local nColor = "180,180,180,100"
    if nCur >= nMax then
        nColor = "234,88,12,255"
    elseif nCur > (nMax / 2) then
        nColor = "100,60,50,255"
    end
    Bang('NerveStatusColor', nColor)
    Bang('NerveTooltip', (nCur >= nMax) and (FormatNumber(nCur) .. " / " .. FormatNumber(nMax)) or (FormatNumber(nCur) .. " / " .. FormatNumber(nMax) .. "#CRLF#Full in " .. FormatTimeHM(nLeft)))

    -- Life
    local lCur = tonumber(api.life.current) or 0
    local lMax = tonumber(api.life.maximum) or 0
    local lLeft = math.max(0, (tonumber(api.life.fulltime) or 0) - elapsed)
    Bang('LifePct', Pct(lCur, lMax))
    Bang('LifeValStr', FormatNumber(lCur) .. " / " .. FormatNumber(lMax))
    Bang('LifeTick', (lCur >= lMax or lLeft <= 0) and "" or ("Full in " .. FormatTimeHM(lLeft)))

    -- Happy
    local hCur = tonumber(api.happy.current) or 0
    local hMax = tonumber(api.happy.maximum) or 0
    Bang('HappyPct', Pct(hCur, hMax))
    Bang('HappyValStr', FormatNumber(hCur) .. " / " .. FormatNumber(hMax))

    -- Notifications & Messages
    local notifs = api.notifications or {}
    local msgCount = tonumber(notifs.messages) or 0
    local eventCount = tonumber(notifs.events) or 0

    local activeGreen = '150,180,62,255'
    local inactiveColor = '180,180,180,100'

    if msgCount > 0 then
        Bang('MessagesCountText', tostring(msgCount) .. ' ')
        Bang('MessagesColor', activeGreen)
        Bang('MessagesTooltip', 'Messages: ' .. msgCount .. ' unread')
    else
        Bang('MessagesCountText', '')
        Bang('MessagesColor', inactiveColor)
        Bang('MessagesTooltip', 'Messages: None')
    end

    if eventCount > 0 then
        Bang('EventsCountText', tostring(eventCount))
        Bang('EventsCountColor', activeGreen)
        Bang('EventsCircleColor', activeGreen)
        Bang('EventsExclColor', '24,26,31,255')
        Bang('EventsTooltip', 'Events: ' .. eventCount .. ' unread')
    else
        Bang('EventsCountText', '')
        Bang('EventsCountColor', inactiveColor)
        Bang('EventsCircleColor', '100,116,139,90')
        Bang('EventsExclColor', '180,180,180,180')
        Bang('EventsTooltip', 'Events: None')
    end

    -- Cooldowns
    local dLeft = math.max(0, (tonumber(api.cooldowns.drug) or 0) - elapsed)
    Bang('DrugTime', FormatTimeHHMMSS(dLeft))
    Bang('DrugGlowAlpha', dLeft <= 0 and "255" or "0")
    Bang('DrugStatusAlpha', dLeft <= 0 and "255" or "100")
    local dColor = "180,180,180,100"
    if dLeft <= 0 then dColor = "239,68,68,255" end
    Bang('DrugStatusColor', dColor)
    Bang('DrugTooltip', dLeft <= 0 and "Drug: Ready" or ("Drug CD#CRLF#" .. FormatTimeHHMMSS(dLeft)))

    local bLeft = math.max(0, (tonumber(api.cooldowns.booster) or 0) - elapsed)
    Bang('BoostTime', FormatTimeHHMMSS(bLeft))
    Bang('BoostGlowAlpha', bLeft <= 0 and "255" or "0")
    Bang('BoostStatusAlpha', bLeft <= 0 and "255" or "100")
    local maxBoosterCD = 86400
    if bLeft > 86400 then maxBoosterCD = 172800 end
    local bColor = "180,180,180,100"
    if bLeft <= 0 then
        bColor = "234,88,12,255"
    elseif bLeft < (maxBoosterCD / 2) then
        bColor = "100,60,50,255"
    end
    Bang('BoostStatusColor', bColor)
    Bang('BoostTooltip', bLeft <= 0 and "Booster: Ready" or ("Booster CD#CRLF#" .. FormatTimeHHMMSS(bLeft)))

    local mLeft = math.max(0, (tonumber(api.cooldowns.medical) or 0) - elapsed)
    Bang('MedTime', FormatTimeHHMMSS(mLeft))
    Bang('MedGlowAlpha', mLeft <= 0 and "255" or "0")
    Bang('MedStatusAlpha', mLeft <= 0 and "255" or "100")
    local maxMedCD = 21600
    local mColor = "180,180,180,100"
    if mLeft <= 0 then
        mColor = "56,189,248,255"
    elseif mLeft < (maxMedCD / 2) then
        mColor = "35,100,145,255"
    end
    Bang('MedStatusColor', mColor)
    Bang('MedTooltip', mLeft <= 0 and "Medical: Ready" or ("Medical CD#CRLF#" .. FormatTimeHHMMSS(mLeft)))
end
