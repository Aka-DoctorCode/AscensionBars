-------------------------------------------------------------------------------
-- Project: AscensionProgressDataBars
-- Author: Aka-DoctorCode
-- File: Constants.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, _ = ...
local ascensionBars = LibStub("AceAddon-3.0"):GetAddon(addonName)

-------------------------------------------------------------------------------
-- Default profile
-------------------------------------------------------------------------------

ascensionBars.defaults = {
    profile = {
        -- -------------------------------------------------------------------------------
        -- GENERAL APPEARANCE
        -- -------------------------------------------------------------------------------
        globalBarHeight = 6,          -- Default height of bars (if not per-block)
        barGap = 2,                   -- Gap between bars (global)
        backgroundAlpha = 0.8,        -- Alpha for bar background texture
        barAnchor = "TOP",            -- Which block appears first (TOP or BOTTOM)
        sparkEnabled = true,          -- Show spark at progress edge

        -- -------------------------------------------------------------------------------
        -- TEXT & FONT
        -- -------------------------------------------------------------------------------
        textSize = 14,                -- Global text size
        textColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }, -- #FFFFFF
        fontOutline = "OUTLINE",      -- Font outline style
        textYOffset = -12,            -- Global text Y offset relative to bar
        textGap = 13.5,               -- Legacy, kept for compatibility

        -- -------------------------------------------------------------------------------
        -- LAYOUT OFFSETS & GAPS (Global)
        -- -------------------------------------------------------------------------------
        yOffset = -2,                 -- Global Y offset for bars (negative for TOP, positive for BOTTOM)

        -- -------------------------------------------------------------------------------
        -- BEHAVIOR SETTINGS
        -- -------------------------------------------------------------------------------
        hideInCombat = false,         -- Hide bars during combat
        hideAtMaxLevel = true,        -- Hide XP bar when at max level
        showOnMouseover = false,      -- Only show bars when mouse is over them
        focusFadeEnabled = true,      -- Fade non‑focused bars when hovering
        focusDimAlpha = 0.4,          -- Alpha for non‑focused bars
        blockTextMode = "FOCUS",      -- "FOCUS" | "GRID" | "NONE"
        useCompactFormat = false,     -- Show compact numbers (e.g., 1.2k)
        useDecimals = true,           -- Show one decimal place in percentages
        useCustomFactionColors = true, -- Use specific colors for certain reputation factions
        factionColors = {},            -- User overrides for faction colors [id] = {r,g,b,a}

        -- -------------------------------------------------------------------------------
        -- PER‑BLOCK CUSTOMIZATION
        -- -------------------------------------------------------------------------------
        usePerBlockHeights = false,   -- Enable separate height per block
        blockHeights = nil,           -- Will be filled at runtime
        usePerBlockOffsets = nil,     -- Not yet used
        usePerBlockGaps = nil,        -- Not yet used
        topOffset = nil,
        bottomOffset = nil,
        topBarGap = nil,
        bottomBarGap = nil,

        -- -------------------------------------------------------------------------------
        -- DISPLAY MODES (Percentage, Absolute)
        -- -------------------------------------------------------------------------------
        showPercentage = true,        -- Show percentage in text
        showAbsoluteValues = true,    -- Show absolute current/max values

        -- -------------------------------------------------------------------------------
        -- ADVANCED CUSTOM GRID
        -- -------------------------------------------------------------------------------
        customGridMasterEnabled = false,   -- Master toggle for custom grid feature
        customGrids = {
            TOP = {
                enabled = false,
                preset = "CUSTOM",
                numRows = 1,
                colsPerRow = { 1 },
                assignments = { [1] = { [1] = "none" } }
            },
            BOTTOM = {
                enabled = false,
                preset = "CUSTOM",
                numRows = 1,
                colsPerRow = { 1 },
                assignments = { [1] = { [1] = "none" } }
            }
        },
        dynamicGridGap = 2,           -- Gap between grid cells

        -- -------------------------------------------------------------------------------
        -- LEGEND & CAROUSEL (Event display)
        -- -------------------------------------------------------------------------------
        legendEnabled = false,
        legendX = -20,
        legendY = 0,
        legendPoint = "RIGHT",
        legendRelativePoint = "RIGHT",
        legendBgAlpha = 0.4,
        legendTextSize = 12,
        legendFontOutline = "OUTLINE",
        carouselEnabled = false,
        carouselBatchDelay = 2,
        carouselRotateInterval = 5,
        carouselXOffset = 0,
        carouselYOffset = -50,
        carouselBgAlpha = 0.4,

        -- -------------------------------------------------------------------------------
        -- BAR SPECIFIC CONFIGURATION (Default settings for built‑in bars)
        -- -------------------------------------------------------------------------------
        bars = {
            ["XP"] = {
                enabled = true,
                block = "TOP",
                order = 1,
                freeX = 0, freeY = 0, freeWidth = 500, freeHeight = 6,
                useCustomFont = false, customFontPath = nil,
                useCustomTextSize = false, customTextSize = 14,
                useCustomTextColor = false,
                customTextColor = { r = 1, g = 1, b = 1, a = 1 } -- #FFFFFF
            },
            ["Rep"] = {
                enabled = true,
                block = "TOP",
                order = 2,
                freeX = 0, freeY = -20, freeWidth = 500, freeHeight = 6,
                useCustomFont = false, customFontPath = nil,
                useCustomTextSize = false, customTextSize = 14,
                useCustomTextColor = false,
                customTextColor = { r = 1, g = 1, b = 1, a = 1 } -- #FFFFFF
            },
            ["Honor"] = {
                enabled = false,
                block = "BOTTOM",
                order = 1,
                freeX = 0, freeY = -40, freeWidth = 500, freeHeight = 6,
                useCustomFont = false, customFontPath = nil,
                useCustomTextSize = false, customTextSize = 14,
                useCustomTextColor = false,
                customTextColor = { r = 1, g = 1, b = 1, a = 1 } -- #FFFFFF
            },
            ["HouseXp"] = {
                enabled = false,
                block = "BOTTOM",
                order = 2,
                freeX = 0, freeY = -60, freeWidth = 500, freeHeight = 6,
                useCustomFont = false, customFontPath = nil,
                useCustomTextSize = false, customTextSize = 14,
                useCustomTextColor = false,
                customTextColor = { r = 1, g = 1, b = 1, a = 1 } -- #FFFFFF
            },
            ["Azerite"] = {
                enabled = false,
                block = "FREE",
                order = 1,
                freeX = 0, freeY = -80, freeWidth = 500, freeHeight = 6,
                useCustomFont = false, customFontPath = nil,
                useCustomTextSize = false, customTextSize = 14,
                useCustomTextColor = false,
                customTextColor = { r = 1, g = 1, b = 1, a = 1 } -- #FFFFFF
            },
        },

        -- -------------------------------------------------------------------------------
        -- XP BAR COLORS
        -- -------------------------------------------------------------------------------
        showRestedBar = true,
        useClassColorXP = true,       -- Use class color for XP bar when available
        xpBarColor = { r = 0.0, g = 0.4, b = 0.9, a = 1.0 }, -- #0066E6
        restedBarColor = { r = 0.6, g = 0.4, b = 0.8, a = 1.0 }, -- #9966CC

        -- -------------------------------------------------------------------------------
        -- REPUTATION BAR
        -- -------------------------------------------------------------------------------
        useReactionColorRep = true,   -- Color by standing (Hated → Exalted)
        repBarColor = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 }, -- #00FF00
        repColors = {
            [1] = { r = 0.8, g = 0.133, b = 0.133, a = 1.0 }, -- #CC2222 (Hated)
            [2] = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 },     -- #FF0000 (Hostile)
            [3] = { r = 0.933, g = 0.4, b = 0.133, a = 1.0 }, -- #EE6622 (Unfriendly)
            [4] = { r = 1.0, g = 1.0, b = 0.0, a = 1.0 },     -- #FFFF00 (Neutral)
            [5] = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 },     -- #00FF00 (Friendly)
            [6] = { r = 0.0, g = 1.0, b = 0.533, a = 1.0 },   -- #00FF88 (Honored)
            [7] = { r = 0.0, g = 1.0, b = 0.8, a = 1.0 },     -- #00FFCC (Revered)
            [8] = { r = 0.0, g = 1.0, b = 1.0, a = 1.0 },     -- #00FFFF (Exalted)
            [9] = { r = 0.858, g = 0.733, b = 0.008, a = 1.0 },-- #DBBA02 (Renown 1)
            [10] = { r = 0.639, g = 0.208, b = 0.933, a = 1.0 },-- #A335EE (Renown 2)
            [11] = { r = 0.255, g = 0.412, b = 0.882, a = 1.0 },-- #4169E1 (Renown 3)
        },

        -- -------------------------------------------------------------------------------
        -- HONOR BAR
        -- -------------------------------------------------------------------------------
        honorBarEnabled = false,
        honorColor = { r = 0.8, g = 0.2, b = 0.2, a = 1.0 }, -- #CC3333

        -- -------------------------------------------------------------------------------
        -- AZERITE BAR
        -- -------------------------------------------------------------------------------
        azeriteBarEnabled = false,
        azeriteColor = { r = 0.9, g = 0.8, b = 0.5, a = 1.0 }, -- #E6CC7F

        -- -------------------------------------------------------------------------------
        -- HOUSE FAVOR BAR
        -- -------------------------------------------------------------------------------
        houseXpBarEnabled = false,
        houseXpColor = { r = 0.9, g = 0.5, b = 0.0, a = 1.0 }, -- #E68000
        houseRewardTextSize = 18,
        houseRewardXOffset = 0,
        houseRewardTextYOffset = -60,
        houseRewardTextColor = { r = 1, g = 0.5, b = 0.1, a = 1.0 }, -- #FF801A

        -- -------------------------------------------------------------------------------
        -- PARAGON ALERTS
        -- -------------------------------------------------------------------------------
        paragonTextSize = 18,
        paragonXOffset = 0,
        paragonYOffset = -100,
        splitParagonText = false,      -- Show each faction on its own line
        paragonPendingColor = { r = 0, g = 1, b = 0, a = 1.0 }, -- #00FF00

        -- -------------------------------------------------------------------------------
        -- DATA CACHES (runtime)
        -- -------------------------------------------------------------------------------
        housingCache = {
            lastTrackedGuid = "",
            houses = {},
        },
    },
    global = {
        paragonRewards = {},
    }
}

