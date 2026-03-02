--[[
    REV UI SIMPLE - Ultra simple UI framework
    Version: 2.0
    Inspired by REV Hub aesthetics
    Use: loadstring(game:HttpGet("raw_url_here"))()
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Color palette
local colors = {
    bg = Color3.fromRGB(26, 26, 26),
    surface = Color3.fromRGB(42, 42, 42),
    surface2 = Color3.fromRGB(58, 58, 58),
    primary = Color3.fromRGB(74, 74, 74),
    text = Color3.fromRGB(255, 255, 255),
    textMuted = Color3.fromRGB(170, 170, 170),
    success = Color3.fromRGB(34, 197, 94),
    danger = Color3.fromRGB(239, 68, 68),
    warning = Color3.fromRGB(245, 158, 11),
    info = Color3.fromRGB(59, 130, 246)
}

-- Size mapping: name -> {width, height}
local sizeMap = {
    mini = {200, 100},
    small = {300, 150},
    medium = {400, 250},
    large = {600, 400},
    giant = {800, 600},
    auto = nil -- for automatic sizing (use with UISizeConstraint)
}

-- Position mapping: name -> {anchor, position}
local positionMap = {
    ["center"] = {anchor = Vector2.new(0.5, 0.5), pos = UDim2.new(0.5, 0, 0.5, 0)},
    ["top left"] = {anchor = Vector2.new(0, 0), pos = UDim2.new(0, 10, 0, 10)},
    ["top center"] = {anchor = Vector2.new(0.5, 0), pos = UDim2.new(0.5, 0, 0, 10)},
    ["top right"] = {anchor = Vector2.new(1, 0), pos = UDim2.new(1, -10, 0, 10)},
    ["middle left"] = {anchor = Vector2.new(0, 0.5), pos = UDim2.new(0, 10, 0.5, 0)},
    ["middle center"] = {anchor = Vector2.new(0.5, 0.5), pos = UDim2.new(0.5, 0, 0.5, 0)},
    ["middle right"] = {anchor = Vector2.new(1, 0.5), pos = UDim2.new(1, -10, 0.5, 0)},
    ["bottom left"] = {anchor = Vector2.new(0, 1), pos = UDim2.new(0, 10, 1, -10)},
    ["bottom center"] = {anchor = Vector2.new(0.5, 1), pos = UDim2.new(0.5, 0, 1, -10)},
    ["bottom right"] = {anchor = Vector2.new(1, 1), pos = UDim2.new(1, -10, 1, -10)},
}

-- Helper: convert size string to UDim2
local function parseSize(size, customWidth, customHeight)
    if size == "custom" then
        return UDim2.new(0, customWidth, 0, customHeight)
    end
    local dims = sizeMap[size]
    if dims then
        return UDim2.new(0, dims[1], 0, dims[2])
    end
    -- Default to medium
    return UDim2.new(0, 400, 0, 250)
end

-- Helper: convert position string to anchor and UDim2
local function parsePosition(posString)
    local p = positionMap[posString] or positionMap["center"]
    return p.anchor, p.pos
end

-- Base instance creator (with optional UICorner)
local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "CornerRadius" and k ~= "Children" then
            obj[k] = v
        end
    end
    if props.CornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = props.CornerRadius
        corner.Parent = obj
    end
    if props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = obj
        end
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

-- ---------------------------------------------------------------------
-- WINDOW
-- ---------------------------------------------------------------------
--[[
    Creates a draggable window with title, minimize/close buttons and content area.
    Usage:
    local win = UI.Window({
        title = "My App",
        size = "medium",      -- "mini", "small", "medium", "large", "giant"
        position = "center",   -- any position from positionMap
        parent = screenGui,    -- required: a ScreenGui
        bgColor = colors.bg,   -- optional (default colors.bg)
        closable = true,       -- show close button
        minimizable = true     -- show minimize button
    })
    
    Returns:
    {
        main: the main frame,
        content: the content frame,
        minimize: function to toggle minimize,
        destroy: function to close window
    }
--]]
local function Window(config)
    config = config or {}
    local title = config.title or "Window"
    local size = config.size or "medium"
    local position = config.position or "center"
    local parent = config.parent
    local bgColor = config.bgColor or colors.bg
    local closable = config.closable ~= false
    local minimizable = config.minimizable ~= false

    if not parent then
        error("Window: missing 'parent' (ScreenGui)")
    end

    local sizeUDim = parseSize(size)
    local anchor, posUDim = parsePosition(position)

    -- Main frame
    local main = create("Frame", {
        Size = sizeUDim,
        Position = posUDim,
        AnchorPoint = anchor,
        BackgroundColor3 = bgColor,
        BackgroundTransparency = 0.2,
        Active = true,
        Draggable = true,
        ClipsDescendants = true,
        CornerRadius = UDim.new(0, 16)
    }, parent)

    -- Title bar
    local titleBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = colors.surface,
        BackgroundTransparency = 0.2,
        CornerRadius = UDim.new(0, 16)
    }, main)

    -- Title text
    create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = colors.text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    }, titleBar)

    -- Minimize button
    local minimizeBtn
    if minimizable then
        minimizeBtn = create("TextButton", {
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(1, -72, 0.5, -16),
            BackgroundColor3 = colors.surface2,
            BackgroundTransparency = 0.1,
            Text = "—",
            TextColor3 = colors.text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 18,
            CornerRadius = UDim.new(0, 8),
            AutoButtonColor = true
        }, titleBar)
    end

    -- Close button
    local closeBtn
    if closable then
        closeBtn = create("TextButton", {
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(1, -36, 0.5, -16),
            BackgroundColor3 = colors.surface2,
            BackgroundTransparency = 0.1,
            Text = "×",
            TextColor3 = colors.danger,
            Font = Enum.Font.GothamSemibold,
            TextSize = 22,
            CornerRadius = UDim.new(0, 8),
            AutoButtonColor = true
        }, titleBar)
    end

    -- Content area
    local content = create("Frame", {
        Size = UDim2.new(1, -32, 1, -64),
        Position = UDim2.new(0, 16, 0, 56),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    }, main)

    -- Window object
    local window = {
        main = main,
        content = content,
        minimized = false,
        originalSize = sizeUDim,
    }

    function window:toggleMinimize()
        self.minimized = not self.minimized
        if self.minimized then
            self.main:TweenSize(UDim2.new(0, self.originalSize.X.Offset, 0, 48), "Out", "Quad", 0.2, true)
            self.content.Visible = false
        else
            self.main:TweenSize(self.originalSize, "Out", "Quad", 0.2, true)
            self.content.Visible = true
        end
    end

    if minimizeBtn then
        minimizeBtn.MouseButton1Click:Connect(function() window:toggleMinimize() end)
    end

    function window:destroy()
        self.main:Destroy()
    end

    if closeBtn then
        closeBtn.MouseButton1Click:Connect(function() window:destroy() end)
    end

    return window
