local insert = table.insert
local stringFind = string.find
local tableSort = table.sort

local SwiftdawnRaidTools = SwiftdawnRaidTools

local activeEncounter = nil

-- key: unitId, value = triggers
local unitHealthTriggersCache = {}

-- key: unitId, value = triggers
local unitHealthUntriggersCache = {}

-- key: spellId, value = triggers
local spellCastTriggersCache = {}

-- key: spellId, value = triggers
local spellCastUntriggersCache = {}

-- key: spellId, value = triggers
local spellAuraTriggersCache = {}

-- key: spellId, value = triggers
local spellAuraUntriggersCache = {}

-- key: text, value = triggers
local raidBossEmoteTriggersCache = {}

-- key: text, value = triggers
local raidBossEmoteUntriggersCache = {}

-- key: fojji key, value = triggers
local fojjiNumenTimersTriggersCache = {}

-- key: fojji key, value = C_Timer.NewTimer
local fojjiNumenTimers = {}

-- key: part uuid, value = [C_Timer.NewTimer]
local delayTimers = {}

local function resetState()
    activeEncounter = nil
    unitHealthTriggersCache = {}
    unitHealthUntriggersCache = {}
    spellCastTriggersCache = {}
    spellCastUntriggersCache = {}
    spellAuraTriggersCache = {}
    spellAuraUntriggersCache = {}
    raidBossEmoteTriggersCache = {}
    raidBossEmoteUntriggersCache = {}
    fojjiNumenTimersTriggersCache = {}

    for key, timer in pairs(fojjiNumenTimers) do
        timer:Cancel()
        fojjiNumenTimers[key] = nil
    end

    for uuid, timers in pairs(delayTimers) do
        for _, timer in ipairs(timers) do
            timer:Cancel()
        end

        delayTimers[uuid] = nil
    end
end

function SwiftdawnRaidTools:RaidAssignmentsStartEncounter(encounterId)
    resetState()

    if not self.TEST and not self:IsPlayerRaidLeader() then
        return
    end

    activeEncounter = self:GetEncounters()[encounterId]

    if activeEncounter then
        if self.DEBUG then self:Print("Encounter starting") end

        self:RaidAssignmentsUpdateGroups()

        -- Populate caches
        for _, part in ipairs(activeEncounter) do
            if part.type == "RAID_ASSIGNMENTS" then
                local triggerClones = self:DeepClone(part.triggers)

                for _, trigger in ipairs(triggerClones) do
                    trigger.triggered = false
                    trigger.uuid = part.uuid

                    if trigger.type == "ENCOUNTER_START" then
                        self:RaidAssignmentsTrigger(trigger)
                    elseif trigger.type == "UNIT_HEALTH" then
                        if not unitHealthTriggersCache[trigger.unit] then
                            unitHealthTriggersCache[trigger.unit] = {}
                        end

                        insert(unitHealthTriggersCache[trigger.unit], trigger)
                    elseif trigger.type == "SPELL_CAST" then
                        if not spellCastTriggersCache[trigger.spell_id] then
                            spellCastTriggersCache[trigger.spell_id] = {}
                        end

                        insert(spellCastTriggersCache[trigger.spell_id], trigger)
                    elseif trigger.type == "SPELL_AURA" then
                        if not spellAuraTriggersCache[trigger.spell_id] then
                            spellAuraTriggersCache[trigger.spell_id] = {}
                        end

                        insert(spellAuraTriggersCache[trigger.spell_id], trigger)
                    elseif trigger.type == "RAID_BOSS_EMOTE" then
                        if not raidBossEmoteTriggersCache[trigger.text] then
                            raidBossEmoteTriggersCache[trigger.text] = {}
                        end

                        insert(raidBossEmoteTriggersCache[trigger.text], trigger)
                    elseif trigger.type == "FOJJI_NUMEN_TIMER" then
                        if not fojjiNumenTimersTriggersCache[trigger.key] then
                            fojjiNumenTimersTriggersCache[trigger.key] = {}
                        end

                        insert(fojjiNumenTimersTriggersCache[trigger.key], trigger)
                    end
                end

                if part.untriggers then
                    local untriggerClones = self:DeepClone(part.untriggers)

                    for _, untrigger in ipairs(untriggerClones) do
                        untrigger.triggered = false
                        untrigger.uuid = part.uuid

                        if untrigger.type == "UNIT_HEALTH" then
                            if not unitHealthUntriggersCache[untrigger.unit] then
                                unitHealthUntriggersCache[untrigger.unit] = {}
                            end

                            insert(unitHealthUntriggersCache[untrigger.unit], untrigger)
                        elseif untrigger.type == "SPELL_CAST" then
                            if not spellCastUntriggersCache[untrigger.spell_id] then
                                spellCastUntriggersCache[untrigger.spell_id] = {}
                            end

                            insert(spellCastUntriggersCache[untrigger.spell_id], untrigger)
                        elseif untrigger.type == "SPELL_AURA" then
                            if not spellAuraUntriggersCache[untrigger.spell_id] then
                                spellAuraUntriggersCache[untrigger.spell_id] = {}
                            end

                            insert(spellAuraUntriggersCache[untrigger.spell_id], untrigger)
                        elseif untrigger.type == "RAID_BOSS_EMOTE" then
                            if not raidBossEmoteUntriggersCache[untrigger.text] then
                                raidBossEmoteUntriggersCache[untrigger.text] = {}
                            end

                            insert(raidBossEmoteUntriggersCache[untrigger.text], untrigger)
                        end
                    end
                end
            end
        end
    end
