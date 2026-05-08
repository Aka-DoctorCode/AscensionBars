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

    -- Visual Feedback for Auto-Hide
    if profile.showOnMouseover or profile.hideInCombat then
        local feedbackText = (profile.showOnMouseover and profile.hideInCombat) 
            and (locales["BARS_HIDDEN_COMBAT_HOVER"] or "Bars hidden - Hover to show (Hidden in Combat)")
            or (profile.showOnMouseover and (locales["BARS_HIDDEN_HOVER"] or "Bars hidden - Hover to show"))
            or (locales["BARS_HIDDEN_COMBAT"] or "Bars hidden in Combat")
            
        layout:label("AutoHideFeedback", feedbackText, nil, colors.gold)
    end
    
    layout:checkbox("ShowOnMouseoverCheckbox", locales["SHOW_ON_MOUSEOVER"], locales["SHOW_ON_MOUSEOVER_DESC"],
        function() return profile.showOnMouseover end,
        function(v)
            profile.showOnMouseover = v
            ascensionBars:updateDisplay()
        end)
        
    layout:checkbox("HideInCombatCheckbox", locales["HIDE_IN_COMBAT"], locales["HIDE_IN_COMBAT_DESC"],
        function() return profile.hideInCombat end,
        function(v)
            profile.hideInCombat = v
            ascensionBars:updateDisplay()
        end)
        
    layout:checkbox("HideAtMaxLevelCheckbox", locales["HIDE_AT_MAX_LEVEL"], locales["HIDE_AT_MAX_LEVEL_DESC"],
        function() return profile.hideAtMaxLevel end,
        function(v)
            profile.hideAtMaxLevel = v
            ascensionBars:updateDisplay()
        end)

    -- Data Display Section
    layout:header("DataDisplayHeader", locales["DATA_DISPLAY"])

    layout:checkbox("ShowPercentageCheckbox", locales["SHOW_PERCENTAGE"], locales["SHOW_PERCENTAGE_DESC"],
        function() return profile.showPercentage end,
        function(v)
            profile.showPercentage = v
            ascensionBars:updateDisplay()
        end)
        
    layout:checkbox("ShowAbsoluteValuesCheckbox", locales["SHOW_ABSOLUTE_VALUES"], locales["SHOW_ABSOLUTE_VALUES_DESC"],
        function() return profile.showAbsoluteValues end,
        function(v)
            profile.showAbsoluteValues = v
            ascensionBars:updateDisplay()
        end)

    layout:checkbox("UseCompactFormatToggle", locales["USE_COMPACT_FORMAT"], locales["USE_COMPACT_FORMAT_DESC"],
        function() return profile.useCompactFormat end,
        function(v)
            profile.useCompactFormat = v; ascensionBars:updateDisplay()
        end)
        
    layout:checkbox("ShowSparkCheckbox", locales["SHOW_SPARK"], locales["SHOW_SPARK_DESC"],
        function() return profile.sparkEnabled end,
        function(v)
            profile.sparkEnabled = v
            ascensionBars:updateDisplay()
        end)

    content:SetHeight(math.abs(layout.y) + 20)
end
