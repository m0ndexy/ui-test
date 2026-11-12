<div align="center">

# LumeUI

**Dark, compact, modern desktop-tool UI library for Roblox.**<br>
Layered near-black surfaces, periwinkle accents, and precision micro-interactions.

<br>

![version](https://img.shields.io/badge/version-1.0.0-7C7CFF?style=flat-square&labelColor=141416)
![style](https://img.shields.io/badge/style-Evenesce_Dark-7C7CFF?style=flat-square&labelColor=141416)
![license](https://img.shields.io/badge/license-MIT-7C7CFF?style=flat-square&labelColor=141416)

[Quick Start](#quick-start) · [Design Tokens](#design-tokens) · [Components](#components) · [Example](Example.luau) · [Showcase](Showcase.luau)

</div>

---

## Overview

LumeUI is a single-file Roblox Luau UI library built on layered dark surfaces. Separation is achieved through subtle surface steps rather than heavy outlines.

- **Layered surfaces**: Panel (`#141416`), Card (`#1A1A1D`), Input/Row (`#202024`), and Hover (`#25252A`).
- **Single periwinkle accent**: `#7C7CFF` applied deliberately to interactive controls.
- **Micro-spring feedback**: `0.98` scale micro-bounce on press with 120–160ms transitions.
- **WCAG contrast verified**: Muted text (`#8E8E99`) maintains over 5:1 contrast against all background surfaces.
- **Accessible & keyboard ready**: Tab focus order, accent focus rings, and Escape dismissals.

---

## Quick Start

### Load via Raw CDN
```lua
local LumeUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/m0ndexy/ui-test/main/Source.luau"))()

local Window = LumeUI:CreateWindow({
    Name = "Lume",
    Subtitle = "Green Screen",
    Backdrop = true, -- Optional backdrop gradient (#8585FF to #5B5BD6)
    Keybind = Enum.KeyCode.RightShift,
    ReducedMotion = false,
})

-- Top-Left Watermark Pill
local Watermark = Window:CreateWatermark({
    Title = "Lume",
    Subtitle = "Green Screen",
})

-- Floating Keybind List
local KeybindList = Window:CreateKeybindList({
    Title = "Keybind list",
    Pinned = true,
})

-- Tab Navigation
local LegitTab = Window:CreateTab({ Name = "Legit", Icon = "rbxassetid://6031265976" })
local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "rbxassetid://6034684930" })

-- Left Column Section
local Aimbot = LegitTab:CreateSection("Aimbot", 1)

Aimbot:CreateToggle({
    Name = "Enable aimbot",
    CurrentValue = true,
    HasChevron = true,
    HasGear = true,
    Callback = function(val)
        print("Aimbot:", val)
    end,
})

Aimbot:CreateSlider({
    Name = "FOV size",
    Range = { 0, 360 },
    CurrentValue = 120,
    Suffix = "px",
    Callback = function(val)
        print("FOV:", val)
    end,
})

Aimbot:CreateRangeSlider({
    Name = "Distance",
    Min = 0,
    Max = 1000,
    Low = 50,
    High = 400,
    Suffix = "m",
    Callback = function(low, high)
        print("Distance range:", low, high)
    end,
})

-- Right Column Section
local Trigger = LegitTab:CreateSection("Triggerbot", 2)

Trigger:CreateToggle({
    Name = "Enable triggerbot",
    CurrentValue = false,
    Disabled = true,
    HasGear = true,
})

Trigger:CreateSlider({
    Name = "Delay",
    Range = { 0, 500 },
    CurrentValue = 120,
    Suffix = "ms",
    Callback = function(val)
        print("Delay:", val)
    end,
})

local WhitelistInput = Trigger:CreateInput({
    Label = "Whitelist player",
    Placeholder = "Username",
})

Trigger:CreateButton({
    Name = "Add to whitelist",
    Callback = function()
        Window:Notify({
            Title = "Lume",
            Content = "Added " .. WhitelistInput.Get() .. " to whitelist",
            Duration = 4,
        })
    end,
})

-- Toast Notification
Window:Notify({
    Title = "Lume",
    Content = "something about making n doing uis",
    Duration = 5,
})
```

---

## Design Tokens

| Token | Value | Hex | Usage |
|---|---|---|---|
| `BackdropTop` | `133, 133, 255` | `#8585FF` | Top of vertical backdrop gradient |
| `BackdropBottom` | `91, 91, 214` | `#5B5BD6` | Bottom of vertical backdrop gradient |
| `PanelSurface` | `20, 20, 22` | `#141416` | Main window shell, floating widgets |
| `CardSurface` | `26, 26, 29` | `#1A1A1D` | Section cards, alternating table rows |
| `InputSurface` | `32, 32, 36` | `#202024` | Input boxes, buttons, search field |
| `HoverRow` | `37, 37, 42` | `#25252A` | Hover feedback surface |
| `Accent` | `124, 124, 255` | `#7C7CFF` | Active checkbox, slider fill, left nav indicator |
| `AccentHover` | `142, 142, 255` | `#8E8EFF` | Secondary logo emblem, accent highlights |
| `TextPrimary` | `242, 242, 245` | `#F2F2F5` | Headings, active nav items, control labels |
| `TextMuted` | `142, 142, 153` | `#8E8E99` | Subtitles, section headers, metadata stats |
| `Border` | `255, 255, 255` | 4% opacity | Subtle 1px separation stroke |
| `RadiusWindow` | `14px` | — | Window corners, keybind list corner |
| `RadiusCard` | `10px` | — | Section cards, notification cards |
| `RadiusRow` | `8px` | — | Inputs, buttons, sidebar rows |

---

## Components

1. **Main Window**: Left sidebar (logo emblem, product title, live search box, nav items with 3px `#7C7CFF` left bar) + Right content zone (top bar category dropdown, breadcrumb `Page > Subpage`, 2-column cards).
2. **Section Cards & Rows**:
   - **Checkbox**: Accent fill with crisp checkmark, right-aligned chevron and gear buttons.
   - **Slider**: Left label, right primary text value, thin track with accent fill, thumb visible on hover.
   - **Range Slider**: Dual-range selection (e.g. `50m - 400m`) with accent track.
   - **Text Input**: `#202024` surface, placeholder, and accent focus ring on active typing.
   - **Button**: Full-width `#202024` button with 0.98 press micro-spring.
   - **Disabled Row**: Muted text with blank, non-interactive checkbox.
3. **Watermark Pill**: Floating top-left pill (`[Logo] [Name] | [Subtitle] | [FPS] | [Ping] | [Clock]`) with live FPS and ping telemetry.
4. **Keybind List Widget**: Floating draggable widget with pin toggle, alternating rows, headers (`Function`, `Hotkey`, `Status`), and `...` status cycler.
5. **Toast Notification**: Floating notification card with icon, title, close `×`, and a draining `#7C7CFF` progress bar that slides out automatically.

---

## Standalone File

To run the complete library and showcase without any external network fetches, load `Showcase.luau`:

```lua
-- In Roblox Studio Command Bar or Executor:
loadstring(readfile("Showcase.luau"))()
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.
