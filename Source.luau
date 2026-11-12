--[[
    LumeUI — Dark Layered Desktop UI Library for Roblox
    Visual Style: Periwinkle on Near-Black Layered Surfaces
    Tokens:
      - Backdrop: #8585FF to #5B5BD6
      - Surfaces: Panel #141416 | Card #1A1A1D | Input/Row #202024 | Hover #25252A
      - Accent: #7C7CFF
      - Typography: Text Primary #F2F2F5 | Text Muted #8E8E99 (>= 4.5:1 contrast)
      - Radii: Window 14px, Card 10px, Row 8px, Pill 16px
      - Shadow: 0 20px 50px rgba(0,0,0,0.45)
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LumeUI = {}
LumeUI.Version = "1.0.0"

local Tokens = {
    BackdropTop = Color3.fromRGB(133, 133, 255),       -- #8585FF
    BackdropBottom = Color3.fromRGB(91, 91, 214),      -- #5B5BD6
    PanelSurface = Color3.fromRGB(20, 20, 22),          -- #141416
    CardSurface = Color3.fromRGB(26, 26, 29),           -- #1A1A1D
    InputSurface = Color3.fromRGB(32, 32, 36),          -- #202024
    HoverRow = Color3.fromRGB(37, 37, 42),              -- #25252A
    ActiveRow = Color3.fromRGB(40, 40, 47),             -- #28282F
    Accent = Color3.fromRGB(124, 124, 255),             -- #7C7CFF
    AccentHover = Color3.fromRGB(142, 142, 255),        -- #8E8EFF
    AccentDull = Color3.fromRGB(80, 80, 160),
    TextPrimary = Color3.fromRGB(242, 242, 245),        -- #F2F2F5
    TextMuted = Color3.fromRGB(142, 142, 153),          -- #8E8E99 (Contrast > 5:1)
    Border = Color3.fromRGB(255, 255, 255),
    BorderTransparency = 0.96,                          -- 1px 4% white
    BorderActive = Color3.fromRGB(124, 124, 255),       -- Accent focus ring
    ShadowAsset = "rbxassetid://6014261993",
    RadiusWindow = UDim.new(0, 14),
    RadiusCard = UDim.new(0, 10),
    RadiusRow = UDim.new(0, 8),
    RadiusPill = UDim.new(0, 16),
}
LumeUI.Tokens = Tokens

-- Font Resolver
local function GetFont(weight)
    local fw = (weight == "Medium" or weight == Enum.FontWeight.Medium or weight == "Bold") and Enum.FontWeight.Medium or Enum.FontWeight.Regular
    local success, font = pcall(function()
        return Font.new("rbxasset://fonts/families/GothamSSm.json", fw, Enum.FontStyle.Normal)
    end)
    if success and font then
        return font
    end
    return Font.fromEnum(fw == Enum.FontWeight.Medium and Enum.Font.GothamMedium or Enum.Font.Gotham)
end

-- Parent Container Resolution
local function GetGuiParent()
    local success, coreGui = pcall(function()
        return (gethui and gethui()) or game:GetService("CoreGui")
    end)
    if success and coreGui then
        return coreGui
    end
    if LocalPlayer then
        return LocalPlayer:WaitForChild("PlayerGui")
    end
    return game:GetService("CoreGui")
end

-- Global Z-Order Management
local GlobalZIndex = 100
local function Elevate(frame)
    GlobalZIndex = GlobalZIndex + 5
    frame.ZIndex = GlobalZIndex
    for _, desc in ipairs(frame:GetDescendants()) do
        if desc:IsA("GuiObject") then
            desc.ZIndex = GlobalZIndex + (desc.ZIndex % 5)
        end
    end
end

-- Smooth Dragging
local function EnableDragging(frame, handle, onElevate)
    handle = handle or frame
    local dragging = false
    local dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if onElevate then onElevate() end
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Tactile 0.98 Press Micro-Spring
local function AttachMicroSpring(button, reducedMotion)
    local uiScale = button:FindFirstChildOfClass("UIScale")
    if not uiScale then
        uiScale = Instance.new("UIScale")
        uiScale.Scale = 1
        uiScale.Parent = button
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if reducedMotion then return end
            TweenService:Create(uiScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.98 }):Play()
        end
    end)
    
    local function restore()
        if reducedMotion then return end
        TweenService:Create(uiScale, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.0 }):Play()
    end
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            restore()
        end
    end)
end

-- Procedural Logo Emblem
local function RenderLogo(parent, size)
    local container = Instance.new("Frame")
    container.Name = "LogoEmblem"
    container.Size = size or UDim2.fromOffset(24, 24)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local p1 = Instance.new("Frame")
    p1.Size = UDim2.new(0.7, 0, 0.28, 0)
    p1.Position = UDim2.new(0.05, 0, 0.2, 0)
    p1.BackgroundColor3 = Tokens.Accent
    p1.BorderSizePixel = 0
    p1.Rotation = -18
    p1.Parent = container
    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(1, 0)
    c1.Parent = p1
    
    local p2 = Instance.new("Frame")
    p2.Size = UDim2.new(0.7, 0, 0.28, 0)
    p2.Position = UDim2.new(0.25, 0, 0.55, 0)
    p2.BackgroundColor3 = Tokens.AccentHover
    p2.BorderSizePixel = 0
    p2.Rotation = -18
    p2.Parent = container
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(1, 0)
    c2.Parent = p2
    
    return container
end

-- Drop Shadow Helper
local function AddWindowShadow(parent, radius)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 10)
    shadow.Size = UDim2.new(1, 56, 1, 56)
    shadow.BackgroundTransparency = 1
    shadow.Image = Tokens.ShadowAsset
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.45
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = math.max(1, parent.ZIndex - 1)
    shadow.Parent = parent
    return shadow
end

-- OOP Methods Tables
local WindowMethods = {}
WindowMethods.__index = WindowMethods

local TabMethods = {}
TabMethods.__index = TabMethods

local SectionMethods = {}
SectionMethods.__index = SectionMethods

