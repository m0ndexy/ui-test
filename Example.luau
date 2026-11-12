--[[
    LumeUI Showcase — Evenesce Visual Style Reproduction
    Matches media_1794460789076_04071a2d.jpg with full fidelity
    
    Tokens:
      - Backdrop: #8585FF to #5B5BD6
      - Panel: #141416 | Card: #1A1A1D | Input/Row: #202024 | Hover: #25252A
      - Accent: #7C7CFF
      - Typography: 18px Title | 14px Body | 12px Muted
      - Radius: 14px Window | 10px Card | 8px Row | 16px Pill
]]

local LumeUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/m0ndexy/ui-test/main/Source.luau"))()

local Window = LumeUI:CreateWindow({
    Name = "Lume",
    Subtitle = "Green Screen",
    Backdrop = true, -- Displays the screenshot backdrop gradient (#8585FF -> #5B5BD6)
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

-- Navigation Tabs
local LegitTab = Window:CreateTab({
    Name = "Legit",
    Icon = "rbxassetid://6031265976", -- Crosshair line icon
})

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "rbxassetid://6034684930", -- Eye line icon
})

-- Left Column: Aimbot
local AimbotSection = LegitTab:CreateSection("Aimbot", 1)

local AimbotToggle = AimbotSection:CreateToggle({
    Name = "Enable aimbot",
    CurrentValue = true,
    HasChevron = true,
    HasGear = true,
    OnGearClick = function()
        Window:Notify({
            Title = "Lume",
            Content = "Opened Aimbot Advanced Settings",
            Duration = 3,
        })
    end,
    Callback = function(val)
        print("[Lume] Aimbot toggled:", val)
    end,
})

local FovSlider = AimbotSection:CreateSlider({
    Name = "FOV size",
    Range = { 0, 360 },
    CurrentValue = 120,
    Increment = 1,
    Suffix = "px",
    Callback = function(val)
        print("[Lume] FOV size:", val)
    end,
})

local DistanceSlider = AimbotSection:CreateRangeSlider({
    Name = "Distance",
    Min = 0,
    Max = 1000,
    Low = 50,
    High = 400,
    Suffix = "m",
    Callback = function(low, high)
        print(string.format("[Lume] Distance Range: %dm - %dm", low, high))
    end,
})

-- Right Column: Triggerbot
local TriggerSection = LegitTab:CreateSection("Triggerbot", 2)

local TriggerToggle = TriggerSection:CreateToggle({
    Name = "Enable triggerbot",
    CurrentValue = false,
    Disabled = true,
    HasGear = true,
})

local DelaySlider = TriggerSection:CreateSlider({
    Name = "Delay",
    Range = { 0, 500 },
    CurrentValue = 120,
    Increment = 5,
    Suffix = "ms",
    Callback = function(val)
        print("[Lume] Trigger Delay:", val)
    end,
})

local WhitelistInput = TriggerSection:CreateInput({
    Label = "Whitelist player",
    Placeholder = "Username",
    Callback = function(text, enterPressed)
        print("[Lume] Whitelist input changed:", text)
    end,
})

local WhitelistButton = TriggerSection:CreateButton({
    Name = "Add to whitelist",
    Callback = function()
        local user = WhitelistInput.Get()
        if user and user ~= "" then
            Window:Notify({
                Title = "Lume",
                Content = "Added " .. user .. " to whitelist",
                Duration = 4,
            })
            WhitelistInput.Set("")
        else
            Window:Notify({
                Title = "Lume",
                Content = "Please enter a valid username",
                Duration = 3,
            })
        end
    end,
})

-- Initial Toast Notification matching screenshot
Window:Notify({
    Title = "Lume",
    Content = "something about making n doing uis",
    Duration = 5,
})
