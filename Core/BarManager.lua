-------------------------------------------------------------------------------
-- Project: AscensionProgressDataBars
-- Author: Aka-DoctorCode
-- File: BarManager.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, addonTable = ...
local ascensionBars = addonTable.main or _G.LibStub("AceAddon-3.0"):GetAddon(addonName)

local texturePool = {}
local lastUpdate  = 0

-------------------------------------------------------------------------------
-- FRAME CREATION
-------------------------------------------------------------------------------

function ascensionBars:createFrames()
    self.textHolder = _G.CreateFrame("Frame", "AscensionBars_TextHolderT1", _G.UIParent)
    if self.textHolder then
        self.textHolder:SetFrameStrata("HIGH")
        self.textHolder:SetClipsChildren(false)
        self.textHolder:SetHeight(20)
        self.textHolder:SetPoint("CENTER", _G.UIParent, "CENTER", 0, 0)
    end

    if not self.hoverFrame then
        self.hoverFrame = _G.CreateFrame("Frame", "AscensionBars_HoverFrame", _G.UIParent)
        if self.hoverFrame then
            self.hoverFrame:SetAllPoints(_G.UIParent)
            self.hoverFrame:SetFrameStrata("BACKGROUND")
            self.hoverFrame:EnableMouse(false)
        end
    end

    if not self.paragonText and _G.UIParent then
        self.paragonText = _G.UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    end

    if not self.houseRewardText and _G.UIParent then
        self.houseRewardText = _G.UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    end

    local barDefs = {
        { key = "XP",      name = "AscensionXPBar_XP"      },
        { key = "Rep",     name = "AscensionXPBar_Rep"     },
        { key = "Honor",   name = "AscensionXPBar_Honor"   },
        { key = "HouseXp", name = "AscensionXPBar_HouseXp" },
        { key = "Azerite", name = "AscensionXPBar_Azerite" },
    }

    self.activeBars = {}
    for _, def in ipairs(barDefs) do
        self.activeBars[def.key] = self:createBar(def.name)
    end

    if self.db and self.db.profile and self.db.profile.bars then
        for k, v in pairs(self.db.profile.bars) do
            if string.match(k, "^Rep_%d+$") then
                self.activeBars[k] = self:createBar("AscensionXPBar_" .. k)
            end
        end
    end

    -- Backward-compat aliases consumed by bar modules
    self.xp      = self.activeBars["XP"]
    self.rep     = self.activeBars["Rep"]
    self.honor   = self.activeBars["Honor"]
    self.houseXp = self.activeBars["HouseXp"]
    self.azerite = self.activeBars["Azerite"]

    if self.honor   then self.honor.bar:Hide()   end
    if self.houseXp then self.houseXp.bar:Hide() end
    if self.azerite then self.azerite.bar:Hide() end
end

function ascensionBars:createDynamicBar(barKey)
    if self.activeBars[barKey] then return end
    self.activeBars[barKey] = self:createBar("AscensionXPBar_" .. barKey)
    if addonTable.dataText and addonTable.dataText.initBarText then
        addonTable.dataText:initBarText(self.activeBars[barKey])
    end
end

function ascensionBars:removeDynamicBar(barKey)
    if not self.activeBars[barKey] then return end
    local barObj = self.activeBars[barKey]
    if barObj.bar then barObj.bar:Hide() end
    if barObj.txFrame then barObj.txFrame:Hide() end
    self.activeBars[barKey] = nil
end

