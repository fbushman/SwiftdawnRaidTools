local insert = table.insert

local SwiftdawnRaidTools = SwiftdawnRaidTools

local timers = {}

local function cancelTimers()
    for i, timer in ipairs(timers) do
        timer:Cancel()
        timers[i] = nil
    end
end

function SwiftdawnRaidTools:InternalTestStart()
    self.TEST = true

    self:OverviewUpdateSpells()

    self:ENCOUNTER_START(nil, 1035)

    -- C_Timer.After(3, function()
    --     SwiftdawnRaidTools:CHAT_MSG_RAID_BOSS_EMOTE(nil, "test 123 432")
    -- end)

    -- C_Timer.After(5, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Dableach", nil, nil, 51052)
    -- end)

    -- C_Timer.After(5, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Anticipâte", nil, nil, 31821)
    -- end)

    -- C_Timer.After(3, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Boss", nil, nil, 93059)
    -- end)

    -- C_Timer.After(10, function()
    --     SwiftdawnRaidTools:CHAT_MSG_RAID_BOSS_EMOTE(nil, "test 123 432")
    -- end)

    -- C_Timer.After(22, function()
    --     self:SpellsResetCache()
    --     self:OverviewUpdateSpells()
    --     self:RaidAssignmentsUpdateGroups()
    -- end)

    -- C_Timer.After(30, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Boss", nil, nil, 93059)
    -- end)

    -- C_Timer.After(32, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Elí", nil, nil, 31821)
    -- end)

    -- C_Timer.After(40, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Boss", nil, nil, 93059)
    -- end)
end

function SwiftdawnRaidTools:InternalTestEnd()
    self.TEST = false

    self:ENCOUNTER_END(nil, 1035)
end

function SwiftdawnRaidTools:TestModeToggle()
    local testMode = not self.TEST

    self:TestModeSet(testMode)
end

function SwiftdawnRaidTools:TestModeSet(testMode)
    self.TEST = testMode

    cancelTimers()

    self:GroupsReset()
    self:SpellsResetCache()
    self:UnitsResetDeadCache()
    self:OverviewUpdate()

    if self.TEST then
        self:OverviewSelectEncounter(1027)
        self:RaidAssignmentsStartEncounter(1027)

        insert(timers, C_Timer.NewTimer(2, function()
            SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Boss", nil, nil, 79023)
        end))

        insert(timers, C_Timer.NewTimer(4, function()
            SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Ant", nil, nil, 31821)
        end))

        insert(timers, C_Timer.NewTimer(15, function()
            SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Boss", nil, nil, 79023)
        end))

        insert(timers, C_Timer.NewTimer(17, function()
            SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Kendoc", nil, nil, 62618)
        end))

        insert(timers, C_Timer.NewTimer(17, function()
            SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Mirven", nil, nil, 98008)
        end))

        insert(timers, C_Timer.NewTimer(25, function()
            SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Boss", nil, nil, 79023)
        end))

        insert(timers, C_Timer.NewTimer(28, function()
            SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Ile", nil, nil, 31821)
        end))

        insert(timers, C_Timer.NewTimer(33, function()
            SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Boss", nil, nil, 91849)
        end))

        insert(timers, C_Timer.NewTimer(35, function()
            SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Claytox", nil, nil, 77764)
        end))

        insert(timers, C_Timer.NewTimer(46, function()
            SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Boss", nil, nil, 91849)
        end))

        insert(timers, C_Timer.NewTimer(47, function()
            SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Yesmon", nil, nil, 77764)
        end))
    else
        self:ENCOUNTER_END(nil, 1027)
    end
end

function SwiftdawnRaidTools:GetEncounters()
    if self.TEST then
        return {
            [1027] = {
                {
                    uuid = "1",
                    type = "RAID_ASSIGNMENTS",
                    version = 1,
                    encounter = 1027,
                    metadata = {
                        name = "Incineration"
                    },
                    triggers = {
                        {
                            type = "SPELL_CAST",
                            spell_id = 79023
                        }
                    },
                    assignments = {
                        {
                            {
                                type = "SPELL",
                                player = "Ant",
                                spell_id = 31821
                            },
                            {
                                type = "SPELL",
                                player = "Eoline",
                                spell_id = 740
                            }
                        },
                        {
                            {
                                type = "SPELL",
                                player = "Mirven",
                                spell_id = 98008
                            },
                            {
                                type = "SPELL",
                                player = "Kendoc",
                                spell_id = 62618
                            }
                        },
                        {
                            {
                                type = "SPELL",
                                player = "Ile",
                                spell_id = 31821
                            }
                        }
                    }
                },
                {
                    uuid = "2",
                    type = "RAID_ASSIGNMENTS",
                    version = 1,
                    encounter = 1027,
                    metadata = {
                        name = "Grip of Death"
                    },
                    triggers = {
                        {
                            type = "SPELL_CAST",
                            spell_id = 91849
                        }
                    },
                    assignments = {
                        {
                            {
                                type = "SPELL",
                                player = "Claytox",
                                spell_id = 77764
                            }
                        },
                        {
                            {
                                type = "SPELL",
                                player = "Yesmon",
                                spell_id = 77764
                            }
                        }
                    }
                }
            }
        }
    else
        return self.db.profile.data.encounters
    end
end