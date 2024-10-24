local SwiftdawnRaidTools = SwiftdawnRaidTools
local insert = table.insert

local SharedMedia = LibStub("LibSharedMedia-3.0")
local AceGUI = LibStub("AceGUI-3.0")

do
    local Type = "ImportMultiLineEditBox"
    local Version = 1

    local function Constructor()
        local widget = AceGUI:Create("MultiLineEditBox")
        widget.button:Disable()

        -- Error label
        -- TODO: Improve this.
        -- This error label is floating beneth the windows.
        -- Only works if there's nothing below the input.
        local errorLabel = widget.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        errorLabel:SetPoint("TOPLEFT", widget.frame, "BOTTOMLEFT", 0, -2)
        errorLabel:SetPoint("TOPRIGHT", widget.frame, "BOTTOMRIGHT", 0, -2)
        errorLabel:SetHeight(20)
        errorLabel:SetJustifyH("LEFT")
        errorLabel:SetJustifyV("TOP")
        errorLabel:SetTextColor(1, 0, 0) -- Red
        errorLabel:SetText("")
        widget.errorLabel = errorLabel

        function widget:Validate()
            local text = self:GetText()

            if text then
                text = text:trim()
            end
            
            if not text or text == "" then
                return true
            end

            local ok, result = SwiftdawnRaidTools:ImportYAML(text)

            if not ok then
                self.errorLabel:SetText(result)
                return false
            end

            self.errorLabel:SetText("")
            return true
        end

        -- Validate on text changed
        widget.editBox:HookScript("OnTextChanged", function(_, userInput)
            if userInput then
                if widget:Validate() then
                    widget.button:Enable()
                else
                    widget.button:Disable()
                end
            end
        end)

        return widget
    end

    AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

