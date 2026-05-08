-------------------------------------------------------------------------------
-- Project: AscensionProgressDataBars
-- Author: Aka-DoctorCode
-- File: Colors.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, addonTable = ...

local ascensionBars = addonTable.main or LibStub("AceAddon-3.0"):GetAddon(addonName)

local locales = LibStub("AceLocale-3.0"):GetLocale("AscensionProgressDataBars")
local colors = setmetatable({}, { __index = function(t, k) return ascensionBars.colors and ascensionBars.colors[k] end })
local menuStyle = setmetatable({}, { __index = function(t, k) return ascensionBars.menuStyle and ascensionBars.menuStyle[k] end })


-- Object-Oriented module for the Colors Tab
addonTable.colorsTab = {}
local colorsTab = addonTable.colorsTab

function colorsTab:build(panel)
    if not panel or not panel.content then return end
    
    addonTable.configUtils:cleanupContent(panel.content)
    
    local content = panel.content
    local profile = ascensionBars.db.profile
    if not profile then return end

    -- UX IMPROVEMENT: 2-Column Layout Calculations
    local defaultAvailableSpace = (ascensionBars.normalWidth or 750) - (menuStyle.sidebarWidth or 150) - 30
    local colGap = 15
    local colWidth = (defaultAvailableSpace - colGap) / 2

    local col1X = 10
    local col2X = 10 + colWidth + colGap
    local startY = -15
    
    -- Independent Layout Models for the 2 columns
    local col1Layout = addonTable.layoutModel:new(nil, content, startY)
    local col2Layout = addonTable.layoutModel:new(nil, content, startY)

    -- Helper to safely trigger layout reflows when checking boxes
    local function triggerLayoutUpdate()
        if panel.updateLayout then
            _G.C_Timer.After(0.01, function() panel:updateLayout() end)
        end
    end

    ---------------------------------------------------------------------------
    -- COLUMN 1: Experience, House Favor, Honor & Azerite
    ---------------------------------------------------------------------------
    local inner1X = col1X + 5
    local picker1X = inner1X + 5
    
    
    -- 1. Experience Card
    col1Layout:beginSection(col1X, colWidth)
    col1Layout:label("ExperienceHeader", locales["EXPERIENCE"], inner1X, colors.gold)
    
    col1Layout:checkbox("UseClassColorXPCheckbox", locales["USE_CLASS_COLOR"], locales["USE_CLASS_COLOR_DESC"],
        function() return profile.useClassColorXP end,
        function(v)
            profile.useClassColorXP = v
            ascensionBars:updateDisplay()
            triggerLayoutUpdate()
        end, inner1X - 6)
        
    if not profile.useClassColorXP then
        col1Layout:colorPicker("CustomXPColorPicker", locales["CUSTOM_XP_COLOR"], nil,
            function()
                local c = profile.xpBarColor
                return c.r, c.g, c.b, c.a
            end,
            function(r, g, b, a)
                if not profile.xpBarColor then profile.xpBarColor = {} end
                local c = profile.xpBarColor
                c.r = r; c.g = g; c.b = b; c.a = a
                ascensionBars:updateDisplay()
            end, picker1X, true)
    end
    
    col1Layout:checkbox("ShowRestedBarCheckbox", locales["SHOW_RESTED_BAR"], locales["SHOW_RESTED_BAR_DESC"],
        function() return profile.showRestedBar end,
        function(v)
            profile.showRestedBar = v
            ascensionBars:updateDisplay()
            triggerLayoutUpdate()
        end, inner1X - 6)
        
    if profile.showRestedBar then
        col1Layout:colorPicker("RestedColorPicker", locales["RESTED_COLOR"], nil,
            function()
                local c = profile.restedBarColor
                return c.r, c.g, c.b, c.a
            end,
            function(r, g, b, a)
                if not profile.restedBarColor then profile.restedBarColor = {} end
                local c = profile.restedBarColor
                c.r = r; c.g = g; c.b = b; c.a = a
                ascensionBars:updateDisplay()
            end, picker1X, true)
    end
    col1Layout.y = col1Layout.y - 12 -- Extra bottom padding to ensure card encapsulates content
    col1Layout:endSection()
    col1Layout.y = col1Layout.y - 15 -- Gap between cards

    -- 2. House Favor Card
    col1Layout:beginSection(col1X, colWidth)
    col1Layout:label("HouseFavorHeader", locales["HOUSE_FAVOR"], inner1X, colors.gold)
    col1Layout.y = col1Layout.y - 8
    
    col1Layout:colorPicker("HouseXPColorPicker", locales["HOUSE_XP_COLOR"], nil,
        function()
            local c = profile.houseXpColor
            if not c then return 0.9, 0.5, 0, 1 end -- #E68000
            return c.r, c.g, c.b, c.a
        end,
        function(r, g, b, a)
            if not profile.houseXpColor then profile.houseXpColor = {} end
            local c = profile.houseXpColor
            c.r = r; c.g = g; c.b = b; c.a = a
            ascensionBars:updateDisplay()
        end, picker1X, true)
        
    col1Layout.y = col1Layout.y - 12
    col1Layout:endSection()
    col1Layout.y = col1Layout.y - 15

    -- 3. Honor Card
    col1Layout:beginSection(col1X, colWidth)
    col1Layout:label("HonorHeader", locales["HONOR"], inner1X, colors.gold)
    col1Layout.y = col1Layout.y - 8
    
    col1Layout:colorPicker("HonorColorPicker", locales["HONOR_COLOR"], nil,
        function()
            local c = profile.honorColor
            if not c then return 0.8, 0.2, 0.2, 1 end -- #CC3333
            return c.r, c.g, c.b, c.a
        end,
        function(r, g, b, a)
            if not profile.honorColor then profile.honorColor = {} end
            local c = profile.honorColor
            c.r = r; c.g = g; c.b = b; c.a = a
            ascensionBars:updateDisplay()
        end, picker1X, true)
        
    col1Layout.y = col1Layout.y - 12
    col1Layout:endSection()
    col1Layout.y = col1Layout.y - 15

    -- 4. Azerite Card
    col1Layout:beginSection(col1X, colWidth)
    col1Layout:label("AzeriteHeader", locales["AZERITE"], inner1X, colors.gold)
    col1Layout.y = col1Layout.y - 8
    
    col1Layout:colorPicker("AzeriteColorPicker", locales["AZERITE_COLOR"], nil,
        function()
            local c = profile.azeriteColor
            if not c then return 0.9, 0.8, 0.5, 1 end -- #E6CC80
            return c.r, c.g, c.b, c.a
        end,
        function(r, g, b, a)
            if not profile.azeriteColor then profile.azeriteColor = {} end
            local c = profile.azeriteColor
            c.r = r; c.g = g; c.b = b; c.a = a
            ascensionBars:updateDisplay()
        end, picker1X, true)
        
    col1Layout.y = col1Layout.y - 12
    col1Layout:endSection()

    ---------------------------------------------------------------------------
    -- COLUMN 2: Reputation (Long Vertical Card to balance the layout)
    ---------------------------------------------------------------------------
    local inner2X = col2X + 5
    local picker2X = inner2X + 6
    
    col2Layout:beginSection(col2X, colWidth)
    col2Layout:label("ReputationHeader", locales["REPUTATION"], inner2X, colors.gold)
    
    col2Layout:checkbox("UseCustomFactionColorsCheckbox", locales["USE_CUSTOM_FACTION_COLORS"] or "Use Custom Faction Colors", locales["USE_CUSTOM_FACTION_COLORS_DESC"],
        function() return profile.useCustomFactionColors end,
        function(v)
            profile.useCustomFactionColors = v
            ascensionBars:updateDisplay()
        end, inner2X - 6)

    col2Layout:checkbox("UseReactionColorsCheckbox", locales["USE_REACTION_COLORS"], locales["USE_REACTION_COLORS_DESC"],
        function() return profile.useReactionColorRep end,
        function(v)
            profile.useReactionColorRep = v
            ascensionBars:updateDisplay()
            triggerLayoutUpdate()
        end, inner2X - 6)
        
    if not profile.useReactionColorRep then
        col2Layout:colorPicker("CustomRepColorPicker", locales["CUSTOM_REP_COLOR"], nil,
            function()
                local c = profile.repBarColor
                return c.r, c.g, c.b, c.a
            end,
            function(r, g, b, a)
                if not profile.repBarColor then profile.repBarColor = {} end
                local c = profile.repBarColor
                c.r = r; c.g = g; c.b = b; c.a = a
                ascensionBars:updateDisplay()
            end, picker2X, true)
    else
        local standingLabels = {
            locales["HATED"], locales["HOSTILE"], locales["UNFRIENDLY"], locales["NEUTRAL"],
            locales["FRIENDLY"], locales["HONORED"], locales["REVERED"], locales["EXALTED"],
            locales["PARAGON"], locales["MAXED"], locales["RENOWN"]
        }
        -- Simple straight vertical list for standings
        for i = 1, 11 do
            col2Layout:colorPicker(
                "RepStandingColorPicker_" .. i,
                standingLabels[i] or string.format(locales["RANK_NUM"], i), nil,
                function()
                    local c = profile.repColors[i] or {r = 1, g = 1, b = 1, a = 1} -- #FFFFFF
                    return c.r, c.g, c.b, c.a
                end,
                function(r, g, b, a)
                    profile.repColors[i] = {r = r, g = g, b = b, a = a}
                    ascensionBars:updateDisplay()
                end,
                picker2X, true)
        end
    end
    col2Layout.y = col2Layout.y - 12 -- Extra bottom padding
    col2Layout:endSection()

    -- 5. Active Faction Colors (Dynamic section)
    if profile.useCustomFactionColors then
        local activeFactions = {}
        
        -- 1. Check watched faction
        if _G.C_Reputation and _G.C_Reputation.GetWatchedFactionData then
            local wd = _G.C_Reputation.GetWatchedFactionData()
            if wd and wd.factionID then
                table.insert(activeFactions, { id = wd.factionID, name = wd.name or locales["REPUTATION"] })
            end
        end
        
        -- 2. Check custom bars
        for k, v in pairs(profile.bars) do
            local fID = tonumber(string.match(k, "^Rep_(%d+)$"))
            if fID and v.enabled then
                -- Avoid duplicates
                local exists = false
                for _, f in ipairs(activeFactions) do if f.id == fID then exists = true break end end
                if not exists then
                    local name = v.name or ("Faction " .. fID)
                    table.insert(activeFactions, { id = fID, name = name })
                end
            end
        end

        if #activeFactions > 0 then
            col2Layout.y = col2Layout.y - 15
            col2Layout:beginSection(col2X, colWidth)
            col2Layout:label("ActiveFactionsHeader", locales["ACTIVE_FACTION_COLORS"] or "Active Faction Colors", inner2X, colors.gold)
            col2Layout.y = col2Layout.y - 8

            for _, f in ipairs(activeFactions) do
                col2Layout:colorPicker("FactionColorPicker_" .. f.id, f.name, nil,
                    function()
                        if not profile.factionColors then profile.factionColors = {} end
                        local c = profile.factionColors[f.id] 
                                  or (ascensionBars.constants.FACTION_COLORS and ascensionBars.constants.FACTION_COLORS[f.id])
                                  or profile.repBarColor
                        if not c then return 1, 1, 1, 1 end
                        return c.r, c.g, c.b, (c.a or 1)
                    end,
                    function(r, g, b, a)
                        if not profile.factionColors then profile.factionColors = {} end
                        profile.factionColors[f.id] = { r = r, g = g, b = b, a = a }
                        ascensionBars:updateDisplay()
                    end, picker2X, true)
            end
            
            col2Layout.y = col2Layout.y - 12
            col2Layout:endSection()
        end
    end

    -- Calculate the lowest Y point between the 2 columns to set the canvas height
    local maxBottomY = math.min(col1Layout.y, col2Layout.y)
    content:SetHeight(math.abs(maxBottomY) + 20)
end