-- =========================================================================
-- CREATE WINDOW
-- =========================================================================
function LumeUI:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Name or "Lume"
    local windowSubtitle = config.Subtitle or "Desktop"
    local showBackdrop = config.Backdrop or false
    local toggleKey = config.Keybind or Enum.KeyCode.RightShift
    local reducedMotion = config.ReducedMotion or false
    
    local Window = setmetatable({
        Title = windowTitle,
        Subtitle = windowSubtitle,
        ReducedMotion = reducedMotion,
        Tabs = {},
        ActiveTab = nil,
        Visible = true,
        ActiveDropdown = nil,
    }, WindowMethods)
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LumeUI_" .. windowTitle
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = GetGuiParent()
    Window.ScreenGui = ScreenGui
    
    -- Optional Fullscreen Backdrop
    if showBackdrop then
        local backdrop = Instance.new("Frame")
        backdrop.Name = "Backdrop"
        backdrop.Size = UDim2.fromScale(1, 1)
        backdrop.Position = UDim2.fromOffset(0, 0)
        backdrop.BackgroundColor3 = Color3.new(1, 1, 1)
        backdrop.BorderSizePixel = 0
        backdrop.ZIndex = 1
        backdrop.Parent = ScreenGui
        
        local bgGradient = Instance.new("UIGradient")
        bgGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Tokens.BackdropTop),
            ColorSequenceKeypoint.new(1, Tokens.BackdropBottom),
        })
        bgGradient.Rotation = 90
        bgGradient.Parent = backdrop
        
        local bgWatermark = Instance.new("TextLabel")
        bgWatermark.Name = "WatermarkText"
        bgWatermark.AnchorPoint = Vector2.new(0.5, 0.5)
        bgWatermark.Position = UDim2.new(0.5, 0, 0.22, 0)
        bgWatermark.Size = UDim2.new(1, 0, 0, 140)
        bgWatermark.BackgroundTransparency = 1
        bgWatermark.Text = string.upper(windowTitle)
        bgWatermark.FontFace = GetFont("Bold")
        bgWatermark.TextSize = 96
        bgWatermark.TextColor3 = Color3.fromRGB(255, 255, 255)
        bgWatermark.TextTransparency = 0.88
        bgWatermark.ZIndex = 2
        bgWatermark.Parent = backdrop
    end
    
    -- Main Window Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.55, 0)
    MainFrame.Size = UDim2.fromOffset(720, 440)
    MainFrame.BackgroundColor3 = Tokens.PanelSurface
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = 10
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui
    Window.MainFrame = MainFrame
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = Tokens.RadiusWindow
    mainCorner.Parent = MainFrame
    
    local mainBorder = Instance.new("UIStroke")
    mainBorder.Color = Tokens.Border
    mainBorder.Transparency = Tokens.BorderTransparency
    mainBorder.Thickness = 1
    mainBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainBorder.Parent = MainFrame
    
    AddWindowShadow(MainFrame, 14)
    EnableDragging(MainFrame, MainFrame, function() Elevate(MainFrame) end)
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Elevate(MainFrame)
        end
    end)
    
    -- Left Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 195, 1, 0)
    Sidebar.Position = UDim2.fromOffset(0, 0)
    Sidebar.BackgroundColor3 = Tokens.PanelSurface
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = MainFrame.ZIndex + 1
    Sidebar.Parent = MainFrame
    Window.Sidebar = Sidebar
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = Tokens.RadiusWindow
    sidebarCorner.Parent = Sidebar
    
    -- Sidebar Brand (Logo + Product Title)
    local BrandContainer = Instance.new("Frame")
    BrandContainer.Name = "Brand"
    BrandContainer.Size = UDim2.new(1, -32, 0, 36)
    BrandContainer.Position = UDim2.fromOffset(18, 18)
    BrandContainer.BackgroundTransparency = 1
    BrandContainer.ZIndex = Sidebar.ZIndex + 1
    BrandContainer.Parent = Sidebar
    
    RenderLogo(BrandContainer, UDim2.fromOffset(24, 24))
    
    local BrandTitle = Instance.new("TextLabel")
    BrandTitle.Name = "BrandTitle"
    BrandTitle.Position = UDim2.fromOffset(34, 0)
    BrandTitle.Size = UDim2.new(1, -34, 1, 0)
    BrandTitle.BackgroundTransparency = 1
    BrandTitle.Text = windowTitle
    BrandTitle.FontFace = GetFont("Medium")
    BrandTitle.TextSize = 18
    BrandTitle.TextColor3 = Tokens.TextPrimary
    BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandTitle.ZIndex = BrandContainer.ZIndex
    BrandTitle.Parent = BrandContainer
    
    -- Search Field
    local SearchBox = Instance.new("Frame")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -36, 0, 32)
    SearchBox.Position = UDim2.fromOffset(18, 62)
    SearchBox.BackgroundColor3 = Tokens.InputSurface
    SearchBox.BorderSizePixel = 0
    SearchBox.ZIndex = Sidebar.ZIndex + 1
    SearchBox.Parent = Sidebar
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = Tokens.RadiusRow
    searchCorner.Parent = SearchBox
    
    local searchStroke = Instance.new("UIStroke")
    searchStroke.Color = Tokens.Border
    searchStroke.Transparency = Tokens.BorderTransparency
    searchStroke.Thickness = 1
    searchStroke.Parent = SearchBox
    
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Name = "SearchIcon"
    searchIcon.Position = UDim2.fromOffset(10, 8)
    searchIcon.Size = UDim2.fromOffset(16, 16)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://6031154877"
    searchIcon.ImageColor3 = Tokens.TextMuted
    searchIcon.ZIndex = SearchBox.ZIndex
    searchIcon.Parent = SearchBox
    
    local searchInput = Instance.new("TextBox")
    searchInput.Name = "SearchInput"
    searchInput.Position = UDim2.fromOffset(32, 0)
    searchInput.Size = UDim2.new(1, -36, 1, 0)
    searchInput.BackgroundTransparency = 1
    searchInput.PlaceholderText = "Search"
    searchInput.PlaceholderColor3 = Tokens.TextMuted
    searchInput.Text = ""
    searchInput.TextColor3 = Tokens.TextPrimary
    searchInput.FontFace = GetFont("Regular")
    searchInput.TextSize = 14
    searchInput.TextXAlignment = Enum.TextXAlignment.Left
    searchInput.ClearTextOnFocus = false
    searchInput.ZIndex = SearchBox.ZIndex
    searchInput.Parent = SearchBox
    
    searchInput.Focused:Connect(function()
        TweenService:Create(searchStroke, TweenInfo.new(0.14), { Color = Tokens.Accent, Transparency = 0 }):Play()
    end)
    searchInput.FocusLost:Connect(function()
        TweenService:Create(searchStroke, TweenInfo.new(0.14), { Color = Tokens.Border, Transparency = Tokens.BorderTransparency }):Play()
    end)
    
    -- Live Search Filter
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(searchInput.Text)
        for _, tab in ipairs(Window.Tabs) do
            local tabMatches = string.find(string.lower(tab.Name), query) ~= nil
            local anySectionMatch = false
            for _, sec in ipairs(tab.Sections or {}) do
                local secMatches = string.find(string.lower(sec.Title), query) ~= nil
                sec.Wrapper.Visible = (query == "") or secMatches or tabMatches
                if secMatches then anySectionMatch = true end
            end
            tab.NavButton.Visible = (query == "") or tabMatches or anySectionMatch
        end
    end)
    
    -- Nav List
    local NavList = Instance.new("ScrollingFrame")
    NavList.Name = "NavList"
    NavList.Position = UDim2.fromOffset(18, 106)
    NavList.Size = UDim2.new(1, -36, 1, -120)
    NavList.BackgroundTransparency = 1
    NavList.BorderSizePixel = 0
    NavList.ScrollBarThickness = 0
    NavList.CanvasSize = UDim2.new(0, 0, 0, 0)
    NavList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    NavList.ZIndex = Sidebar.ZIndex + 1
    NavList.Parent = Sidebar
    Window.NavList = NavList
    
    local navLayout = Instance.new("UIListLayout")
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 6)
    navLayout.Parent = NavList
    
    -- Vertical Divider Line
    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.Name = "Divider"
    sidebarDivider.Position = UDim2.new(0, 195, 0, 14)
    sidebarDivider.Size = UDim2.new(0, 1, 1, -28)
    sidebarDivider.BackgroundColor3 = Tokens.CardSurface
    sidebarDivider.BorderSizePixel = 0
    sidebarDivider.ZIndex = MainFrame.ZIndex + 1
    sidebarDivider.Parent = MainFrame
    
    -- Right Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Position = UDim2.fromOffset(196, 0)
    ContentArea.Size = UDim2.new(1, -196, 1, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = MainFrame.ZIndex + 1
    ContentArea.Parent = MainFrame
    Window.ContentArea = ContentArea
    
    -- Content Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Position = UDim2.fromOffset(24, 18)
    TopBar.Size = UDim2.new(1, -48, 0, 36)
    TopBar.BackgroundTransparency = 1
    TopBar.ZIndex = ContentArea.ZIndex + 1
    TopBar.Parent = ContentArea
    
    local folderBtn = Instance.new("TextButton")
    folderBtn.Name = "FolderButton"
    folderBtn.Size = UDim2.fromOffset(32, 32)
    folderBtn.Position = UDim2.fromOffset(0, 2)
    folderBtn.BackgroundColor3 = Tokens.InputSurface
    folderBtn.BorderSizePixel = 0
    folderBtn.Text = ""
    folderBtn.AutoButtonColor = false
    folderBtn.ZIndex = TopBar.ZIndex
    folderBtn.Parent = TopBar
    
    local folderCorner = Instance.new("UICorner")
    folderCorner.CornerRadius = Tokens.RadiusRow
    folderCorner.Parent = folderBtn
    
    local folderIcon = Instance.new("ImageLabel")
    folderIcon.Name = "FolderIcon"
    folderIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    folderIcon.Position = UDim2.fromScale(0.5, 0.5)
    folderIcon.Size = UDim2.fromOffset(16, 16)
    folderIcon.BackgroundTransparency = 1
    folderIcon.Image = "rbxassetid://6034327424"
    folderIcon.ImageColor3 = Tokens.TextMuted
    folderIcon.ZIndex = folderBtn.ZIndex
    folderIcon.Parent = folderBtn
    
    AttachMicroSpring(folderBtn, reducedMotion)
    folderBtn.MouseEnter:Connect(function()
        TweenService:Create(folderBtn, TweenInfo.new(0.14), { BackgroundColor3 = Tokens.HoverRow }):Play()
        TweenService:Create(folderIcon, TweenInfo.new(0.14), { ImageColor3 = Tokens.TextPrimary }):Play()
    end)
    folderBtn.MouseLeave:Connect(function()
        TweenService:Create(folderBtn, TweenInfo.new(0.14), { BackgroundColor3 = Tokens.InputSurface }):Play()
        TweenService:Create(folderIcon, TweenInfo.new(0.14), { ImageColor3 = Tokens.TextMuted }):Play()
    end)
    
    -- Category Dropdown
    local categoryBtn = Instance.new("TextButton")
    categoryBtn.Name = "CategoryDropdown"
    categoryBtn.Position = UDim2.fromOffset(40, 2)
    categoryBtn.Size = UDim2.fromOffset(110, 32)
    categoryBtn.BackgroundColor3 = Tokens.InputSurface
    categoryBtn.BorderSizePixel = 0
    categoryBtn.Text = ""
    categoryBtn.AutoButtonColor = false
    categoryBtn.ZIndex = TopBar.ZIndex
    categoryBtn.Parent = TopBar
    
    local catCorner = Instance.new("UICorner")
    catCorner.CornerRadius = Tokens.RadiusRow
    catCorner.Parent = categoryBtn
    
    local catStroke = Instance.new("UIStroke")
    catStroke.Color = Tokens.Border
    catStroke.Transparency = Tokens.BorderTransparency
    catStroke.Thickness = 1
    catStroke.Parent = categoryBtn
    
    local catLabel = Instance.new("TextLabel")
    catLabel.Name = "Label"
    catLabel.Position = UDim2.fromOffset(12, 0)
    catLabel.Size = UDim2.new(1, -36, 1, 0)
    catLabel.BackgroundTransparency = 1
    catLabel.Text = "Combat"
    catLabel.FontFace = GetFont("Regular")
    catLabel.TextSize = 14
    catLabel.TextColor3 = Tokens.TextPrimary
    catLabel.TextXAlignment = Enum.TextXAlignment.Left
    catLabel.ZIndex = categoryBtn.ZIndex
    catLabel.Parent = categoryBtn
    
    local catChevron = Instance.new("ImageLabel")
    catChevron.Name = "Chevron"
    catChevron.AnchorPoint = Vector2.new(1, 0.5)
    catChevron.Position = UDim2.new(1, -10, 0.5, 0)
    catChevron.Size = UDim2.fromOffset(14, 14)
    catChevron.BackgroundTransparency = 1
    catChevron.Image = "rbxassetid://6034818372"
    catChevron.ImageColor3 = Tokens.TextMuted
    catChevron.ZIndex = categoryBtn.ZIndex
    catChevron.Parent = categoryBtn
    
    -- Breadcrumb Row
    local Breadcrumb = Instance.new("Frame")
    Breadcrumb.Name = "Breadcrumb"
    Breadcrumb.Position = UDim2.fromOffset(24, 62)
    Breadcrumb.Size = UDim2.new(1, -48, 0, 20)
    Breadcrumb.BackgroundTransparency = 1
    Breadcrumb.ZIndex = ContentArea.ZIndex + 1
    Breadcrumb.Parent = ContentArea
    
    local breadcrumbLayout = Instance.new("UIListLayout")
    breadcrumbLayout.FillDirection = Enum.FillDirection.Horizontal
    breadcrumbLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    breadcrumbLayout.SortOrder = Enum.SortOrder.LayoutOrder
    breadcrumbLayout.Padding = UDim.new(0, 8)
    breadcrumbLayout.Parent = Breadcrumb
    
    local bPrimary = Instance.new("TextLabel")
    bPrimary.Name = "Primary"
    bPrimary.BackgroundTransparency = 1
    bPrimary.Text = "Legit"
    bPrimary.FontFace = GetFont("Medium")
    bPrimary.TextSize = 14
    bPrimary.TextColor3 = Tokens.TextPrimary
    bPrimary.AutomaticSize = Enum.AutomaticSize.X
    bPrimary.Size = UDim2.new(0, 0, 1, 0)
    bPrimary.LayoutOrder = 1
    bPrimary.ZIndex = Breadcrumb.ZIndex
    bPrimary.Parent = Breadcrumb
    
    local bChevron = Instance.new("TextLabel")
    bChevron.Name = "Chevron"
    bChevron.BackgroundTransparency = 1
    bChevron.Text = "›"
    bChevron.FontFace = GetFont("Regular")
    bChevron.TextSize = 14
    bChevron.TextColor3 = Tokens.TextMuted
    bChevron.AutomaticSize = Enum.AutomaticSize.X
    bChevron.Size = UDim2.new(0, 0, 1, 0)
    bChevron.LayoutOrder = 2
    bChevron.ZIndex = Breadcrumb.ZIndex
    bChevron.Parent = Breadcrumb
    
    local bSecondary = Instance.new("TextLabel")
    bSecondary.Name = "Secondary"
    bSecondary.BackgroundTransparency = 1
    bSecondary.Text = "Combat"
    bSecondary.FontFace = GetFont("Regular")
    bSecondary.TextSize = 14
    bSecondary.TextColor3 = Tokens.TextMuted
    bSecondary.AutomaticSize = Enum.AutomaticSize.X
    bSecondary.Size = UDim2.new(0, 0, 1, 0)
    bSecondary.LayoutOrder = 3
    bSecondary.ZIndex = Breadcrumb.ZIndex
    bSecondary.Parent = Breadcrumb
    
    Window.SetBreadcrumb = function(_, primary, secondary)
        bPrimary.Text = primary or "Legit"
        bSecondary.Text = secondary or "Combat"
    end
    
    -- Floating Dropdown Menu
    local catMenu = Instance.new("Frame")
    catMenu.Name = "CategoryMenu"
    catMenu.Size = UDim2.fromOffset(140, 0)
    catMenu.Position = UDim2.fromOffset(64, 54)
    catMenu.BackgroundColor3 = Tokens.InputSurface
    catMenu.BorderSizePixel = 0
    catMenu.ClipsDescendants = true
    catMenu.Visible = false
    catMenu.ZIndex = ContentArea.ZIndex + 50
    catMenu.Parent = ContentArea
    
    local catMenuCorner = Instance.new("UICorner")
    catMenuCorner.CornerRadius = Tokens.RadiusRow
    catMenuCorner.Parent = catMenu
    
    local catMenuStroke = Instance.new("UIStroke")
    catMenuStroke.Color = Tokens.Border
    catMenuStroke.Transparency = Tokens.BorderTransparency
    catMenuStroke.Thickness = 1
    catMenuStroke.Parent = catMenu
    
    local catMenuList = Instance.new("UIListLayout")
    catMenuList.SortOrder = Enum.SortOrder.LayoutOrder
    catMenuList.Padding = UDim.new(0, 2)
    catMenuList.Parent = catMenu
    
    local catMenuPad = Instance.new("UIPadding")
    catMenuPad.PaddingTop = UDim.new(0, 4)
    catMenuPad.PaddingBottom = UDim.new(0, 4)
    catMenuPad.PaddingLeft = UDim.new(0, 4)
    catMenuPad.PaddingRight = UDim.new(0, 4)
    catMenuPad.Parent = catMenu
    
    local function ToggleCategoryDropdown(open)
        if open == nil then open = not catMenu.Visible end
        if open then
            catMenu.Visible = true
            Window.ActiveDropdown = catMenu
            TweenService:Create(catChevron, TweenInfo.new(0.14), { Rotation = 180 }):Play()
            TweenService:Create(catMenu, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(140, 104)
            }):Play()
        else
            Window.ActiveDropdown = nil
            TweenService:Create(catChevron, TweenInfo.new(0.14), { Rotation = 0 }):Play()
            local closeTween = TweenService:Create(catMenu, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(140, 0)
            })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                if not Window.ActiveDropdown then
                    catMenu.Visible = false
                end
            end)
        end
    end
    categoryBtn.MouseButton1Click:Connect(function()
        ToggleCategoryDropdown()
    end)
    
    local function AddCategoryOption(name)
        local opt = Instance.new("TextButton")
        opt.Name = "Option_" .. name
        opt.Size = UDim2.new(1, 0, 0, 28)
        opt.BackgroundColor3 = Tokens.InputSurface
        opt.BackgroundTransparency = 1
        opt.BorderSizePixel = 0
        opt.Text = "  " .. name
        opt.FontFace = GetFont("Regular")
        opt.TextSize = 13
        opt.TextColor3 = Tokens.TextPrimary
        opt.TextXAlignment = Enum.TextXAlignment.Left
        opt.ZIndex = catMenu.ZIndex + 1
        opt.AutoButtonColor = false
        opt.Parent = catMenu
        
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 6)
        optCorner.Parent = opt
        
        opt.MouseEnter:Connect(function()
            TweenService:Create(opt, TweenInfo.new(0.12), { BackgroundTransparency = 0, BackgroundColor3 = Tokens.HoverRow }):Play()
        end)
        opt.MouseLeave:Connect(function()
            TweenService:Create(opt, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
        end)
        opt.MouseButton1Click:Connect(function()
            catLabel.Text = name
            bSecondary.Text = name
            ToggleCategoryDropdown(false)
        end)
    end
    AddCategoryOption("Combat")
    AddCategoryOption("Movement")
    AddCategoryOption("World")
    
    -- Content Pages Container
    local ContentPages = Instance.new("Frame")
    ContentPages.Name = "PagesHost"
    ContentPages.Position = UDim2.fromOffset(24, 94)
    ContentPages.Size = UDim2.new(1, -48, 1, -106)
    ContentPages.BackgroundTransparency = 1
    ContentPages.ZIndex = ContentArea.ZIndex + 2
    ContentPages.Parent = ContentArea
    Window.ContentPages = ContentPages
    
    -- Input Handling
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == toggleKey then
            Window:Toggle()
        elseif input.KeyCode == Enum.KeyCode.Escape then
            if Window.ActiveDropdown then
                ToggleCategoryDropdown(false)
            end
        end
    end)
    
    return Window