local mainOptions = {
    name = "Swiftdawn Raid Tools " .. SwiftdawnRaidTools.VERSION,
    type = "group",
    args =  {
        buttonGroup = {
            type = "group",
            inline = true,
            name = "",
            order = 1,
            args = {
                toggleAnchors = {
                    type = "execute",
                    name = "Toggle Anchors",
                    desc = "Toggle Anchors Visibility.",
                    func = function()
                        SwiftdawnRaidTools:NotificationsToggleFrameLock()
                    end,
                    order = 1,
                },
                toggleTestMode = {
                    type = "execute",
                    name = "Toggle Test Mode",
                    desc = "Toggle Test Mode on and off.",
                    func = function()
                        if not InCombatLockdown() then
                            SwiftdawnRaidTools:TestModeToggle()
                        end
                    end,
                    order = 2,
                },
                separator01 = {
                    type = "description",
                    name = " ",
                    width = "full",
                    order = 3,
                },
                resetAppearance = {
                    type = "execute",
                    name = "Reset Appearance",
                    desc = "Reset to default settings.",
                    func = function()
                        SwiftdawnRaidTools.db.profile.overview.appearance.scale = 1.0
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleFontSize = 10
                        SwiftdawnRaidTools.db.profile.overview.appearance.headerFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.overview.appearance.headerFontSize = 10
                        SwiftdawnRaidTools.db.profile.overview.appearance.playerFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.overview.appearance.playerFontSize = 10
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleBarOpacity = 0.8
                        SwiftdawnRaidTools.db.profile.overview.appearance.backgroundOpacity = 0.4
                        SwiftdawnRaidTools.db.profile.overview.appearance.iconSize = 14
                        SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontSize = 14
                        SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontSize = 12
                        SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontSize = 12
                        SwiftdawnRaidTools.db.profile.notifications.appearance.scale = 1.2
                        SwiftdawnRaidTools.db.profile.notifications.appearance.backgroundOpacity = 0.9
                        SwiftdawnRaidTools.db.profile.notifications.appearance.iconSize = 16
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.scale = 1.0
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.headerFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.headerFontSize = 10
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.logFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.logFontSize = 10
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.titleBarOpacity = 0.8
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.backgroundOpacity = 0.4
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.iconSize = 14

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                        SwiftdawnRaidTools:NotificationsUpdateAppearance()
                        SwiftdawnRaidTools:DebugLogUpdateAppearance()
                    end,
                    order = 5,
                },
                resetAnchors = {
                    type = "execute",
                    name = "Reset Anchors",
                    desc = "Reset to default locations.",
                    func = function()
                        SwiftdawnRaidTools.db.profile.overview.anchorX = -800
                        SwiftdawnRaidTools.db.profile.overview.anchorY = 200
                        SwiftdawnRaidTools.db.profile.notifications.anchorX = 0
                        SwiftdawnRaidTools.db.profile.notifications.anchorY = 200
                        SwiftdawnRaidTools.db.profile.debugLog.anchorX = -800
                        SwiftdawnRaidTools.db.profile.debugLog.anchorY = 0

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                        SwiftdawnRaidTools:NotificationsUpdateAppearance()
                        SwiftdawnRaidTools:DebugLogUpdateAppearance()
                    end,
                    order = 6,
                },
            },
        },
        separator01 = {
            type = "description",
            name = " ",
            width = "full",
            order = 2,
        },
        showEnableWindowsDescription = {
            type = "description",
            name = "Enable or Disable Windows",
            width = "full",
            fontSize = "large",
            order = 3,
        },
        separator02 = {
            type = "description",
            name = " ",
            width = "full",
            order = 4,
        },
        showOverviewDescription = {
            type = "description",
            name = "Show Overview",
            width = "normal",
            order = 10,
        },
        showOverview = {
            name = " ",
            desc = "Enables / Disables Overview window",
            type = "toggle",
            width = "half",
            set = function(info, value)
                SwiftdawnRaidTools.db.profile.overview.show = value
                SwiftdawnRaidTools:OverviewUpdate()
            end,
            get = function(info) return SwiftdawnRaidTools.db.profile.overview.show end,
            order = 11,
        },
        lockOverviewDescription = {
            type = "description",
            name = "Lock Overview",
            width = "normal",
            order = 12,
        },
        lockOverview = {
            name = " ",
            desc = "Lock / Unlocks Overview window",
            type = "toggle",
            width = "half",
            set = function(info, value)
                SwiftdawnRaidTools.db.profile.overview.locked = value
                SwiftdawnRaidTools:OverviewUpdate()
            end,
            get = function(info) return SwiftdawnRaidTools.db.profile.overview.locked end,
            order = 13,
        },
        showDebugLogDescription = {
            type = "description",
            name = "Show Debug Log",
            width = "normal",
            order = 20,
        },
        showDebugLog = {
            name = " ",
            desc = "Enables / Disables Debug Log window",
            type = "toggle",
            width = "half",
            set = function(info, value)
                SwiftdawnRaidTools.db.profile.debugLog.show = value
                SwiftdawnRaidTools:DebugLogUpdate()
            end,
            get = function(info) return SwiftdawnRaidTools.db.profile.debugLog.show end,
            order = 21,
        },
        lockDebugLogDescription = {
            type = "description",
            name = "Lock Debug Log",
            width = "normal",
            order = 22,
        },
        lockDebugLog = {
            name = " ",
            desc = "Lock / Unlocks Debug Log window",
            type = "toggle",
            width = "half",
            set = function(info, value)
                SwiftdawnRaidTools.db.profile.debugLog.locked = value
                SwiftdawnRaidTools:DebugLogUpdate()
            end,
            get = function(info) return SwiftdawnRaidTools.db.profile.debugLog.locked end,
            order = 23,
        },
    },
}

-- Convert from TOPLEFT to CENTER coordinates
function TopLeftToCenterX(topLeftX, frameWidth)
    local screenWidth = GetScreenWidth()
    -- Adjust for center point and correct for Y-axis inversion
    local centerX = topLeftX - (screenWidth / 2) + (frameWidth / 2)
    print(string.format("TopLeftX: %.2d  CenterX: %.2d", topLeftX, centerX))
    return centerX
