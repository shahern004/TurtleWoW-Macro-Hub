---------------------------------------------------------------
-- DoiteSettings.lua
-- Settings UI for DoiteAuras
-- Please respect license note: Ask permission
-- WoW 1.12 | Lua 5.0
---------------------------------------------------------------

DoiteSettings = DoiteSettings or {}

local settingsFrame
----------------------------------------
-- Local helpers
----------------------------------------
-- Match "top-most" behavior
local function DS_MakeTopMost(frame)
    if not frame then return end
    frame:SetFrameStrata("TOOLTIP")
end

local function DS_CloseOtherWindows()
    local f

    f = _G["DoiteAurasImportFrame"]
    if f and f.IsShown and f:IsShown() then
        f:Hide()
    end

    f = _G["DoiteAurasExportFrame"]
    if f and f.IsShown and f:IsShown() then
        f:Hide()
    end
end

----------------------------------------
-- Frame
----------------------------------------
local function DS_CreateSettingsFrame()
    if settingsFrame then
        return
    end

    local f = CreateFrame("Frame", "DoiteAurasSettingsFrame", UIParent)
    settingsFrame = f

    -- Size similar to Import frame, same style
    f:SetWidth(250)
    f:SetHeight(350)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    f:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)

    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:SetBackdropColor(0, 0, 0, 1)
    f:SetBackdropBorderColor(1, 1, 1, 1)
    f:SetFrameStrata("TOOLTIP")
    f:Hide()

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -15)
    title:SetText("|cff6FA8DCDoiteSettings|r")

    -- Separator line (same idea as export/import)
    local sep = f:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -35)
    sep:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -35)
    sep:SetTexture(1, 1, 1)
    if sep.SetVertexColor then
        sep:SetVertexColor(1, 1, 1, 0.25)
    end

    -- Close X
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
    close:SetScript("OnClick", function()
        f:Hide()
    end)
	
	-- Coming soon text (center body)
    local coming = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    coming:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -100)
    coming:SetWidth(210)
    coming:SetJustifyH("LEFT")
    coming:SetJustifyV("TOP")
    coming:SetText("Settings coming:\n\n* Soon of CD (Range for sliders & Time)\n* Refresh rate for certain rebuilds (like group)")

    ---------------------------------------------------------------
    -- pfUI border toggle
    ---------------------------------------------------------------
    local pfuiBorderBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    pfuiBorderBtn:SetWidth(120)
    pfuiBorderBtn:SetHeight(20)
    pfuiBorderBtn:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -50)

    local function DS_HasPfUI()
        if type(DoiteAuras_HasPfUI) == "function" then
            return DoiteAuras_HasPfUI() == true
        end
        return false
    end

    local function DS_UpdatePfUIButton()
        local hasPfUI = DS_HasPfUI()

		-- If pfUI exists and the user has no saved choice yet, default ON
		if hasPfUI and DoiteAurasDB and DoiteAurasDB.pfuiBorder == nil then
			DoiteAurasDB.pfuiBorder = true
		end

        -- If pfUI is missing: force OFF first
        if not hasPfUI then
            if DoiteAurasDB then
                DoiteAurasDB.pfuiBorder = false
            end
        end

        -- set label from the final state
        if DoiteAurasDB and DoiteAurasDB.pfuiBorder == true then
            pfuiBorderBtn:SetText("pfUI icons: ON")
        else
            pfuiBorderBtn:SetText("pfUI icons: OFF")
        end

        -- Disable + grey when pfUI missing
        if not hasPfUI then
            if pfuiBorderBtn.Disable then pfuiBorderBtn:Disable() end

            local fs = pfuiBorderBtn.GetFontString and pfuiBorderBtn:GetFontString()
            if fs and fs.SetTextColor then
                fs:SetTextColor(0.6, 0.6, 0.6)
            end
        else
            if pfuiBorderBtn.Enable then pfuiBorderBtn:Enable() end

            local fs = pfuiBorderBtn.GetFontString and pfuiBorderBtn:GetFontString()
            if fs and fs.SetTextColor then
                fs:SetTextColor(1, 0.82, 0)
            end
        end
    end

    pfuiBorderBtn:SetScript("OnClick", function()
        if not DS_HasPfUI() then
            return
        end

        DoiteAurasDB.pfuiBorder = not (DoiteAurasDB.pfuiBorder == true)
        DS_UpdatePfUIButton()

        if type(DoiteAuras_ApplyBorderToAllIcons) == "function" then
            DoiteAuras_ApplyBorderToAllIcons()
        end
        if DoiteAuras_RefreshIcons then
            pcall(DoiteAuras_RefreshIcons)
        end
    end)

    DS_UpdatePfUIButton()

    ---------------------------------------------------------------
    -- Item tooltip toggle
    ---------------------------------------------------------------
    local itemTooltipBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    itemTooltipBtn:SetWidth(120)
    itemTooltipBtn:SetHeight(20)
    itemTooltipBtn:SetPoint("TOPLEFT", pfuiBorderBtn, "BOTTOMLEFT", 0, -5)

    local function DS_UpdateItemTooltipButton()
        if not DoiteAurasDB then DoiteAurasDB = {} end

        -- Default ON if unset
        if DoiteAurasDB.showtooltip == nil then
            DoiteAurasDB.showtooltip = true
        end

        if DoiteAurasDB.showtooltip == true then
            itemTooltipBtn:SetText("Item tooltip: ON")
        else
            itemTooltipBtn:SetText("Item tooltip: OFF")
        end

        -- Always enabled, match pfUI button "enabled" color
        if itemTooltipBtn.Enable then itemTooltipBtn:Enable() end
        local fs = itemTooltipBtn.GetFontString and itemTooltipBtn:GetFontString()
        if fs and fs.SetTextColor then
            fs:SetTextColor(1, 0.82, 0)
        end
    end

    itemTooltipBtn:SetScript("OnClick", function()
        if not DoiteAurasDB then DoiteAurasDB = {} end
        DoiteAurasDB.showtooltip = not (DoiteAurasDB.showtooltip == true)
        DS_UpdateItemTooltipButton()

        -- Refresh so mouse handlers/tooltip scripts are updated immediately
        if DoiteAuras_RefreshIcons then
            pcall(DoiteAuras_RefreshIcons)
        end
    end)

    DS_UpdateItemTooltipButton()

    -- OnShow: enforce exclusivity + top-most
    f:SetScript("OnShow", function()
        DS_CloseOtherWindows()
        DS_MakeTopMost(f)
        DS_UpdatePfUIButton()
        DS_UpdateItemTooltipButton()
    end)

    DS_MakeTopMost(f)
end

-- Public entrypoint called by the Settings button in DoiteAuras.lua
function DoiteAuras_ShowSettings()
    if not settingsFrame then
        DS_CreateSettingsFrame()
    end

    -- If Import/Export are open, close them so only one window is visible
    DS_CloseOtherWindows()

    settingsFrame:Show()
end
----------------------------------------
-- End of frame
----------------------------------------