end

-- =========================================================================
-- WINDOW METHODS
-- =========================================================================
function WindowMethods:CreateTab(config)
    local Window = self
    config = config or {}
    local tabName = config.Name or "Tab"
    local tabIconId = config.Icon or "rbxassetid://6031265976"
    
    local Tab = setmetatable({
        Name = tabName,
        Window = Window,
        Sections = {},
    }, TabMethods)
    
    local isFirstTab = (#Window.Tabs == 0)
    
    local navBtn = Instance.new("TextButton")
    navBtn.Name = "Nav_" .. tabName
    navBtn.Size = UDim2.new(1, 0, 0, 36)
    navBtn.BackgroundColor3 = isFirstTab and Tokens.InputSurface or Tokens.PanelSurface
    navBtn.BackgroundTransparency = isFirstTab and 0 or 1
    navBtn.BorderSizePixel = 0
    navBtn.Text = ""
    navBtn.AutoButtonColor = false
    navBtn.ZIndex = Window.MainFrame.ZIndex + 2
    navBtn.Parent = Window.NavList
    
    local navCorner = Instance.new("UICorner")
    navCorner.CornerRadius = Tokens.RadiusRow
    navCorner.Parent = navBtn
    
    -- 3px Accent Bar on Left Edge
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.AnchorPoint = Vector2.new(0, 0.5)
    accentBar.Position = UDim2.new(0, 0, 0.5, 0)
    accentBar.Size = UDim2.new(0, 3, 0.7, 0)
    accentBar.BackgroundColor3 = Tokens.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Visible = isFirstTab
    accentBar.ZIndex = navBtn.ZIndex + 1
    accentBar.Parent = navBtn
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = accentBar
    
    local navIcon = Instance.new("ImageLabel")
    navIcon.Name = "Icon"
    navIcon.Position = UDim2.fromOffset(12, 10)
    navIcon.Size = UDim2.fromOffset(16, 16)
    navIcon.BackgroundTransparency = 1
    navIcon.Image = tabIconId
    navIcon.ImageColor3 = isFirstTab and Tokens.TextPrimary or Tokens.TextMuted
    navIcon.ZIndex = navBtn.ZIndex + 1
    navIcon.Parent = navBtn
    
    local navLabel = Instance.new("TextLabel")
    navLabel.Name = "Label"
    navLabel.Position = UDim2.fromOffset(36, 0)
    navLabel.Size = UDim2.new(1, -40, 1, 0)
    navLabel.BackgroundTransparency = 1
    navLabel.Text = tabName
    navLabel.FontFace = isFirstTab and GetFont("Medium") or GetFont("Regular")
    navLabel.TextSize = 14
    navLabel.TextColor3 = isFirstTab and Tokens.TextPrimary or Tokens.TextMuted
    navLabel.TextXAlignment = Enum.TextXAlignment.Left
    navLabel.ZIndex = navBtn.ZIndex + 1
    navLabel.Parent = navBtn
    
    -- Two-Column Page Frame
    local pageFrame = Instance.new("ScrollingFrame")
    pageFrame.Name = "Page_" .. tabName
    pageFrame.Size = UDim2.fromScale(1, 1)
    pageFrame.Position = UDim2.fromOffset(0, 0)
    pageFrame.BackgroundTransparency = 1
    pageFrame.BorderSizePixel = 0
    pageFrame.ScrollBarThickness = 2
    pageFrame.ScrollBarImageColor3 = Tokens.HoverRow
    pageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    pageFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pageFrame.Visible = isFirstTab
    pageFrame.ZIndex = Window.ContentPages.ZIndex
    pageFrame.Parent = Window.ContentPages
    
    local columnsGrid = Instance.new("Frame")
    columnsGrid.Name = "Columns"
    columnsGrid.Size = UDim2.new(1, 0, 0, 0)
    columnsGrid.AutomaticSize = Enum.AutomaticSize.Y
    columnsGrid.BackgroundTransparency = 1
    columnsGrid.Parent = pageFrame
    
    local colLeft = Instance.new("Frame")
    colLeft.Name = "ColLeft"
    colLeft.Size = UDim2.new(0.5, -8, 0, 0)
    colLeft.Position = UDim2.fromOffset(0, 0)
    colLeft.AutomaticSize = Enum.AutomaticSize.Y
    colLeft.BackgroundTransparency = 1
    colLeft.Parent = columnsGrid
    
    local colLeftLayout = Instance.new("UIListLayout")
    colLeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    colLeftLayout.Padding = UDim.new(0, 14)
    colLeftLayout.Parent = colLeft
    
    local colRight = Instance.new("Frame")
    colRight.Name = "ColRight"
    colRight.AnchorPoint = Vector2.new(1, 0)
    colRight.Position = UDim2.new(1, 0, 0, 0)
    colRight.Size = UDim2.new(0.5, -8, 0, 0)
    colRight.AutomaticSize = Enum.AutomaticSize.Y
    colRight.BackgroundTransparency = 1
    colRight.Parent = columnsGrid
    
    local colRightLayout = Instance.new("UIListLayout")
    colRightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    colRightLayout.Padding = UDim.new(0, 14)
    colRightLayout.Parent = colRight
    
    Tab.Columns = { colLeft, colRight }
    Tab.PageFrame = pageFrame
    Tab.NavButton = navBtn
    
    function Tab:Select()
        for _, other in ipairs(Window.Tabs) do
            other.PageFrame.Visible = false
            other.NavButton.AccentBar.Visible = false
            TweenService:Create(other.NavButton, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(other.NavButton.Label, TweenInfo.new(0.14), { TextColor3 = Tokens.TextMuted }):Play()
            TweenService:Create(other.NavButton.Icon, TweenInfo.new(0.14), { ImageColor3 = Tokens.TextMuted }):Play()
            other.NavButton.Label.FontFace = GetFont("Regular")
        end
        pageFrame.Visible = true
        accentBar.Visible = true
        TweenService:Create(navBtn, TweenInfo.new(0.14), { BackgroundColor3 = Tokens.InputSurface, BackgroundTransparency = 0 }):Play()
        TweenService:Create(navLabel, TweenInfo.new(0.14), { TextColor3 = Tokens.TextPrimary }):Play()
        TweenService:Create(navIcon, TweenInfo.new(0.14), { ImageColor3 = Tokens.TextPrimary }):Play()
        navLabel.FontFace = GetFont("Medium")
        Window.ActiveTab = Tab
        Window:SetBreadcrumb(tabName, "Combat")
    end
    
    navBtn.MouseButton1Click:Connect(function()
        Tab:Select()
    end)
    
    navBtn.MouseEnter:Connect(function()
        if Window.ActiveTab ~= Tab then
            TweenService:Create(navBtn, TweenInfo.new(0.12), { BackgroundColor3 = Tokens.HoverRow, BackgroundTransparency = 0 }):Play()
            TweenService:Create(navLabel, TweenInfo.new(0.12), { TextColor3 = Tokens.TextPrimary }):Play()
        end
    end)
    navBtn.MouseLeave:Connect(function()
        if Window.ActiveTab ~= Tab then
            TweenService:Create(navBtn, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(navLabel, TweenInfo.new(0.12), { TextColor3 = Tokens.TextMuted }):Play()
        end
    end)
    
    table.insert(Window.Tabs, Tab)
    if isFirstTab then
        Window.ActiveTab = Tab
    end
    
    return Tab
end

-- =========================================================================
-- TAB METHODS: CREATE SECTION
-- =========================================================================
function TabMethods:CreateSection(title, columnIndex)
    local Tab = self
    columnIndex = columnIndex or 1
    local parentCol = Tab.Columns[columnIndex] or Tab.Columns[1]
    
    local Section = setmetatable({
        Title = title,
        Tab = Tab,
    }, SectionMethods)
    
    local wrapper = Instance.new("Frame")
    wrapper.Name = "Section_" .. title
    wrapper.Size = UDim2.new(1, 0, 0, 0)
    wrapper.AutomaticSize = Enum.AutomaticSize.Y
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parentCol
    Section.Wrapper = wrapper
    
    local wrapperLayout = Instance.new("UIListLayout")
    wrapperLayout.SortOrder = Enum.SortOrder.LayoutOrder
    wrapperLayout.Padding = UDim.new(0, 6)
    wrapperLayout.Parent = wrapper
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "SectionTitle"
    titleLabel.Size = UDim2.new(1, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.FontFace = GetFont("Regular")
    titleLabel.TextSize = 12
    titleLabel.TextColor3 = Tokens.TextMuted
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = wrapper
    
    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Tokens.CardSurface
    card.BorderSizePixel = 0
    card.Parent = wrapper
    Section.Card = card
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = Tokens.RadiusCard
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Tokens.Border
    cardStroke.Transparency = Tokens.BorderTransparency
    cardStroke.Thickness = 1
    cardStroke.Parent = card
    
    local cardPad = Instance.new("UIPadding")
    cardPad.PaddingTop = UDim.new(0, 10)
    cardPad.PaddingBottom = UDim.new(0, 10)
    cardPad.PaddingLeft = UDim.new(0, 12)
    cardPad.PaddingRight = UDim.new(0, 12)
    cardPad.Parent = card
    
    local cardList = Instance.new("UIListLayout")
    cardList.SortOrder = Enum.SortOrder.LayoutOrder
    cardList.Padding = UDim.new(0, 8)
    cardList.Parent = card
    
    table.insert(Tab.Sections, Section)
    return Section
end

-- =========================================================================
-- SECTION METHODS: CONTROLS
-- =========================================================================

-- Checkbox Toggle
function SectionMethods:CreateToggle(cfg)
    local card = self.Card
    cfg = cfg or {}
    local name = cfg.Name or "Option"
    local state = cfg.CurrentValue or false
    local disabled = cfg.Disabled or false
    local hasChevron = cfg.HasChevron or false
    local hasGear = cfg.HasGear or false
    local callback = cfg.Callback or function() end
    
    local row = Instance.new("TextButton")
    row.Name = "Toggle_" .. name
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = Tokens.CardSurface
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Parent = card
    
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = Tokens.RadiusRow
    rowCorner.Parent = row
    
    local rowPad = Instance.new("UIPadding")
    rowPad.PaddingLeft = UDim.new(0, 4)
    rowPad.PaddingRight = UDim.new(0, 4)
    rowPad.Parent = row
    
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.AnchorPoint = Vector2.new(0, 0.5)
    box.Position = UDim2.new(0, 0, 0.5, 0)
    box.Size = UDim2.fromOffset(18, 18)
    box.BackgroundColor3 = state and Tokens.Accent or (disabled and Tokens.CardSurface or Tokens.InputSurface)
    box.BorderSizePixel = 0
    box.Parent = row
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = disabled and Color3.fromRGB(44, 44, 50) or (state and Tokens.Accent or Tokens.Border)
    boxStroke.Transparency = state and 0 or (disabled and 0 or Tokens.BorderTransparency)
    boxStroke.Thickness = 1
    boxStroke.Parent = box
    
    local checkMark = Instance.new("TextLabel")
    checkMark.Name = "Check"
    checkMark.Size = UDim2.fromScale(1, 1)
    checkMark.BackgroundTransparency = 1
    checkMark.Text = "✓"
    checkMark.FontFace = GetFont("Bold")
    checkMark.TextSize = 13
    checkMark.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkMark.Visible = state
    checkMark.Parent = box
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Position = UDim2.fromOffset(28, 0)
    label.Size = UDim2.new(1, -90, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.FontFace = GetFont("Regular")
    label.TextSize = 14
    label.TextColor3 = disabled and Tokens.TextMuted or Tokens.TextPrimary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    
    local rightControls = Instance.new("Frame")
    rightControls.Name = "Controls"
    rightControls.AnchorPoint = Vector2.new(1, 0.5)
    rightControls.Position = UDim2.new(1, 0, 0.5, 0)
    rightControls.Size = UDim2.fromOffset(50, 24)
    rightControls.BackgroundTransparency = 1
    rightControls.Parent = row
    
    local rcLayout = Instance.new("UIListLayout")
    rcLayout.FillDirection = Enum.FillDirection.Horizontal
    rcLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    rcLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rcLayout.Padding = UDim.new(0, 6)
    rcLayout.Parent = rightControls
    
    if hasChevron then
        local chev = Instance.new("ImageLabel")
        chev.Name = "Chevron"
        chev.Size = UDim2.fromOffset(14, 14)
        chev.BackgroundTransparency = 1
        chev.Image = "rbxassetid://6034306857"
        chev.ImageColor3 = disabled and Color3.fromRGB(80, 80, 90) or Tokens.TextMuted
        chev.Parent = rightControls
    end
    
    if hasGear then
        local gear = Instance.new("ImageButton")
        gear.Name = "Gear"
        gear.Size = UDim2.fromOffset(15, 15)
        gear.BackgroundTransparency = 1
        gear.Image = "rbxassetid://6031280882"
        gear.ImageColor3 = disabled and Color3.fromRGB(80, 80, 90) or Tokens.TextMuted
        gear.Parent = rightControls
        
        gear.MouseEnter:Connect(function()
            if not disabled then
                TweenService:Create(gear, TweenInfo.new(0.12), { ImageColor3 = Tokens.TextPrimary }):Play()
            end
        end)
        gear.MouseLeave:Connect(function()
            if not disabled then
                TweenService:Create(gear, TweenInfo.new(0.12), { ImageColor3 = Tokens.TextMuted }):Play()
            end
        end)
        if cfg.OnGearClick then
            gear.MouseButton1Click:Connect(cfg.OnGearClick)
        end
    end
    
    local function SetState(val)
        if disabled then return end
        state = val
        checkMark.Visible = state
        if state then
            TweenService:Create(box, TweenInfo.new(0.14), { BackgroundColor3 = Tokens.Accent }):Play()
            TweenService:Create(boxStroke, TweenInfo.new(0.14), { Color = Tokens.Accent, Transparency = 0 }):Play()
        else
            TweenService:Create(box, TweenInfo.new(0.14), { BackgroundColor3 = Tokens.InputSurface }):Play()
            TweenService:Create(boxStroke, TweenInfo.new(0.14), { Color = Tokens.Border, Transparency = Tokens.BorderTransparency }):Play()
        end
        callback(state)
    end
    
    if not disabled then
        AttachMicroSpring(row)
        row.MouseEnter:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = Tokens.HoverRow, BackgroundTransparency = 0 }):Play()
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
        end)
        row.MouseButton1Click:Connect(function()
            SetState(not state)
        end)
    end
    
    return {
        Set = SetState,
        Get = function() return state end,
        Row = row,
    }
end

-- Slider (Thin Track, Accent Fill, Thumb on Hover)
function SectionMethods:CreateSlider(cfg)
    local card = self.Card
    cfg = cfg or {}
    local name = cfg.Name or "Slider"
    local minVal = (cfg.Range and cfg.Range[1]) or cfg.Min or 0
    local maxVal = (cfg.Range and cfg.Range[2]) or cfg.Max or 100
    local inc = cfg.Increment or 1
    local suffix = cfg.Suffix or ""
    local currentVal = math.clamp(cfg.CurrentValue or minVal, minVal, maxVal)
    local callback = cfg.Callback or function() end
    
    local row = Instance.new("Frame")
    row.Name = "Slider_" .. name
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundTransparency = 1
    row.Parent = card
    
    local rowPad = Instance.new("UIPadding")
    rowPad.PaddingLeft = UDim.new(0, 4)
    rowPad.PaddingRight = UDim.new(0, 4)
    rowPad.Parent = row
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.6, 0, 0, 18)
    label.Position = UDim2.fromOffset(0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.FontFace = GetFont("Regular")
    label.TextSize = 14
    label.TextColor3 = Tokens.TextPrimary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    
    local valLabel = Instance.new("TextLabel")
    valLabel.Name = "Value"
    valLabel.AnchorPoint = Vector2.new(1, 0)
    valLabel.Position = UDim2.new(1, 0, 0, 0)
    valLabel.Size = UDim2.new(0.4, 0, 0, 18)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(currentVal) .. suffix
    valLabel.FontFace = GetFont("Regular")
    valLabel.TextSize = 14
    valLabel.TextColor3 = Tokens.TextPrimary
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = row
    
    local track = Instance.new("TextButton")
    track.Name = "Track"
    track.Position = UDim2.fromOffset(0, 24)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.BackgroundColor3 = Tokens.InputSurface
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = row
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local initialFrac = (currentVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(initialFrac, 0, 1, 0)
    fill.BackgroundColor3 = Tokens.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(1, 0, 0.5, 0)
    thumb.Size = UDim2.fromOffset(10, 10)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.BackgroundTransparency = 1
    thumb.ZIndex = track.ZIndex + 2
    thumb.Parent = fill
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    row.MouseEnter:Connect(function()
        TweenService:Create(thumb, TweenInfo.new(0.14), { BackgroundTransparency = 0 }):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(thumb, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
    end)
    
    local dragging = false
    local function UpdateFromX(x)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsWidth = track.AbsoluteSize.X
        local frac = math.clamp((x - trackAbsPos) / trackAbsWidth, 0, 1)
        local rawVal = minVal + frac * (maxVal - minVal)
        local steppedVal = math.floor((rawVal / inc) + 0.5) * inc
        currentVal = math.clamp(steppedVal, minVal, maxVal)
        
        local snappedFrac = (currentVal - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(snappedFrac, 0, 1, 0)
        valLabel.Text = tostring(currentVal) .. suffix
        callback(currentVal)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            TweenService:Create(thumb, TweenInfo.new(0.14), { BackgroundTransparency = 0 }):Play()
            UpdateFromX(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateFromX(input.Position.X)
        end
    end)
    
    return {
        Set = function(_, v)
            currentVal = math.clamp(v, minVal, maxVal)
            local frac = (currentVal - minVal) / (maxVal - minVal)
            fill.Size = UDim2.new(frac, 0, 1, 0)
            valLabel.Text = tostring(currentVal) .. suffix
            callback(currentVal)
        end,
        Get = function() return currentVal end,
        Row = row,
    }
end

-- Range Slider (Dual Value Display e.g. "50m - 400m")
function SectionMethods:CreateRangeSlider(cfg)
    local card = self.Card
    cfg = cfg or {}
    local name = cfg.Name or "Range"
    local minVal = cfg.Min or 0
    local maxVal = cfg.Max or 500
    local lowVal = cfg.Low or 50
    local highVal = cfg.High or 400
    local suffix = cfg.Suffix or "m"
    local callback = cfg.Callback or function() end
    
    local row = Instance.new("Frame")
    row.Name = "RangeSlider_" .. name
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundTransparency = 1
    row.Parent = card
    
    local rowPad = Instance.new("UIPadding")
    rowPad.PaddingLeft = UDim.new(0, 4)
    rowPad.PaddingRight = UDim.new(0, 4)
    rowPad.Parent = row
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.5, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = name
    label.FontFace = GetFont("Regular")
    label.TextSize = 14
    label.TextColor3 = Tokens.TextPrimary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    
    local valLabel = Instance.new("TextLabel")
    valLabel.Name = "Value"
    valLabel.AnchorPoint = Vector2.new(1, 0)
    valLabel.Position = UDim2.new(1, 0, 0, 0)
    valLabel.Size = UDim2.new(0.5, 0, 0, 18)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = string.format("%d%s - %d%s", lowVal, suffix, highVal, suffix)
    valLabel.FontFace = GetFont("Regular")
    valLabel.TextSize = 14
    valLabel.TextColor3 = Tokens.TextPrimary
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = row
    
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Position = UDim2.fromOffset(0, 24)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.BackgroundColor3 = Tokens.InputSurface
    track.BorderSizePixel = 0
    track.Parent = row
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local lowFrac = (lowVal - minVal) / (maxVal - minVal)
    local highFrac = (highVal - minVal) / (maxVal - minVal)
    
    local rangeFill = Instance.new("Frame")
    rangeFill.Name = "Fill"
    rangeFill.Position = UDim2.new(lowFrac, 0, 0, 0)
    rangeFill.Size = UDim2.new(highFrac - lowFrac, 0, 1, 0)
    rangeFill.BackgroundColor3 = Tokens.Accent
    rangeFill.BorderSizePixel = 0
    rangeFill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = rangeFill
    
    return {
        Set = function(_, l, h)
            lowVal = math.clamp(l, minVal, maxVal)
            highVal = math.clamp(h, lowVal, maxVal)
            lowFrac = (lowVal - minVal) / (maxVal - minVal)
            highFrac = (highVal - minVal) / (maxVal - minVal)
            rangeFill.Position = UDim2.new(lowFrac, 0, 0, 0)
            rangeFill.Size = UDim2.new(highFrac - lowFrac, 0, 1, 0)
            valLabel.Text = string.format("%d%s - %d%s", lowVal, suffix, highVal, suffix)
            callback(lowVal, highVal)
        end,
        Get = function() return lowVal, highVal end,
        Row = row,
    }
end

-- Text Input (Row Surface, Focus Ring)
function SectionMethods:CreateInput(cfg)
    local card = self.Card
    cfg = cfg or {}
    local placeholder = cfg.Placeholder or "Username"
    local labelText = cfg.Label
    local callback = cfg.Callback or function() end
    
    if labelText then
        local subLabel = Instance.new("TextLabel")
        subLabel.Name = "InputLabel"
        subLabel.Size = UDim2.new(1, 0, 0, 16)
        subLabel.BackgroundTransparency = 1
        subLabel.Text = labelText
        subLabel.FontFace = GetFont("Regular")
        subLabel.TextSize = 12
        subLabel.TextColor3 = Tokens.TextMuted
        subLabel.TextXAlignment = Enum.TextXAlignment.Left
        subLabel.Parent = card
    end
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputBox"
    inputFrame.Size = UDim2.new(1, 0, 0, 32)
    inputFrame.BackgroundColor3 = Tokens.InputSurface
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = card
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Tokens.RadiusRow
    corner.Parent = inputFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Tokens.Border
    stroke.Transparency = Tokens.BorderTransparency
    stroke.Thickness = 1
    stroke.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "Field"
    textBox.Position = UDim2.fromOffset(12, 0)
    textBox.Size = UDim2.new(1, -24, 1, 0)
    textBox.BackgroundTransparency = 1
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = Tokens.TextMuted
    textBox.Text = ""
    textBox.TextColor3 = Tokens.TextPrimary
    textBox.FontFace = GetFont("Regular")
    textBox.TextSize = 14
    textBox.TextXAlignment = Enum.TextXAlignment.Center
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputFrame
    
    textBox.Focused:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.14), { Color = Tokens.Accent, Transparency = 0 }):Play()
    end)
    textBox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(stroke, TweenInfo.new(0.14), { Color = Tokens.Border, Transparency = Tokens.BorderTransparency }):Play()
        callback(textBox.Text, enterPressed)
    end)
    
    return {
        Get = function() return textBox.Text end,
        Set = function(_, t) textBox.Text = t end,
        Row = inputFrame,
    }
end

-- Full-Width Button
function SectionMethods:CreateButton(cfg)
    local card = self.Card
    cfg = cfg or {}
    local name = cfg.Name or "Button"
    local callback = cfg.Callback or function() end
    
    local btn = Instance.new("TextButton")
    btn.Name = "Button_" .. name
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Tokens.InputSurface
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.FontFace = GetFont("Medium")
    btn.TextSize = 14
    btn.TextColor3 = Tokens.TextPrimary
    btn.AutoButtonColor = false
    btn.Parent = card
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Tokens.RadiusRow
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Tokens.Border
    stroke.Transparency = Tokens.BorderTransparency
    stroke.Thickness = 1
    stroke.Parent = btn
    
    AttachMicroSpring(btn)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.14), { BackgroundColor3 = Tokens.HoverRow }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.14), { BackgroundColor3 = Tokens.InputSurface }):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    
    return {
        Button = btn,
    }