end

-- Convert from TOPLEFT to CENTER coordinates
function TopLeftToCenterY(topLeftY, frameHeight)
    local screenHeight = GetScreenHeight()
    -- Adjust for center point and correct for Y-axis inversion
    local centerY = -(topLeftY - (screenHeight / 2) + (frameHeight / 2))
    return centerY
end

-- Convert from CENTER to TOPLEFT coordinates
function CenterToTopLeftX(centerX, frameWidth)
    local screenWidth = GetScreenWidth()

    -- Adjust for center point and correct for Y-axis inversion
    local topLeftX = centerX + (screenWidth / 2) - (frameWidth / 2)

    return topLeftX
end

-- Convert from CENTER to TOPLEFT coordinates
function CenterToTopLeftY(centerY, frameHeight)
    local screenHeight = GetScreenHeight()

    -- Adjust for center point and correct for Y-axis inversion
    local topLeftY = -(centerY - (screenHeight / 2) + (frameHeight / 2)) + screenHeight

    return topLeftY
end

local appearanceOptions = {
    name = "Appearance",
    type = "group",
    childGroups = "tab",
    args =  {
        overview = {
            type = "group",
            name = "Overview",
            order = 1, 
            args = {
                overviewPositionDescription = {
                    type = "description",
                    name = "Position",
                    width = "normal",
                    order = 12,
                },
                overviewPositionXDescription = {
                    type = "description",
                    name = "              X",
                    width = "half",
                    order = 13,
                },
                overviewPositionX = {
                    type = "input",
                    name = "",
                    width = "half",
                    desc = "Overview anchor X position",
                    get = function(info)
                        return string.format("%.1f", TopLeftToCenterX(SwiftdawnRaidTools.db.profile.overview.anchorX, SwiftdawnRaidTools.overviewFrame:GetWidth()))
                    end,
                    set = function(info, value)
                        local numValue = tonumber(value)
                        if numValue then
                            SwiftdawnRaidTools.db.profile.overview.anchorX = CenterToTopLeftX(numValue, SwiftdawnRaidTools.overviewFrame:GetWidth())
                            SwiftdawnRaidTools:OverviewUpdateAppearance()
                        else
                            print("Please enter a valid number for X position.")
                        end
                    end,
                    pattern = "^[+-]?(\d*\.\d+|\d+\.?)([eE][+-]?\d+)?$",  -- Allows negative and positive integers
                    order = 14
                },
                overviewPositionYDescription = {
                    type = "description",
                    name = "              Y",
                    width = "half",
                    order = 15,
                },
                overviewPositionY = {
                    type = "input",
                    name = "",
                    width = "half",
                    desc = "Overview anchor Y position",
                    get = function(info)
                        return string.format("%.1f", SwiftdawnRaidTools.db.profile.overview.anchorY)
                    end,
                    set = function(info, value)
                        local numValue = tonumber(value)
                        if numValue then
                            print("New Y: "..numValue)
                            SwiftdawnRaidTools.db.profile.overview.anchorY = numValue
                            SwiftdawnRaidTools:OverviewUpdateAppearance()
                        else
                            print("Please enter a valid number for Y position.")
                        end
                    end,
                    pattern = "^[+-]?(\d*\.\d+|\d+\.?)([eE][+-]?\d+)?$",  -- Allows negative and positive integers
                    order = 16
                },
                overviewScaleDescription = {
                    type = "description",
                    name = "Scale",
                    width = "normal",
                    order = 18,
                },
                overviewScale = {
                    type = "range",
                    min = 0.6,
                    max = 1.4,
                    isPercent = true,
                    name = "",
                    desc = "Set the Overview UI Scale.",
                    width = "double",
                    order = 19,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.scale end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.scale = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                    end,
                },
                overviewTitleFontDescription = {
                    type = "description",
                    name = "Encounter Name",
                    width = "normal",
                    order = 21,
                },
                overviewTitleFontType = {
                    type = "select",
                    name = "",
                    desc = "Set the font used in the overview title",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 22,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.titleFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleFontType = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                    end,
                },
                overviewTitleFontSize = {
                    type = "range",
                    name = "",
                    desc = "Set the font size used in the overview title",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 23,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.titleFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleFontSize = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                    end,
                },
                overviewHeaderFontDescription = {
                    type = "description",
                    name = "Boss Ability",
                    width = "normal",
                    order = 31,
                },
                overviewHeaderFontType = {
                    type = "select",
                    name = "",
                    desc = "Set the font used in the overview header",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 32,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.headerFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.headerFontType = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                    end,
                },
                overviewHeaderFontSize = {
                    type = "range",
                    name = "",
                    desc = "Set the font sze used in the overview header",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 33,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.headerFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.headerFontSize = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                    end,
                },
                overviewPlayerFontDescription = {
                    type = "description",
                    name = "Player Names",
                    width = "normal",
                    order = 41,
                },
                overviewPlayerFontType = {
                    type = "select",
                    name = "",
                    desc = "Set the font used in the overview player name",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 42,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.playerFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.playerFontType = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                    end,
                },
                overviewPlayerFontSize = {
                    type = "range",
                    name = "",
                    desc = "Set the font size used in the overview player name",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 43,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.playerFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.playerFontSize = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                    end,
                },
                overviewIconSizeDescription = {
                    type = "description",
                    name = "Icon Size",
                    width = "normal",
                    order = 51,
                },
                overviewIconSize = {
                    type = "range",
                    min = 12,
                    max = 32,
                    step = 1,
                    name = "",
                    desc = "Set the ability icon size.",
                    width = "double",
                    order = 52,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.iconSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.iconSize = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                    end,
                },
                overviewTitleBarOpacityDescription = {
                    type = "description",
                    name = "Title Bar Opacity",
                    width = "normal",
                    order = 53,
                },
                overviewTitleBarOpacity = {
                    type = "range",
                    min = 0,
                    max = 1,
                    isPercent = true,
                    name = "",
                    desc = "Set the Overview Background Opacity.",
                    width = "double",
                    order = 54,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.titleBarOpacity end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleBarOpacity = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                    end,
                },
                overviewBackgroundOpacityDescription = {
                    type = "description",
                    name = "Background Opacity",
                    width = "normal",
                    order = 55,
                },
                overviewBackgroundOpacity = {
                    type = "range",
                    min = 0,
                    max = 1,
                    isPercent = true,
                    name = "",
                    desc = "Set the Overview Background Opacity.",
                    width = "double",
                    order = 56,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.backgroundOpacity end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.backgroundOpacity = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                    end,
                }
            }
        },
        notifications = {
            type = "group",
            name = "Notifications",
            order = 2,
            args = {
                notificationsPositionDescription = {
                    type = "description",
                    name = "Position",
                    width = "normal",
                    order = 63,
                },
                notificationsPositionXDescription = {
                    type = "description",
                    name = "              X",
                    width = "half",
                    order = 64,
                },
                notificationsPositionX = {
                    type = "input",
                    name = "",
                    width = "half",
                    desc = "Notifications anchor X position",
                    get = function(info)
                        return string.format("%.1f", TopLeftToCenterX(SwiftdawnRaidTools.db.profile.notifications.anchorX, SwiftdawnRaidTools.notificationFrame:GetWidth()))
                    end,
                    set = function(info, value)
                        local numValue = tonumber(value)
                        if numValue then
                            SwiftdawnRaidTools.db.profile.notifications.anchorX = CenterToTopLeftX(numValue, SwiftdawnRaidTools.notificationFrame:GetWidth())
                            SwiftdawnRaidTools:NotificationsUpdateAppearance()
                        else
                            print("Please enter a valid number for X position.")
                        end
                    end,
                    pattern = "^[+-]?(\d*\.\d+|\d+\.?)([eE][+-]?\d+)?$",  -- Allows negative and positive integers
                    order = 65
                },
                notificationsPositionYDescription = {
                    type = "description",
                    name = "              Y",
                    width = "half",
                    order = 66,
                },
                notificationsPositionY = {
                    type = "input",
                    name = "",
                    width = "half",
                    desc = "Notifications anchor Y position",
                    get = function(info) return tostring(SwiftdawnRaidTools.db.profile.notifications.anchorY) end,
                    set = function(info, value)
                        local numValue = tonumber(value)
                        if numValue then
                            SwiftdawnRaidTools.db.profile.notifications.anchorY = numValue
                            SwiftdawnRaidTools:NotificationsUpdateAppearance()
                        else
                            print("Please enter a valid number for Y position.")
                        end
                    end,
                    pattern = "^[+-]?(\d*\.\d+|\d+\.?)([eE][+-]?\d+)?$",  -- Allows negative and positive integers
                    order = 67
                },
                notificationsScaleDescription = {
                    type = "description",
                    name = "Scale",
                    width = "normal",
                    order = 68,
                },
                notificationsScale = {
                    type = "range",
                    min = 0.6,
                    max = 1.4,
                    isPercent = true,
                    name = "",
                    desc = "Set the Notifications UI Scale.",
                    width = "double",
                    order = 69,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.scale end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.scale = value

                        SwiftdawnRaidTools:NotificationsUpdateAppearance()
                    end,
                },
                notificationsHeaderFontDescription = {
                    type = "description",
                    name = "Boss Ability",
                    width = "normal",
                    order = 71,
                },
                notificationsHeaderFontType = {
                    type = "select",
                    name = "",
                    desc = "Sets the font used in notification header",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 72,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontType = value

                        SwiftdawnRaidTools:NotificationsUpdateAppearance()
                    end,
                },
                notificationsHeaderFontSize = {
                    type = "range",
                    name = "",
                    desc = "Sets the font size used in notification header",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 73,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontSize end,
                    set = function(self, key)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontSize = key

                        SwiftdawnRaidTools:NotificationsUpdateAppearance()
                    end,
                },
                notificationsPlayerFontDescription = {
                    type = "description",
                    name = "Player Names",
                    width = "normal",
                    order = 81,
                },
                notificationsPlayerFontType = {
                    type = "select",
                    name = "",
                    desc = "Sets the font used in notification player names",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 82,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontType end,
                    set = function(_, key)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontType = key

                        SwiftdawnRaidTools:NotificationsUpdateAppearance()
                    end,
                },
                notificationsPlayerFontSize = {
                    type = "range",
                    name = "",
                    desc = "Sets the font size used in notification player names",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 83,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontSize = value

                        SwiftdawnRaidTools:NotificationsUpdateAppearance()
                    end,
                },
                notificationsCountdownFontDescription = {
                    type = "description",
                    name = "Countdown",
                    width = "normal",
                    order = 84,
                },
                notificationsCountdownFontType = {
                    type = "select",
                    name = "",
                    desc = "Sets the font used in notification countdown",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 85,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontType = value

                        SwiftdawnRaidTools:NotificationsUpdateAppearance()
                    end,
                },
                notificationsCountdownFontSize = {
                    type = "range",
                    name = "",
                    desc = "Sets the font size used in notification countdown",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 86,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontSize = value

                        SwiftdawnRaidTools:NotificationsUpdateAppearance()
                    end,
                },
                notificationsIconSizeDescription = {
                    type = "description",
                    name = "Icon Size",
                    width = "normal",
                    order = 91,
                },
                notificationsIconSize = {
                    type = "range",
                    min = 12,
                    max = 32,
                    step = 1,
                    name = "",
                    desc = "Set the notification icon size",
                    width = "double",
                    order = 92,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.iconSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.iconSize = value

                        SwiftdawnRaidTools:NotificationsUpdateAppearance()
                    end,
                },
                notificationsBackgroundOpacityDescription = {
                    type = "description",
                    name = "Background Opacity",
                    width = "normal",
                    order = 93,
                },
                notificationsBackgroundOpacity = {
                    type = "range",
                    min = 0,
                    max = 1,
                    isPercent = true,
                    name = "",
                    desc = "Set the Notifications Background Opacity.",
                    width = "double",
                    order = 94,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.backgroundOpacity end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.backgroundOpacity = value

                        SwiftdawnRaidTools:NotificationsUpdateAppearance()
                    end,
                },
            },
        },
        debugLog = {
            type = "group",
            name = "Debug Log",
            order = 3,
            args = {
                debugLogPositionDescription = {
                    type = "description",
                    name = "Position",
                    width = "normal",
                    order = 1,
                },
                debugLogPositionXDescription = {
                    type = "description",
                    name = "              X",
                    width = "half",
                    order = 2,
                },
                debugLogPositionX = {
                    type = "input",
                    name = "",
                    width = "half",
                    desc = "Debug Log anchor X position",
                    get = function(info) return tostring(SwiftdawnRaidTools.db.profile.debugLog.anchorX) end,
                    set = function(info, value)
                        local numValue = tonumber(value)
                        if numValue then
                            SwiftdawnRaidTools.db.profile.debugLog.anchorX = numValue
                            SwiftdawnRaidTools:DebugLogUpdateAppearance()
                        else
                            print("Please enter a valid number for X position.")
                        end
                    end,
                    pattern = "^[+-]?(\d*\.\d+|\d+\.?)([eE][+-]?\d+)?$",  -- Allows negative and positive integers
                    order = 3
                },
                debugLogPositionYDescription = {
                    type = "description",
                    name = "              Y",
                    width = "half",
                    order = 5,
                },
                debugLogPositionY = {
                    type = "input",
                    name = "",
                    width = "half",
                    desc = "Debug Log anchor Y position",
                    get = function(info) return tostring(SwiftdawnRaidTools.db.profile.debugLog.anchorY) end,
                    set = function(info, value)
                        local numValue = tonumber(value)
                        if numValue then
                            SwiftdawnRaidTools.db.profile.debugLog.anchorY = numValue
                            SwiftdawnRaidTools:DebugLogUpdateAppearance()
                        else
                            print("Please enter a valid number for Y position.")
                        end
                    end,
                    pattern = "^[+-]?(\d*\.\d+|\d+\.?)([eE][+-]?\d+)?$",  -- Allows negative and positive integers
                    order = 6
                },
                debugLogScaleDescription = {
                    type = "description",
                    name = "Scale",
                    width = "normal",
                    order = 10,
                },
                debugLogScale = {
                    type = "range",
                    min = 0.6,
                    max = 1.4,
                    isPercent = true,
                    name = "",
                    desc = "Set the Debug Log UI Scale.",
                    width = "double",
                    order = 11,
                    get = function() return SwiftdawnRaidTools.db.profile.debugLog.appearance.scale end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.scale = value

                        SwiftdawnRaidTools:DebugLogUpdateAppearance()
                    end,
                },
                debugLogTitleFontDescription = {
                    type = "description",
                    name = "Title Bar",
                    width = "normal",
                    order = 20,
                },
                debugLogTitleFontType = {
                    type = "select",
                    name = "",
                    desc = "Set the font used in the Debug Log title",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 21,
                    get = function() return SwiftdawnRaidTools.db.profile.debugLog.appearance.titleFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.titleFontType = value

                        SwiftdawnRaidTools:DebugLogUpdateAppearance()
                    end,
                },
                debugLogTitleFontSize = {
                    type = "range",
                    name = "",
                    desc = "Set the font size used in the Debug Log title",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 22,
                    get = function() return SwiftdawnRaidTools.db.profile.debugLog.appearance.titleFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.titleFontSize = value

                        SwiftdawnRaidTools:DebugLogUpdateAppearance()
                    end,
                },
                debugLogLineFontDescription = {
                    type = "description",
                    name = "Log Lines",
                    width = "normal",
                    order = 30,
                },
                debugLogLineFontType = {
                    type = "select",
                    name = "",
                    desc = "Set the font used in the Debug Log lines",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 142,
                    get = function() return SwiftdawnRaidTools.db.profile.debugLog.appearance.logFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.logFontType = value

                        SwiftdawnRaidTools:DebugLogUpdateAppearance()
                    end,
                },
                debugLogLineFontSize = {
                    type = "range",
                    name = "",
                    desc = "Set the font size used in the Debug Log lines",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 143,
                    get = function() return SwiftdawnRaidTools.db.profile.debugLog.appearance.logFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.logFontSize = value

                        SwiftdawnRaidTools:DebugLogUpdateAppearance()
                    end,
                },
                debugLogTitleBarOpacityDescription = {
                    type = "description",
                    name = "Title Bar Opacity",
                    width = "normal",
                    order = 153,
                },
                debugLogTitleBarOpacity = {
                    type = "range",
                    min = 0,
                    max = 1,
                    isPercent = true,
                    name = "",
                    desc = "Set the Debug Log title bar background opacity.",
                    width = "double",
                    order = 154,
                    get = function() return SwiftdawnRaidTools.db.profile.debugLog.appearance.titleBarOpacity end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.titleBarOpacity = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                        SwiftdawnRaidTools:DebugLogUpdateAppearance()
                    end,
                },
                debugLogBackgroundOpacityDescription = {
                    type = "description",
                    name = "Background Opacity",
                    width = "normal",
                    order = 155,
                },
                debugLogBackgroundOpacity = {
                    type = "range",
                    min = 0,
                    max = 1,
                    isPercent = true,
                    name = "",
                    desc = "Set the Debug Log background opacity.",
                    width = "double",
                    order = 156,
                    get = function() return SwiftdawnRaidTools.db.profile.debugLog.appearance.backgroundOpacity end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debugLog.appearance.backgroundOpacity = value

                        SwiftdawnRaidTools:OverviewUpdateAppearance()
                        SwiftdawnRaidTools:DebugLogUpdateAppearance()
                    end,
                },
            },
        },
    },
}

