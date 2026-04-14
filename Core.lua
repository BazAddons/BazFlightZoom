-- BazFlightZoom Core
-- Auto-zoom camera and minimap when flying, powered by BazCore

local ADDON_NAME = "BazFlightZoom"

local addon
addon = BazCore:RegisterAddon(ADDON_NAME, {
    title = "BazFlightZoom",
    savedVariable = "BazFlightZoomSV",
    profiles = true,
    defaults = {
        enabled        = true,
        zoomCamera     = true,
        zoomMinimap    = true,
        cameraDistance  = 50,
        minimapZoom    = 0,
        zoomSpeed      = 0,
        zoomDelay      = 0.3,
        groundMount    = false,
        groundDistance  = 20,
    },

    slash = { "/bfz", "/bazflightzoom" },
    commands = {
        camera = {
            desc = "Toggle camera zoom",
            handler = function()
                local new = not addon:GetSetting("zoomCamera")
                addon:SetSetting("zoomCamera", new)
                addon:Print("Camera zoom " .. (new and "|cff00ff00ON|r" or "|cffff4444OFF|r"))
            end,
        },
        minimap = {
            desc = "Toggle minimap zoom",
            handler = function()
                local new = not addon:GetSetting("zoomMinimap")
                addon:SetSetting("zoomMinimap", new)
                addon:Print("Minimap zoom " .. (new and "|cff00ff00ON|r" or "|cffff4444OFF|r"))
            end,
        },
    },

    minimap = {
        label = "BazFlightZoom",
        icon = 135992,
    },

    onReady = function(self)
        self:SetupEvents()
    end,
})

-- addon.db is auto-wired by BazCore:CreateDBProxy() in RegisterAddon

---------------------------------------------------------------------------
-- Zoom Logic
---------------------------------------------------------------------------

local savedCameraZoom = nil
local savedMinimapZoom = nil
local isZoomedOut = false
local zoomType = nil -- "flying" or "ground"

local IsMounted = IsMounted
local GetCameraZoom = GetCameraZoom
local CameraZoomOut = CameraZoomOut
local CameraZoomIn = CameraZoomIn

-- Mount type IDs that can fly
local FLYING_MOUNT_TYPES = {
    [230] = true, -- Flying
    [241] = true, -- AQ40
    [247] = true, -- Red Flying Cloud
    [248] = true, -- Flying (old)
    [402] = true, -- Dragonriding
    [407] = true, -- Dynamic flight
    [424] = true, -- Steady flight
}

local function IsOnFlyingMount()
    for i = 1, 40 do
        local auraData = C_UnitAuras.GetBuffDataByIndex("player", i)
        if not auraData then break end
        local rawSpellID = auraData.spellId
        if rawSpellID then
            -- Strip secret number taint (Midnight)
            local ok, cleanID = pcall(function() return rawSpellID + 0 end)
            if not ok then
                ok, cleanID = pcall(function() return tonumber(string.format("%d", rawSpellID)) end)
            end
            local spellID = ok and cleanID or nil
            if not spellID then break end
            local mountIDs = C_MountJournal.GetMountIDs()
            for _, mountID in ipairs(mountIDs) do
                local name, mSpellID, _, _, _, _, _, _, _, _, _, mID = C_MountJournal.GetMountInfoByID(mountID)
                if mSpellID == spellID then
                    local _, _, _, _, mountTypeID = C_MountJournal.GetMountInfoExtraByID(mountID)
                    return FLYING_MOUNT_TYPES[mountTypeID] == true
                end
            end
        end
    end
    return false
end

local function ZoomCameraTo(targetDistance)
    local current = GetCameraZoom()
    local delta = targetDistance - current
    if delta > 0.5 then
        CameraZoomOut(delta)
    elseif delta < -0.5 then
        CameraZoomIn(-delta)
    end
end

local function SmoothZoomTo(targetDistance, speed)
    local steps = math.max(1, math.floor(speed * 10))
    local i = 0
    C_Timer.NewTicker(0.03, function(ticker)
        i = i + 1
        if i >= steps then
            ticker:Cancel()
            ZoomCameraTo(targetDistance)
            return
        end
        local current = GetCameraZoom()
        local remaining = steps - i
        local stepSize = (targetDistance - current) / remaining
        if stepSize > 0 then CameraZoomOut(stepSize)
        elseif stepSize < 0 then CameraZoomIn(-stepSize) end
    end)
end

local function DoZoom(targetDistance)
    if addon:GetSetting("zoomCamera") then
        savedCameraZoom = GetCameraZoom()
        local current = savedCameraZoom
        if math.abs(targetDistance - current) > 0.5 then
            local speed = addon:GetSetting("zoomSpeed") or 0
            if speed > 0 then
                SmoothZoomTo(targetDistance, speed)
            else
                ZoomCameraTo(targetDistance)
            end
        end
    end

    if addon:GetSetting("zoomMinimap") then
        savedMinimapZoom = Minimap:GetZoom()
        local targetZoom = addon:GetSetting("minimapZoom") or 0
        C_Timer.After(0.2, function()
            if isZoomedOut then
                Minimap:SetZoom(targetZoom)
            end
        end)
    end

    isZoomedOut = true
end

local function ZoomRestore()
    if not isZoomedOut then return end

    if savedCameraZoom and addon:GetSetting("zoomCamera") then
        local speed = addon:GetSetting("zoomSpeed") or 0
        if speed > 0 then
            SmoothZoomTo(savedCameraZoom, speed)
        else
            ZoomCameraTo(savedCameraZoom)
        end
        savedCameraZoom = nil
    end

    if savedMinimapZoom and addon:GetSetting("zoomMinimap") then
        Minimap:SetZoom(savedMinimapZoom)
        savedMinimapZoom = nil
    end

    isZoomedOut = false
    zoomType = nil
