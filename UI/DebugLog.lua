local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

local MIN_HEIGHT = 100
local MIN_WIDTH = 100
local MAX_SCROLLBACK = 500

local function getTitleFontType()
    return SharedMedia:Fetch("font", SwiftdawnRaidTools.db.profile.debugLog.appearance.titleFontType)
end

function SwiftdawnRaidTools:DebugLogInit()
    local titleFontSize = self.db.profile.debugLog.appearance.titleFontSize
    local logFontSize = self.db.profile.debugLog.appearance.logFontSize
    local container = CreateFrame("Frame", "SwiftdawnRaidToolsDebugLog", UIParent, "BackdropTemplate")
    container:SetSize(400, MIN_HEIGHT)
    container:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    container:SetBackdropColor(0, 0, 0, self.db.profile.debugLog.appearance.backgroundOpacity)
    container:SetMovable(true)
    container:EnableMouse(true)
    container:SetUserPlaced(true)
    container:SetClampedToScreen(true)
    container:RegisterForDrag("LeftButton")
    container:SetScript("OnDragStart", function(self)
        self:StartMoving()
        self:SetScript("OnUpdate", function()  -- Continuously update the frame size
            SwiftdawnRaidTools.db.profile.debugLog.anchorX = tonumber(string.format("%.2f", self:GetLeft()))
            SwiftdawnRaidTools.db.profile.debugLog.anchorY = tonumber(string.format("%.2f", self:GetTop() - GetScreenHeight()))
            LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools Appearance")
            SwiftdawnRaidTools:DebugLogUpdateAppearance()
        end)
    end)
    container:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self:SetScript("OnUpdate", nil)
    end)
    container:SetScale(self.db.profile.debugLog.appearance.scale)
    container:SetClipsChildren(true)
    container:SetResizable(true)

    local popup = CreateFrame("Frame", "SwiftdawnRaidToolsDebugLogPopup", UIParent, "BackdropTemplate")
    popup:SetClampedToScreen(true)
    popup:SetSize(200, 50)
    popup:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2,
        },
    })
    popup:SetBackdropColor(0, 0, 0, 1)
    popup:SetFrameStrata("DIALOG")

    popup:Hide() -- Start hidden

    local function showPopup()
        if not self.TEST and (InCombatLockdown() or SwiftdawnRaidTools:RaidAssignmentsInEncounter()) then
            return
        end
        SwiftdawnRaidTools:DebugLogUpdatePopup()
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        x, y = x / scale, y / scale
        popup:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", x, y)
        popup:Show()
    end

    local header = CreateFrame("Frame", "SwiftdawnRaidToolsDebugLogHeader", container, "BackdropTemplate")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:SetMovable(true)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 16,
    })
    header:SetBackdropColor(0, 0, 0, self.db.profile.debugLog.appearance.titleBarOpacity)
    header:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            showPopup()
        end
    end)
    header:SetScript("OnDragStart", function(self)
        container:StartMoving()
        container:SetScript("OnUpdate", function()  -- Continuously update the frame size
            SwiftdawnRaidTools.db.profile.debugLog.anchorX = tonumber(string.format("%.2f", self:GetLeft()))
            SwiftdawnRaidTools.db.profile.debugLog.anchorY = tonumber(string.format("%.2f", self:GetTop() - GetScreenHeight()))
            LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools Appearance")
            SwiftdawnRaidTools:DebugLogUpdateAppearance()
        end)
    end)
    header:SetScript("OnDragStop", function(self)
        container:StopMovingOrSizing()
        container:SetScript("OnUpdate", nil)
    end)

    header:SetScript("OnEnter", function()
        SwiftdawnRaidTools.debugLogHeader:SetBackdropColor(0, 0, 0, 1)
        SwiftdawnRaidTools.debugLogHeaderButton:SetAlpha(1)
    end)
    header:SetScript("OnLeave", function()
        SwiftdawnRaidTools.debugLogHeader:SetBackdropColor(0, 0, 0, SwiftdawnRaidTools.db.profile.debugLog.appearance.titleBarOpacity)
        SwiftdawnRaidTools.debugLogHeaderButton:SetAlpha(SwiftdawnRaidTools.db.profile.debugLog.appearance.titleBarOpacity)
    end)

    local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerText:SetFont(getTitleFontType(), titleFontSize)
    headerText:SetPoint("LEFT", header, "LEFT", 10, 0)
    headerText:SetShadowOffset(1, -1)
    headerText:SetShadowColor(0, 0, 0, 1)
    headerText:SetJustifyH("LEFT")
    headerText:SetWordWrap(false)
    headerText:SetText("Debug Log")

    local headerButton = CreateFrame("Button", nil, header)
    headerButton:SetSize(titleFontSize, titleFontSize)
    headerButton:SetPoint("RIGHT", header, "RIGHT", -3, 0)
    headerButton:SetNormalTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetHighlightTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetPushedTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetAlpha(self.db.profile.debugLog.appearance.titleBarOpacity)
    headerButton:SetScript("OnEnter", function()
        SwiftdawnRaidTools.debugLogHeader:SetBackdropColor(0, 0, 0, 1)
        SwiftdawnRaidTools.debugLogHeaderButton:SetAlpha(1)
    end)
    headerButton:SetScript("OnLeave", function()
        SwiftdawnRaidTools.debugLogHeader:SetBackdropColor(0, 0, 0, SwiftdawnRaidTools.db.profile.debugLog.appearance.titleBarOpacity)
        SwiftdawnRaidTools.debugLogHeaderButton:SetAlpha(SwiftdawnRaidTools.db.profile.debugLog.appearance.titleBarOpacity)
    end)

    headerButton:SetScript("OnClick", function()
        showPopup()
    end)
    headerButton:RegisterForClicks("AnyDown", "AnyUp")

    local main = CreateFrame("Frame", "SwiftdawnRaidToolsDebugLogMain", container, "BackdropTemplate")
    main:SetPoint("BOTTOMLEFT", 0, 0)
    main:SetPoint("BOTTOMRIGHT", 0, 0)

    -- Create the scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "MyScrollFrame", main, "UIPanelScrollFrameTemplate")
    --scrollFrame:SetSize(500, MIN_HEIGHT)  -- Set the size of the scroll frame
    scrollFrame:SetPoint("TOPLEFT", main, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("TOPRIGHT", main, "TOPRIGHT", 0, 0)
    scrollFrame:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 0, 5)
    scrollFrame:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", 0, 5)

    local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
    scrollBar.scrollStep = logFontSize  -- Change this value to adjust the scroll amount per tick
    -- Create a content frame to hold the text
    local contentFrame = CreateFrame("Frame", "MyContentFrame", scrollFrame)
    contentFrame:SetSize(500, MIN_HEIGHT)  -- Set the size of the content frame (height is larger for scrolling)
    contentFrame:SetPoint("TOPLEFT")
    contentFrame:SetPoint("TOPRIGHT")

    -- Set the content frame as the scroll frame's scroll child
    scrollFrame:SetScrollChild(contentFrame)

    -- Create a button in the bottom-right corner (resize handle)
    local resizeButton = CreateFrame("Button", nil, container)
    resizeButton:SetSize(12, 12)
    resizeButton:SetPoint("BOTTOMRIGHT")
    local resizeTexture = resizeButton:CreateTexture(nil, "BACKGROUND")
    resizeTexture:SetAllPoints(resizeButton)
    resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up") -- Use a default WoW texture for resize
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetAlpha(0)
    resizeButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            container:StartSizing("BOTTOMRIGHT")  -- Start resizing from bottom-right corner
            container:SetScript("OnUpdate", function()  -- Continuously update the frame size
                SwiftdawnRaidTools:DebugLogUpdateAppearance()
            end)

        end
    end)
    resizeButton:SetScript("OnEnter", function()
        resizeButton:SetAlpha(1)
    end)
    resizeButton:SetScript("OnLeave", function()
        resizeButton:SetAlpha(0)
    end)
    resizeButton:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            container:StopMovingOrSizing()  -- Stop the resizing action
            container:SetScript("OnUpdate", nil)  -- Stop updating frame size
        end
    end)
    container:SetScript("OnSizeChanged", function(self, width, height)
        if width < MIN_WIDTH then width = MIN_WIDTH end
        if height < MIN_HEIGHT then height = MIN_HEIGHT end
        container:SetSize(width, height)
    end)

    self.debugLogFrame = container
    self.debugLogPopup = popup
    self.debugLogPopupListItems = {}
    self.debugLogHeader = header
    self.debugLogHeaderButton = headerButton
    self.debugLogHeaderText = headerText
    self.debugLogMain = main
    self.debugLogBossAbilities = {}
    self.debugLogAssignmentGroups = {}

    self.debugLogScrollFrame = scrollFrame
    self.debugLogScrollContentFrame = contentFrame
    self.debugLogResizeButton = resizeButton

    self.debugLogItems = {}

    self:DebugLogUpdateAppearance()