local notificationOptions = {
    name = "Notifications",
    type = "group",
    args =  {
        showOnlyOwnNotificationsCheckbox = {
            type = "toggle",
            name = "Limit Notifications",
            desc = "Only show Raid Notifications that apply to You.",
            width = "full",
            order = 1,
            get = function() return SwiftdawnRaidTools.db.profile.notifications.showOnlyOwnNotifications end,
            set = function(_, value) SwiftdawnRaidTools.db.profile.notifications.showOnlyOwnNotifications = value end,
        },
        showOnlyOwnNotificationsDescription = {
            type = "description",
            name = "Only show Raid Notifications that apply to you.",
            order = 2,
        },
        separator = {
            type = "description",
            name = " ",
            order = 3,
        },
        muteCheckbox = {
            type = "toggle",
            name = "Mute Sounds",
            desc = "Mute all Raid Notification Sounds.",
            width = "full",
            order = 4,
            get = function() return SwiftdawnRaidTools.db.profile.notifications.mute end,
            set = function(_, value)SwiftdawnRaidTools.db.profile.notifications.mute = value end,
        },
        muteDescription = {
            type = "description",
            name = "Mute all Raid Notification Sounds.",
            order = 5,
        },
    },
}

local fojjiIntegrationOptions = {
    name = "Fojji Integration (Experimental)",
    type = "group",
    args = {
        weakAuraText = {
            type = "description",
            name = "Fojji Integration require the use of a Helper WeakAura. This WeakAura is only required if you are the Raid Leader and configure assignments that are activated by Fojji timers.",
            order = 1,
        },
        separator = {
            type = "description",
            name = " ",
            order = 2,
        },
        weakAurasNotInstalledError = {
            type = "description",
            fontSize = "medium",
            name = "|cffff0000WeakAuras is not installed.|r",
            order = 3,
            hidden = function() return SwiftdawnRaidTools:WeakAurasIsInstalled() end
        },
        helperWeakAuraInstalledMessage = {
            type = "description",
            fontSize = "medium",
            name = "|cff00ff00Swiftdawn Raid Tools Helper WeakAura Installed.|r",
            order = 4,
            hidden = function() return not SwiftdawnRaidTools:WeakaurasIsHelperInstalled() end
        },
        installWeakAuraButton = {
            type = "execute",
            name = "Install WeakAura",
            desc = "Install the Swiftdawn Raid Tools Helper WeakAura.",
            func = function() SwiftdawnRaidTools:WeakAurasInstallHelper(function()
                LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools Fojji Integration")
            end) end,
            order = 5,
            hidden = function() return not SwiftdawnRaidTools:WeakAurasIsInstalled() or SwiftdawnRaidTools:WeakaurasIsHelperInstalled() end
        },
    },
}

