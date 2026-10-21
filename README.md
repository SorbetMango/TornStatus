# 🏙️ TornStatus — Rainmeter HUD & Status Bar

[![Rainmeter](https://img.shields.io/badge/Rainmeter-4.5%2B-blue.svg)](https://www.rainmeter.net/)
[![Game](https://img.shields.io/badge/Torn%20City-API%20Integrated-green.svg)](https://www.torn.com/)
[![Version](https://img.shields.io/badge/Version-0.1.0-orange.svg)](#)
[![License](https://img.shields.io/badge/License-Free%20to%20use-lightgrey.svg)](#)

A sleek, lightweight, and modern desktop status bar suite for [Torn City](https://www.torn.com/) players, powered by [Rainmeter](https://www.rainmeter.net/). Monitor your vital stats, travel progress, cooldowns, and faction wars directly on your desktop without cluttering your browser.

---

## ✨ Features

- **⚡ Live Vitals & Timers**: Energy, Nerve, Life, and Happy with full-time indicators and automatic status color coding.
- **✈️ Interactive Travel Tracker**:
  - Real-time progress bar tracking destination, remaining flight time, and ETA.
  - Direction-aware airplane indicator (outbound vs. returning).
  - Hospital & Jail progress counters with dynamic color themes.
- **💊 Cooldown Monitoring**: Drug, Medical, and Booster cooldown timers with active / ready states.
- **⚔️ Ranked War Alerts**: Live war state, opponent names, countdown timer, and faction vs. enemy scoreboards.
- **💵 Cash & Financials**: Live on-hand cash display with quick links to the Stock Market and City Bank.
- **🔔 Notifications**: Unread message indicator (`✉`) and events counter (`!`) linking straight to Torn.
- **🖥️ Multi-Size & Multi-Monitor Support**:
  - **Small (510px)**: Compact bar perfect for secondary monitors or tight desktop setups.
  - **Medium (1920px)**: Full HD widescreen layout.
  - **Large (3840px)**: Designed for 4K and ultrawide resolutions.
  - *Run multiple bars simultaneously across different screens!*
- **🚀 Local API Cache Architecture**:
  - Status bars cache the latest API response locally (`@Resources/Cache/user.json`).
  - Modular popups open instantly (0 ms latency) without consuming extra API calls or risking rate limits (100 req/min).
- **🛡️ Safe `.rmskin` Updates**: User settings (`APIKey`, `BgAlpha`, custom theme colors) are isolated in `UserVariables.inc` so they are **never overwritten** when updating.
- **⚙️ Integrated GUI Settings**: One-click API key setup, theme switches (Dark / Light), opacity controls, and independent bar toggles.

---

## 📸 Preview & Bar Layout

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ Okay // TORN CITY   💵 $1,132,775   ⚔ 1,420 vs 980          🚀 🏥 💊   ⚡ 🔥   ✉ 🔔 ↻ │
│ [==================================== ✈ =============================================] │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📥 Installation

### Method 1: `.rmskin` Package (Recommended)
1. Download the latest `TornStatus.rmskin` from the [Releases](#) tab.
2. Double-click the file to open the Rainmeter Skin Installer.
3. Click **Install**.
4. The Settings window will automatically open (or right-click the bar ➔ **Open Settings**).
5. Paste your Torn API Key and click **Save**.

### Method 2: Manual Installation (Git)
1. Clone this repository into your Rainmeter skins directory:
   ```bash
   git clone https://github.com/YourUsername/TornStatus.git "%USERPROFILE%\Documents\Rainmeter\Skins\TornStatus"
   ```
2. Open Rainmeter, click **Refresh All** in the Manage window.
3. Expand `TornStatus` ➔ `StatusBar` ➔ choose `Small`, `Medium`, or `Large` and click **Load**.

---

## 🔑 Getting Your Torn API Key

1. Log into your account on [Torn City](https://www.torn.com/).
2. Navigate to your [API Preferences](https://www.torn.com/preferences.php#tab=api).
3. Generate a key with at least **Public / Minimal** access (or use an existing key).
4. Paste it into the `TornStatus` Settings window.

> [!NOTE]
> **Privacy & Security**: Your API key is stored locally on your machine in `@Resources\UserVariables.inc`. It is **never** shared, transmitted, or logged anywhere other than making direct HTTPS requests to `api.torn.com`.

---

## 🎮 Controls & Shortcuts

| Action | Control | Result |
| :--- | :--- | :--- |
| **Open Settings** | Right-click bar ➔ `Open Settings` | Opens configuration GUI |
| **Toggle Overview Popup** | Right-click bar ➔ `Toggle Overview Popup` | Opens/closes instant cached overview window |
| **Force API Refresh** | Click `↻` (Sync icon) | Triggers immediate API fetch |
| **Open Torn Pages** | Click any status icon (⚡, 🔥, 💊, ✉, 💵, etc.) | Opens the corresponding Torn page in your browser |
| **Move / Position** | Click & drag (when Draggable is enabled in Rainmeter) | Repositions the bar on your screen |

---

## 🏗️ Architecture & Development

The suite is structured for modularity, clean code separation, and safe packaging:

```text
TornStatus/
├── @Resources/
│   ├── UserVariables.inc       # User preferences (APIKey, opacity, theme). Protected during updates!
│   ├── SystemVariables.inc     # Static internal variables (Version, fonts, color palettes).
│   ├── Settings.inc            # Legacy wrapper for backward compatibility.
│   ├── Include/
│   │   ├── TornAPI.inc         # Core WebParser measures, state variables & Lua bridge.
│   │   └── Updater.inc         # GitHub remote version comparison stub.
│   ├── Cache/                  # Local cached API payloads (user.json, faction.json).
│   └── Lua/
│       ├── json.lua            # Pure Lua JSON parser.
│       └── TornParser.lua      # Business logic: timers, formatters, and cache persistence.
├── StatusBar/
│   ├── Small/StatusBarSmall.ini       # 510px config
│   ├── Medium/StatusBarMedium.ini     # 1920px config
│   └── Large/StatusBarLarge.ini       # 3840px / 4K config
├── Popups/
│   └── TemplatePopup/TemplatePopup.ini # Zero-API-call modal popup consuming local Cache
└── Settings/
    └── Settings.ini            # Configuration manager window
```

### Adding New Pop-ups
To build a custom popup (e.g. Travel details, Chain counter, Stock portfolio):
1. Create a new folder under `Popups\<YourPopupName>\`.
2. Add your `.ini` file including `#@#UserVariables.inc` and `#@#SystemVariables.inc`.
3. Use `WebParser` pointing to `file://#UserCacheFile#` to read the cached data without triggering network requests.
4. Call `[!ToggleConfig "TornStatus\Popups\<YourPopupName>" "<YourPopupName>.ini"]` from any meter on the main status bar.

---

## 🎁 Support & Credits

- **Author**: `Sorbeta_Mango` [`4034124`]
- **License**: Free to use and modify. Credit appreciated!
- **Donations / Tips**: If you find this skin useful, in-game tips or items sent to [Sorbeta_Mango [4034124]](https://www.torn.com/profiles.php?XID=4034124) are warmly welcomed!