end

-- ---------------------------------------------------------------------
-- TABS
-- ---------------------------------------------------------------------
--[[
    Creates a tab system inside a container (usually window.content).
    
    Parameters:
    - parent: the frame where tabs will go
    - position: "top" (horizontal) or "left" (vertical) - default "top"
    - bgColor: background color of the tab bar (optional)
    
    Returns an object with:
    - container: the frame containing tabs and content
    - tabs: table of created tabs (name -> {button, panel})
    - addTab(name, callback): function to add a tab, returns the content panel
    - selectTab(name): selects a tab by name
--]]
local function Tabs(config)
    config = config or {}
    local parent = config.parent
    local position = config.position or "top" -- "top" or "left"
    local bgColor = config.bgColor or colors.surface2

    if not parent then
        error("Tabs: missing 'parent'")
    end

    -- Main container for the whole tab system
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    }, parent)

    local tabBar, tabContent
    local tabs = {}
    local selectedTab = nil

    if position == "top" then
        -- Horizontal tab bar (top)
        tabBar = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = bgColor,
            BackgroundTransparency = 0.2,
            CornerRadius = UDim.new(0, 10),
            ScrollBarThickness = 0,
            AutomaticCanvasSize = Enum.AutomaticSize.X,
            ClipsDescendants = true
        }, container)

        -- Content area (below the bar)
        tabContent = create("Frame", {
            Size = UDim2.new(1, 0, 1, -50),
            Position = UDim2.new(0, 0, 0, 45),
            BackgroundTransparency = 1,
            ClipsDescendants = true
        }, container)

        -- Horizontal layout for buttons
        local layout = Instance.new("UIListLayout")
        layout.Parent = tabBar
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.Padding = UDim.new(0, 4)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
    else -- "left"
        -- Vertical tab bar (left)
        tabBar = create("ScrollingFrame", {
            Size = UDim2.new(0, 120, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = bgColor,
            BackgroundTransparency = 0.2,
            CornerRadius = UDim.new(0, 10),
            ScrollBarThickness = 0,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true
        }, container)

        -- Content area (to the right of the bar)
        tabContent = create("Frame", {
            Size = UDim2.new(1, -130, 1, 0),
            Position = UDim2.new(0, 125, 0, 0),
            BackgroundTransparency = 1,
            ClipsDescendants = true
        }, container)

        -- Vertical layout for buttons
        local layout = Instance.new("UIListLayout")
        layout.Parent = tabBar
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.Padding = UDim.new(0, 4)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
    end

    -- Function to add a tab
    local function addTab(name, onClick)
        -- Tab button
        local btn = create("TextButton", {
            Size = (position == "top") and UDim2.new(0, 90, 1, -8) or UDim2.new(1, -8, 0, 40),
            BackgroundColor3 = colors.surface2,
            BackgroundTransparency = 0.1,
            Text = name,
            TextColor3 = colors.textMuted,
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            CornerRadius = UDim.new(0, 8),
            AutoButtonColor = true
        }, tabBar)

        -- Content panel for this tab (initially invisible)
        local panel = create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ClipsDescendants = true
        }, tabContent)

        -- Store reference
        tabs[name] = {
            button = btn,
            panel = panel
        }

        -- Click event
        btn.MouseButton1Click:Connect(function()
            if selectedTab then
                tabs[selectedTab].button.BackgroundColor3 = colors.surface2
                tabs[selectedTab].button.TextColor3 = colors.textMuted
                tabs[selectedTab].panel.Visible = false
            end
            selectedTab = name
            btn.BackgroundColor3 = colors.primary
            btn.TextColor3 = colors.text
            panel.Visible = true
            if onClick then
                onClick(panel)
            end
        end)

        -- If it's the first tab, select it by default
        if next(tabs) == nil then
            selectedTab = name
            btn.BackgroundColor3 = colors.primary
            btn.TextColor3 = colors.text
            panel.Visible = true
        end

        return panel -- return panel so user can add stuff
    end

    -- Function to programmatically select a tab
    local function selectTab(name)
        local tab = tabs[name]
        if tab then
            tab.button.MouseButton1Click:Fire()
        end
    end

    return {
        container = container,
        tabs = tabs,
        addTab = addTab,
        selectTab = selectTab
    }
