---------------------------------------------------------------------------
-- BazFlightZoom User Guide
---------------------------------------------------------------------------

if not BazCore or not BazCore.RegisterUserGuide then return end

BazCore:RegisterUserGuide("BazFlightZoom", {
    title = "BazFlightZoom",
    intro = "Automatically zooms your camera (and optionally your minimap) out when you take flight, then restores your previous zoom on dismount.",
    pages = {
        {
            title = "Welcome",
            blocks = {
                { type = "lead", text = "BazFlightZoom (BFZ) detects when you mount a flying mount and smoothly zooms your camera out for a full view of the world. When you dismount, it restores your previous camera and minimap zoom levels — you're right back where you started." },
                { type = "note", style = "tip", text = "No keybinds. No macros. No interaction needed." },
            },
        },
        {
            title = "How It Works",
            blocks = {
                { type = "paragraph", text = "BFZ scans your active buffs for the flying-mount aura on a short interval. When detected, it kicks off the zoom; when the aura drops, it restores your previous values." },
                { type = "note", style = "info", text = "Uses CVars only — no secure frame interaction, fully combat-safe." },
            },
        },
        {
            title = "Camera Zoom",
            blocks = {
                { type = "lead", text = "Settings for the main camera." },
                { type = "table",
                  columns = { "Setting", "Range", "Default" },
                  rows = {
                      { "Max Distance", "5–50",  "50 (the max WoW allows)" },
                      { "Smooth Zoom",  "on/off", "on" },
                      { "Zoom Delay",   "0–3 s",  "0.3 s" },
                  },
                },
                { type = "h3", text = "Smooth Zoom" },
                { type = "paragraph", text = "When enabled, the zoom transitions gradually instead of snapping. Looks more cinematic." },
                { type = "h3", text = "Zoom Delay" },
                { type = "paragraph", text = "How long to wait after mounting before zoom kicks in. Useful if you want a brief moment of the mount-up animation before the camera pulls back." },
            },
        },
        {
            title = "Minimap Zoom",
            blocks = {
                { type = "paragraph", text = "Optionally also zoom the minimap out while flying. Handy for spotting nodes, NPCs, and rare spawns from altitude." },
                { type = "note", style = "info", text = "Disable to leave the minimap at its current zoom." },
            },
        },
        {
            title = "Ground Mounts",
            blocks = {
                { type = "paragraph", text = "Optional separate zoom for ground mounts with its own distance setting. Disabled by default — most users only want the flight zoom — but if you also like a wider view while ground-riding, enable it and set your preferred distance." },
            },
        },
        {
            title = "Restore on Dismount",
            blocks = {
                { type = "paragraph", text = "When the flying aura drops, BFZ restores your previous camera and minimap zoom." },
                { type = "note", style = "info", text = "The values are captured at mount-up time, so whatever you had before is what you get back." },
            },
        },
        {
            title = "Slash Commands",
            blocks = {
                { type = "table",
                  columns = { "Command", "Effect" },
                  rows = {
                      { "/bfz",           "Open the BazFlightZoom settings page" },
                      { "/bfz camera",    "Toggle camera zoom on/off" },
                      { "/bfz minimap",   "Toggle minimap zoom on/off" },
                      { "/bazflightzoom", "Alias for /bfz — every subcommand works on either form" },
                  },
                },
            },
        },
    },
})