-------------------------------------------------------------------------------
-- Constants for internal use
-------------------------------------------------------------------------------

ascensionBars.constants = {
    TEXTURE_BAR = "Interface\\Buttons\\WHITE8X8",
    TEXTURE_SPARK = "Interface\\CastingBar\\UI-CastingBar-Spark",
    UPDATE_THROTTLE = 1,           -- Seconds between forced updates
    DEFAULT_GAP = 30,
    MIN_BAR_HEIGHT = 1,
    MAX_BAR_HEIGHT = 50,
    MIN_TEXT_WIDTH = 100,
    MIN_TEXT_SIZE = 8,
    MAX_TEXT_SIZE = 24,
}

-------------------------------------------------------------------------------
-- UI State Management variables
-------------------------------------------------------------------------------

ascensionBars.configFrame = nil
ascensionBars.isMinimized = false
ascensionBars.normalWidth = 1000
ascensionBars.normalHeight = 500
ascensionBars.activeTab = 1
ascensionBars.tabs = {}
ascensionBars.panels = {}

-------------------------------------------------------------------------------
-- FACTION SPECIFIC COLORS
-------------------------------------------------------------------------------

local function hexToRGB(hex)
    local r = tonumber(hex:sub(2,3), 16) / 255
    local g = tonumber(hex:sub(4,5), 16) / 255
    local b = tonumber(hex:sub(6,7), 16) / 255
    return { r = r, g = g, b = b, a = 1 }