end

local function OnMountChanged()
    if not addon:GetSetting("enabled") then return end

    if IsMounted() then
        local delay = addon:GetSetting("zoomDelay") or 0.3
        C_Timer.After(math.max(0.1, delay), function()
            if not IsMounted() then return end
            if isZoomedOut then return end

            if IsOnFlyingMount() then
                zoomType = "flying"
                DoZoom(addon:GetSetting("cameraDistance") or 50)
            elseif addon:GetSetting("groundMount") then
                zoomType = "ground"
                DoZoom(addon:GetSetting("groundDistance") or 20)
            end
        end)
    else
        ZoomRestore()
    end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

function addon:SetupEvents()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    frame:SetScript("OnEvent", function()
        C_Timer.After(0.1, OnMountChanged)
    end)
end

---------------------------------------------------------------------------
-- Options (BazCore OptionsPanel)
---------------------------------------------------------------------------

local function GetLandingPage()
    return BazCore:CreateLandingPage("BazFlightZoom", {
        subtitle = "Auto-zoom on flight",
        description = "Automatically zooms out the camera and minimap when you take flight, and restores them when you land. " ..
            "Supports flying mounts and optionally ground mounts with separate distance settings.",
        features = "Configurable camera distance, zoom speed, and delay. " ..
            "Minimap zoom out on flight with auto-restore on land. " ..
            "Optional ground mount zoom with separate distance. " ..
            "Smooth zoom transitions.",
        guide = {
            { "Mount Up", "Camera and minimap zoom out automatically when you fly" },
            { "Dismount", "Everything restores to your normal view" },
            { "Customize", "Open Settings to adjust distance, speed, and delay" },
        },
    })
end

local function GetSettingsPage()
    return {
        name = "Settings",
        type = "group",
        args = {
            intro = {
                order = 0.1,
                type = "lead",
                text = "Configure how far the camera and minimap zoom out when you take flight, and what changes when you land.",
            },
            generalHeader = {
                order = 1,
                type = "header",
                name = "General",
            },
            enabled = {
                order = 2,
                type = "toggle",
                name = "Enable BazFlightZoom",
                desc = "Toggle the addon on or off",
                get = function() return addon:GetSetting("enabled") ~= false end,
                set = function(_, val) addon:SetSetting("enabled", val) end,
            },

            cameraHeader = {
                order = 10,
                type = "header",
                name = "Camera",
            },
            zoomCamera = {
                order = 11,
                type = "toggle",
                name = "Zoom Camera Out",
                desc = "Zoom the game camera when mounted",
                get = function() return addon:GetSetting("zoomCamera") ~= false end,
                set = function(_, val) addon:SetSetting("zoomCamera", val) end,
            },
            cameraDistance = {
                order = 12,
                type = "range",
                name = "Flight Camera Distance",
                min = 5, max = 50, step = 1,
                get = function() return addon:GetSetting("cameraDistance") or 50 end,
                set = function(_, val) addon:SetSetting("cameraDistance", val) end,
            },
            zoomSpeed = {
                order = 13,
                type = "range",
                name = "Zoom Speed",
                desc = "0 = instant, higher = slower smooth transition",
                min = 0, max = 3, step = 0.1,
                get = function() return addon:GetSetting("zoomSpeed") or 0 end,
                set = function(_, val) addon:SetSetting("zoomSpeed", val) end,
            },
            zoomDelay = {
                order = 14,
                type = "range",
                name = "Zoom Delay (sec)",
                desc = "Wait before zooming after mounting",
                min = 0.1, max = 3, step = 0.1,
                get = function() return addon:GetSetting("zoomDelay") or 0.3 end,
                set = function(_, val) addon:SetSetting("zoomDelay", val) end,
            },

            minimapHeader = {
                order = 20,
                type = "header",
                name = "Minimap",
            },
            zoomMinimap = {
                order = 21,
                type = "toggle",
                name = "Zoom Minimap Out",
                desc = "Zoom the minimap when flying",
                get = function() return addon:GetSetting("zoomMinimap") ~= false end,
                set = function(_, val) addon:SetSetting("zoomMinimap", val) end,
            },
            minimapZoom = {
                order = 22,
                type = "range",
                name = "Minimap Zoom Level",
                desc = "0 = fully zoomed out, 5 = close",
                min = 0, max = 5, step = 1,
                get = function() return addon:GetSetting("minimapZoom") or 0 end,
                set = function(_, val) addon:SetSetting("minimapZoom", val) end,
            },

            groundHeader = {
                order = 30,
                type = "header",
                name = "Ground Mounts",
            },
            groundMount = {
                order = 31,
                type = "toggle",
                name = "Zoom on Ground Mounts",
                desc = "Also zoom out when on a ground mount",
                get = function() return addon:GetSetting("groundMount") or false end,
                set = function(_, val) addon:SetSetting("groundMount", val) end,
            },
            groundDistance = {
                order = 32,
                type = "range",
                name = "Ground Camera Distance",
                min = 5, max = 50, step = 1,
                get = function() return addon:GetSetting("groundDistance") or 20 end,
                set = function(_, val) addon:SetSetting("groundDistance", val) end,
            },
        },
    }
end

addon.config.onLoad = function(self)
    BazCore:RegisterOptionsTable(ADDON_NAME, GetLandingPage)
    BazCore:AddToSettings(ADDON_NAME, "BazFlightZoom")

    BazCore:RegisterOptionsTable(ADDON_NAME .. "-Settings", GetSettingsPage)
    BazCore:AddToSettings(ADDON_NAME .. "-Settings", "Settings", ADDON_NAME)
end
