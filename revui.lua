--[[
    REV UI LIBRARY v3.0
    - Sistema de componentes
    - Animaciones
    - Temas (?)
    - Sistema de notificaciones
    - Búsqueda integrada en dropdowns
    - Sistema de tabs
]]

local REV = {}
REV.__index = REV

-- Servicios
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Tema por defecto (Dark Purple)
REV.Themes = {
    DarkPurple = {
        Background = Color3.fromRGB(25, 0, 35),
        Surface = Color3.fromRGB(40, 10, 60),
        SurfaceHighlight = Color3.fromRGB(60, 20, 90),
        Primary = Color3.fromRGB(147, 51, 234),
        PrimaryHover = Color3.fromRGB(168, 85, 247),
        Secondary = Color3.fromRGB(59, 130, 246),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(245, 158, 11),
        Danger = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(6, 182, 212),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(200, 180, 220),
        TextDark = Color3.fromRGB(15, 15, 15),
        Border = Color3.fromRGB(80, 40, 120),
        Glow = Color3.fromRGB(147, 51, 234)
    },
    Midnight = {
        Background = Color3.fromRGB(15, 23, 42),
        Surface = Color3.fromRGB(30, 41, 59),
        SurfaceHighlight = Color3.fromRGB(51, 65, 85),
        Primary = Color3.fromRGB(99, 102, 241),
        PrimaryHover = Color3.fromRGB(129, 140, 248),
        Secondary = Color3.fromRGB(14, 165, 233),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(251, 191, 36),
        Danger = Color3.fromRGB(248, 113, 113),
        Info = Color3.fromRGB(56, 189, 248),
        Text = Color3.fromRGB(248, 250, 252),
        TextMuted = Color3.fromRGB(148, 163, 184),
        TextDark = Color3.fromRGB(15, 23, 42),
        Border = Color3.fromRGB(71, 85, 105),
        Glow = Color3.fromRGB(99, 102, 241)
    },
    Crimson = {
        Background = Color3.fromRGB(30, 0, 15),
        Surface = Color3.fromRGB(60, 10, 30),
        SurfaceHighlight = Color3.fromRGB(90, 20, 50),
        Primary = Color3.fromRGB(220, 38, 38),
        PrimaryHover = Color3.fromRGB(239, 68, 68),
        Secondary = Color3.fromRGB(251, 146, 60),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(250, 204, 21),
        Danger = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(56, 189, 248),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(220, 180, 180),
        TextDark = Color3.fromRGB(30, 0, 15),
        Border = Color3.fromRGB(120, 40, 60),
        Glow = Color3.fromRGB(220, 38, 38)
    }
}

-- Configuración
REV.Config = {
    AnimationSpeed = 0.3,
    CornerRadius = 12,
    ShadowTransparency = 0.6,
    DragSmoothness = 0.15,
    MaxNotifications = 5,
    Version = "3.0"
}

-- Utilidades
local function Tween(obj, props, duration, easing, callback)
    duration = duration or REV.Config.AnimationSpeed
    easing = easing or Enum.EasingStyle.Quart
    local tween = TweenService:Create(obj, TweenInfo.new(duration, easing, Enum.EasingDirection.Out), props)
    if callback then tween.Completed:Connect(callback) end
    tween:Play()
    return tween
end

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Children" and k ~= "CornerRadius" and k ~= "Stroke" and k ~= "Gradient" then
            obj[k] = v
        end
    end
    if props.CornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = props.CornerRadius
        corner.Parent = obj
    end
    if props.Stroke then
        local stroke = Instance.new("UIStroke")
        stroke.Color = props.Stroke.Color or Color3.new(1, 1, 1)
        stroke.Thickness = props.Stroke.Thickness or 1
        stroke.Transparency = props.Stroke.Transparency or 0
        stroke.Parent = obj
    end
    if props.Gradient then
        local grad = Instance.new("UIGradient")
        grad.Color = props.Gradient.Color or ColorSequence.new(Color3.new(1,1,1))
        grad.Rotation = props.Gradient.Rotation or 0
        grad.Parent = obj
    end
    if props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = obj
        end
    end
    return obj
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local currentPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
            local newPos = UDim2.new(
                startPos.X.Scale, 
                math.clamp(startPos.X.Offset + delta.X, -frame.Size.X.Offset/2, mouse.ViewSizeX - frame.Size.X.Offset/2),
                startPos.Y.Scale,
                math.clamp(startPos.Y.Offset + delta.Y, 0, mouse.ViewSizeY - frame.Size.Y.Offset)
            )
            currentPos = newPos
            frame.Position = newPos
        end
    end)