function ascensionBars:createBar(name)
    local bar = _G.CreateFrame("StatusBar", name, _G.UIParent)
    bar:SetFrameStrata("MEDIUM")
    bar:EnableMouse(true)

    local barKey = string.match(name, "AscensionXPBar_(.+)")

    bar:SetScript("OnEnter", function()
        if self.state then
            self.state.isHovering  = true
            self.state.hoveredBarKey = barKey
            self:updateVisibility()
        end
    end)

    bar:SetScript("OnLeave", function()
        if self.state then
            self.state.isHovering  = false
            self.state.hoveredBarKey = nil
            self:updateVisibility()
        end
    end)

    bar:SetStatusBarTexture(self.constants.TEXTURE_BAR)
    bar:SetClipsChildren(true)

    local background = self:acquireTexture(bar)
    if background then
        background:SetAllPoints()
        background:SetTexture(self.constants.TEXTURE_BAR)
        local bgAlpha = (self.db and self.db.profile and self.db.profile.backgroundAlpha) or 0.5
        background:SetVertexColor(0, 0, 0, bgAlpha) -- #000000
        background:SetDrawLayer("BACKGROUND", -1)
    end

    -- Spark outer glow bloom layer
    local sparkGlow = bar:CreateTexture(nil, "ARTWORK", nil, 1)
    sparkGlow:SetTexture(self.constants.TEXTURE_SPARK)
    sparkGlow:SetBlendMode("ADD")
    sparkGlow:SetVertexColor(1, 1, 1, 0.9) -- #FFFFFF
    sparkGlow:Hide()

    -- Spark inner hard-edge core line
    local sparkCore = bar:CreateTexture(nil, "ARTWORK", nil, 2)
    sparkCore:SetTexture(self.constants.TEXTURE_BAR)
    sparkCore:SetBlendMode("ADD")
    sparkCore:SetVertexColor(1, 1, 1, 1) -- #FFFFFF
    sparkCore:Hide()

    local restedOverlay = (name == "AscensionXPBar_XP") and bar:CreateTexture(nil, "ARTWORK") or nil

    local txFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    txFrame:SetFrameStrata("HIGH")
    txFrame:SetFrameLevel(bar:GetFrameLevel() + 5)
    txFrame:SetAllPoints(bar)
    txFrame:Hide()

    local leftText   = txFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    local centerText = txFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    local rightText  = txFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")

    return {
        bar           = bar,
        sparkGlow     = sparkGlow,
        sparkCore     = sparkCore,
        leftText      = leftText,
        centerText    = centerText,
        rightText     = rightText,
        txFrame       = txFrame,
        restedOverlay = restedOverlay,
        background    = background,
    }
end

function ascensionBars:acquireTexture(parent)
    if not parent then return nil end
    for i = 1, #texturePool do
        if not texturePool[i]:IsShown() and texturePool[i]:GetParent() == parent then
            texturePool[i]:Show()
            return texturePool[i]
        end
    end
    local texture = parent:CreateTexture(nil, "BACKGROUND")
    table.insert(texturePool, texture)
    return texture
end

function ascensionBars:cleanupTextures()
    for i = 1, #texturePool do
        if texturePool[i] then texturePool[i]:Hide() end
    end
end

-------------------------------------------------------------------------------
-- DISPLAY HELPERS
-------------------------------------------------------------------------------

function ascensionBars:updateSpark(bar, minVal, maxVal, currentVal)
    local hasGlow = bar and bar.sparkGlow
    local hasCore = bar and bar.sparkCore

    if not (self.db and self.db.profile and self.db.profile.sparkEnabled) then
        if hasGlow then bar.sparkGlow:Hide() end
        if hasCore then bar.sparkCore:Hide() end
        return
    end

    if not hasGlow or not hasCore then return end

    local barWidth  = bar.bar:GetWidth() or 0
    local barHeight = bar.bar:GetHeight() or 0
    local percentage = (maxVal > minVal) and (currentVal - minVal) / (maxVal - minVal) or 0
    local xPos = barWidth * percentage

    -- Core: 2px wide, exact bar height — the sharp bright edge
    bar.sparkCore:SetSize(2, barHeight)
    bar.sparkCore:ClearAllPoints()
    bar.sparkCore:SetPoint("CENTER", bar.bar, "LEFT", xPos, 0)
    bar.sparkCore:Show()

    -- Glow: wide soft bloom, at least 3x bar height for visible bleed effect
    local glowHeight = math.max(barHeight * 3, 18)
    local glowWidth  = math.max(glowHeight * 4, 75)
    bar.sparkGlow:SetSize(glowWidth, glowHeight)
    bar.sparkGlow:ClearAllPoints()
    bar.sparkGlow:SetPoint("CENTER", bar.bar, "LEFT", xPos, 0)
    bar.sparkGlow:Show()
end

function ascensionBars:setupBar(bar, minVal, maxVal, currentVal, color)
    if not bar or not bar.bar then return end
    if maxVal <= minVal then maxVal = minVal + 1 end
    bar.bar:SetMinMaxValues(minVal, maxVal)
    bar.bar:SetValue(currentVal)
    bar.bar:SetStatusBarColor(color.r, color.g, color.b, color.a or 1)
    self:updateSpark(bar, minVal, maxVal, currentVal)
end

