> **Warning: Requires [BazCore](https://www.curseforge.com/wow/addons/bazcore).** If you use the CurseForge app, it will be installed automatically. Manual users must install BazCore separately.

# BazFlightZoom

![WoW](https://img.shields.io/badge/WoW-12.0_Midnight-blue) ![License](https://img.shields.io/badge/License-GPL_v2-green) ![Version](https://img.shields.io/github/v/tag/bazsec/BazFlightZoom?label=Version&color=orange)

Automatically zooms out your camera and minimap when you take flight, and restores your previous zoom levels when you land.

BazFlightZoom detects when you mount a flying mount and smoothly zooms your camera out to maximum distance so you get a full view of the world. When you dismount, it restores your previous camera and minimap zoom levels so you're right back where you started. Simple, automatic, no keybinds needed.

***

## Features

*   **Auto camera zoom** on flying mount with configurable max distance (5-50)
*   **Smooth zoom** option - gradual transition instead of instant snap
*   **Configurable zoom delay** after mounting before zoom kicks in
*   **Minimap zoom** - optionally zoom out the minimap while flying
*   **Ground mount zoom** - optional separate zoom for ground mounts with its own distance setting
*   **Auto restore** - previous zoom levels restored on dismount
*   **Profile support** for per-character settings via BazCore

***

## Slash Commands

| Command | Description |
| --- | --- |
| `/bfz` | Open settings panel |
| `/bfz camera` | Toggle camera zoom on/off |
| `/bfz minimap` | Toggle minimap zoom on/off |
| `/bazflightzoom` | Alias for `/bfz` |

***

## Compatibility

*   **WoW Version:** Retail 12.0 (Midnight)
*   **Combat Safe:** Uses CVar manipulation only, no secure frame interaction

***

## Dependencies

**Required:**

*   [BazCore](https://www.curseforge.com/wow/addons/bazcore) - shared framework for Baz Suite addons

***

## Part of the Baz Suite

BazFlightZoom is part of the **Baz Suite** of addons, all built on the [BazCore](https://www.curseforge.com/wow/addons/bazcore) framework:

*   **[BazBars](https://www.curseforge.com/wow/addons/bazbars)** - Custom extra action bars
*   **[BazWidgetDrawers](https://www.curseforge.com/wow/addons/bazwidgetdrawers)** - Slide-out widget drawer
*   **[BazWidgets](https://www.curseforge.com/wow/addons/bazwidgets)** - Widget pack for BazWidgetDrawers
*   **[BazNotificationCenter](https://www.curseforge.com/wow/addons/baznotificationcenter)** - Toast notification system
*   **[BazLootNotifier](https://www.curseforge.com/wow/addons/bazlootnotifier)** - Animated loot popups
*   **[BazFlightZoom](https://www.curseforge.com/wow/addons/bazflightzoom)** - Auto zoom on flying mounts
*   **[BazMap](https://www.curseforge.com/wow/addons/bazmap)** - Resizable map and quest log window
*   **[BazMapPortals](https://www.curseforge.com/wow/addons/bazmapportals)** - Mage portal/teleport map pins

***

## License

BazFlightZoom is licensed under the **GNU General Public License v2** (GPL v2).