end

function SwiftdawnRaidTools:DebugLogScrollToBottom()
    local logFontSize = self.db.profile.debugLog.appearance.logFontSize
    local scrollBar = _G[self.debugLogScrollFrame:GetName() .. "ScrollBar"]
    scrollBar:SetValue(15 + #self.debugLogItems * (logFontSize + 3))
end

function SwiftdawnRaidTools:DebugLogAddItem(logItem)
    logItem:CreateFrame(self.debugLogScrollContentFrame, SwiftdawnRaidTools.db.profile)
    -- fix connection points for new and old lines
    if #self.debugLogItems == 0 then
        -- no other lines, so connect to top
        logItem.frame:SetPoint("TOPLEFT", self.debugLogScrollContentFrame, "TOPLEFT", 5, -3)
    else
        if #self.debugLogItems > MAX_SCROLLBACK then
            -- too many lines; remove first line in log
            local removedItem = table.remove(self.debugLogItems, 1)
            removedItem:DeleteFrame()
            -- connect new first line to top
            self.debugLogItems[1].frame:SetPoint("TOPLEFT", self.debugLogScrollContentFrame, "TOPLEFT", 5, -3)
        end
        -- connect to last line in log
        logItem.frame:SetPoint("TOPLEFT", self.debugLogItems[#self.debugLogItems].frame, "BOTTOMLEFT", 0, -3)
    end
    -- add line to the list
    self.debugLogItems[#self.debugLogItems +1] = logItem
    if self.db.profile.debugLog.scrollToBottom then
        self:DebugLogScrollToBottom()
    end
end

function SwiftdawnRaidTools:DebugLogUpdateAppearance()
    self.debugLogFrame:ClearAllPoints()
    self.debugLogFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", self.db.profile.debugLog.anchorX, self.db.profile.debugLog.anchorY)

    local titleFontSize = self.db.profile.debugLog.appearance.titleFontSize
    local logFontSize = self.db.profile.debugLog.appearance.logFontSize

    self.debugLogFrame:SetScale(self.db.profile.debugLog.appearance.scale)
    self.debugLogHeaderText:SetFont(getTitleFontType(), titleFontSize)
    local headerHeight = titleFontSize + 8
    self.debugLogHeader:SetHeight(headerHeight)

    local headerWidth = self.debugLogFrame:GetWidth()
    self.debugLogHeaderText:SetWidth(headerWidth - 10 - titleFontSize)

    self.debugLogScrollContentFrame:SetHeight(15 + #self.debugLogItems * (logFontSize + 3))
    for _, item in ipairs(self.debugLogItems) do
        item:UpdateAppearance(SwiftdawnRaidTools.db.profile)
    end
    local scrollBar = _G[self.debugLogScrollFrame:GetName() .. "ScrollBar"]
    scrollBar.scrollStep = logFontSize * 2

    self.debugLogMain:SetPoint("TOPLEFT", 0, -headerHeight)
    self.debugLogMain:SetPoint("TOPRIGHT", 0, -headerHeight)
    self.debugLogHeaderButton:SetSize(titleFontSize, titleFontSize)
    self.debugLogHeaderButton:SetAlpha(self.db.profile.debugLog.appearance.titleBarOpacity)

    self.debugLogHeader:SetBackdropColor(0, 0, 0, self.db.profile.debugLog.appearance.titleBarOpacity)
    local r, g, b = self.overviewFrame:GetBackdropColor()
    self.debugLogFrame:SetBackdropColor(r, g, b, self.db.profile.debugLog.appearance.backgroundOpacity)
end

function SwiftdawnRaidTools:DebugLogUpdate()
    local show = self.db.profile.debugLog.show

    if not show then
        self.debugLogFrame:Hide()
        return
    end

    self:DebugLogUpdateLocked()
    self.debugLogFrame:Show()
end

function SwiftdawnRaidTools:DebugLogUpdateLocked()
    if self.db.profile.debugLog.locked then
        self.debugLogFrame:EnableMouse(false)
        self.debugLogHeader:EnableMouse(false)
        self.debugLogResizeButton:EnableMouse(false)
        self.debugLogResizeButton:Hide()
    else
        self.debugLogFrame:EnableMouse(true)
        self.debugLogHeader:EnableMouse(true)
        self.debugLogResizeButton:EnableMouse(true)
        self.debugLogResizeButton:Show()
    end
end

function SwiftdawnRaidTools:DebugLogToggleLock()
    self.db.profile.debugLog.locked = not self.db.profile.debugLog.locked
    LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools")
    self:DebugLogUpdateLocked()
end

function SwiftdawnRaidTools:DebugLogUpdateAutoScroll()
    if self.db.profile.debugLog.scrollToBottom then
        self:DebugLogScrollToBottom()
    end
end

function SwiftdawnRaidTools:DebugLogToggleAutoScroll()
    self.db.profile.debugLog.scrollToBottom = not self.db.profile.debugLog.scrollToBottom
    self:DebugLogUpdateAutoScroll()
end

local function createPopupListItem(popupFrame, text, onClick)
    local item = CreateFrame("Frame", nil, popupFrame, "BackdropTemplate")
    item.highlight = item:CreateTexture(nil, "HIGHLIGHT")

    item:SetHeight(20)
    item:EnableMouse(true)
    item:SetScript("OnEnter", function() item.highlight:Show() end)
    item:SetScript("OnLeave", function() item.highlight:Hide() end)
    item:EnableMouse(true)
    item:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if item.onClick then item.onClick() end
            popupFrame:Hide()
        end
    end)

    item.highlight:SetPoint("TOPLEFT", 10, 0)
    item.highlight:SetPoint("BOTTOMRIGHT", -10, 0)
    item.highlight:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    item.highlight:SetBlendMode("ADD")
    item.highlight:SetAlpha(0.5)
    item.highlight:Hide()

    item.text = item:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    item.text:SetFont(SwiftdawnRaidTools:AppearancePopupFontType(), 10)
    item.text:SetTextColor(1, 1, 1)
    item.text:SetPoint("BOTTOMLEFT", 15, 5)
    item.text:SetText(text)

    item.onClick = onClick

    return item
end

function SwiftdawnRaidTools:DebugLogShowPopupListItem(index, text, setting, onClick, accExtraOffset, extraOffset)
    if not self.debugLogPopupListItems[index] then
        self.debugLogPopupListItems[index] = createPopupListItem(self.debugLogPopup)
    end
    local item = self.debugLogPopupListItems[index]
    local yOfs = -10 - (20 * (index -1))
    if accExtraOffset then
        yOfs = yOfs - accExtraOffset
    end
    if extraOffset then
        yOfs = yOfs - 10
    end
    if setting then
        item.text:SetTextColor(1, 1, 1, 1)
    else
        item.text:SetTextColor(1, 0.8235, 0)
    end
    item:SetPoint("TOPLEFT", 0, yOfs)
    item:SetPoint("TOPRIGHT", 0, yOfs)
    item.text:SetText(text)
    item.onClick = onClick
    item:Show()
    return yOfs
end

function SwiftdawnRaidTools:DebugLogClearWindow()
    for i, _ in ipairs(self.debugLogItems) do
        self.debugLogItems[i]:DeleteFrame()
    end
    self.debugLogItems = {}
    self:DebugLogUpdateAppearance()
end

function SwiftdawnRaidTools:DebugLogUpdatePopup()
    if InCombatLockdown() then
        return
    end

    local index = 1

    local clearFunc = function() self:DebugLogClearWindow() end
    self:DebugLogShowPopupListItem(index, "Clear log", true, clearFunc, 0, false)

    index = index + 1

    local lockFunc = function() self:DebugLogToggleLock() end
    local lockedText = self.db.profile.debugLog.locked and "Unlock Debug Log" or "Lock Debug Log"
    self:DebugLogShowPopupListItem(index, lockedText, true, lockFunc, 0, false)

    index = index + 1

    local scrollFunc = function() self:DebugLogToggleAutoScroll() end
    local scrollText = self.db.profile.debugLog.scrollToBottom and "Don't autoscroll" or "Scroll to bottom"
    self:DebugLogShowPopupListItem(index, scrollText, true, scrollFunc, 0, false)

    index = index + 1

    local configurationFunc = function() InterfaceOptionsFrame_OpenToCategory("Swiftdawn Raid Tools") end
    self:DebugLogShowPopupListItem(index, "Configuration", true, configurationFunc, 0, false)

    index = index + 1

    local yOfs = self:DebugLogShowPopupListItem(index, "Close", true, nil, 0, true)

    local popupHeight = math.abs(yOfs) + 30

    -- Update popup size
    self.debugLogPopup:SetHeight(popupHeight)
end