end

-- Sistema de Notificaciones Mejorado
REV.Notifications = {}
REV.NotificationQueue = {}

function REV:Notify(data)
    data = data or {}
    local notifData = {
        Title = data.Title or "Notification",
        Content = data.Content or "",
        Type = data.Type or "Info", -- Success, Error, Warning, Info
        Duration = data.Duration or 4,
        Icon = data.Icon or "bell",
        Actions = data.Actions or nil -- { {Name = "Action", Callback = function} }
    }
    
    table.insert(REV.NotificationQueue, notifData)
    self:ProcessNotificationQueue()
end

function REV:ProcessNotificationQueue()
    if #REV.Notifications >= REV.Config.MaxNotifications then return end
    if #REV.NotificationQueue == 0 then return end
    
    local data = table.remove(REV.NotificationQueue, 1)
    local theme = self.CurrentTheme or REV.Themes.DarkPurple
    
    -- Iconos simples usando texto/emojis
    local icons = {
        bell = "🔔",
        check = "✓",
        x = "✕",
        alert = "⚠",
        info = "ℹ",
        heart = "♥",
        star = "★",
        play = "▶",
        stop = "■",
        settings = "⚙",
        user = "👤",
        search = "🔍"
    }
    
    local colors = {
        Success = theme.Success,
        Error = theme.Danger,
        Warning = theme.Warning,
        Info = theme.Info
    }
    
    local notifGui = player:WaitForChild("PlayerGui"):FindFirstChild("REV_Notifications")
    if not notifGui then
        notifGui = Create("ScreenGui", {
            Name = "REV_Notifications",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
        notifGui.Parent = player:WaitForChild("PlayerGui")
        
        local layout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom
        })
        layout.Parent = notifGui
    end
    
    local notifFrame = Create("Frame", {
        Size = UDim2.new(0, 320, 0, 80),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 20, 0, 0),
        CornerRadius = UDim.new(0, REV.Config.CornerRadius),
        Stroke = { Color = theme.Border, Thickness = 1, Transparency = 0.5 },
        Children = {
            Create("Frame", {
                Name = "Accent",
                Size = UDim2.new(0, 4, 1, 0),
                BackgroundColor3 = colors[data.Type] or theme.Primary,
                BorderSizePixel = 0
            }),
            Create("TextLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(0, 15, 0, 15),
                BackgroundTransparency = 1,
                Text = icons[data.Icon] or icons.bell,
                TextColor3 = colors[data.Type] or theme.Primary,
                Font = Enum.Font.GothamBold,
                TextSize = 20
            }),
            Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -60, 0, 20),
                Position = UDim2.new(0, 50, 0, 12),
                BackgroundTransparency = 1,
                Text = data.Title,
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Create("TextLabel", {
                Name = "Content",
                Size = UDim2.new(1, -60, 0, 40),
                Position = UDim2.new(0, 50, 0, 32),
                BackgroundTransparency = 1,
                Text = data.Content,
                TextColor3 = theme.TextMuted,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true
            }),
            Create("TextButton", {
                Name = "Close",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -25, 0, 10),
                BackgroundTransparency = 1,
                Text = "×",
                TextColor3 = theme.TextMuted,
                Font = Enum.Font.GothamBold,
                TextSize = 18
            })
        }
    })
    notifFrame.Parent = notifGui
    
    table.insert(REV.Notifications, notifFrame)
    
    -- Animación de entrada
    Tween(notifFrame, { Position = UDim2.new(1, -340, 0, 0) }, 0.4, Enum.EasingStyle.Back)
    
    -- Cerrar al hacer clic
    local closeBtn = notifFrame:WaitForChild("Close")
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, { TextColor3 = theme.Danger }) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, { TextColor3 = theme.TextMuted }) end)
    
    local function closeNotif()
        if not notifFrame.Parent then return end
        Tween(notifFrame, { Position = UDim2.new(1, 20, 0, 0) }, 0.3, nil, function()
            notifFrame:Destroy()
            for i, n in ipairs(REV.Notifications) do
                if n == notifFrame then
                    table.remove(REV.Notifications, i)
                    break
                end
            end
            REV:ProcessNotificationQueue()
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(closeNotif)
    
    -- Auto cerrar
    task.delay(data.Duration, closeNotif)
    
    -- Procesar siguiente en cola
    task.delay(0.1, function() REV:ProcessNotificationQueue() end)
end

-- Crear Ventana Principal
function REV:CreateWindow(config)
    config = config or {}
    local theme = config.Theme and (type(config.Theme) == "string" and REV.Themes[config.Theme] or config.Theme) or REV.Themes.DarkPurple
    self.CurrentTheme = theme
    
    local window = {}
    setmetatable(window, REV)
    
    -- ScreenGui
    local gui = Create("ScreenGui", {
        Name = config.Name or "REV_UI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    gui.Parent = player:WaitForChild("PlayerGui")
    window.GUI = gui
    
    -- Main Frame con Shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(0, config.Width + 40 or 540, 0, config.Height + 40 or 690),
        Position = UDim2.new(0.5, -(config.Width or 500)/2 - 20, 0.5, -(config.Height or 650)/2 - 20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217", -- Shadow image
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = REV.Config.ShadowTransparency,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118)
    })
    shadow.Parent = gui
    
    local main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, config.Width or 500, 0, config.Height or 650),
        Position = UDim2.new(0.5, -(config.Width or 500)/2, 0.5, -(config.Height or 650)/2),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        CornerRadius = UDim.new(0, REV.Config.CornerRadius),
        ClipsDescendants = true
    })
    main.Parent = gui
    window.Main = main
    
    -- Title Bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, REV.Config.CornerRadius) }),
            Create("Frame", { -- Para tapar esquina inferior
                Size = UDim2.new(1, 0, 0, 10),
                Position = UDim2.new(0, 0, 1, -10),
                BackgroundColor3 = theme.Surface,
                BorderSizePixel = 0
            })
        }
    })
    titleBar.Parent = main
    
    -- Logo/Icono
    local logo = Create("TextLabel", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 15, 0, 10),
        BackgroundColor3 = theme.Primary,
        Text = config.Icon or "⚡",
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        CornerRadius = UDim.new(0, 8)
    })
    logo.Parent = titleBar
    
    -- Titulo
    local title = Create("TextLabel", {
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 55, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "REV UI",
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    title.Parent = titleBar
    
    -- Botones de control
    local minimizeBtn = Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -75, 0, 10),
        BackgroundColor3 = theme.SurfaceHighlight,
        Text = "—",
        TextColor3 = theme.TextMuted,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        CornerRadius = UDim.new(0, 8)
    })
    minimizeBtn.Parent = titleBar
    
    local closeBtn = Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 10),
        BackgroundColor3 = theme.Danger,
        Text = "×",
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        CornerRadius = UDim.new(0, 8)
    })
    closeBtn.Parent = titleBar
    
    -- Sistema de Tabs Mejorado
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = theme.Surface,
        CornerRadius = UDim.new(0, 10),
        Stroke = { Color = theme.Border, Thickness = 1, Transparency = 0.3 }
    })
    tabContainer.Parent = main
    
    local tabLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    tabLayout.Parent = tabContainer
    
    -- Contenido de Tabs
    local contentContainer = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -20, 1, -105),
        Position = UDim2.new(0, 10, 0, 100),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })
    contentContainer.Parent = main
    
    window.Tabs = {}
    window.ActiveTab = nil
    window.TabContents = {}
    window.Theme = theme
    
    -- Función para crear tabs
    function window:CreateTab(name, icon)
        local tab = {}
        
        local btn = Create("TextButton", {
            Name = name .. "Tab",
            Size = UDim2.new(0, 80, 0, 32),
            BackgroundColor3 = theme.SurfaceHighlight,
            Text = icon and (icon .. " " .. name) or name,
            TextColor3 = theme.TextMuted,
            Font = Enum.Font.GothamSemibold,
            TextSize = 11,
            CornerRadius = UDim.new(0, 6),
            AutoButtonColor = false
        })
        btn.Parent = tabContainer
        
        -- Contenido del tab
        local content = Create("ScrollingFrame", {
            Name = name .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Primary,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false
        })
        content.Parent = contentContainer
        
        local contentLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        contentLayout.Parent = content
        
        -- Actualizar canvas size automáticamente
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        tab.Button = btn
        tab.Content = content
        tab.Name = name
        tab.Elements = {}
        
        -- Selección de tab
        btn.MouseButton1Click:Connect(function()
            window:SelectTab(tab)
        end)
        
        btn.MouseEnter:Connect(function()
            if window.ActiveTab ~= tab then
                Tween(btn, { BackgroundColor3 = theme.SurfaceHighlight, TextColor3 = theme.Text })
            end
        end)
        
        btn.MouseLeave:Connect(function()
            if window.ActiveTab ~= tab then
                Tween(btn, { BackgroundColor3 = theme.SurfaceHighlight, TextColor3 = theme.TextMuted })
            end
        end)
        
        table.insert(window.Tabs, tab)
        window.TabContents[name] = content
        
        -- Auto seleccionar primero
        if #window.Tabs == 1 then
            window:SelectTab(tab)
        end
        
        -- Funciones para agregar elementos
        function tab:CreateSection(titleText)
            local section = Create("TextLabel", {
                Size = UDim2.new(1, -20, 0, 25),
                BackgroundTransparency = 1,
                Text = titleText,
                TextColor3 = theme.TextMuted,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            section.Parent = content
            table.insert(tab.Elements, section)
            return section
        end
        
        function tab:CreateLabel(text, options)
            options = options or {}
            local label = Create("TextLabel", {
                Size = UDim2.new(1, -20, 0, options.Height or 20),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = options.Color or theme.Text,
                Font = options.Font or Enum.Font.Gotham,
                TextSize = options.Size or 12,
                TextXAlignment = options.Alignment or Enum.TextXAlignment.Left,
                TextWrapped = true
            })
            label.Parent = content
            table.insert(tab.Elements, label)
            return label
        end
        
        function tab:CreateButton(config)
            local btnFrame = Create("TextButton", {
                Size = UDim2.new(1, -20, 0, 42),
                BackgroundColor3 = theme.Primary,
                Text = config.Text or "Button",
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                CornerRadius = UDim.new(0, 10),
                AutoButtonColor = false,
                Stroke = { Color = theme.PrimaryHover, Thickness = 1, Transparency = 0.5 }
            })
            btnFrame.Parent = content
            
            -- Hover effect
            btnFrame.MouseEnter:Connect(function()
                Tween(btnFrame, { BackgroundColor3 = theme.PrimaryHover, Size = UDim2.new(1, -16, 0, 44) })
            end)
            
            btnFrame.MouseLeave:Connect(function()
                Tween(btnFrame, { BackgroundColor3 = theme.Primary, Size = UDim2.new(1, -20, 0, 42) })
            end)
            
            btnFrame.MouseButton1Down:Connect(function()
                Tween(btnFrame, { Size = UDim2.new(1, -24, 0, 40) })
            end)
            
            btnFrame.MouseButton1Up:Connect(function()
                Tween(btnFrame, { Size = UDim2.new(1, -20, 0, 42) })
            end)
            
            btnFrame.MouseButton1Click:Connect(function()
                if config.Callback then
                    local success, err = pcall(config.Callback)
                    if not success then
                        warn("Button error: " .. tostring(err))
                        REV:Notify({
                            Title = "Error",
                            Content = "Button callback failed",
                            Type = "Error"
                        })
                    end
                end
            end)
            
            table.insert(tab.Elements, btnFrame)
            
            return {
                SetText = function(self, newText) btnFrame.Text = newText end,
                SetCallback = function(self, newCallback) config.Callback = newCallback end
            }
        end
        
        function tab:CreateToggle(config)
            local value = config.Default or false
            
            local container = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 45),
                BackgroundColor3 = theme.Surface,
                CornerRadius = UDim.new(0, 10),
                Stroke = { Color = theme.Border, Thickness = 1, Transparency = 0.3 }
            })
            container.Parent = content
            
            local label = Create("TextLabel", {
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Text or "Toggle",
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            label.Parent = container
            
            -- Toggle switch
            local switchBg = Create("Frame", {
                Size = UDim2.new(0, 50, 0, 26),
                Position = UDim2.new(1, -65, 0.5, -13),
                BackgroundColor3 = value and theme.Success or theme.SurfaceHighlight,
                CornerRadius = UDim.new(1, 0)
            })
            switchBg.Parent = container
            
            local switchKnob = Create("Frame", {
                Size = UDim2.new(0, 22, 0, 22),
                Position = value and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11),
                BackgroundColor3 = theme.Text,
                CornerRadius = UDim.new(1, 0)
            })
            switchKnob.Parent = switchBg
            
            local function updateToggle(newValue)
                value = newValue
                Tween(switchBg, { BackgroundColor3 = value and theme.Success or theme.SurfaceHighlight })
                Tween(switchKnob, { Position = value and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11) })
                if config.Callback then
                    pcall(config.Callback, value)
                end
            end
            
            container.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    updateToggle(not value)
                end
            end)
            
            table.insert(tab.Elements, container)
            
            return {
                GetValue = function() return value end,
                SetValue = function(self, newValue) updateToggle(newValue) end,
                Toggle = function(self) updateToggle(not value) end
            }
        end
        
        function tab:CreateSlider(config)
            local value = config.Default or config.Min or 0
            local min = config.Min or 0
            local max = config.Max or 100
            local dragging = false
            
            local container = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 70),
                BackgroundColor3 = theme.Surface,
                CornerRadius = UDim.new(0, 10),
                Stroke = { Color = theme.Border, Thickness = 1, Transparency = 0.3 }
            })
            container.Parent = content
            
            local label = Create("TextLabel", {
                Size = UDim2.new(0.5, 0, 0, 25),
                Position = UDim2.new(0, 15, 0, 8),
                BackgroundTransparency = 1,
                Text = config.Text or "Slider",
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            label.Parent = container
            
            local valueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 50, 0, 25),
                Position = UDim2.new(1, -65, 0, 8),
                BackgroundTransparency = 1,
                Text = tostring(value) .. (config.Suffix or ""),
                TextColor3 = theme.Primary,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            valueLabel.Parent = container
            
            -- Track
            local track = Create("Frame", {
                Size = UDim2.new(1, -30, 0, 6),
                Position = UDim2.new(0, 15, 0, 45),
                BackgroundColor3 = theme.SurfaceHighlight,
                CornerRadius = UDim.new(1, 0)
            })
            track.Parent = container
            
            -- Fill
            local fill = Create("Frame", {
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = theme.Primary,
                CornerRadius = UDim.new(1, 0)
            })
            fill.Parent = track
            
            -- Thumb
            local thumb = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8),
                BackgroundColor3 = theme.Text,
                CornerRadius = UDim.new(1, 0)
            })
            thumb.Parent = track
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = min + (pos * (max - min))
                if config.Increment then
                    value = math.floor(value / config.Increment + 0.5) * config.Increment
                end
                value = math.clamp(value, min, max)
                
                fill.Size = UDim2.new(pos, 0, 1, 0)
                thumb.Position = UDim2.new(pos, -8, 0.5, -8)
                valueLabel.Text = string.format("%.2f", value):gsub("%.?0+$", "") .. (config.Suffix or "")
                
                if config.Callback then
                    pcall(config.Callback, value)
                end
            end
            
            thumb.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            table.insert(tab.Elements, container)
            
            return {
                GetValue = function() return value end,
                SetValue = function(self, newValue)
                    value = math.clamp(newValue, min, max)
                    local pos = (value - min) / (max - min)
                    fill.Size = UDim2.new(pos, 0, 1, 0)
                    thumb.Position = UDim2.new(pos, -8, 0.5, -8)
                    valueLabel.Text = tostring(value) .. (config.Suffix or "")
                end
            }
        end
        
        function tab:CreateInput(config)
            local container = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 75),
                BackgroundColor3 = theme.Surface,
                CornerRadius = UDim.new(0, 10),
                Stroke = { Color = theme.Border, Thickness = 1, Transparency = 0.3 }
            })
            container.Parent = content
            
            local label = Create("TextLabel", {
                Size = UDim2.new(1, -30, 0, 25),
                Position = UDim2.new(0, 15, 0, 8),
                BackgroundTransparency = 1,
                Text = config.Text or "Input",
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            label.Parent = container
            
            local inputBg = Create("Frame", {
                Size = UDim2.new(1, -30, 0, 32),
                Position = UDim2.new(0, 15, 0, 35),
                BackgroundColor3 = theme.Background,
                CornerRadius = UDim.new(0, 8),
                Stroke = { Color = theme.Border, Thickness = 1, Transparency = 0.5 }
            })
            inputBg.Parent = container
            
            local input = Create("TextBox", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Default or "",
                PlaceholderText = config.Placeholder or "Enter text...",
                PlaceholderColor3 = theme.TextMuted,
                TextColor3 = theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                ClearTextOnFocus = config.ClearOnFocus or false
            })
            input.Parent = inputBg
            
            input.Focused:Connect(function()
                Tween(inputBg, { Stroke = { Color = theme.Primary, Thickness = 2, Transparency = 0 } })
            end)
            
            input.FocusLost:Connect(function(enterPressed)
                Tween(inputBg, { Stroke = { Color = theme.Border, Thickness = 1, Transparency = 0.5 } })
                if config.Callback then
                    pcall(config.Callback, input.Text, enterPressed)
                end
            end)
            
            table.insert(tab.Elements, container)
            
            return {
                GetText = function() return input.Text end,
                SetText = function(self, text) input.Text = text end,
                Focus = function() input:CaptureFocus() end
            }
        end
        
        function tab:CreateDropdown(config)
            local options = config.Options or {}
            local selected = config.Default or (options[1] or "Select...")
            local open = false
            
            local container = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 45),
                BackgroundColor3 = theme.Surface,
                CornerRadius = UDim.new(0, 10),
                Stroke = { Color = theme.Border, Thickness = 1, Transparency = 0.3 },
                ClipsDescendants = true
            })
            container.Parent = content
            
            local label = Create("TextLabel", {
                Size = UDim2.new(1, -50, 0, 45),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = selected,
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            label.Parent = container
            
            local arrow = Create("TextLabel", {
                Size = UDim2.new(0, 30, 0, 45),
                Position = UDim2.new(1, -35, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = theme.TextMuted,
                Font = Enum.Font.GothamBold,
                TextSize = 12
            })
            arrow.Parent = container
            
            local optionsFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 45),
                BackgroundTransparency = 1,
                ClipsDescendants = true
            })
            optionsFrame.Parent = container
            
            local optionsLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 2)
            })
            optionsLayout.Parent = optionsFrame
            
            local optionButtons = {}
            
            local function selectOption(opt)
                selected = opt
                label.Text = opt
                if config.Callback then
                    pcall(config.Callback, opt)
                end
                -- Cerrar dropdown
                open = false
                Tween(container, { Size = UDim2.new(1, -20, 0, 45) })
                Tween(arrow, { Rotation = 0 })
                for _, btn in ipairs(optionButtons) do
                    btn.Visible = false
                end
            end
            
            for _, opt in ipairs(options) do
                local btn = Create("TextButton", {
                    Size = UDim2.new(1, -10, 0, 35),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundColor3 = theme.SurfaceHighlight,
                    Text = opt,
                    TextColor3 = theme.TextMuted,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    CornerRadius = UDim.new(0, 6),
                    Visible = false
                })
                btn.Parent = optionsFrame
                
                btn.MouseEnter:Connect(function()
                    Tween(btn, { BackgroundColor3 = theme.Primary, TextColor3 = theme.Text })
                end)
                
                btn.MouseLeave:Connect(function()
                    Tween(btn, { BackgroundColor3 = theme.SurfaceHighlight, TextColor3 = theme.TextMuted })
                end)
                
                btn.MouseButton1Click:Connect(function()
                    selectOption(opt)
                end)
                
                table.insert(optionButtons, btn)
            end
            
            container.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    open = not open
                    if open then
                        local totalHeight = #options * 37 + 5
                        Tween(container, { Size = UDim2.new(1, -20, 0, 45 + totalHeight) })
                        Tween(arrow, { Rotation = 180 })
                        for _, btn in ipairs(optionButtons) do
                            btn.Visible = true
                        end
                    else
                        Tween(container, { Size = UDim2.new(1, -20, 0, 45) })
                        Tween(arrow, { Rotation = 0 })
                        for _, btn in ipairs(optionButtons) do
                            btn.Visible = false
                        end
                    end
                end
            end)
            
            table.insert(tab.Elements, container)
            
            return {
                GetSelected = function() return selected end,
                SetOptions = function(self, newOptions)
                    -- Recrear opciones (simplificado)
                    options = newOptions
                    selected = options[1] or "Select..."
                    label.Text = selected
                end
            }
        end
        
        function tab:CreateKeybind(config)
            local key = config.Default or Enum.KeyCode.Unknown
            local listening = false
            
            local container = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 45),
                BackgroundColor3 = theme.Surface,
                CornerRadius = UDim.new(0, 10),
                Stroke = { Color = theme.Border, Thickness = 1, Transparency = 0.3 }
            })
            container.Parent = content
            
            local label = Create("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Text or "Keybind",
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            label.Parent = container
            
            local keyBtn = Create("TextButton", {
                Size = UDim2.new(0, 80, 0, 30),
                Position = UDim2.new(1, -95, 0.5, -15),
                BackgroundColor3 = theme.Background,
                Text = key.Name ~= "Unknown" and key.Name or "None",
                TextColor3 = theme.Primary,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                CornerRadius = UDim.new(0, 6),
                Stroke = { Color = theme.Primary, Thickness = 1, Transparency = 0.5 }
            })
            keyBtn.Parent = container
            
            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
                Tween(keyBtn, { BackgroundColor3 = theme.Primary, TextColor3 = theme.Text })
            end)
            
            local connection = UserInputService.InputBegan:Connect(function(input, gp)
                if listening and not gp then
                    if input.KeyCode ~= Enum.KeyCode.Unknown then
                        key = input.KeyCode
                        keyBtn.Text = key.Name
                        listening = false
                        Tween(keyBtn, { BackgroundColor3 = theme.Background, TextColor3 = theme.Primary })
                        if config.Callback then
                            pcall(config.Callback, key)
                        end
                    end
                elseif input.KeyCode == key and not gp and config.Action then
                    pcall(config.Action)
                end
            end)
            
            table.insert(tab.Elements, container)
            
            return {
                GetKey = function() return key end,
                SetKey = function(self, newKey)
                    key = newKey
                    keyBtn.Text = key.Name
                end,
                Destroy = function() connection:Disconnect() end
            }
        end
        
        function tab:CreateColorPicker(config)
            local color = config.Default or Color3.fromRGB(255, 255, 255)
            
            local container = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 45),
                BackgroundColor3 = theme.Surface,
                CornerRadius = UDim.new(0, 10),
                Stroke = { Color = theme.Border, Thickness = 1, Transparency = 0.3 }
            })
            container.Parent = content
            
            local label = Create("TextLabel", {
                Size = UDim2.new(0.7, 0, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Text or "Color",
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            label.Parent = container
            
            local colorPreview = Create("TextButton", {
                Size = UDim2.new(0, 40, 0, 30),
                Position = UDim2.new(1, -55, 0.5, -15),
                BackgroundColor3 = color,
                Text = "",
                CornerRadius = UDim.new(0, 6),
                Stroke = { Color = theme.Text, Thickness = 2, Transparency = 0.3 }
            })
            colorPreview.Parent = container
            
            -- Simplified color picker (just cycles through preset colors for now)
            local presets = {
                Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(0, 0, 255),
                Color3.fromRGB(255, 255, 0),
                Color3.fromRGB(255, 0, 255),
                Color3.fromRGB(0, 255, 255),
                Color3.fromRGB(255, 255, 255),
                Color3.fromRGB(0, 0, 0)
            }
            local currentIndex = 1
            
            colorPreview.MouseButton1Click:Connect(function()
                currentIndex = currentIndex % #presets + 1
                color = presets[currentIndex]
                Tween(colorPreview, { BackgroundColor3 = color })
                if config.Callback then
                    pcall(config.Callback, color)
                end
            end)
            
            table.insert(tab.Elements, container)
            
            return {
                GetColor = function() return color end,
                SetColor = function(self, newColor)
                    color = newColor
                    colorPreview.BackgroundColor3 = color
                end
            }
        end
        
        return tab
    end
    
    -- Función para seleccionar tab
    function window:SelectTab(tab)
        if self.ActiveTab == tab then return end
        
        -- Desactivar tab anterior
        if self.ActiveTab then
            Tween(self.ActiveTab.Button, { BackgroundColor3 = theme.SurfaceHighlight, TextColor3 = theme.TextMuted })
            self.ActiveTab.Content.Visible = false
        end
        
        -- Activar nuevo tab
        self.ActiveTab = tab
        Tween(tab.Button, { BackgroundColor3 = theme.Primary, TextColor3 = theme.Text })
        tab.Content.Visible = true
        
        -- Animación de fade in para el contenido
        tab.Content.ScrollBarImageTransparency = 1
        Tween(tab.Content, { ScrollBarImageTransparency = 0 }, 0.3)
    end
    
    -- Minimizar/Maximizar
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(main, { Size = UDim2.new(0, config.Width or 500, 0, 50) }, 0.3)
            Tween(shadow, { ImageTransparency = 1 }, 0.3)
            contentContainer.Visible = false
            tabContainer.Visible = false
            minimizeBtn.Text = "+"
        else
            Tween(main, { Size = UDim2.new(0, config.Width or 500, 0, config.Height or 650) }, 0.3)
            Tween(shadow, { ImageTransparency = REV.Config.ShadowTransparency }, 0.3)
            contentContainer.Visible = true
            tabContainer.Visible = true
            minimizeBtn.Text = "—"
        end
    end)
    
    -- Cerrar
    closeBtn.MouseButton1Click:Connect(function()
        Tween(main, { Position = UDim2.new(0.5, -(config.Width or 500)/2, 1, 0) }, 0.3, nil, function()
            gui:Destroy()
        end)
    end)
    
    -- Drag
    MakeDraggable(main, titleBar)
    
    -- Keybind para minimizar (default R)
    if config.MinimizeKey then
        UserInputService.InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == config.MinimizeKey then
                minimizeBtn.MouseButton1Click:Fire()
            end
        end)
    end
    
    return window
end

-- Función para crear notificación rápida
function REV:NotifyQuick(title, content, type)
    self:Notify({
        Title = title,
        Content = content,
        Type = type or "Info",
        Duration = 3
    })
end

print("REV UI Library v" .. REV.Config.Version .. " loaded successfully!")

return REV