end

-- =========================================================================
-- FLOATING WIDGETS
-- =========================================================================

-- Floating Watermark Pill (Top-Left)
function WindowMethods:CreateWatermark(cfg)
    local Window = self
    cfg = cfg or {}
    local title = cfg.Title or Window.Title or "Lume"
    local subtitle = cfg.Subtitle or "Green Screen"
    
    local pill = Instance.new("Frame")
    pill.Name = "WatermarkPill"
    pill.Position = UDim2.fromOffset(24, 24)
    pill.Size = UDim2.fromOffset(340, 34)
    pill.BackgroundColor3 = Tokens.PanelSurface
    pill.BorderSizePixel = 0
    pill.ZIndex = 80
    pill.Parent = Window.ScreenGui
    
    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = Tokens.RadiusPill
    pillCorner.Parent = pill
    
    local pillStroke = Instance.new("UIStroke")
    pillStroke.Color = Tokens.Border
    pillStroke.Transparency = Tokens.BorderTransparency
    pillStroke.Thickness = 1
    pillStroke.Parent = pill
    
    AddWindowShadow(pill, 16)
    EnableDragging(pill, pill, function() Elevate(pill) end)
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 10)
    layout.Parent = pill
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = pill
    
    RenderLogo(pill, UDim2.fromOffset(18, 18))
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.FontFace = GetFont("Medium")
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = Tokens.TextPrimary
    titleLbl.AutomaticSize = Enum.AutomaticSize.X
    titleLbl.Size = UDim2.new(0, 0, 1, 0)
    titleLbl.ZIndex = pill.ZIndex + 1
    titleLbl.Parent = pill
    
    local function AddDivider()
        local d = Instance.new("Frame")
        d.Size = UDim2.fromOffset(1, 14)
        d.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
        d.BorderSizePixel = 0
        d.ZIndex = pill.ZIndex + 1
        d.Parent = pill
        return d
    end
    
    AddDivider()
    
    local subLbl = Instance.new("TextLabel")
    subLbl.BackgroundTransparency = 1
    subLbl.Text = subtitle
    subLbl.FontFace = GetFont("Regular")
    subLbl.TextSize = 12
    subLbl.TextColor3 = Tokens.TextMuted
    subLbl.AutomaticSize = Enum.AutomaticSize.X
    subLbl.Size = UDim2.new(0, 0, 1, 0)
    subLbl.ZIndex = pill.ZIndex + 1
    subLbl.Parent = pill
    
    AddDivider()
    
    local fpsLbl = Instance.new("TextLabel")
    fpsLbl.BackgroundTransparency = 1
    fpsLbl.Text = "60 fps"
    fpsLbl.FontFace = GetFont("Regular")
    fpsLbl.TextSize = 12
    fpsLbl.TextColor3 = Tokens.TextMuted
    fpsLbl.AutomaticSize = Enum.AutomaticSize.X
    fpsLbl.Size = UDim2.new(0, 0, 1, 0)
    fpsLbl.ZIndex = pill.ZIndex + 1
    fpsLbl.Parent = pill
    
    AddDivider()
    
    local pingLbl = Instance.new("TextLabel")
    pingLbl.BackgroundTransparency = 1
    pingLbl.Text = "32 ms"
    pingLbl.FontFace = GetFont("Regular")
    pingLbl.TextSize = 12
    pingLbl.TextColor3 = Tokens.TextMuted
    pingLbl.AutomaticSize = Enum.AutomaticSize.X
    pingLbl.Size = UDim2.new(0, 0, 1, 0)
    pingLbl.ZIndex = pill.ZIndex + 1
    pingLbl.Parent = pill
    
    AddDivider()
    
    local clockLbl = Instance.new("TextLabel")
    clockLbl.BackgroundTransparency = 1
    clockLbl.Text = os.date("%X")
    clockLbl.FontFace = GetFont("Regular")
    clockLbl.TextSize = 12
    clockLbl.TextColor3 = Tokens.TextMuted
    clockLbl.AutomaticSize = Enum.AutomaticSize.X
    clockLbl.Size = UDim2.new(0, 0, 1, 0)
    clockLbl.ZIndex = pill.ZIndex + 1
    clockLbl.Parent = pill
    
    local frameCount = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 0.5 then
            local fps = math.floor(frameCount / (now - lastTime))
            fpsLbl.Text = tostring(fps) .. " fps"
            frameCount = 0
            lastTime = now
            clockLbl.Text = os.date("%X")
            
            pcall(function()
                local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                pingLbl.Text = tostring(ping) .. " ms"
            end)
        end
    end)
    
    return pill