function ascensionBars:updateStandardBar(barObj, barKey, currentFunc, maxFunc, colorFunc, textFunc)
    if not self.db or not barObj then return end
    local profile = self.db.profile
    if not profile or not profile.bars then return end

    local config = profile.bars[barKey]
    if not config or not config.enabled then
        if barObj.bar    then barObj.bar:Hide()    end
        if barObj.txFrame then barObj.txFrame:Hide() end
        return
    end

    if barObj.bar     then barObj.bar:Show()    end
    if barObj.txFrame then barObj.txFrame:Show() end

    local current = currentFunc()
    local maxVal  = maxFunc()
    if maxVal == 0 then maxVal = 1 end

    local color = colorFunc()
    self:setupBar(barObj, 0, maxVal, current, color)

    barObj.current    = current
    barObj.max        = maxVal
    barObj.percentage = (current / maxVal) * 100
    barObj.color      = color

    local str = textFunc(current, maxVal, (current / maxVal) * 100)
    if barObj.centerText then barObj.centerText:SetText(str) end
    if barObj.leftText   then barObj.leftText:SetText("")   end
    if barObj.rightText  then barObj.rightText:SetText("")  end
end

-------------------------------------------------------------------------------
-- DISPLAY PIPELINE
-------------------------------------------------------------------------------

function ascensionBars:applyTextStyles()
    if not self.db or not self.db.profile then return end

    local profile = self.db.profile
    local font    = profile.fontPath or [[Fonts\FRIZQT__.TTF]]
    local outline = profile.fontOutline or "OUTLINE"

    for barKey, obj in pairs(self.activeBars or {}) do
        if obj then
            local barConfig  = profile.bars and profile.bars[barKey]
            local finalFont  = font
            if barConfig and barConfig.useCustomFont then
                finalFont = barConfig.customFontPath or finalFont
            end

            local finalSize = profile.textSize or 14
            if barConfig and barConfig.useCustomTextSize then
                finalSize = barConfig.customTextSize or finalSize
            end

            local finalColor = profile.textColor or { r = 1, g = 1, b = 1, a = 1 } -- #FFFFFF
            if barConfig and barConfig.useCustomTextColor then
                finalColor = barConfig.customTextColor or finalColor
            end

            local function applyStyle(fontString, anchor, xOff)
                if not fontString then return end
                fontString:SetFont(finalFont, finalSize, outline)
                fontString:SetTextColor(finalColor.r or 1, finalColor.g or 1, finalColor.b or 1, finalColor.a or 1)
                local yOff = profile.textYOffset or 0
                fontString:ClearAllPoints()
                fontString:SetPoint(anchor, obj.bar, anchor, xOff, yOff)
            end

            applyStyle(obj.leftText,   "LEFT",    10)
            applyStyle(obj.centerText, "CENTER",   0)
            applyStyle(obj.rightText,  "RIGHT",  -10)
        end
    end
end

function ascensionBars:updateDisplay(force)
    local now = _G.GetTime()
    if not force and (now - lastUpdate < ascensionBars.constants.UPDATE_THROTTLE) then
        if self.state and not self.state.updatePending then
            self.state.updatePending = true
            _G.C_Timer.After(ascensionBars.constants.UPDATE_THROTTLE, function()
                if self.state then self.state.updatePending = false end
                self:updateDisplay(true)
            end)
        end
        return
    end
    lastUpdate = now

    if not self.db or not self.db.profile then return end
    local profile = self.db.profile
    local bars    = profile and profile.bars or nil
    if not bars then return end

    self:applyTextStyles()

    local maxLevel   = self:getPlayerMaxLevel() or 1
    local curLevel   = _G.UnitLevel("player") or 0
    local isConfig   = self.state and self.state.isConfigMode
    local shouldHideXP = (curLevel >= maxLevel) and profile.hideAtMaxLevel and not isConfig

    self:updateLayout(shouldHideXP)
    self:updateVisibility()

    -- Dispatch to every registered module's UpdateRender method
    for _, module in self:IterateModules() do
        if module:IsEnabled() and module.UpdateRender then
            module:UpdateRender(isConfig, shouldHideXP)
        end
    end

    if self.updateLegend             then self:updateLegend()             end
    if self.updateCarouselVisibility then self:updateCarouselVisibility() end
end