end

-- ---------------------------------------------------------------------
-- BUTTON
-- ---------------------------------------------------------------------
--[[
    Creates a styled button.
    Usage:
    local btn = UI.Button({
        text = "Click",
        size = "medium",        -- or "mini", "small", "large", etc.
        color = "primary",       -- key from colors table
        radius = 10,             -- corner radius
        textSize = 14,
        action = function() print("clicked") end
    }, parent)
--]]
local function Button(config, parent)
    config = config or {}
    local text = config.text or "Button"
    local size = config.size or "medium"
    local color = colors[config.color] or colors.primary
    local radius = config.radius or 10
    local textSize = config.textSize or 14

    local btn = create("TextButton", {
        Size = parseSize(size),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.1,
        Text = text,
        TextColor3 = colors.text,
        Font = Enum.Font.GothamSemibold,
        TextSize = textSize,
        CornerRadius = UDim.new(0, radius),
        AutoButtonColor = true
    }, parent)

    if config.action then
        btn.MouseButton1Click:Connect(config.action)
    end

    return btn
end

-- ---------------------------------------------------------------------
-- LABEL
-- ---------------------------------------------------------------------
--[[
    Creates a text label.
    Usage:
    local lbl = UI.Label({
        text = "Hello world",
        size = "auto",            -- "auto" uses width of parent
        color = "text",            -- text color key
        textSize = 14,
        align = Enum.TextXAlignment.Left,
        wrapped = true
    }, parent)
--]]
local function Label(config, parent)
    config = config or {}
    local text = config.text or ""
    local size = config.size or "auto"
    local color = colors[config.color] or colors.text
    local textSize = config.textSize or 14
    local align = config.align or Enum.TextXAlignment.Left
    local wrapped = config.wrapped or false

    local sizeUDim
    if size == "auto" then
        sizeUDim = UDim2.new(1, -20, 0, textSize + 4) -- approximate
    else
        sizeUDim = parseSize(size)
    end

    return create("TextLabel", {
        Size = sizeUDim,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color,
        Font = Enum.Font.Gotham,
        TextSize = textSize,
        TextXAlignment = align,
        TextWrapped = wrapped
    }, parent)