end

-- Floating Keybind List Widget
function WindowMethods:CreateKeybindList(cfg)
    local Window = self
    cfg = cfg or {}
    local title = cfg.Title or "Keybind list"
    local pinned = cfg.Pinned ~= false
    
    local widget = Instance.new("Frame")
    widget.Name = "KeybindListWidget"
    widget.Position = UDim2.new(0, 24, 1, -250)
    widget.Size = UDim2.fromOffset(300, 180)
    widget.BackgroundColor3 = Tokens.PanelSurface
    widget.BorderSizePixel = 0
    widget.ZIndex = 80
    widget.Parent = Window.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Tokens.RadiusWindow
    corner.Parent = widget
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Tokens.Border
    stroke.Transparency = Tokens.BorderTransparency
    stroke.Thickness = 1
    stroke.Parent = widget
    
    AddWindowShadow(widget, 14)
    EnableDragging(widget, widget, function() Elevate(widget) end)
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, -24, 0, 36)
    header.Position = UDim2.fromOffset(12, 4)
    header.BackgroundTransparency = 1
    header.ZIndex = widget.ZIndex + 1
    header.Parent = widget
    
    local listIcon = Instance.new("ImageLabel")
    listIcon.Position = UDim2.fromOffset(2, 10)
    listIcon.Size = UDim2.fromOffset(16, 16)
    listIcon.BackgroundTransparency = 1
    listIcon.Image = "rbxassetid://6034656460"
    listIcon.ImageColor3 = Tokens.TextMuted
    listIcon.ZIndex = header.ZIndex
    listIcon.Parent = header
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Position = UDim2.fromOffset(26, 0)
    headerTitle.Size = UDim2.new(1, -60, 1, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = title
    headerTitle.FontFace = GetFont("Medium")
    headerTitle.TextSize = 14
    headerTitle.TextColor3 = Tokens.TextPrimary
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.ZIndex = header.ZIndex
    headerTitle.Parent = header
    
    local pinBtn = Instance.new("ImageButton")
    pinBtn.Name = "PinButton"
    pinBtn.AnchorPoint = Vector2.new(1, 0.5)
    pinBtn.Position = UDim2.new(1, 0, 0.5, 0)
    pinBtn.Size = UDim2.fromOffset(16, 16)
    pinBtn.BackgroundTransparency = 1
    pinBtn.Image = "rbxassetid://6034455856"
    pinBtn.ImageColor3 = pinned and Tokens.Accent or Tokens.TextMuted
    pinBtn.ZIndex = header.ZIndex
    pinBtn.Parent = header
    
    pinBtn.MouseButton1Click:Connect(function()
        pinned = not pinned
        TweenService:Create(pinBtn, TweenInfo.new(0.14), { ImageColor3 = pinned and Tokens.Accent or Tokens.TextMuted }):Play()
    end)
    
    local colHeader = Instance.new("Frame")
    colHeader.Name = "ColHeader"
    colHeader.Position = UDim2.fromOffset(12, 42)
    colHeader.Size = UDim2.new(1, -24, 0, 20)
    colHeader.BackgroundTransparency = 1
    colHeader.ZIndex = widget.ZIndex + 1
    colHeader.Parent = widget
    
    local function AddColHeader(text, xPos, width, align)
        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.new(xPos, 0, 0, 0)
        lbl.Size = UDim2.new(width, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.FontFace = GetFont("Regular")
        lbl.TextSize = 12
        lbl.TextColor3 = Tokens.TextMuted
        lbl.TextXAlignment = align or Enum.TextXAlignment.Left
        lbl.ZIndex = colHeader.ZIndex
        lbl.Parent = colHeader
    end
    AddColHeader("Function", 0, 0.42, Enum.TextXAlignment.Left)
    AddColHeader("Hotkey", 0.44, 0.22, Enum.TextXAlignment.Center)
    AddColHeader("Status", 0.68, 0.22, Enum.TextXAlignment.Center)
    
    local rowsHost = Instance.new("Frame")
    rowsHost.Name = "Rows"
    rowsHost.Position = UDim2.fromOffset(12, 66)
    rowsHost.Size = UDim2.new(1, -24, 1, -74)
    rowsHost.BackgroundTransparency = 1
    rowsHost.ZIndex = widget.ZIndex + 1
    rowsHost.Parent = widget
    
    local rowsLayout = Instance.new("UIListLayout")
    rowsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowsLayout.Padding = UDim.new(0, 4)
    rowsLayout.Parent = rowsHost
    
    local rowIndex = 0
    local function AddKeybindRow(fnName, key, status)
        rowIndex = rowIndex + 1
        local isAlt = (rowIndex % 2 == 0)
        
        local row = Instance.new("Frame")
        row.Name = "Row_" .. fnName
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundColor3 = isAlt and Tokens.InputSurface or Tokens.CardSurface
        row.BorderSizePixel = 0
        row.ZIndex = rowsHost.ZIndex + 1
        row.Parent = rowsHost
        
        local rCorner = Instance.new("UICorner")
        rCorner.CornerRadius = UDim.new(0, 6)
        rCorner.Parent = row
        
        local rPad = Instance.new("UIPadding")
        rPad.PaddingLeft = UDim.new(0, 8)
        rPad.PaddingRight = UDim.new(0, 8)
        rPad.Parent = row
        
        local fnLbl = Instance.new("TextLabel")
        fnLbl.Size = UDim2.new(0.42, 0, 1, 0)
        fnLbl.BackgroundTransparency = 1
        fnLbl.Text = fnName
        fnLbl.FontFace = GetFont("Regular")
        fnLbl.TextSize = 14
        fnLbl.TextColor3 = Tokens.TextPrimary
        fnLbl.TextXAlignment = Enum.TextXAlignment.Left
        fnLbl.ZIndex = row.ZIndex
        fnLbl.Parent = row
        
        local keyLbl = Instance.new("TextLabel")
        keyLbl.Position = UDim2.new(0.44, 0, 0, 0)
        keyLbl.Size = UDim2.new(0.22, 0, 1, 0)
        keyLbl.BackgroundTransparency = 1
        keyLbl.Text = key
        keyLbl.FontFace = GetFont("Regular")
        keyLbl.TextSize = 14
        keyLbl.TextColor3 = Tokens.TextPrimary
        keyLbl.TextXAlignment = Enum.TextXAlignment.Center
        keyLbl.ZIndex = row.ZIndex
        keyLbl.Parent = row
        
        local statusLbl = Instance.new("TextLabel")
        statusLbl.Position = UDim2.new(0.68, 0, 0, 0)
        statusLbl.Size = UDim2.new(0.22, 0, 1, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = status
        statusLbl.FontFace = GetFont("Regular")
        statusLbl.TextSize = 14
        statusLbl.TextColor3 = Tokens.TextPrimary
        statusLbl.TextXAlignment = Enum.TextXAlignment.Center
        statusLbl.ZIndex = row.ZIndex
        statusLbl.Parent = row
        
        local dotBtn = Instance.new("TextButton")
        dotBtn.Name = "Dots"
        dotBtn.AnchorPoint = Vector2.new(1, 0.5)
        dotBtn.Position = UDim2.new(1, 0, 0.5, 0)
        dotBtn.Size = UDim2.fromOffset(20, 20)
        dotBtn.BackgroundTransparency = 1
        dotBtn.Text = "···"
        dotBtn.FontFace = GetFont("Bold")
        dotBtn.TextSize = 14
        dotBtn.TextColor3 = Tokens.TextMuted
        dotBtn.AutoButtonColor = false
        dotBtn.ZIndex = row.ZIndex
        dotBtn.Parent = row
        
        dotBtn.MouseButton1Click:Connect(function()
            if statusLbl.Text == "Hold" then
                statusLbl.Text = "Toggle"
            elseif statusLbl.Text == "Toggle" then
                statusLbl.Text = "Always"
            else
                statusLbl.Text = "Hold"
            end
        end)
    end
    
    AddKeybindRow("Aimbot", "Q", "Hold")
    AddKeybindRow("Triggerbot", "E", "Toggle")
    
    return widget
end

-- Toast Notification
function WindowMethods:Notify(cfg)
    local Window = self
    cfg = cfg or {}
    local title = cfg.Title or Window.Title or "Lume"
    local content = cfg.Content or "something about making n doing uis"
    local duration = cfg.Duration or 5
    
    local toast = Instance.new("Frame")
    toast.Name = "Toast"
    toast.AnchorPoint = Vector2.new(1, 0)
    toast.Position = UDim2.new(1, 340, 0, 100)
    toast.Size = UDim2.fromOffset(330, 74)
    toast.BackgroundColor3 = Tokens.PanelSurface
    toast.BorderSizePixel = 0
    toast.ZIndex = 120
    toast.ClipsDescendants = true
    toast.Parent = Window.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Tokens.RadiusCard
    corner.Parent = toast
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Tokens.Border
    stroke.Transparency = Tokens.BorderTransparency
    stroke.Thickness = 1
    stroke.Parent = toast
    
    AddWindowShadow(toast, 10)
    
    local msgIcon = Instance.new("ImageLabel")
    msgIcon.Position = UDim2.fromOffset(14, 12)
    msgIcon.Size = UDim2.fromOffset(16, 16)
    msgIcon.BackgroundTransparency = 1
    msgIcon.Image = "rbxassetid://6034287594"
    msgIcon.ImageColor3 = Tokens.TextMuted
    msgIcon.ZIndex = toast.ZIndex + 1
    msgIcon.Parent = toast
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Position = UDim2.fromOffset(36, 10)
    titleLbl.Size = UDim2.new(1, -70, 0, 18)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.FontFace = GetFont("Medium")
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = Tokens.TextPrimary
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = toast.ZIndex + 1
    titleLbl.Parent = toast
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, -12, 0, 10)
    closeBtn.Size = UDim2.fromOffset(18, 18)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.FontFace = GetFont("Bold")
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Tokens.TextMuted
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = toast.ZIndex + 1
    closeBtn.Parent = toast
    
    local bodyLbl = Instance.new("TextLabel")
    bodyLbl.Position = UDim2.fromOffset(14, 34)
    bodyLbl.Size = UDim2.new(1, -28, 0, 18)
    bodyLbl.BackgroundTransparency = 1
    bodyLbl.Text = content
    bodyLbl.FontFace = GetFont("Regular")
    bodyLbl.TextSize = 12
    bodyLbl.TextColor3 = Tokens.TextMuted
    bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
    bodyLbl.ZIndex = toast.ZIndex + 1
    bodyLbl.Parent = toast
    
    local barTrack = Instance.new("Frame")
    barTrack.AnchorPoint = Vector2.new(0, 1)
    barTrack.Position = UDim2.new(0, 0, 1, 0)
    barTrack.Size = UDim2.new(1, 0, 0, 3)
    barTrack.BackgroundColor3 = Tokens.InputSurface
    barTrack.BorderSizePixel = 0
    barTrack.ZIndex = toast.ZIndex + 1
    barTrack.Parent = toast
    
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.fromScale(1, 1)
    barFill.BackgroundColor3 = Tokens.Accent
    barFill.BorderSizePixel = 0
    barFill.ZIndex = barTrack.ZIndex + 1
    barFill.Parent = barTrack
    
    TweenService:Create(toast, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -350, 0, 100)
    }):Play()
    
    local drainTween = TweenService:Create(barFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    })
    drainTween:Play()
    
    local dismissed = false
    local function Dismiss()
        if dismissed then return end
        dismissed = true
        local slideOut = TweenService:Create(toast, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 350, 0, 100)
        })
        slideOut:Play()
        slideOut.Completed:Connect(function()
            toast:Destroy()
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(Dismiss)
    drainTween.Completed:Connect(Dismiss)
end

-- Window Toggle & Destroy
function WindowMethods:Toggle(state)
    local Window = self
    if state == nil then
        state = not Window.Visible
    end
    Window.Visible = state
    
    if state then
        Window.MainFrame.Visible = true
        TweenService:Create(Window.MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.55, 0)
        }):Play()
    else
        local hideTween = TweenService:Create(Window.MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0.58, 0)
        })
        hideTween:Play()
        hideTween.Completed:Connect(function()
            if not Window.Visible then
                Window.MainFrame.Visible = false
            end
        end)
    end
end

function WindowMethods:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return LumeUI
