local ADDON_NAME = "BazFlightZoom"

-- Saved variables and defaults
local DEFAULTS = {
    enabled     = true,
    zoomCamera  = true,
    zoomMinimap = true,
}

local db
local savedCameraZoom = nil
local savedMinimapZoom = nil
local isZoomedOut = false
local flyCheckTicker = nil

-- Localized globals
local IsMounted = IsMounted
local IsFlying = IsFlying
local GetCameraZoom = GetCameraZoom
local CameraZoomOut = CameraZoomOut
local CameraZoomIn = CameraZoomIn

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function GetSetting(key)
    if db and db[key] ~= nil then return db[key] end
    return DEFAULTS[key]
end

local function SetSetting(key, value)
    BazFlightZoomSV = BazFlightZoomSV or {}
    BazFlightZoomSV[key] = value
    db = BazFlightZoomSV
end

---------------------------------------------------------------------------
-- Zoom Logic
---------------------------------------------------------------------------

local function ZoomOut()
    if isZoomedOut then return end

    -- Save current zoom levels
    if GetSetting("zoomCamera") then
        savedCameraZoom = GetCameraZoom()
        CameraZoomOut(50) -- zoom to max
    end

    if GetSetting("zoomMinimap") then
        savedMinimapZoom = Minimap:GetZoom()
        Minimap:SetZoom(0) -- fully zoomed out
    end

    isZoomedOut = true
end

local function ZoomRestore()
    if not isZoomedOut then return end

    -- Restore camera
    if savedCameraZoom and GetSetting("zoomCamera") then
        local current = GetCameraZoom()
        local delta = current - savedCameraZoom
        if delta > 0 then
            CameraZoomIn(delta)
        elseif delta < 0 then
            CameraZoomOut(-delta)
        end
        savedCameraZoom = nil
    end

    -- Restore minimap
    if savedMinimapZoom and GetSetting("zoomMinimap") then
        Minimap:SetZoom(savedMinimapZoom)
        savedMinimapZoom = nil
    end

    isZoomedOut = false
end

local function CancelFlyCheck()
    if flyCheckTicker then
        flyCheckTicker:Cancel()
        flyCheckTicker = nil
    end
end

local function OnMountChanged()
    if not GetSetting("enabled") then return end

    if IsMounted() then
        -- Start checking if we're flying (not instant on mount)
        CancelFlyCheck()
        local checks = 0
        flyCheckTicker = C_Timer.NewTicker(0.5, function()
            checks = checks + 1
            if IsFlying() then
                CancelFlyCheck()
                ZoomOut()
            elseif checks >= 10 then
                -- 5 seconds passed, not flying — ground mount, cancel
                CancelFlyCheck()
            end
        end)
    else
        -- Dismounted
        CancelFlyCheck()
        ZoomRestore()
    end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        BazFlightZoomSV = BazFlightZoomSV or {}
        db = BazFlightZoomSV
        for k, v in pairs(DEFAULTS) do
            if db[k] == nil then db[k] = v end
        end
        print("|cff3399ffBazFlightZoom|r loaded. Type |cff00ff00/bfz|r for commands.")
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
        -- Small delay to let mount state settle
        C_Timer.After(0.1, OnMountChanged)
    end
end)

---------------------------------------------------------------------------
-- Slash Commands
---------------------------------------------------------------------------

SLASH_BAZFLIGHTZOOM1 = "/bfz"
SLASH_BAZFLIGHTZOOM2 = "/bazflightzoom"
SlashCmdList["BAZFLIGHTZOOM"] = function(msg)
    local cmd = strlower(strtrim(msg))
    if cmd == "" or cmd == "toggle" then
        local new = not GetSetting("enabled")
        SetSetting("enabled", new)
        print("|cff3399ffBazFlightZoom|r: " .. (new and "|cff00ff00Enabled|r" or "|cffff4444Disabled|r"))
    elseif cmd == "camera" then
        local new = not GetSetting("zoomCamera")
        SetSetting("zoomCamera", new)
        print("|cff3399ffBazFlightZoom|r: Camera zoom " .. (new and "|cff00ff00ON|r" or "|cffff4444OFF|r"))
    elseif cmd == "minimap" then
        local new = not GetSetting("zoomMinimap")
        SetSetting("zoomMinimap", new)
        print("|cff3399ffBazFlightZoom|r: Minimap zoom " .. (new and "|cff00ff00ON|r" or "|cffff4444OFF|r"))
    elseif cmd == "settings" then
        if BazFlightZoom_SettingsCategory then
            Settings.OpenToCategory(BazFlightZoom_SettingsCategory:GetID())
        end
    elseif cmd == "help" then
        print("|cff3399ffBazFlightZoom|r commands:")
        print("  |cff00ff00/bfz|r - Toggle addon on/off")
        print("  |cff00ff00/bfz camera|r - Toggle camera zoom")
        print("  |cff00ff00/bfz minimap|r - Toggle minimap zoom")
        print("  |cff00ff00/bfz settings|r - Open settings")
    else
        print("|cff3399ffBazFlightZoom|r: Unknown command. Type |cff00ff00/bfz help|r")
    end
end

---------------------------------------------------------------------------
-- Settings Panel
---------------------------------------------------------------------------

local function InitSettings()
    local panel = CreateFrame("Frame", nil, UIParent)
    panel:Hide()

    local PAD = 16
    local CBSIZE = 20
    local yPos = -PAD

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", PAD, yPos)
    title:SetText("BazFlightZoom")
    yPos = yPos - 20

    local sub = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", PAD, yPos)
    sub:SetText("Automatically zooms out when flying, restores on dismount")
    sub:SetTextColor(0.6, 0.6, 0.6)
    yPos = yPos - 30

    local function Checkbox(key, labelText, descText)
        local cb = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", PAD, yPos)
        cb:SetSize(CBSIZE, CBSIZE)
        cb:SetChecked(GetSetting(key))

        local label = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        label:SetText(labelText)

        cb:SetScript("OnClick", function(self)
            SetSetting(key, self:GetChecked())
        end)
        yPos = yPos - CBSIZE - 2

        if descText then
            local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            desc:SetPoint("TOPLEFT", PAD + CBSIZE + 4, yPos)
            desc:SetText(descText)
            desc:SetTextColor(0.5, 0.5, 0.5)
            desc:SetWidth(400)
            desc:SetJustifyH("LEFT")
            yPos = yPos - 16
        end
        yPos = yPos - 8
    end

    Checkbox("enabled", "Enable BazFlightZoom", "Toggle the addon on or off")
    Checkbox("zoomCamera", "Zoom Camera Out", "Zoom the game camera to max distance while flying")
    Checkbox("zoomMinimap", "Zoom Minimap Out", "Zoom the minimap to maximum range while flying")

    local category = Settings.RegisterCanvasLayoutCategory(panel, "BazFlightZoom")
    Settings.RegisterAddOnCategory(category)
    BazFlightZoom_SettingsCategory = category
end

EventUtil.ContinueOnAddOnLoaded(ADDON_NAME, InitSettings)
