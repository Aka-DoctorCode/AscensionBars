-------------------------------------------------------------------------------
-- Project: AscensionProgressDataBars
-- Author: Aka-DoctorCode
-- File: Behavior.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, addonTable = ...

local ascensionBars = addonTable.main or LibStub("AceAddon-3.0"):GetAddon(addonName)

local locales = LibStub("AceLocale-3.0"):GetLocale("AscensionProgressDataBars")

-- Object-Oriented module for the Behavior Tab
addonTable.behaviorTab = {}
local behaviorTab = addonTable.behaviorTab

function behaviorTab:build(panel)
    if not panel or not panel.content then return end
    
    addonTable.configUtils:cleanupContent(panel.content)
    
    local content = panel.content
    local profile = ascensionBars.db.profile
    if not profile then return end

    local layout = addonTable.layoutModel:new(nil, content, -15)
    
    -- Auto Hide Logic Section
    layout:header("AutoHideLogicHeader", locales["AUTO_HIDE_LOGIC"])
    
    local cbMouseover = layout:checkbox("ShowOnMouseoverCheckbox", locales["SHOW_ON_MOUSEOVER"], nil,
        function() return profile.showOnMouseover end,
        function(v)
            profile.showOnMouseover = v
            ascensionBars:updateDisplay()
            if panel.updateLayout then panel:updateLayout() end
        end)
    addonTable.configUtils:setTooltip(cbMouseover, locales["SHOW_ON_MOUSEOVER_DESC"] or "Show bars when mouse is over them")
        
    local cbCombat = layout:checkbox("HideInCombatCheckbox", locales["HIDE_IN_COMBAT"], nil,
        function() return profile.hideInCombat end,
        function(v)
            profile.hideInCombat = v
            ascensionBars:updateDisplay()
            if panel.updateLayout then panel:updateLayout() end
        end)
    addonTable.configUtils:setTooltip(cbCombat, locales["HIDE_IN_COMBAT_DESC"] or "Hide bars when in combat")
        
    local cbMaxLevel = layout:checkbox("HideAtMaxLevelCheckbox", locales["HIDE_AT_MAX_LEVEL"], nil,
        function() return profile.hideAtMaxLevel end,
        function(v)
            profile.hideAtMaxLevel = v
            ascensionBars:updateDisplay()
        end)
    addonTable.configUtils:setTooltip(cbMaxLevel, locales["HIDE_AT_MAX_LEVEL_DESC"] or "Hide bars at max level")

    if profile.showOnMouseover or profile.hideInCombat then
        layout.y = layout.y - 10
        layout:label("HiddenStateFeedback", locales["BARS_HIDDEN_FEEDBACK"] or "Bars hidden - hover or exit combat to show", 15, {1, 0.5, 0, 1})
        layout.y = layout.y - 10
    end

    -- Data Display Section
    layout:header("DataDisplayHeader", locales["DATA_DISPLAY"])

    local cbPercentage = layout:checkbox("ShowPercentageCheckbox", locales["SHOW_PERCENTAGE"], nil,
        function() return profile.showPercentage end,
        function(v)
            profile.showPercentage = v
            ascensionBars:updateDisplay()
        end)
    addonTable.configUtils:setTooltip(cbPercentage, locales["SHOW_PERCENTAGE_DESC"] or "Show percentage text on bars")
        
    local cbAbsolute = layout:checkbox("ShowAbsoluteValuesCheckbox", locales["SHOW_ABSOLUTE_VALUES"], nil,
        function() return profile.showAbsoluteValues end,
        function(v)
            profile.showAbsoluteValues = v
            ascensionBars:updateDisplay()
        end)
    addonTable.configUtils:setTooltip(cbAbsolute, locales["SHOW_ABSOLUTE_VALUES_DESC"] or "Show absolute values text on bars")

    local cbCompact = layout:checkbox("UseCompactFormatToggle", locales["USE_COMPACT_FORMAT"], nil,
        function() return profile.useCompactFormat end,
        function(v)
            profile.useCompactFormat = v; ascensionBars:updateDisplay()
        end)
    addonTable.configUtils:setTooltip(cbCompact, locales["USE_COMPACT_FORMAT_DESC"] or "Use compact number format")
        
    local cbSpark = layout:checkbox("ShowSparkCheckbox", locales["SHOW_SPARK"], nil,
        function() return profile.sparkEnabled end,
        function(v)
            profile.sparkEnabled = v
            ascensionBars:updateDisplay()
        end)
    addonTable.configUtils:setTooltip(cbSpark, locales["SHOW_SPARK_DESC"] or "Show spark on progress bar")

    content:SetHeight(math.abs(layout.y) + 20)
end