function ascensionBars:updateLayout(shouldHideXP)
    if not self.db or not self.db.profile then return end
    local profile = self.db.profile
    local bars    = profile and profile.bars or nil
    if not bars then return end

    local blocks = { TOP = {}, BOTTOM = {}, FREE = {} }

    for barKey, entry in pairs(self.activeBars or {}) do
        local config = bars[barKey]
        if config and config.enabled and not (barKey == "XP" and shouldHideXP) then
            table.insert(blocks[config.block or "TOP"], { obj = entry, key = barKey })
            if entry.txFrame then entry.txFrame:Show() end
        else
            if entry.bar     then entry.bar:Hide()     end
            if entry.txFrame then entry.txFrame:Hide() end
        end
    end

    local function getBarHeight(entry)
        local config = bars[entry.key]
        if not config then return profile.globalBarHeight or 6 end
        local block = config.block or "TOP"
        if block == "FREE" then return config.freeHeight or 15 end
        if config.useCustomHeight then return config.customHeight or 10 end
        if profile.usePerBlockHeights and profile.blockHeights and profile.blockHeights[block] then
            return profile.blockHeights[block]
        end
        return profile.globalBarHeight or 6
    end

    local sortFn = function(a, b)
        return (bars[a.key].order or 0) < (bars[b.key].order or 0)
    end
    table.sort(blocks.TOP,    sortFn)
    table.sort(blocks.BOTTOM, sortFn)

    ---------------------------------------------------------------------------
    local barAnchor = profile.barAnchor or "TOP"
    local screenW   = _G.UIParent:GetWidth() or 1024

    local function layoutBlock(block, blockName, startAnchor, anchorFrame, direction)
        local prevBar = nil
        
        local initialYOffset
        if blockName == "TOP" then
            initialYOffset = profile.usePerBlockOffsets and (profile.topOffset or 0) or (profile.yOffset or -2)
        else
            initialYOffset = profile.usePerBlockOffsets and (profile.bottomOffset or 0) or math.abs(profile.yOffset or -2)
        end
        
        local gap = profile.usePerBlockGaps and (blockName == "TOP" and (profile.topBarGap or 0) or (profile.bottomBarGap or 0)) or (profile.barGap or 2)
        
        for i, entry in ipairs(block) do
            local obj    = entry.obj
            local height = getBarHeight(entry)
            obj.bar:SetHeight(height)
            obj.bar:ClearAllPoints()

            if entry.key == "XP" and shouldHideXP then
                obj.bar:Hide()
            end

            if prevBar then
                local gapDirection = (blockName == "TOP") and -gap or gap
                obj.bar:SetPoint(startAnchor, prevBar, direction, 0, gapDirection)
                obj.bar:SetWidth(screenW)
            else
                obj.bar:SetPoint(startAnchor, anchorFrame, startAnchor, 0, initialYOffset)
                obj.bar:SetWidth(screenW)
            end

            if entry.txFrame then
                obj.txFrame:SetAllPoints(obj.bar)
            end

            obj.bar:Show()
            prevBar = obj.bar
        end
    end

    local function layoutGridBlock(block, blockName, startAnchor, anchorFrame, direction)
        local grid = profile.customGrids and profile.customGrids[blockName]
        if not grid or not grid.enabled then return false end
        
        local initialYOffset
        if blockName == "TOP" then
            initialYOffset = profile.usePerBlockOffsets and (profile.topOffset or 0) or (profile.yOffset or -2)
        else
            initialYOffset = profile.usePerBlockOffsets and (profile.bottomOffset or 0) or math.abs(profile.yOffset or -2)
        end
        local gap = profile.usePerBlockGaps and (blockName == "TOP" and (profile.topBarGap or 0) or (profile.bottomBarGap or 0)) or (profile.barGap or 2)
        local gapDirection = (blockName == "TOP") and -gap or gap
        
        local availableBars = {}
        for _, entry in ipairs(block) do availableBars[entry.key] = entry end
        
        local prevRowBar = nil
        
        for r = 1, grid.numRows or 1 do
            local cols = (grid.colsPerRow and grid.colsPerRow[r]) or 1
            local cellWidth = (screenW - ((cols - 1) * gap)) / cols
            local prevColBar = nil
            local firstBarInRow = nil
            
            for c = 1, cols do
                local assignedKey = grid.assignments and grid.assignments[r] and grid.assignments[r][c]
                local entry = assignedKey and availableBars[assignedKey]
                
                if entry then
                    local obj = entry.obj
                    local height = getBarHeight(entry)
                    obj.bar:SetHeight(height)
                    obj.bar:SetWidth(cellWidth)
                    obj.bar:ClearAllPoints()
                    
                    if entry.key == "XP" and shouldHideXP then
                        obj.bar:Hide()
                    else
                        if c == 1 then
                            if r == 1 then
                                obj.bar:SetPoint(startAnchor, anchorFrame, startAnchor, 0, initialYOffset)
                            else
                                if prevRowBar then
                                    obj.bar:SetPoint(startAnchor, prevRowBar, direction, 0, gapDirection)
                            else
                                    obj.bar:SetPoint(startAnchor, anchorFrame, startAnchor, 0, initialYOffset)
                                end
                            end
                            firstBarInRow = obj.bar
                            prevRowBar = obj.bar
                        else
                            if prevColBar then
                                obj.bar:SetPoint("LEFT", prevColBar, "RIGHT", gap, 0)
                            end
                        end
                        
                        if entry.txFrame then obj.txFrame:SetAllPoints(obj.bar) end
                        obj.bar:Show()
                        prevColBar = obj.bar
                    end
                    availableBars[assignedKey] = nil
                end
            end
            if firstBarInRow then prevRowBar = firstBarInRow end
        end
        
        for key, entry in pairs(availableBars) do
            entry.obj.bar:Hide()
            if entry.obj.txFrame then entry.obj.txFrame:Hide() end
        end
        return true
    end

    local function renderBlock(blockData, blockName, startAnchor, anchorFrame, direction)
        local gridOpts = profile.customGrids and profile.customGrids[blockName]
        if gridOpts and gridOpts.enabled then
            layoutGridBlock(blockData, blockName, startAnchor, anchorFrame, direction)
        else
            layoutBlock(blockData, blockName, startAnchor, anchorFrame, direction)
        end
    end

    if barAnchor == "TOP" then
        renderBlock(blocks.TOP,    "TOP",    "TOPLEFT",    _G.UIParent, "BOTTOMLEFT")
        renderBlock(blocks.BOTTOM, "BOTTOM", "BOTTOMLEFT", _G.UIParent, "TOPLEFT")
    else
        renderBlock(blocks.BOTTOM, "BOTTOM", "BOTTOMLEFT", _G.UIParent, "TOPLEFT")
        renderBlock(blocks.TOP,    "TOP",    "TOPLEFT",    _G.UIParent, "BOTTOMLEFT")
    end

    for _, entry in ipairs(blocks.FREE) do
        local obj    = entry.obj
        local config = bars[entry.key]
        if config then
            obj.bar:ClearAllPoints()
            obj.bar:SetPoint("CENTER", _G.UIParent, "CENTER", config.freeX or 0, config.freeY or 0)
            obj.bar:SetWidth(config.freeWidth or screenW)
            obj.bar:SetHeight(getBarHeight(entry))
            if obj.txFrame then obj.txFrame:SetAllPoints(obj.bar) end
            obj.bar:Show()
        end
    end
