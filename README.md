<h1 align="center">BazFlightZoom</h1>

<p align="center">
  <strong>Auto-zoom camera and minimap when flying</strong><br/>
  Zooms out when you take flight, restores your previous zoom on dismount.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/WoW-12.0%20Midnight-blue" alt="WoW Version"/>
  <img src="https://img.shields.io/badge/License-GPL%20v2-green" alt="License"/>
  <img src="https://img.shields.io/badge/Version-001-orange" alt="Version"/>
</p>

---

## What is BazFlightZoom?

BazFlightZoom automatically zooms out your game camera and minimap when you take flight on a flying mount or dragonriding. When you dismount, both are smoothly restored to their previous zoom levels. Ground mounts are ignored.

Simple, lightweight, no configuration required — just install and fly.

---

## Features

- **Camera zoom out** — automatically zooms to max camera distance when airborne
- **Minimap zoom out** — zooms the minimap to maximum range for better navigation while flying
- **Smart detection** — only triggers on flying mounts, not ground mounts
- **Remembers your zoom** — saves your exact camera distance and minimap zoom before changing them
- **Clean restore** — returns to your previous zoom levels on dismount
- **Per-feature toggles** — independently enable/disable camera zoom and minimap zoom
- **Zero dependencies** — no libraries, completely standalone

---

## Settings

Open via `/bfz settings` or WoW Settings → AddOns → BazFlightZoom.

| Setting | Description |
|---------|-------------|
| Enable BazFlightZoom | Toggle the addon on or off |
| Zoom Camera Out | Zoom the game camera to max distance while flying |
| Zoom Minimap Out | Zoom the minimap to maximum range while flying |

---

## Slash Commands

| Command | Description |
|---------|-------------|
| `/bfz` | Toggle addon on/off |
| `/bfz camera` | Toggle camera zoom |
| `/bfz minimap` | Toggle minimap zoom |
| `/bfz settings` | Open settings panel |
| `/bfz help` | Show all commands |

---

## Installation

### CurseForge / WoW Addon Manager
Search for **BazFlightZoom** in your addon manager of choice.

### Manual Installation
1. Download the latest release
2. Extract to `World of Warcraft/_retail_/Interface/AddOns/BazFlightZoom/`
3. Restart WoW or `/reload`

---

## Compatibility

| | |
|---|---|
| **WoW Version** | Retail 12.0.1 (Midnight) |
| **Dependencies** | None — completely standalone |

---

## License

BazFlightZoom is licensed under the [GNU General Public License v2](LICENSE) (GPL v2).

---

<p align="center">
  <sub>Built by <strong>Baz4k</strong></sub>
</p>