local importDescription = [[
Paste your raid assignments and other import data below. The import should be valid YAML.

For the full Import API spec, visit https://github.com/gonstr/SwiftdawnRaidTools.
]]

local importOptions = {
    name = "Import",
    type = "group",
    args = {
        description = {
            type = "description",
            name = importDescription,
            fontSize = "medium",
            order = 1,
        },
        import = {
            type = "input",
            name = "Import",
            desc = "Paste your import data here.",
            multiline = 25,
            width = "full",
            dialogControl = "ImportMultiLineEditBox",
            order = 2,
            get = function() return SwiftdawnRaidTools.db.profile.options.import end,
            set = function(_, val)
                if val then
                    val = val:trim()
                end

                SwiftdawnRaidTools:TestModeEnd()

                SwiftdawnRaidTools.db.profile.options.import = val

                SwiftdawnRaidTools.db.profile.data.encounters = {}
                SwiftdawnRaidTools.db.profile.data.encountersId = nil

                if val ~= nil and val ~= "" then
                    local _, result = SwiftdawnRaidTools:ImportYAML(val)
                    local encounters, encountersId = SwiftdawnRaidTools:ImportCreateEncountersData(result)

                    SwiftdawnRaidTools.db.profile.data.encountersId = encountersId
                    SwiftdawnRaidTools.db.profile.data.encounters = encounters
                end

                SwiftdawnRaidTools:SyncSchedule()
                SwiftdawnRaidTools:OverviewUpdate()
            end,
        },
    },
}

function SwiftdawnRaidTools:OptionsInit()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools", mainOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools", "Swiftdawn Raid Tools")


    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Appearance", appearanceOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Appearance", "Appearance", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Notifications", notificationOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Notifications", "Notifications", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Fojji Integration", fojjiIntegrationOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Fojji Integration", "Fojji Integration", "Swiftdawn Raid Tools")
    
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Import", importOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Import", "Import", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Profiles", "Profiles", "Swiftdawn Raid Tools")
end

function SwiftdawnRaidTools:ToggleFrameLock(lock) end

function SwiftdawnRaidTools:OnConfigChanged()
    SwiftdawnRaidTools:UpdatePartyFramesVisibility(self.db.profile.hideBlizPartyFrame)
    SwiftdawnRaidTools:UpdateArenaFramesVisibility(self.db.profile.hideBlizArenaFrame)
    SwiftdawnRaidTools:UpdateAuraDurationsVisibility()
end

SwiftdawnRaidTools:RegisterChatCommand("art", function()
    LibStub("AceConfigDialog-3.0"):Open("SwiftdawnRaidTools")
end)