end

function SwiftdawnRaidTools:RaidAssignmentsEndEncounter()
    if not activeEncounter then
        return
    end

    if self.DEBUG then self:Print("Encounter ended") end

    resetState()
    self:GroupsReset()
    self:OverviewUpdateActiveGroups()
end

function SwiftdawnRaidTools:RaidAssignmentsInEncounter()
    return activeEncounter ~= nil
end

function SwiftdawnRaidTools:RaidAssignmentsIsGroupsEqual(grp1, grp2)
    if grp1 == nil and grp2 == nil then
        return true
    end

    if grp1 == nil or grp2 == nil then
        return false
    end

    if #grp1 ~= #grp2 then
        return false
    end

    local grp1Copy = self:ShallowClone(grp1)
    local grp2Copy = self:ShallowClone(grp2)

    tableSort(grp1Copy)
    tableSort(grp2Copy)

    for i = 1, #grp1Copy do
        if grp1Copy[i] ~= grp2Copy[i] then
            return false
        end
    end

    return true
end

function SwiftdawnRaidTools:RaidAssignmentsUpdateGroups()
    if not activeEncounter then
        return
    end

    if self.DEBUG then self:Print("Update groups start") end

    local groupsUpdated = false

    for _, part in ipairs(activeEncounter) do
        if part.type == "RAID_ASSIGNMENTS" then
            -- Prevent active group from being updated if any spells in the current active group is still ready
            local allActiveGroupsReady = true

            local activeGroups = self:GroupsGetActive(part.uuid)

            if not activeGroups then
                allActiveGroupsReady = false
            else
                for _, groupIndex in ipairs(activeGroups) do
                    local group = part.assignments[groupIndex]

                    for _, assignment in ipairs(group) do
                        if not self:SpellsIsSpellReady(assignment.player, assignment.spell_id) then
                            allActiveGroupsReady = false
                        end
                    end
                end
            end

            if not allActiveGroupsReady then
                local selectedGroups = self:RaidAssignmentsSelectGroup(part.assignments)

                if not self:RaidAssignmentsIsGroupsEqual(activeGroups, selectedGroups) then
                    if self.DEBUG then self:Print("Updated groups for", part.uuid) end

                    groupsUpdated = true
                    self:GroupsSetActive(part.uuid, selectedGroups)
                end
            end
        end
    end

    if self.DEBUG then self:Print("Update groups done. Changed:", groupsUpdated) end

    if groupsUpdated then
        self:SendRaidMessage("ACT_GRPS", self:GroupsGetAllActive())
    end
end

function SwiftdawnRaidTools:RaidAssignmentsSelectBestMatchIndex(assignments)
    local bestMatchIndex = nil
    local maxReadySpells = 0

    -- First pass: check for a group where all assignments are ready
    for i, group in ipairs(assignments) do
        local ready = true
        for _, assignment in ipairs(group) do
            if not self:SpellsIsSpellActive(assignment.player, assignment.spell_id) and not self:SpellsIsSpellReady(assignment.player, assignment.spell_id) then
                ready = false
                break
            end
        end
        
        if ready then
            return i
        end
    end
    
    -- Second pass: Find the group with the most ready assignments
    for i, group in pairs(assignments) do
        local readySpells = 0
        
        for _, assignment in ipairs(group) do
            if self:SpellsIsSpellActive(assignment.player, assignment.spell_id) or self:SpellsIsSpellReady(assignment.player, assignment.spell_id) then
                readySpells = readySpells + 1
            end
        end
        
        if readySpells > maxReadySpells then
            bestMatchIndex = i
            maxReadySpells = readySpells
        end
    end

    return bestMatchIndex
end

function SwiftdawnRaidTools:RaidAssignmentsSelectGroup(assignments)
    local groups = {}

    local bestMatchIndex = self:RaidAssignmentsSelectBestMatchIndex(assignments)

    if bestMatchIndex then
        insert(groups, bestMatchIndex)
    end

    return groups
end

