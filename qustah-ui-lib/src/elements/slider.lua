-- card:Slider({ Title, Desc, Flag, Min, Max, Default, Step, Suffix, Callback, Locked, Icons = { From = "volume", To = "volume-2" }, Bubble = true })
-- Drag the track, or click the value and type a number. Icons puts an icon at each end of the track (clicking one
-- steps the value); while dragging a bubble over the knob shows the value (Bubble = false turns it off).
-- Callback(value, dragging): dragging is true while the knob is held, and one last call with false comes on
-- release - do heavy work only when `dragging` is false.
local Util = require("util")
local Theme = require("theme")
local Base = require("elements/base")
local Icons = require("icons")

local create, corner = Util.create, Util.corner

return function(card, cfg)
    local window = card.window
    local min, max = tonumber(cfg.Min) or 0, tonumber(cfg.Max) or 100
    if max < min then min, max = max, min end
    local step = tonumber(cfg.Step) or 1
    local suffix = cfg.Suffix and (" " .. tostring(cfg.Suffix)) or ""
    local decimals = Util.decimals(step)
    local top = cfg.Desc and 42 or 24
    local row, title, desc = Base.row(card, cfg, top + 20, { right = 70, titleHeight = 22, helpRight = 64, helpY = 11 })

    if desc then desc.Size = UDim2.new(1, 0, 0, 16) end -- the value sits on the title line only
    local box = create("TextBox", {
        Name = "Value", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(54, 20),
        BackgroundTransparency = 0.5, BorderSizePixel = 0, Text = "", TextSize = 12, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center, ClearTextOnFocus = false, Parent = row,
    })
    Theme.bind(box, "TextColor3", "heading")
    Theme.bind(box, "BackgroundColor3", "input")
    corner(box, 5)
    local boxStroke = Util.stroke(box, nil, 0.45)
    Theme.bind(boxStroke, "Color", "buttonEdge")
    box.Focused:Connect(function() box.BackgroundTransparency = 0.1 Theme.tweenTo(boxStroke, "Color", "accent", 0.12) end)
    box.FocusLost:Connect(function() box.BackgroundTransparency = 0.5 Theme.tweenTo(boxStroke, "Color", "buttonEdge", 0.12) end)
    local sideIcons = type(cfg.Icons) == "table" and cfg.Icons or nil
    local inset = sideIcons and 20 or 0
    local track = create("Frame", { Name = "Track", Position = UDim2.new(0, inset, 0, top + 8), Size = UDim2.new(1, -inset * 2, 0, 4), BorderSizePixel = 0, Parent = row })
    Theme.bind(track, "BackgroundColor3", "buttonEdge")
    corner(track, 2)
    local fill = create("Frame", { Name = "Fill", Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, Parent = track })
    Theme.bind(fill, "BackgroundColor3", "accent")
    corner(fill, 2)
    local knob = create("Frame", { Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(12, 12), BorderSizePixel = 0, ZIndex = 2, Parent = track })
    Theme.bind(knob, "BackgroundColor3", "heading")
    corner(knob, 6)
    local knobStroke = Util.stroke(knob, nil, 0.3)
    Theme.bind(knobStroke, "Color", "accent")
    local knobScale = create("UIScale", { Name = "macOSKnobScale", Scale = 1, Parent = knob })
    -- (taller on touch screens: easier to catch with a finger)
    local reach = Util.isTouch() and 8 or 0
    local hit = create("TextButton", { Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.new(0, inset - 6, 0, top - reach), Size = UDim2.new(1, 12 - inset * 2, 0, 18 + reach * 2), ZIndex = 3, Parent = row })
    -- value bubble over the knob while dragging
    local bubble = create("TextLabel", {
        Name = "Bubble", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, -6), Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X,
        BorderSizePixel = 0, Text = "", TextSize = 9, Font = Enum.Font.GothamMedium, Visible = false, ZIndex = 6, Parent = knob,
    })
    Theme.bind(bubble, "BackgroundColor3", "selected")
    Theme.bind(bubble, "TextColor3", "heading")
    corner(bubble, 5)
    local bubbleScale = create("UIScale", { Name = "macOSBubbleScale", Scale = 1, Parent = bubble })
    Util.padding(bubble, 7, 7, 0, 0)
    Theme.bind(Util.stroke(bubble), "Color", "buttonEdge")

    local element = Base.element(card, "Slider", cfg, row, title, desc)
    local focused = false
    local dragging, movedWhileDragging = false, false
    element.Dragging = false

    local function format(value)
        return (decimals > 0 and string.format("%." .. decimals .. "f", value) or tostring(math.floor(value + 0.5))) .. suffix
    end
    local function render()
        local ratio = max > min and (element.Value - min) / (max - min) or 0
        fill.Size = UDim2.new(ratio, 5 - 10 * ratio, 1, 0)
        knob.Position = UDim2.new(ratio, 5 - 10 * ratio, 0.5, 0)
        if not focused then box.Text = format(element.Value) end
        bubble.Text = format(element.Value)
    end
    function element:Set(value, silent)
        value = tonumber(value)
        if not value then render() return end
        value = math.clamp(Util.round(value - min, step) + min, min, max)
        if decimals > 0 then value = tonumber(string.format("%." .. decimals .. "f", value)) end
        local changed = value ~= self.Value
        self.Value = value
        render()
        if changed and dragging then movedWhileDragging = true end
        self:_fire(value, silent or not changed, dragging)
    end
    function element:Get() return self.Value end
    function element:SetRange(newMin, newMax)
        min, max = tonumber(newMin) or min, tonumber(newMax) or max
        self:Set(self.Value)
    end

    local function fromPoint(point)
        local width = track.AbsoluteSize.X
        if width <= 0 then return end
        local inset = 5 * (window.scale and window.scale.Scale or 1)
        element:Set(min + math.clamp((point.X - Util.screenPos(track).X - inset) / math.max(1, width - inset * 2), 0, 1) * (max - min))
    end
    hit.InputBegan:Connect(function(input)
        if not Util.isPress(input) or element.Locked then return end
        if cfg.Bubble ~= false then
            bubble.Visible = true
            bubbleScale.Scale = 0.75
            Util.tween(bubbleScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
        Util.tween(knobScale, 0.16, { Scale = 1.25 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        dragging, movedWhileDragging = true, false
        element.Dragging = true
        fromPoint(Util.pointer(input))
        window:_beginDrag(input, fromPoint, function()
            Util.tween(knobScale, 0.16, { Scale = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            if bubble.Visible then
                Util.tween(bubbleScale, 0.12, { Scale = 0.75 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                task.delay(0.12, function()
                    if not dragging then bubble.Visible = false end
                end)
            end
            dragging = false
            element.Dragging = false
            if movedWhileDragging then element:_fire(element.Value, false, false) end -- released: the final value
        end)
    end)
    if sideIcons then
        -- icons at both ends; a click moves one step (or a tenth of the range) that way
        local stride = step > 0 and math.max(step, (max - min) / 10) or (max - min) / 10
        for index, key in ipairs({ "From", "To" }) do
            local name = sideIcons[key] or sideIcons[index]
            local icon = name and Icons.themed(row, name, 14, "muted", {
                Name = key .. "Icon", AnchorPoint = Vector2.new(index == 1 and 0 or 1, 0.5), Position = UDim2.new(index == 1 and 0 or 1, 0, 0, top + 9),
            })
            if icon then
                local click = create("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 6, 1, 6), Position = UDim2.fromOffset(-3, -3), ZIndex = 4, Parent = icon })
                click.Activated:Connect(function()
                    if element.Locked then return end
                    element:Set(element.Value + (index == 1 and -stride or stride))
                end)
                click.MouseEnter:Connect(function() Theme.tweenTo(icon, "ImageColor3", "heading", 0.1) end)
                click.MouseLeave:Connect(function() Theme.tweenTo(icon, "ImageColor3", "muted", 0.1) end)
            end
        end
    end
    box.Focused:Connect(function() focused = true end)
    box.FocusLost:Connect(function()
        focused = false
        local number = tonumber((box.Text:gsub("[^%d%.%-]", "")))
        if number then element:Set(number) else render() end
        render()
    end)

    element.Value = math.clamp(tonumber(cfg.Default) or min, min, max)
    render()
    element:_fire(element.Value, true)
    return Base.finish(element, cfg)
end