end

function ascensionBars:updateVisibility()
    if not self.db or not self.db.profile or not self.state then return end
    local profile      = self.db.profile
    local blockMode    = profile.blockTextMode or "FOCUS"
    local isConfig     = self.state.isConfigMode
    local legendHovered = self.state.legendHovered

    local baseAlpha = 1
    if not legendHovered and not isConfig then
        if profile.hideInCombat and self.state.inCombat then
            baseAlpha = 0
        elseif profile.showOnMouseover and not self.state.isHovering then
            baseAlpha = 0
        end
    end

    local dimAlpha = profile.focusDimAlpha or 0.4

    for key, barObj in pairs(self.activeBars or {}) do
        local barConfig = profile.bars and profile.bars[key]
        if barObj and barObj.bar and barConfig and barConfig.enabled then
            local barAlpha    = baseAlpha
            local centerAlpha = 0

            if blockMode == "FOCUS" then
                if self.state.hoveredBarKey == nil then
                    barAlpha    = baseAlpha
                    centerAlpha = 0
                elseif self.state.hoveredBarKey == key then
                    barAlpha    = baseAlpha
                    centerAlpha = baseAlpha
                else
                    barAlpha    = baseAlpha * dimAlpha
                    centerAlpha = 0
                end
            else
                barAlpha    = baseAlpha
                centerAlpha = baseAlpha
            end

            barObj.bar:SetAlpha(barAlpha)
            if barAlpha > 0 and not barObj.bar:IsShown() then
                barObj.bar:Show()
            end

            if barObj.leftText   then barObj.leftText:SetAlpha(0)             end
            if barObj.rightText  then barObj.rightText:SetAlpha(0)            end
            if barObj.centerText then barObj.centerText:SetAlpha(centerAlpha)  end
            if barObj.txFrame    then barObj.txFrame:SetAlpha(barAlpha)       end
        end
    end

    if self.textHolder then self.textHolder:SetAlpha(baseAlpha) end
end
