-------------------------------------------------------------------------------
-- Project: AscensionProgressDataBars
-- Author: Aka-DoctorCode
-- File: Profiles.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, addonTable = ...

local ascensionBars = addonTable.main or LibStub("AceAddon-3.0"):GetAddon(addonName)

local L = LibStub("AceLocale-3.0"):GetLocale("AscensionProgressDataBars")
local colors = setmetatable({}, { __index = function(t, k) return ascensionBars.colors and ascensionBars.colors[k] end })
local menuStyle = setmetatable({}, { __index = function(t, k) return ascensionBars.menuStyle and ascensionBars.menuStyle[k] end })

addonTable.profilesTab = {}
local profilesTab = addonTable.profilesTab

-------------------------------------------------------------------------------
-- Styled Button Helper (matches the addon's BackdropTemplate button style)
-------------------------------------------------------------------------------
local function createStyledButton(parent, w, h, labelText, onClick)
    local files = ascensionBars.files
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(w, h)
    btn:SetBackdrop({
        bgFile   = files.bgFile,
        edgeFile = files.edgeFile,
        edgeSize = 1,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btn:SetBackdropColor(unpack(colors.surfaceHighlight))
    btn:SetBackdropBorderColor(unpack(colors.blackDetail))

    local btnLabel = btn:CreateFontString(nil, "OVERLAY", menuStyle.labelFont)
    btnLabel:SetPoint("CENTER", 0, 0)
    btnLabel:SetText(labelText)
    btnLabel:SetTextColor(unpack(colors.textLight))
    btn.label = btnLabel

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(colors.primary))
        self:SetBackdropBorderColor(unpack(colors.textLight))
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(colors.surfaceHighlight))
        self:SetBackdropBorderColor(unpack(colors.blackDetail))
    end)
    btn:SetScript("OnMouseDown", function(self) self.label:SetPoint("CENTER", 1, -1) end)
    btn:SetScript("OnMouseUp",   function(self) self.label:SetPoint("CENTER", 0,  0) end)
    btn:SetScript("OnClick", function() if onClick then onClick() end end)
    return btn
end

-------------------------------------------------------------------------------
-- UI Refresh Helper
-------------------------------------------------------------------------------
local function refreshConfigPanel()
    if ascensionBars.refreshConfig then
        ascensionBars:refreshConfig()
    else
        ascensionBars:updateDisplay(true)
    end
end

-------------------------------------------------------------------------------
-- Profile Data Helpers
-------------------------------------------------------------------------------
local function isProfileExisting(db, profileName)
    if not db or not profileName then return false end
    for _, name in ipairs(db:GetProfiles()) do
        if name == profileName then
            return true
        end
    end
    return false
end

local function getProfileChoices(db, excludeCurrent)
    local choices = {}
    local currentProfile = db:GetCurrentProfile()
    
    for _, name in ipairs(db:GetProfiles()) do
        if not excludeCurrent or name ~= currentProfile then
            table.insert(choices, { label = name, value = name })
        end
    end
    return choices
end



