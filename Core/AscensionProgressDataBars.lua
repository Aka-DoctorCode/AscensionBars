-------------------------------------------------------------------------------
-- Project: AscensionProgressDataBars
-- Author: Aka-DoctorCode
-- File: AscensionProgressDataBars.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, addonTable = ...
local locales = _G.LibStub("AceLocale-3.0"):GetLocale("AscensionProgressDataBars")

local ascensionBars = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceConsole-3.0")

addonTable.main = ascensionBars

-------------------------------------------------------------------------------
-- UTILITIES
-------------------------------------------------------------------------------

function ascensionBars:getPlayerMaxLevel()
    if _G.GetMaxLevelForLatestExpansion then
        local maxLevel = _G.GetMaxLevelForLatestExpansion()
        if maxLevel then return maxLevel end
    end
    return 80
end

function ascensionBars:getClassColor()
    if not self.state then return { r = 1, g = 1, b = 1, a = 1 } end -- #FFFFFF

    if not self.state.cachedClassColor then
        local _, classFilename = _G.UnitClass("player")
        if classFilename and _G.C_ClassColor and _G.C_ClassColor.GetClassColor then
            local classColor = _G.C_ClassColor.GetClassColor(classFilename)
            if classColor then
                self.state.cachedClassColor = classColor
                return self.state.cachedClassColor
            end
        end
        self.state.cachedClassColor = { r = 1, g = 1, b = 1, a = 1 } -- #FFFFFF
    end
    return self.state.cachedClassColor
end

function ascensionBars:hideBlizzardFrames()
    local framesToHide = { _G["StatusTrackingBarManager"], _G["UIWidgetPowerBarContainerFrame"] }
    for _, frame in pairs(framesToHide) do
        if frame then
            frame:UnregisterAllEvents()
            frame:Hide()
            frame:SetAlpha(0)
            frame.Show = function() end
        end
    end
end

function ascensionBars:formatXP()
    local dt = addonTable.dataText
    if dt then return dt:combine(dt:formatExperience()) end
    return ""
end
-------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------

function ascensionBars:OnInitialize()
    local db = LibStub("AceDB-3.0"):New("AscensionProgressDataBarsDB", self.defaults, true)
    self.db = db

    self.db.RegisterCallback(self, "OnProfileChanged", "refreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied",  "refreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset",   "refreshConfig")

    local function migrateOldSettings()
        if not db or not db.profile then return end
        local p = db.profile
        if not p then return end

        p.textGroups       = nil
        p.usePerGroupSize  = nil
        p.usePerGroupColor = nil
        p.textLayoutMode   = nil
        p.textFollowBar    = nil

        if p.bars and type(p.bars) == "table" then
            for _, v in pairs(p.bars) do
                if v and type(v) == "table" then
                    v.textBlock = nil
                    v.textOrder = nil
                    v.textX     = nil
                    v.textY     = nil
                end
            end
        end
    end

    migrateOldSettings()

    self.state = {
        isConfigMode     = false,
        isHovering       = false,
        inCombat         = false,
        updatePending    = false,
        hoveredBarKey    = nil,
        legendHovered    = false,
        cachedClassColor = nil,
        lastXP           = 0,
        lastXPMax        = 0,
        lastHonor        = 0,
        lastReputation   = {},
        lastAzeriteXP    = 0,
        lastHouseFavor   = {},
    }

    local defaultFont = [[Fonts\FRIZQT__.TTF]]
    self.fontToUse = defaultFont
    if _G.GameFontNormal and _G.GameFontNormal.GetFont then
        local fontPath = _G.GameFontNormal:GetFont()
        if fontPath then
            self.fontToUse = fontPath
        end
    end

    local function toggleConfig()
        self:toggleConfig()
    end
    self:RegisterChatCommand("apb", toggleConfig)

    self:createFrames()

    local AscensionUI = LibStub("AscensionSuit-UI", true)
    if not AscensionUI then
        error("AscensionProgressDataBars requires AscensionSuit-UI library from AscensionSuit addon.")
        return
    end

    local UIContext = AscensionUI:CreateContext()
    addonTable.UIContext = UIContext
    addonTable.layoutModel = UIContext.layoutModel
    addonTable.layoutFactory = UIContext
    
    self.colors = UIContext.styles.colors
    self.files = UIContext.styles.files
    
    self.menuStyle = {}
    for k, v in pairs(UIContext.styles.dimensions) do self.menuStyle[k] = v end
    if UIContext.styles.fonts then
        self.menuStyle.headerFont = UIContext.styles.fonts.header
        self.menuStyle.labelFont = UIContext.styles.fonts.label
        self.menuStyle.descFont = UIContext.styles.fonts.desc
    end

    -- Register Blizzard Interface Options using the shared library helper
    if AscensionUI.Integration and AscensionUI.Integration.registerBlizzardPanel then
        AscensionUI.Integration:registerBlizzardPanel(
            "AscensionProgressDataBars",
            locales["ADDON_NAME"] or "Ascension Progress Data Bar",
            function() self:toggleConfig() end
        )
    end
end

function ascensionBars:OnEnable()
    self.state.isConfigMode  = false
    self.state.isHovering    = false
    self.state.inCombat      = false
    self.state.cachedClassColor = nil

    if self.coreEvents and self.coreEvents.Enable then
        self.coreEvents:Enable()
    end

    if addonTable.dataText and addonTable.dataText.initBarText then
        for _, bar in pairs(self.activeBars or {}) do
            if bar then addonTable.dataText:initBarText(bar) end
        end
    end

    if self.refreshHousingFavor  then self:refreshHousingFavor()  end
    if self.scanParagonRewards   then self:scanParagonRewards()    end
    self:hideBlizzardFrames()
    self:updateDisplay(true)
end



function ascensionBars:OnDisable()
    self:cleanupTextures()
    for _, barObj in pairs(self.activeBars or {}) do
        if barObj and barObj.bar then barObj.bar:Hide() end
    end
    if self.textHolder then self.textHolder:Hide() end
end

function ascensionBars:refreshConfig()
    -- Ensure all dynamic bars (e.g. extra reputations) from the new profile exist
    if self.db and self.db.profile and self.db.profile.bars then
        for k, _ in pairs(self.db.profile.bars) do
            if string.match(k, "^Rep_%d+$") then
                self:createDynamicBar(k)
            end
        end
    end

    -- Refresh the configuration UI if it's currently loaded
    if self.refreshConfigUI then
        self:refreshConfigUI()
    end

    -- Update the actual bars on screen
    self:updateDisplay(true)
end

function ascensionBars:toggleConfig()
    if not self.configFrame then
        self:refreshConfigUI()
    end
    if self.configFrame then
        local isOpening = not self.configFrame:IsShown()
        self.configFrame:SetShown(isOpening)
        if not isOpening then
            self.state.isConfigMode = false
            self:updateDisplay(true)
        end
    end
end