end

-- ---------------------------------------------------------------------
-- FRAME
-- ---------------------------------------------------------------------
--[[
    Creates a container frame with background.
    Usage:
    local frm = UI.Frame({
        size = "medium",
        color = "surface",
        radius = 10,
        transparency = 0.2
    }, parent)
--]]
local function Frame(config, parent)
    config = config or {}
    local size = config.size or "medium"
    local color = colors[config.color] or colors.surface
    local radius = config.radius or 10
    local transp = config.transparency or 0.2

    return create("Frame", {
        Size = parseSize(size),
        BackgroundColor3 = color,
        BackgroundTransparency = transp,
        CornerRadius = UDim.new(0, radius)
    }, parent)
end

-- ---------------------------------------------------------------------
-- SCROLL AREA
-- ---------------------------------------------------------------------
--[[
    Creates a scrolling frame with automatic vertical layout.
    Usage:
    local scroll = UI.ScrollArea({
        size = "large",
        barColor = colors.primary,
        padding = 8
    }, parent)
--]]
local function ScrollArea(config, parent)
    config = config or {}
    local size = config.size or "large"
    local barColor = config.barColor or colors.primary
    local padding = config.padding or 8

    local sf = create("ScrollingFrame", {
        Size = parseSize(size),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = barColor,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, parent)

    local layout = Instance.new("UIListLayout")
    layout.Parent = sf
    layout.Padding = UDim.new(0, padding)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    return sf
end

-- ---------------------------------------------------------------------
-- NOTIFICATIONS
-- ---------------------------------------------------------------------
local notificationHolder = nil
local notifLayout = nil

--[[
    Sets up the notification system (call once at start).
    Usage: UI.SetupNotifications(screenGui, "bottom right")
--]]
function SetupNotifications(parent, position)
    position = position or "bottom right"
    local anchor, posUDim = parsePosition(position)

    notificationHolder = create("Frame", {
        Name = "NotificationHolder",
        Size = UDim2.new(0, 300, 0, 0), -- dynamic height
        Position = posUDim,
        AnchorPoint = anchor,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 100
    }, parent)

    notifLayout = Instance.new("UIListLayout")
    notifLayout.Parent = notificationHolder
    notifLayout.Padding = UDim.new(0, 8)
    notifLayout.HorizontalAlignment = (position:find("right") and Enum.HorizontalAlignment.Right) or
                                      (position:find("center") and Enum.HorizontalAlignment.Center) or
                                      Enum.HorizontalAlignment.Left
    notifLayout.VerticalAlignment = (position:find("bottom") and Enum.VerticalAlignment.Bottom) or
                                    (position:find("top") and Enum.VerticalAlignment.Top) or
                                    Enum.VerticalAlignment.Center

    -- Adjust holder height to content
    notifLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        notificationHolder.Size = UDim2.new(0, 300, 0, notifLayout.AbsoluteContentSize.Y)
    end)
end

--[[
    Shows a notification.
    Usage: UI.Notify("Message", "success", 3)
    types: "success", "error", "warning", "info" (any other uses primary)
--]]
function Notify(message, type, duration)
    type = type or "info"
    duration = duration or 3
    if not notificationHolder then
        warn("Notifications not set up. Call SetupNotifications first.")
        return
    end

    local notif = create("Frame", {
        Size = UDim2.new(0, 280, 0, 50),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.2,
        CornerRadius = UDim.new(0, 8)
    }, notificationHolder)

    -- Colored side bar
    create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = type == "success" and colors.success or
                          type == "error" and colors.danger or
                          type == "warning" and colors.warning or colors.primary,
        CornerRadius = UDim.new(0, 4)
    }, notif)

    -- Text
    create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = colors.text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left
    }, notif)

    -- Entrance animation
    notif.Position = UDim2.new(1, 0, 0, 0)
    notif:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.3, true)

    -- Auto-remove
    task.delay(duration, function()
        if notif and notif.Parent then
            notif:TweenPosition(UDim2.new(1, 0, 0, 0), "In", "Quad", 0.3, true)
            task.delay(0.3, function()
                if notif and notif.Parent then
                    notif:Destroy()
                end
            end)
        end
    end)