function SwiftdawnRaidTools:RaidAssignmentsTrigger(trigger, countdown)
    if self.DEBUG then self:Print("Sending TRIGGER start") end

    local activeGroups = self:GroupsGetActive(trigger.uuid)

    countdown = countdown or trigger.countdown or 0

    local delay = trigger.delay or 0

    if activeGroups and #activeGroups > 0 then
        local data = {
            uuid = trigger.uuid,
            countdown = countdown,
            delay = delay
        }

        if self.DEBUG then self:Print("Sending TRIGGER done") end

        if trigger.delay then
            if not delayTimers[trigger.uuid] then
                delayTimers[trigger.uuid] = {}
            end

            insert(delayTimers[trigger.uuid], C_Timer.NewTimer(trigger.delay, function()
                self:SendRaidMessage("TRIGGER", data)
            end))
        else
            self:SendRaidMessage("TRIGGER", data)
        end
    end
end

local function cancelDelayTimers(uuid)
    if delayTimers[uuid] then
        for _, timer in ipairs(delayTimers[uuid]) do
            timer:Cancel()
        end

        delayTimers[uuid] = nil
    end
end

function SwiftdawnRaidTools:RaidAssignmentsHandleUnitHealth(unit)
    if not activeEncounter then
        return
    end

    local triggers = unitHealthTriggersCache[unit]

    if triggers then
        for _, trigger in ipairs(triggers) do
            if not trigger.triggered then
                local health = UnitHealth(unit)
                local maxHealth = UnitHealthMax(unit)
                local percentage = health / maxHealth * 100

                if percentage < trigger.percentage then
                    trigger.triggered = true

                    self:RaidAssignmentsTrigger(trigger)
                end
            end
        end
    end

    local untriggers = unitHealthUntriggersCache[unit]

    if untriggers then
        for _, untrigger in ipairs(untriggers) do
            if not untrigger.triggered then
                local health = UnitHealth(unit)
                local maxHealth = UnitHealthMax(unit)
                local percentage = health / maxHealth * 100

                if percentage < untrigger.percentage then
                    untrigger.triggered = true

                    cancelDelayTimers(untrigger.uuid)
                end
            end
        end
    end
end

function SwiftdawnRaidTools:RaidAssignmentsHandleSpellCast(event, spellId)
    if not activeEncounter then
        return
    end

    local triggers = spellCastTriggersCache[spellId]

    if triggers then
        local _, _, _, castTime = GetSpellInfo(spellId)

        -- We don't want to handle a spellcast twice so we only look for start events or success events for instant cast spells
        if event == "SPELL_CAST_START" or (event == "SPELL_CAST_SUCCESS" and (not castTime or castTime == 0)) then
            for _, trigger in ipairs(triggers) do
                self:RaidAssignmentsTrigger(trigger, castTime / 1000)
            end
        end
    end

    local untriggers = spellCastUntriggersCache[spellId]

    if untriggers then
        local _, _, _, castTime = GetSpellInfo(spellId)

        if event == "SPELL_CAST_START" or (event == "SPELL_CAST_SUCCESS" and (not castTime or castTime == 0)) then
            for _, untrigger in ipairs(untriggers) do
                cancelDelayTimers(untrigger.uuid)
            end
        end
    end
end

function SwiftdawnRaidTools:RaidAssignmentsHandleSpellAura(event, spellId)
    if not activeEncounter then
        return
    end

    local triggers = spellAuraTriggersCache[spellId]

    if triggers then
        for _, trigger in ipairs(triggers) do
            self:RaidAssignmentsTrigger(trigger)
        end
    end

    local untriggers = spellAuraUntriggersCache[spellId]

    if untriggers then
        for _, untrigger in ipairs(untriggers) do
            cancelDelayTimers(untrigger.uuid)
        end
    end
end

function SwiftdawnRaidTools:RaidAssignmentsHandleRaidBossEmote(text)
    if not activeEncounter then
        return
    end

    for _, triggers in pairs(raidBossEmoteTriggersCache) do
        for _, trigger in ipairs(triggers) do
            if stringFind(text, trigger.text) ~= nil then
                self:RaidAssignmentsTrigger(trigger)
            end
        end
    end

    for _, untriggers in pairs(raidBossEmoteUntriggersCache) do
        for _, untrigger in ipairs(untriggers) do
            if stringFind(text, untrigger.text) ~= nil then
                cancelDelayTimers(untrigger.uuid)
            end
        end
    end
end

local function cancelFojjiNumenTimer(key)
    local timer = fojjiNumenTimers[key]

    if timer then
        timer:Cancel()
        fojjiNumenTimers[key] = nil
    end
end

function SwiftdawnRaidTools:RaidAssignmentsHandleFojjiNumenTimer(key, countdown)
    if not activeEncounter or not countdown then
        return
    end

    local triggers = fojjiNumenTimersTriggersCache[key]

    if triggers then
        for _, trigger in ipairs(triggers) do
            if countdown <= 5 then
                self:RaidAssignmentsTrigger(trigger, countdown)
            else
                cancelFojjiNumenTimer(key)

                fojjiNumenTimers[key] = C_Timer.NewTimer(countdown - 5, function()
                    self:RaidAssignmentsTrigger(trigger, 5)
                end)
            end
        end
    end
end
