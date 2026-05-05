-------------------------------------------------------------------------------
-- Project: AscensionProgressDataBars
-- Author: Aka-DoctorCode
-- File: Events.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, addonTable = ...
local ascensionBars = addonTable.main or LibStub("AceAddon-3.0"):GetAddon(addonName)

local CoreEvents = {}
ascensionBars.coreEvents = CoreEvents

function CoreEvents:Enable()
    local coreEventsList = {
        ["PLAYER_ENTERING_WORLD"] = "onPlayerEnteringWorld",
        ["PLAYER_REGEN_DISABLED"] = "onCombatStart",
        ["PLAYER_REGEN_ENABLED"]  = "onCombatEnd",
        ["QUEST_TURNED_IN"]       = "onQuestTurnIn",
        ["NEIGHBORHOOD_NAME_UPDATED"]  = "onNeighborhoodNameUpdated",
        ["CVAR_UPDATE"]           = "onCVarUpdate",
    }

    for event, method in pairs(coreEventsList) do
        if self[method] then
            ascensionBars:RegisterEvent(event, function(...) self[method](self, ...) end)
        end
    end

    if C_Reputation and C_Reputation.SetWatchedFactionByID then
        hooksecurefunc(C_Reputation, "SetWatchedFactionByID", function()
            ascensionBars:updateDisplay()
        end)
    end

    if C_Housing and C_Housing.SetTrackedHouseGuid then
        hooksecurefunc(C_Housing, "SetTrackedHouseGuid", function()
            C_Timer.After(0.15, function()
                if ascensionBars.refreshHousingFavor then ascensionBars:refreshHousingFavor() end
                ascensionBars:updateDisplay()
            end)
        end)
    end
end

function CoreEvents:onPlayerEnteringWorld()
    if ascensionBars.scanParagonRewards  then ascensionBars:scanParagonRewards()  end
    if ascensionBars.refreshHousingFavor then ascensionBars:refreshHousingFavor() end

    if not ascensionBars.state then return end
    ascensionBars.state.lastXP      = UnitXP("player")     or 0
    ascensionBars.state.lastXPMax   = UnitXPMax("player")  or 0
    ascensionBars.state.lastHonor   = UnitHonor("player")  or 0
    ascensionBars.state.lastHonorMax = UnitHonorMax("player") or 0

    if C_AzeriteItem and C_AzeriteItem.FindActiveAzeriteItem then
        local itemLoc = C_AzeriteItem.FindActiveAzeriteItem()
        if itemLoc and C_AzeriteItem.GetAzeriteItemXPInfo then
            ascensionBars.state.lastAzeriteXP = C_AzeriteItem.GetAzeriteItemXPInfo(itemLoc) or 0
        end
    end

    ascensionBars:updateDisplay(true)
end

function CoreEvents:onCombatStart()
    if ascensionBars.state then ascensionBars.state.inCombat = true end
    ascensionBars:updateVisibility()
    if ascensionBars.updateCarouselVisibility then ascensionBars:updateCarouselVisibility() end
end

function CoreEvents:onCombatEnd()
    if ascensionBars.state then ascensionBars.state.inCombat = false end
    ascensionBars:updateVisibility()
    if ascensionBars.updateCarouselVisibility then ascensionBars:updateCarouselVisibility() end
    if ascensionBars.startCarousel then ascensionBars:startCarousel() end
end

function CoreEvents:onQuestTurnIn()
    C_Timer.After(1, function()
        if ascensionBars.scanParagonRewards then ascensionBars:scanParagonRewards() end
    end)
end

function CoreEvents:onNeighborhoodNameUpdated()
    ascensionBars:updateDisplay()
end

function CoreEvents:onCVarUpdate(event, name, ...)
    if name == "trackedHouseFavor" then
        C_Timer.After(0.15, function()
            if ascensionBars.refreshHousingFavor then ascensionBars:refreshHousingFavor() end
            ascensionBars:updateDisplay()
        end)
    end
end