end

local rawFactionColors = {
    -- Classic / Vanilla
    [469] = "#001289", 
    [529] = "#F0F0F0", 
    [87] = "#8A0303", 
    [21] = "#ADD8E6", 
    [910] = "#CD7F32",
    [609] = "#228B23", 
    [909] = "#800081", 
    [69] = "#4B0083", 
    [1447] = "#00CED2", 
    [577] = "#F8F8F9",
    [729] = "#F0F8FD", 
    [369] = "#D2B48C", 
    [92] = "#C2B281", 
    [54] = "#E6F5EC", 
    [66] = "#660101",
    [749] = "#00BFEF", 
    [47] = "#8A151B", 
    [93] = "#C2B282", 
    [76] = "#8C1617", 
    [470] = "#A0522E",
    [349] = "#2C2C2C", 
    [890] = "#1A2B5C", 
    [169] = "#C2A45D", 
    [730] = "#B0C4DE", 
    [72] = "#0033A1",
    [510] = "#4A5D23", 
    [509] = "#DAA526", 
    [59] = "#4A4A4B", 
    [81] = "#654321", 
    [576] = "#8B4514",
    [68] = "#660066", 
    [889] = "#8A0707", 
    [589] = "#B0E0E6",
    -- The Burning Crusade
    [1012] = "#556B30", 
    [942] = "#32CD33", 
    [946] = "#00008B", 
    [989] = "#DAA521", 
    [978] = "#8F5E4D",
    [1011] = "#8B7356", 
    [1015] = "#483D8C", 
    [1038] = "#DA70D6", 
    [1077] = "#FFA501", 
    [911] = "#B20000",
    [970] = "#7FFFD5", 
    [932] = "#FFD701", 
    [933] = "#EE82EE", 
    [930] = "#990099", 
    [941] = "#CD8540",
    [990] = "#F0E68D", 
    [934] = "#DC143D", 
    [935] = "#E6E6FB", 
    [967] = "#9932CD", 
    [947] = "#8B0001",
    [922] = "#708091",
    -- Wrath of the Lich King
    [1037] = "#2B4F82", 
    [1106] = "#E8E8E8", 
    [1068] = "#F5F5DC", 
    [1104] = "#D2691E", 
    [1052] = "#8B2526",
    [1090] = "#8A2BE3", 
    [1098] = "#2F4F50", 
    [1156] = "#69696A", 
    [1126] = "#ADD8E7", 
    [1067] = "#556B31",
    [1073] = "#87CEEC", 
    [1105] = "#9ACD33", 
    [1094] = "#C0C0C1", 
    [1119] = "#E0FFFA", 
    [1124] = "#FF2400",
    [1064] = "#D2B48D", 
    [1091] = "#B8860C", 
    [1050] = "#104E8C", 
    [1085] = "#8B1A1B",
    -- Cataclysm
    [1204] = "#FF4501", 
    [1177] = "#778899", 
    [1133] = "#FF7F00", 
    [1172] = "#4A0405", 
    [1134] = "#1A1A1B",
    [1158] = "#2E8B58", 
    [1178] = "#424242", 
    [1173] = "#F4A461", 
    [1135] = "#20B2AB", 
    [1171] = "#8B6915",
    [1174] = "#6B8E24",
    -- Mists of Pandaria
    [1341] = "#00CED3", 
    [1277] = "#8B5A2B", 
    [1375] = "#B22223", 
    [1275] = "#FFC0CB", 
    [1492] = "#FFFFE1",
    [1283] = "#556B2E", 
    [1282] = "#4682B4", 
    [1228] = "#A52A2A", 
    [1281] = "#D2691F", 
    [1269] = "#FFD702",
    [1279] = "#8B4513", 
    [1352] = "#CC0000", 
    [1273] = "#800080", 
    [1387] = "#9370DC", 
    [1337] = "#BDB76B",
    [1358] = "#FFD000", 
    [1276] = "#A0522C", 
    [1376] = "#4169E2", 
    [1271] = "#FF8C01", 
    [1242] = "#66CDAA",
    [1270] = "#1B1B1B", 
    [1435] = "#800001", 
    [1278] = "#FF4502", 
    [1388] = "#DC143E", 
    [1302] = "#4682B5",
    [1359] = "#0A0A0A", 
    [1345] = "#FFE4B5", 
    [1272] = "#8FBC90", 
    [1280] = "#DA70D6", 
    [1353] = "#008081",
    -- Warlords of Draenor
    [1740] = "#DC143C", 
    [1515] = "#301934", 
    [1731] = "#EEDC83", 
    [1738] = "#F0E68C", 
    [1733] = "#2F4F4F",
    [1445] = "#F0F8FE", 
    [1847] = "#DAA522", 
    [1708] = "#FFFFF0", 
    [1741] = "#20B2AA", 
    [1849] = "#00FF00",
    [1710] = "#BDB76C", 
    [1711] = "#D26920", 
    [1737] = "#4B0082", 
    [1850] = "#006400", 
    [1736] = "#CD853F",
    [1739] = "#FF8C00", 
    [1848] = "#8B0002", 
    [1681] = "#FF0001", 
    [1682] = "#0000F0",
    -- Legion
    [2099] = "#4A8B9A", 
    [2170] = "#BA55D4", 
    [2045] = "#7CFC01", 
    [2165] = "#FFFFE2", 
    [2135] = "#CD7F33",
    [1975] = "#00BFFF", 
    [2100] = "#5F9EA0", 
    [1900] = "#40E0D1", 
    [1883] = "#00FA9B", 
    [1828] = "#8B4516",
    [2097] = "#7FFFD4", 
    [2102] = "#32CD32", 
    [2098] = "#00FA9A", 
    [2101] = "#8A2BE2", 
    [2040] = "#FFFFF1",
    [1859] = "#8A2BE4", 
    [1894] = "#006401", 
    [1948] = "#DAA523",
    -- Battle for Azeroth
    [2159] = "#191971", 
    [2393] = "#000080", 
    [2392] = "#4169E1", 
    [2164] = "#00FFFF", 
    [2394] = "#87CEFA",
    [2395] = "#FFC100", 
    [2389] = "#FF1493", 
    [2161] = "#2F4F51", 
    [2388] = "#00CED1", 
    [2160] = "#008082",
    [2415] = "#E6E6FC", 
    [2391] = "#B87334", 
    [2162] = "#4682B6", 
    [2156] = "#8B008C", 
    [2157] = "#8B0003",
    [2373] = "#48D1CD", 
    [2163] = "#556B32", 
    [2417] = "#DAA524", 
    [2390] = "#2E8B57", 
    [2158] = "#F4A462",
    [2400] = "#0000CE", 
    [2103] = "#FFD703",
    -- Shadowlands
    [2450] = "#2F4F4E", 
    [2446] = "#008080", 
    [2454] = "#D2B48D", 
    [2413] = "#8B0004", 
    [2464] = "#191970",
    [2455] = "#696969", 
    [2470] = "#2F4F52", 
    [2456] = "#556B2F", 
    [2457] = "#8B0005", 
    [2451] = "#228B22",
    [2458] = "#E0FFFF", 
    [2447] = "#EE82EE", 
    [2463] = "#A52A2B", 
    [2448] = "#C0C0C0", 
    [2461] = "#3CB371",
    [2452] = "#FFD700", 
    [2453] = "#8B4515", 
    [2459] = "#F5DEB3", 
    [2462] = "#9ACD32", 
    [2460] = "#A9A9A9",
    [2472] = "#FFDABA", 
    [2407] = "#87CEED", 
    [2439] = "#800000", 
    [2449] = "#8B008B", 
    [2445] = "#5C1D1E",
    [2478] = "#FFFFE3", 
    [2410] = "#556B33", 
    [2465] = "#0000CF", 
    [2432] = "#A9A9AA",
    -- Dragonflight
    [2544] = "#C0C0C2", 
    [2615] = "#D2B48E", 
    [2550] = "#0000CD", 
    [2507] = "#8B4517", 
    [2574] = "#32CD34",
    [2568] = "#9ACD34", 
    [2511] = "#5F9EA1", 
    [2564] = "#A0522F", 
    [2503] = "#6B8E25", 
    [2518] = "#2C2C2D",
    [2553] = "#DAA525", 
    [2510] = "#B8860D", 
    [2526] = "#FAFAFA", 
    [2517] = "#1A1A1A",
    -- The War Within
    [2675] = "#0A2B4C", 
    [2640] = "#B8860B", 
    [2590] = "#A9A9AB", 
    [2669] = "#4B0085", 
    [2657] = "#800082",
    [2664] = "#8B0006", 
    [2685] = "#FFD704", 
    [2570] = "#FFFACE", 
    [2665] = "#D32F2F", 
    [2663] = "#D2B48F",
    [2594] = "#8B008D", 
    [2609] = "#3E2723", 
    [2653] = "#00FF7F", 
    [2605] = "#483D8B", 
    [2606] = "#1B5E20",
    [2600] = "#4B0084", 
    [2614] = "#BF360C", 
    [2635] = "#4A148C", 
    [2607] = "#8A2BE2", 
    [2601] = "#E6E6FA",
    [2602] = "#311B92", 
    [2671] = "#8B4518",
    -- Midnight
    [2696] = "#557A2B", 
    [2712] = "#9E1B1E", 
    [2713] = "#4D712C", 
    [2704] = "#0BDE9E", 
    [2711] = "#6C2E9C",
    [2781] = "#006402", 
    [2714] = "#3E3B4F", 
    [2780] = "#2E8B59", 
    [2710] = "#E5C158", 
    [2770] = "#A62438",
    [2699] = "#36175E", 
    [2744] = "#B22224", 
    [2709] = "#FFFA11", 
    [2706] = "#556B34",
    -- Other / Global
    [1169] = "#D4AF37", 
    [2593] = "#8B4519",
}

ascensionBars.constants.FACTION_COLORS = {}
for id, hex in pairs(rawFactionColors) do
    ascensionBars.constants.FACTION_COLORS[id] = hexToRGB(hex)
end
