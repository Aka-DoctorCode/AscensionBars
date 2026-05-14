-------------------------------------------------------------------------------
-- Project: AscensionProgressDataBars
-- Author: Aka-DoctorCode
-- File: Main.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field


local addonName, addonTable = ...
local ascensionBars = addonTable.main or LibStub("AceAddon-3.0"):GetAddon(addonName)
local locales = LibStub("AceLocale-3.0"):GetLocale("AscensionProgressDataBars")

-- Configuration frame setup
function CreateConfigFrame()
    local UIContext = addonTable.UIContext
    if not UIContext then return end

    local colors = ascensionBars.colors
    local files = ascensionBars.files
    local menuStyle = ascensionBars.menuStyle
    if ascensionBars.configFrame then return end

    ascensionBars.configFrame = CreateFrame("Frame", "AscensionBarsConfigFrame", _G.UIParent, "BackdropTemplate")
    local configFrame = ascensionBars.configFrame
    configFrame:SetFrameStrata("DIALOG")
    configFrame:SetSize(ascensionBars.normalWidth or 860, ascensionBars.normalHeight or 500)
    configFrame:SetPoint("CENTER")
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)

    configFrame:SetResizable(true)
    configFrame:SetResizeBounds(400, 300)
    
    configFrame:SetBackdrop({
        bgFile = files.bgFile,
        edgeFile = files.edgeFile,
        edgeSize = 3,
        insets = { left = 2, right = 2, top = 3, bottom = 3 }
    })
    configFrame:SetBackdropColor(unpack(colors.mainBackground))
    configFrame:SetBackdropBorderColor(unpack(colors.sidebarAccent))

    configFrame:SetPropagateKeyboardInput(true)
    configFrame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput(false)
            self:Hide()
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)
    tinsert(UISpecialFrames, "AscensionBarsConfigFrame")

    local title = configFrame:CreateFontString(nil, "OVERLAY", menuStyle.headerFont)
    title:SetPoint("TOPLEFT", menuStyle.titleLeft, menuStyle.titleTop)
    title:SetText(locales["ADDON_NAME"])
    title:SetTextColor(unpack(colors.gold)) -- #FFCC33

    local closeButton = CreateFrame("Button", nil, configFrame, "BackdropTemplate")
    closeButton:SetSize(24, 24)
    closeButton:SetPoint("TOPRIGHT", configFrame, "TOPRIGHT", -6, -6)
    closeButton:SetBackdrop({
        bgFile   = files.bgFile,
        edgeFile = files.edgeFile,
        edgeSize = 1,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    closeButton:SetBackdropColor(unpack(colors.surfaceLight))
    closeButton:SetBackdropBorderColor(unpack(colors.blackDetail))

    local xLine1 = closeButton:CreateTexture(nil, "OVERLAY")
    xLine1:SetTexture(ascensionBars.constants.TEXTURE_BAR)
    xLine1:SetSize(13, 2)
    xLine1:SetPoint("CENTER", 0, 0)
    xLine1:SetRotation(math.rad(45))
    xLine1:SetVertexColor(unpack(colors.textLight))

    local xLine2 = closeButton:CreateTexture(nil, "OVERLAY")
    xLine2:SetTexture(ascensionBars.constants.TEXTURE_BAR)
    xLine2:SetSize(13, 2)
    xLine2:SetPoint("CENTER", 0, 0)
    xLine2:SetRotation(math.rad(-45))
    xLine2:SetVertexColor(unpack(colors.textLight))

    closeButton.xLine1 = xLine1
    closeButton.xLine2 = xLine2

    local function setCloseXColor(r, g, b)
        xLine1:SetVertexColor(r, g, b, 1)
        xLine2:SetVertexColor(r, g, b, 1)
    end

    closeButton:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.60, 0.10, 0.10, 1)
        self:SetBackdropBorderColor(1, 0.35, 0.35, 1)
        setCloseXColor(1, 0.4, 0.4)
    end)
    closeButton:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(colors.surfaceLight))
        self:SetBackdropBorderColor(unpack(colors.blackDetail))
        setCloseXColor(unpack(colors.textLight))
    end)
    closeButton:SetScript("OnClick", function() configFrame:Hide() end)

    local resizeGrip = CreateFrame("Button", nil, configFrame)
    resizeGrip:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -6, 6)
    resizeGrip:SetSize(16, 16)
    resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    
    resizeGrip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then configFrame:StartSizing("BOTTOMRIGHT") end
    end)
    
    resizeGrip:SetScript("OnMouseUp", function()
        configFrame:StopMovingOrSizing()
        if ascensionBars and ascensionBars.configTabs and ascensionBars.configTabs.getActiveTab and ascensionBars.configTabs.selectTab then
            ascensionBars.configTabs.selectTab(ascensionBars.configTabs.getActiveTab())
        end
    end)

    local configModeCheck = UIContext:createCheckbox({
        parent = configFrame,
        text = locales["CONFIG_MODE"],
        tooltip = locales["CONFIG_MODE_DESC"],
        getter = function() return ascensionBars.state.isConfigMode end,
        setter = function(v)
            ascensionBars.state.isConfigMode = v
            ascensionBars:updateDisplay(true)
        end,
        xOffset = 6,
        yOffset = 6
    })
    configModeCheck:ClearAllPoints()
    configModeCheck:SetPoint("BOTTOMLEFT", configFrame, "BOTTOMLEFT", 6, 6)

    configFrame:SetScript("OnShow", function(self)
        configModeCheck:SetChecked(ascensionBars.state.isConfigMode)
    end)

    local tabNames = {
        locales["TAB_BARS_LAYOUT"],
        locales["TAB_CUSTOM_GRID"],
        locales["TAB_TEXT_LAYOUT"],
        locales["TAB_BEHAVIOR"],
        locales["TAB_COLORS"],
        locales["TAB_PARAGON_ALERTS"],
        locales["TAB_PROFILES"]
    }
    
    local buildFuncs = {
        function(panel) if addonTable.barsLayoutTab then addonTable.barsLayoutTab:build(panel) end end,
        function(panel) if addonTable.customGridTab then addonTable.customGridTab:build(panel) end end,
        function(panel) if addonTable.textLayoutTab then addonTable.textLayoutTab:build(panel) end end,
        function(panel) if addonTable.behaviorTab then addonTable.behaviorTab:build(panel) end end,
        function(panel) if addonTable.colorsTab then addonTable.colorsTab:build(panel) end end,
        function(panel) if addonTable.paragonAlertsTab then addonTable.paragonAlertsTab:build(panel) end end,
        function(panel) if addonTable.profilesTab then addonTable.profilesTab:build(panel) end end
    }

    ascensionBars.configTabs = UIContext:createTabbedInterface(configFrame, tabNames, buildFuncs, 1)
    configFrame:Hide()
end

-- UI refresh handler
function ascensionBars:refreshConfigUI()
    if not self.configFrame then
        CreateConfigFrame()
    end

    if self.configFrame then
        local wasShown = self.configFrame:IsShown()
        local currentTab = 1
        
        if self.configTabs and self.configTabs.getActiveTab then
            currentTab = self.configTabs.getActiveTab()
        end

        -- Reset current frame to apply changes
        self.configFrame:Hide()
        self.configFrame = nil
        self.configTabs = nil

        -- Re-initialize
        CreateConfigFrame()

        if wasShown then
            self.configFrame:Show()
            if self.configTabs and self.configTabs.selectTab then
                self.configTabs.selectTab(currentTab)
            end
        end
    end
end