-------------------------------------------------------------------------------
-- Confirmation Dialog
-------------------------------------------------------------------------------
local function showConfirmDialog(message, onConfirm)
    local dialog = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    dialog:SetSize(300, 100)
    dialog:SetPoint("CENTER")
    dialog:SetBackdrop({
        bgFile = ascensionBars.files.bgFile,
        edgeFile = ascensionBars.files.edgeFile,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    dialog:SetBackdropColor(unpack(colors.surfaceDark))
    dialog:SetBackdropBorderColor(unpack(colors.surfaceHighlight))
    dialog:SetFrameStrata("TOOLTIP") -- Raised to Tooltip level to prevent overlapping issues

    local text = dialog:CreateFontString(nil, "OVERLAY", menuStyle.labelFont)
    text:SetPoint("TOP", 0, -20)
    text:SetWidth(280)
    text:SetText(message)

    local yes = createStyledButton(dialog, 80, 30, L["YES"] or "Yes", function()
        if onConfirm then onConfirm() end
        dialog:Hide()
    end)
    yes:SetPoint("BOTTOMRIGHT", -10, 10)

    local no = createStyledButton(dialog, 80, 30, L["NO"] or "No", function()
        dialog:Hide()
    end)
    no:SetPoint("BOTTOMLEFT", 10, 10)

    dialog:Show()
end

-------------------------------------------------------------------------------
-- Text Generator Helper
-------------------------------------------------------------------------------
local function createDescText(parent, text, yOffset)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    
    -- Anchoring to both sides allows dynamic width adaptation
    fs:SetPoint("TOPLEFT", 20, yOffset)
    fs:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, yOffset)
    fs:SetJustifyH("LEFT")
    fs:SetTextColor(1, 0.82, 0) -- #FFD100
    fs:SetText(text)
    
    local height = fs:GetStringHeight()
    fs:SetHeight(height)
    return fs, height
end

-------------------------------------------------------------------------------
-- Import / Export Helpers
-------------------------------------------------------------------------------
local function exportProfileData()
    local serializer = LibStub("AceSerializer-3.0", true)
    local deflate = LibStub("LibDeflate", true)
    if not serializer or not deflate then return "Missing Libraries" end

    local currentData = ascensionBars.db.profile
    local serialized = serializer:Serialize(currentData)
    local compressed = deflate:CompressDeflate(serialized)
    return deflate:EncodeForPrint(compressed)
end

local function importProfileData(text)
    local serializer = LibStub("AceSerializer-3.0", true)
    local deflate = LibStub("LibDeflate", true)
    if not serializer or not deflate or not text or text == "" then return false end

    local decoded = deflate:DecodeForPrint(text)
    if not decoded then return false end
    
    local decompressed = deflate:DecompressDeflate(decoded)
    if not decompressed then return false end

    local success, data = serializer:Deserialize(decompressed)
    if success and type(data) == "table" then
        -- Overwrite current profile settings with imported data
        for k, v in pairs(data) do
            ascensionBars.db.profile[k] = v
        end
        return true
    end
    return false
end

local function showDataPopup(title, isImport)
    -- Initialize or retrieve the global frame
    local frame = _G["AscensionBarsDataPopup"]
    if not frame then
        frame = CreateFrame("Frame", "AscensionBarsDataPopup", UIParent, "BackdropTemplate")
        frame:SetSize(500, 400)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("TOOLTIP")

        -- Draggable setup
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

        frame:SetBackdrop({
            bgFile = ascensionBars.files.bgFile,
            edgeFile = ascensionBars.files.edgeFile,
            edgeSize = 12,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        frame:SetBackdropColor(0, 0, 0, 0.95)
        
        -- Title text (Store in frame for easy updating)
        frame.titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.titleText:SetPoint("TOP", 0, -15)

        -- Background for the EditBox to add contrast
        local scrollBg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        scrollBg:SetPoint("TOPLEFT", 15, -45)
        scrollBg:SetPoint("BOTTOMRIGHT", -15, 55)
        scrollBg:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground", -- Flat solid texture
            edgeFile = ascensionBars.files.edgeFile,
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        scrollBg:SetBackdropColor(0.15, 0.15, 0.15, 1) -- #262626
        scrollBg:SetBackdropBorderColor(unpack(colors.surfaceHighlight))

        -- Scroll and EditBox setup
        local scroll = CreateFrame("ScrollFrame", "AscensionBarsDataScroll", frame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", scrollBg, "TOPLEFT", 8, -8)
        scroll:SetPoint("BOTTOMRIGHT", scrollBg, "BOTTOMRIGHT", -28, 8) -- Padding for the scrollbar

        frame.editBox = CreateFrame("EditBox", nil, scroll)
        frame.editBox:SetMultiLine(true)
        frame.editBox:SetMaxLetters(0)
        frame.editBox:SetFontObject("ChatFontNormal")
        frame.editBox:SetWidth(430)
        frame.editBox:SetAutoFocus(false) -- Prevent stealing focus on show
        scroll:SetScrollChild(frame.editBox)

        local closeBtn = createStyledButton(frame, 100, 30, L["CLOSE"] or "Close", function()
            frame:Hide()
        end)
        closeBtn:SetPoint("BOTTOMRIGHT", -20, 15)

        frame.importBtn = createStyledButton(frame, 100, 30, L["IMPORT"] or "Import", function()
            if importProfileData(frame.editBox:GetText()) then
                frame:Hide()
                refreshConfigPanel()
            end
        end)
        frame.importBtn:SetPoint("BOTTOMLEFT", 20, 15)
    end

    -- Update Frame Content based on mode (Import vs Export)
    frame.titleText:SetText(title)

    if isImport then
        -- Import Mode: Show import button, clear text, allow user to paste
        frame.importBtn:Show()
        frame.editBox:SetText("")
        frame.editBox:SetFocus()
    else
        -- Export Mode: Hide import button, generate text, highlight for copying
        frame.importBtn:Hide()
        frame.editBox:SetText(exportProfileData())
        frame.editBox:HighlightText()
        frame.editBox:SetFocus()
    end

    -- Ensure it's on top and visible
    frame:Raise()
    frame:Show()
end
-------------------------------------------------------------------------------
-- Main Tab Builder
-------------------------------------------------------------------------------
function profilesTab:build(panel)
    if not panel or not panel.content then return end
    addonTable.configUtils:cleanupContent(panel.content)

    local content = panel.content
    local db = ascensionBars.db
    local currentProfile = db:GetCurrentProfile()
    local layout = addonTable.layoutModel:new(nil, content, 0)
    local currentY = -15

    local profileIndicator = content:CreateFontString(nil, "OVERLAY", menuStyle.headerFont)
    profileIndicator:SetPoint("TOPLEFT", 15, currentY)
    profileIndicator:SetText("Active Profile:  " .. currentProfile)
    profileIndicator:SetTextColor(unpack(colors.gold))
    local indicatorH = profileIndicator:GetStringHeight()
    if indicatorH == 0 then indicatorH = 16 end
    currentY = currentY - indicatorH - 20

    -- ==========================================
    -- 2. New & Existing Profiles Section
    -- ==========================================
    local _, h3 = createDescText(content, L["PROFILE_DESC_3"] or "Create a new profile or choose an existing one.", currentY)
    currentY = currentY - h3 - 25

    local newLbl = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    newLbl:SetPoint("TOPLEFT", 15, currentY)
    newLbl:SetText(L["NEW"] or "New Profile")
    newLbl:SetFontObject("GameFontNormalLarge")
    newLbl:SetTextColor(unpack(colors.gold))

    local newEditBox = CreateFrame("EditBox", "AscensionBarsProfileNewEditBox", content, "InputBoxTemplate")
    newEditBox:SetSize(200, 20)
    newEditBox:SetPoint("TOPLEFT", 20, currentY - 25)
    newEditBox:SetAutoFocus(false)
    newEditBox:SetScript("OnEnterPressed", function(self)
        local val = self:GetText()
        if val and val ~= "" and not isProfileExisting(db, val) then
            db:SetProfile(val)
            refreshConfigPanel()
        end
        self:ClearFocus()
    end)
    newEditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    currentY = currentY - 70 -- Space for EditBox and Label
    
    -- Define switchChoices before using it in the dropdown (Fixes Lua Error)
    local switchChoices = getProfileChoices(db, false)
    layout.y = currentY 
    layout:dropdown("SwitchProfileDropdown", L["EXISTING_PROFILES"] or "Existing Profiles", switchChoices,
        function() return currentProfile end,
        function(value)
            if value == currentProfile then return end
            db:SetProfile(value)
            refreshConfigPanel()
        end, 200)
    
    currentY = currentY - 50

-- ==========================================
    -- 3. Copy & Delete Section
    -- ==========================================
    local copyChoices = getProfileChoices(db, true)
    table.insert(copyChoices, 1, { label = "---", value = "" })

    local _, h5 = createDescText(content, L["COPY_PROFILE_DESC"] or "Copy settings from another profile into the current one.", currentY)
    currentY = currentY - h5 - 15

    layout.y = currentY
    layout:dropdown("CopyProfileDropdown", L["COPY_FROM"] or "Copy From", copyChoices,
        function() return "" end,
        function(value)
            if value == "" then return end
            pcall(function() db:CopyProfile(value) end)
            refreshConfigPanel()
        end, 200)

    currentY = currentY - 60

    local deleteChoices = getProfileChoices(db, true)
    table.insert(deleteChoices, 1, { label = "---", value = "" })

    local _, h6 = createDescText(content, L["DELETE_PROFILE_DESC"] or "Delete unused profiles to save space.", currentY)
    currentY = currentY - h6 - 15

    layout.y = currentY
    layout:dropdown("DeleteProfileDropdown", L["DELETE_PROFILE"] or "Delete a Profile", deleteChoices,
        function() return "" end,
        function(value)
            if value == "" then return end
            showConfirmDialog(string.format(L["DELETE_PROFILE_CONFIRM"] or "Delete profile '%s'?", value), function()
                pcall(function() db:DeleteProfile(value) end)
                refreshConfigPanel()
            end)
        end, 200)

    currentY = currentY - 70

    -- ==========================================
    -- 3b. Reset Current Profile
    -- ==========================================
    local _, hReset = createDescText(content, "Restore the current profile to its default settings. This cannot be undone.", currentY)
    currentY = currentY - hReset - 15

    local resetBtn = createStyledButton(content, 200, 35, L["FACTION_STANDINGS_RESET"] or "Reset Current Profile", function()
        showConfirmDialog(
            "Reset profile '" .. currentProfile .. "' to defaults? This cannot be undone.",
            function()
                pcall(function() db:ResetProfile() end)
                refreshConfigPanel()
            end
        )
    end)
    resetBtn:SetPoint("TOPLEFT", 20, currentY)

    currentY = currentY - 55

    -- ==========================================
    -- 4. Import & Export Section
    -- ==========================================
    currentY = currentY - 20
    local _, h7 = createDescText(content, L["IMPORT_EXPORT_DESC"] or "Share your configuration with others.", currentY)
    currentY = currentY - h7 - 25

    local exportBtn = createStyledButton(content, 160, 35, L["EXPORT_PROFILE"] or "Export Profile", function()
        showDataPopup(L["EXPORT_PROFILE"] or "Export Profile", false)
    end)
    exportBtn:SetPoint("TOPLEFT", 20, currentY)

    local importBtn = createStyledButton(content, 160, 35, L["IMPORT_PROFILE"] or "Import Profile", function()
        showDataPopup(L["IMPORT_PROFILE"] or "Import Profile", true)
    end)
    importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 20, 0)

    currentY = currentY - 80
    content:SetHeight(math.abs(currentY))
end