end

-- ---------------------------------------------------------------------
-- DIALOGS
-- ---------------------------------------------------------------------
--[[
    Confirmation dialog (Yes/No).
    Usage:
    UI.Confirm("Are you sure?", function(answer)
        if answer then print("Accepted") end
    end)
--]]
function Confirm(message, callback)
    local bg = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.5,
        Active = true,
        ZIndex = 200
    }, game:GetService("CoreGui"))

    local dialog = Frame({
        size = "small",
        color = "surface",
        transparency = 0,
        radius = 16
    }, bg)
    dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.ZIndex = 201
    dialog.Active = true
    dialog.Draggable = true

    Label({
        text = message,
        size = "auto",
        textSize = 14,
        align = Enum.TextXAlignment.Center,
        wrapped = true
    }, dialog)

    local yesBtn = Button({
        text = "Yes",
        size = "mini",
        color = "success",
        action = function()
            callback(true)
            bg:Destroy()
        end
    }, dialog)
    yesBtn.Position = UDim2.new(0.2, -40, 1, -50)
    yesBtn.AnchorPoint = Vector2.new(0.5, 0)

    local noBtn = Button({
        text = "No",
        size = "mini",
        color = "danger",
        action = function()
            callback(false)
            bg:Destroy()
        end
    }, dialog)
    noBtn.Position = UDim2.new(0.8, -40, 1, -50)
    noBtn.AnchorPoint = Vector2.new(0.5, 0)

    return bg
end

--[[
    Rename dialog (similar to REV Hub's).
    Usage:
    UI.Rename("Current name", function(newName)
        print("New name:", newName)
    end)
--]]
function Rename(currentValue, callback)
    local bg = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.5,
        Active = true,
        ZIndex = 200
    }, game:GetService("CoreGui"))

    local dialog = Frame({
        size = "small",
        color = "surface",
        transparency = 0,
        radius = 16
    }, bg)
    dialog.Size = UDim2.new(0, 300, 0, 150)
    dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.ZIndex = 201
    dialog.Active = true
    dialog.Draggable = true

    Label({
        text = "Rename",
        size = "auto",
        textSize = 16,
        align = Enum.TextXAlignment.Center
    }, dialog)

    local textBox = create("TextBox", {
        Size = UDim2.new(1, -40, 0, 30),
        Position = UDim2.new(0, 20, 0, 40),
        BackgroundColor3 = colors.surface2,
        BackgroundTransparency = 0.1,
        Text = currentValue,
        TextColor3 = colors.text,
        PlaceholderText = "New name",
        PlaceholderColor3 = colors.textMuted,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        ClearTextOnFocus = false,
        CornerRadius = UDim.new(0, 6)
    }, dialog)

    local saveBtn = Button({
        text = "Save",
        size = "mini",
        color = "success",
        action = function()
            local new = textBox.Text
            if new and new ~= "" then
                callback(new)
                bg:Destroy()
            else
                Notify("Name cannot be empty", "warning")
            end
        end
    }, dialog)
    saveBtn.Position = UDim2.new(0.2, -40, 1, -40)
    saveBtn.AnchorPoint = Vector2.new(0.5, 0)

    local cancelBtn = Button({
        text = "Cancel",
        size = "mini",
        color = "danger",
        action = function()
            bg:Destroy()
        end
    }, dialog)
    cancelBtn.Position = UDim2.new(0.8, -40, 1, -40)
    cancelBtn.AnchorPoint = Vector2.new(0.5, 0)

    return bg
end

-- ---------------------------------------------------------------------
-- EXPORT
-- ---------------------------------------------------------------------
return {
    colors = colors,
    Window = Window,
    Tabs = Tabs,
    Button = Button,
    Label = Label,
    Frame = Frame,
    ScrollArea = ScrollArea,
    SetupNotifications = SetupNotifications,
    Notify = Notify,
    Confirm = Confirm,
    Rename = Rename
}
