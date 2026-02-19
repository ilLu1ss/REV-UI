--[[
    REV UI-LIBRARY
    Una biblioteca de interfaz estilo REV HUB para Roblox
    Creada por tu servidor
]]

local RevUI = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Temas predefinidos
local themes = {
    Default = {
        bg = Color3.fromRGB(30, 0, 40),
        surface = Color3.fromRGB(50, 10, 70),
        surface2 = Color3.fromRGB(70, 20, 90),
        primary = Color3.fromRGB(120, 40, 170),
        text = Color3.fromRGB(255, 255, 255),
        textMuted = Color3.fromRGB(200, 180, 220),
        success = Color3.fromRGB(34, 197, 94),
        danger = Color3.fromRGB(239, 68, 68),
        warning = Color3.fromRGB(245, 158, 11),
        info = Color3.fromRGB(59, 130, 246)
    },
    Dark = {
        bg = Color3.fromRGB(10, 10, 10),
        surface = Color3.fromRGB(30, 30, 30),
        surface2 = Color3.fromRGB(50, 50, 50),
        primary = Color3.fromRGB(0, 120, 210),
        text = Color3.fromRGB(255, 255, 255),
        textMuted = Color3.fromRGB(180, 180, 180),
        success = Color3.fromRGB(0, 200, 0),
        danger = Color3.fromRGB(200, 0, 0),
        warning = Color3.fromRGB(255, 165, 0),
        info = Color3.fromRGB(100, 149, 237)
    },
    Light = {
        bg = Color3.fromRGB(240, 240, 240),
        surface = Color3.fromRGB(220, 220, 220),
        surface2 = Color3.fromRGB(200, 200, 200),
        primary = Color3.fromRGB(0, 100, 200),
        text = Color3.fromRGB(0, 0, 0),
        textMuted = Color3.fromRGB(80, 80, 80),
        success = Color3.fromRGB(0, 150, 0),
        danger = Color3.fromRGB(200, 0, 0),
        warning = Color3.fromRGB(200, 100, 0),
        info = Color3.fromRGB(0, 100, 200)
    },
    Ocean = {
        bg = Color3.fromRGB(0, 40, 60),
        surface = Color3.fromRGB(0, 70, 100),
        surface2 = Color3.fromRGB(0, 100, 140),
        primary = Color3.fromRGB(0, 160, 210),
        text = Color3.fromRGB(255, 255, 255),
        textMuted = Color3.fromRGB(180, 220, 240),
        success = Color3.fromRGB(0, 200, 100),
        danger = Color3.fromRGB(230, 70, 70),
        warning = Color3.fromRGB(255, 180, 0),
        info = Color3.fromRGB(70, 130, 200)
    }
}

-- Variables internas
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RevUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Sistema de notificaciones
local notificationHolder = Instance.new("Frame")
notificationHolder.Name = "NotificationHolder"
notificationHolder.Size = UDim2.new(0, 300, 1, -20)
notificationHolder.Position = UDim2.new(1, -310, 0.5, -150)
notificationHolder.BackgroundTransparency = 1
notificationHolder.Parent = screenGui

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.Parent = notificationHolder
notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notificationLayout.Padding = UDim.new(0, 8)

function RevUI:Notify(message, type)
    type = type or "info"
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 50)
    notif.BackgroundColor3 = self.colors.surface
    notif.BackgroundTransparency = 0.2
    notif.Parent = notificationHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif

    local colorBar = Instance.new("Frame")
    colorBar.Size = UDim2.new(0, 4, 1, 0)
    colorBar.BackgroundColor3 = type == "success" and self.colors.success or
        type == "error" and self.colors.danger or
        type == "warning" and self.colors.warning or
        self.colors.primary
    colorBar.Parent = notif

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -16, 1, 0)
    msg.Position = UDim2.new(0, 12, 0, 0)
    msg.BackgroundTransparency = 1
    msg.Text = message
    msg.TextColor3 = self.colors.text
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 12
    msg.TextWrapped = true
    msg.Parent = notif

    notif.Position = UDim2.new(1, 0, 0, 0)
    notif:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)

    task.delay(3, function()
        notif:TweenPosition(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
        task.delay(0.3, notif.Destroy, notif)
    end)
end

-- Función para crear una ventana
function RevUI:CreateWindow(options)
    options = options or {}
    local windowName = options.Name or "RevUI Window"
    local windowSize = options.Size or Vector2.new(500, 600)
    local startTheme = options.Theme or "Default"
    local minimizeKey = options.MinimizeKey or Enum.KeyCode.R

    -- Configuración de la ventana
    local window = {
        Name = windowName,
        Size = windowSize,
        Minimized = false,
        Colors = themes[startTheme] or themes.Default,
        CurrentTheme = startTheme,
        CustomThemes = {},
        Tabs = {},
        ActiveTab = nil,
        MainFrame = nil,
        ContentArea = nil,
        TabBar = nil,
        MinimizeKey = minimizeKey,
    }

    -- Archivo para guardar temas
    local themeFileName = "RevUI/revui_themes.json"
    if makefolder and not isfile("RevUI") then makefolder("RevUI") end

    -- Cargar temas guardados
    local function loadThemes()
        if readfile and isfile(themeFileName) then
            local success, data = pcall(HttpService.JSONDecode, HttpService, readfile(themeFileName))
            if success and data then
                window.CustomThemes = data.customThemes or {}
                if data.currentTheme and (themes[data.currentTheme] or window.CustomThemes[data.currentTheme]) then
                    window.CurrentTheme = data.currentTheme
                    if themes[data.currentTheme] then
                        window.Colors = themes[data.currentTheme]
                    else
                        window.Colors = window.CustomThemes[data.currentTheme]
                    end
                end
            end
        end
    end
    loadThemes()

    -- Guardar temas
    local function saveThemes()
        if writefile then
            local data = {
                customThemes = window.CustomThemes,
                currentTheme = window.CurrentTheme
            }
            writefile(themeFileName, HttpService:JSONEncode(data))
        end
    end

    -- Construcción de la GUI
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, windowSize.X, 0, windowSize.Y)
    mainFrame.Position = UDim2.new(0.5, -windowSize.X/2, 0.5, -windowSize.Y/2)
    mainFrame.BackgroundColor3 = window.Colors.bg
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    window.MainFrame = mainFrame

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame

    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 48)
    titleBar.BackgroundColor3 = window.Colors.surface
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 16, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = windowName
    titleText.TextColor3 = window.Colors.text
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.Parent = titleBar

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    minimizeBtn.Position = UDim2.new(1, -72, 0.5, -16)
    minimizeBtn.BackgroundColor3 = window.Colors.surface2
    minimizeBtn.BackgroundTransparency = 0.2
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = window.Colors.textMuted
    minimizeBtn.Font = Enum.Font.Gotham
    minimizeBtn.TextSize = 18
    minimizeBtn.Parent = titleBar

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minimizeBtn

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -16)
    closeBtn.BackgroundColor3 = window.Colors.surface2
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "×"
    closeBtn.TextColor3 = window.Colors.danger
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 22
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    -- Barra de pestañas
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -32, 0, 40)
    tabBar.Position = UDim2.new(0, 16, 0, 56)
    tabBar.BackgroundColor3 = window.Colors.surface2
    tabBar.BackgroundTransparency = 0.2
    tabBar.Parent = mainFrame
    window.TabBar = tabBar

    local tabBarCorner = Instance.new("UICorner")
    tabBarCorner.CornerRadius = UDim.new(0, 10)
    tabBarCorner.Parent = tabBar

    -- Área de contenido
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -32, 1, -140)
    contentArea.Position = UDim2.new(0, 16, 0, 104)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame
    window.ContentArea = contentArea

    -- Función para actualizar tema de toda la ventana
    local function refreshTheme()
        mainFrame.BackgroundColor3 = window.Colors.bg
        titleBar.BackgroundColor3 = window.Colors.surface
        minimizeBtn.BackgroundColor3 = window.Colors.surface2
        closeBtn.BackgroundColor3 = window.Colors.surface2
        tabBar.BackgroundColor3 = window.Colors.surface2

        -- Actualizar pestañas
        for _, tab in ipairs(window.Tabs) do
            tab.Button.BackgroundColor3 = (tab == window.ActiveTab) and window.Colors.primary or window.Colors.surface2
            tab.Button.TextColor3 = (tab == window.ActiveTab) and window.Colors.text or window.Colors.textMuted
        end

        -- Actualizar contenido de pestañas (recursivo)
        local function updateDescendants(obj)
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("Frame") and child ~= mainFrame and child.BackgroundTransparency < 1 then
                    if child:FindFirstChildOfClass("TextLabel") or child:FindFirstChildOfClass("TextButton") then
                        child.BackgroundColor3 = window.Colors.surface
                    else
                        child.BackgroundColor3 = window.Colors.surface2
                    end
                end
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    child.TextColor3 = window.Colors.text
                end
                if child:IsA("ScrollingFrame") then
                    child.ScrollBarImageColor3 = window.Colors.primary
                end
                if #child:GetChildren() > 0 then
                    updateDescendants(child)
                end
            end
        end
        updateDescendants(contentArea)
    end

    -- Crear una pestaña
    function window:CreateTab(name)
        local tab = {
            Name = name,
            Panel = nil,
            Button = nil,
            Elements = {},
        }

        -- Crear botón de pestaña
        local tabCount = #self.Tabs
        local tabWidth = 0.9 / math.max(1, tabCount + 1) -- Espacio para todas
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(tabWidth, -2, 1, -4)
        btn.Position = UDim2.new(tabCount * tabWidth, 2, 0, 2)
        btn.BackgroundColor3 = self.Colors.surface2
        btn.BackgroundTransparency = 0.2
        btn.Text = name
        btn.TextColor3 = self.Colors.textMuted
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 12
        btn.Parent = self.TabBar

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        tab.Button = btn

        -- Crear panel para la pestaña
        local panel = Instance.new("ScrollingFrame")
        panel.Size = UDim2.new(1, 0, 1, 0)
        panel.BackgroundTransparency = 1
        panel.BorderSizePixel = 0
        panel.CanvasSize = UDim2.new(0, 0, 0, 0)
        panel.ScrollBarThickness = 6
        panel.ScrollBarImageColor3 = self.Colors.primary
        panel.Visible = false
        panel.Parent = self.ContentArea

        local panelLayout = Instance.new("UIListLayout")
        panelLayout.Parent = panel
        panelLayout.Padding = UDim.new(0, 16)
        panelLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            panel.CanvasSize = UDim2.new(0, 0, 0, panelLayout.AbsoluteContentSize.Y + 20)
        end)

        tab.Panel = panel

        -- Manejar clic en pestaña
        btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(self.Tabs) do
                t.Panel.Visible = (t == tab)
                t.Button.BackgroundColor3 = (t == tab) and self.Colors.primary or self.Colors.surface2
                t.Button.TextColor3 = (t == tab) and self.Colors.text or self.Colors.textMuted
            end
            self.ActiveTab = tab
        end)

        -- Si es la primera pestaña, activarla
        if #self.Tabs == 0 then
            tab.Panel.Visible = true
            tab.Button.BackgroundColor3 = self.Colors.primary
            tab.Button.TextColor3 = self.Colors.text
            self.ActiveTab = tab
        end

        table.insert(self.Tabs, tab)

        -- Métodos para añadir elementos a la pestaña
        function tab:CreateButton(text, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 50)
            frame.BackgroundColor3 = window.Colors.surface
            frame.BackgroundTransparency = 0.2
            frame.Parent = self.Panel

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = frame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -24, 1, -12)
            btn.Position = UDim2.new(0, 12, 0, 6)
            btn.BackgroundColor3 = window.Colors.primary
            btn.BackgroundTransparency = 0.1
            btn.Text = text
            btn.TextColor3 = window.Colors.text
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.Parent = frame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn

            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        function tab:CreateToggle(text, default, callback)
            default = default or false
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 70)
            frame.BackgroundColor3 = window.Colors.surface
            frame.BackgroundTransparency = 0.2
            frame.Parent = self.Panel

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = frame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -80, 0, 24)
            title.Position = UDim2.new(0, 12, 0, 12)
            title.BackgroundTransparency = 1
            title.Text = text
            title.TextColor3 = window.Colors.text
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Font = Enum.Font.GothamSemibold
            title.TextSize = 14
            title.Parent = frame

            local desc = Instance.new("TextLabel")
            desc.Size = UDim2.new(1, -80, 0, 20)
            desc.Position = UDim2.new(0, 12, 0, 36)
            desc.BackgroundTransparency = 1
            desc.Text = "Haz clic para cambiar"
            desc.TextColor3 = window.Colors.textMuted
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.Font = Enum.Font.Gotham
            desc.TextSize = 12
            desc.Parent = frame

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 60, 0, 30)
            toggleBtn.Position = UDim2.new(1, -72, 0.5, -15)
            toggleBtn.BackgroundColor3 = default and window.Colors.success or window.Colors.surface2
            toggleBtn.BackgroundTransparency = 0.2
            toggleBtn.Text = default and "ON" or "OFF"
            toggleBtn.TextColor3 = window.Colors.text
            toggleBtn.Font = Enum.Font.GothamBold
            toggleBtn.TextSize = 12
            toggleBtn.Parent = frame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = toggleBtn

            local state = default
            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                toggleBtn.BackgroundColor3 = state and window.Colors.success or window.Colors.surface2
                toggleBtn.Text = state and "ON" or "OFF"
                callback(state)
            end)

            return toggleBtn
        end

        function tab:CreateSlider(name, min, max, default, callback)
            min = min or 0
            max = max or 1
            default = default or (min + max) / 2
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 100)
            frame.BackgroundColor3 = window.Colors.surface
            frame.BackgroundTransparency = 0.2
            frame.Parent = self.Panel

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = frame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -80, 0, 24)
            title.Position = UDim2.new(0, 12, 0, 12)
            title.BackgroundTransparency = 1
            title.Text = name
            title.TextColor3 = window.Colors.text
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Font = Enum.Font.GothamSemibold
            title.TextSize = 14
            title.Parent = frame

            local valueBox = Instance.new("TextBox")
            valueBox.Size = UDim2.new(0, 60, 0, 24)
            valueBox.Position = UDim2.new(1, -72, 0, 12)
            valueBox.BackgroundColor3 = window.Colors.surface2
            valueBox.BackgroundTransparency = 0.2
            valueBox.Text = string.format("%.1f", default)
            valueBox.TextColor3 = window.Colors.text
            valueBox.Font = Enum.Font.GothamBold
            valueBox.TextSize = 14
            valueBox.PlaceholderText = tostring(min) .. "-" .. tostring(max)
            valueBox.PlaceholderColor3 = window.Colors.textMuted
            valueBox.Parent = frame

            local valueCorner = Instance.new("UICorner")
            valueCorner.CornerRadius = UDim.new(0, 6)
            valueCorner.Parent = valueBox

            -- Barra del slider
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(1, -24, 0, 4)
            slider.Position = UDim2.new(0, 12, 0, 52)
            slider.BackgroundColor3 = window.Colors.surface2
            slider.BackgroundTransparency = 0.2
            slider.Parent = frame

            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(1, 0)
            sliderCorner.Parent = slider

            -- Barra de progreso
            local range = max - min
            local progress = Instance.new("Frame")
            progress.Size = UDim2.new((default - min) / range, 0, 1, 0)
            progress.BackgroundColor3 = window.Colors.primary
            progress.BackgroundTransparency = 0.1
            progress.Parent = slider

            local progCorner = Instance.new("UICorner")
            progCorner.CornerRadius = UDim.new(1, 0)
            progCorner.Parent = progress

            -- Thumb
            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.new(0, 16, 0, 16)
            thumb.Position = UDim2.new((default - min) / range, -8, 0.5, -8)
            thumb.BackgroundColor3 = window.Colors.primary
            thumb.BackgroundTransparency = 0.1
            thumb.Parent = slider
            thumb.ZIndex = 3

            local thumbCorner = Instance.new("UICorner")
            thumbCorner.CornerRadius = UDim.new(1, 0)
            thumbCorner.Parent = thumb

            -- Lógica del slider
            local dragging = false
            local function updateFromMouse(mouseX)
                local sPos = slider.AbsolutePosition.X
                local sSize = slider.AbsoluteSize.X
                local rel = math.clamp((mouseX - sPos) / sSize, 0, 1)
                local val = min + rel * range
                val = math.round(val * 10) / 10
                progress.Size = UDim2.new(rel, 0, 1, 0)
                thumb.Position = UDim2.new(rel, -8, 0.5, -8)
                valueBox.Text = string.format("%.1f", val)
                callback(val)
            end

            thumb.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)

            thumb.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mouse = player:GetMouse()
                    updateFromMouse(mouse.X)
                    dragging = true
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mouse = player:GetMouse()
                    updateFromMouse(mouse.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            valueBox.FocusLost:Connect(function(enter)
                local val = tonumber(valueBox.Text)
                if val then
                    val = math.clamp(val, min, max)
                    val = math.round(val * 10) / 10
                    valueBox.Text = string.format("%.1f", val)
                    local rel = (val - min) / range
                    progress.Size = UDim2.new(rel, 0, 1, 0)
                    thumb.Position = UDim2.new(rel, -8, 0.5, -8)
                    callback(val)
                else
                    valueBox.Text = string.format("%.1f", default)
                end
            end)

            return {Slider = slider, ValueBox = valueBox}
        end

        function tab:CreateDropdown(name, options, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 70)
            frame.BackgroundColor3 = window.Colors.surface
            frame.BackgroundTransparency = 0.2
            frame.Parent = self.Panel

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = frame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -24, 0, 24)
            title.Position = UDim2.new(0, 12, 0, 8)
            title.BackgroundTransparency = 1
            title.Text = name
            title.TextColor3 = window.Colors.text
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Font = Enum.Font.GothamSemibold
            title.TextSize = 14
            title.Parent = frame

            local dropdown = Instance.new("TextButton")
            dropdown.Size = UDim2.new(0.9, 0, 0, 30)
            dropdown.Position = UDim2.new(0, 12, 0, 36)
            dropdown.BackgroundColor3 = window.Colors.surface2
            dropdown.BackgroundTransparency = 0.2
            dropdown.Text = ""
            dropdown.Parent = frame
            dropdown.ZIndex = 2

            local dropCorner = Instance.new("UICorner")
            dropCorner.CornerRadius = UDim.new(0, 6)
            dropCorner.Parent = dropdown

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -30, 1, 0)
            label.Position = UDim2.new(0, 8, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = default or options[1] or "Seleccionar"
            label.TextColor3 = window.Colors.text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
            label.Parent = dropdown
            label.ZIndex = 2

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 30, 1, 0)
            arrow.Position = UDim2.new(1, -30, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = window.Colors.text
            arrow.Font = Enum.Font.Gotham
            arrow.TextSize = 12
            arrow.Parent = dropdown
            arrow.ZIndex = 2

            -- Lista flotante
            local listFrame = Instance.new("Frame")
            listFrame.Size = UDim2.new(0, 200, 0, 150)
            listFrame.BackgroundColor3 = window.Colors.surface2
            listFrame.BackgroundTransparency = 0.1
            listFrame.Visible = false
            listFrame.Parent = mainFrame
            listFrame.ZIndex = 10
            listFrame.ClipsDescendants = true

            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 6)
            listCorner.Parent = listFrame

            local listScroller = Instance.new("ScrollingFrame")
            listScroller.Size = UDim2.new(1, -10, 1, -10)
            listScroller.Position = UDim2.new(0, 5, 0, 5)
            listScroller.BackgroundTransparency = 1
            listScroller.BorderSizePixel = 0
            listScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
            listScroller.ScrollBarThickness = 4
            listScroller.ScrollBarImageColor3 = window.Colors.primary
            listScroller.Parent = listFrame
            listScroller.ZIndex = 10

            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = listScroller
            listLayout.Padding = UDim.new(0, 2)
            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                listScroller.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
                listFrame.Size = UDim2.new(0, 200, 0, math.min(150, listLayout.AbsoluteContentSize.Y + 20))
            end)

            for _, opt in ipairs(options) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -8, 0, 24)
                btn.Position = UDim2.new(0, 4, 0, 0)
                btn.BackgroundTransparency = 1
                btn.Text = opt
                btn.TextColor3 = window.Colors.text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.Parent = listScroller
                btn.ZIndex = 10

                btn.MouseEnter:Connect(function()
                    btn.BackgroundColor3 = window.Colors.surface2
                    btn.BackgroundTransparency = 0.3
                end)
                btn.MouseLeave:Connect(function()
                    btn.BackgroundTransparency = 1
                end)

                btn.MouseButton1Click:Connect(function()
                    label.Text = opt
                    listFrame.Visible = false
                    callback(opt)
                end)
            end

            dropdown.MouseButton1Click:Connect(function()
                if listFrame.Visible then
                    listFrame.Visible = false
                else
                    local absPos = dropdown.AbsolutePosition
                    local absSize = dropdown.AbsoluteSize
                    listFrame.Position = UDim2.new(0, absPos.X - mainFrame.AbsolutePosition.X, 0, absPos.Y - mainFrame.AbsolutePosition.Y + absSize.Y + 5)
                    listFrame.Visible = true
                end
            end)

            -- Cerrar al hacer clic fuera
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if listFrame.Visible then
                        local mousePos = Vector2.new(input.Position.X, input.Position.Y)
                        local listAbs = listFrame.AbsolutePosition
                        local listSize = listFrame.AbsoluteSize
                        if not (mousePos.X >= listAbs.X and mousePos.X <= listAbs.X + listSize.X and
                                mousePos.Y >= listAbs.Y and mousePos.Y <= listAbs.Y + listSize.Y) then
                            listFrame.Visible = false
                        end
                    end
                end
            end)

            return dropdown
        end

        function tab:CreateParagraph(title, content)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 60)
            frame.BackgroundColor3 = window.Colors.surface
            frame.BackgroundTransparency = 0.2
            frame.Parent = self.Panel

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = frame

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -24, 0, 24)
            titleLabel.Position = UDim2.new(0, 12, 0, 8)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = window.Colors.text
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Font = Enum.Font.GothamSemibold
            titleLabel.TextSize = 14
            titleLabel.Parent = frame

            local contentLabel = Instance.new("TextLabel")
            contentLabel.Size = UDim2.new(1, -24, 0, 20)
            contentLabel.Position = UDim2.new(0, 12, 0, 32)
            contentLabel.BackgroundTransparency = 1
            contentLabel.Text = content
            contentLabel.TextColor3 = window.Colors.textMuted
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.Font = Enum.Font.Gotham
            contentLabel.TextSize = 12
            contentLabel.Parent = frame

            return {Title = titleLabel, Content = contentLabel}
        end

        function tab:CreateColorPicker(name, default, callback)
            default = default or Color3.new(1,0,0)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 70)
            frame.BackgroundColor3 = window.Colors.surface
            frame.BackgroundTransparency = 0.2
            frame.Parent = self.Panel

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = frame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -80, 0, 24)
            title.Position = UDim2.new(0, 12, 0, 12)
            title.BackgroundTransparency = 1
            title.Text = name
            title.TextColor3 = window.Colors.text
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Font = Enum.Font.GothamSemibold
            title.TextSize = 14
            title.Parent = frame

            local preview = Instance.new("Frame")
            preview.Size = UDim2.new(0, 30, 0, 30)
            preview.Position = UDim2.new(1, -72, 0.5, -15)
            preview.BackgroundColor3 = default
            preview.Parent = frame

            local previewCorner = Instance.new("UICorner")
            previewCorner.CornerRadius = UDim.new(0, 6)
            previewCorner.Parent = preview

            local pickerBtn = Instance.new("TextButton")
            pickerBtn.Size = UDim2.new(0, 60, 0, 30)
            pickerBtn.Position = UDim2.new(1, -140, 0.5, -15)
            pickerBtn.BackgroundColor3 = window.Colors.primary
            pickerBtn.BackgroundTransparency = 0.1
            pickerBtn.Text = "Elegir"
            pickerBtn.TextColor3 = window.Colors.text
            pickerBtn.Font = Enum.Font.GothamBold
            pickerBtn.TextSize = 12
            pickerBtn.Parent = frame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = pickerBtn

            -- Paleta de colores flotante
            local paletteFrame = Instance.new("Frame")
            paletteFrame.Size = UDim2.new(0, 200, 0, 150)
            paletteFrame.BackgroundColor3 = window.Colors.surface2
            paletteFrame.BackgroundTransparency = 0.1
            paletteFrame.Visible = false
            paletteFrame.Parent = mainFrame
            paletteFrame.ZIndex = 10
            paletteFrame.ClipsDescendants = true

            local paletteCorner = Instance.new("UICorner")
            paletteCorner.CornerRadius = UDim.new(0, 6)
            paletteCorner.Parent = paletteFrame

            local paletteGrid = Instance.new("Frame")
            paletteGrid.Size = UDim2.new(1, -10, 1, -10)
            paletteGrid.Position = UDim2.new(0, 5, 0, 5)
            paletteGrid.BackgroundTransparency = 1
            paletteGrid.Parent = paletteFrame
            paletteGrid.ZIndex = 10

            local gridLayout = Instance.new("UIGridLayout")
            gridLayout.Parent = paletteGrid
            gridLayout.FillDirection = Enum.FillDirection.Horizontal
            gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
            gridLayout.CellSize = UDim2.new(0, 30, 0, 30)
            gridLayout.CellPadding = UDim2.new(0, 4, 0, 4)

            local paletteColors = {
                Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255),
                Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255),
                Color3.fromRGB(255,128,0), Color3.fromRGB(128,0,255), Color3.fromRGB(255,255,255),
                Color3.fromRGB(128,128,128), Color3.fromRGB(0,0,0), Color3.fromRGB(255,192,203)
            }

            for _, col in ipairs(paletteColors) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundColor3 = col
                btn.Text = ""
                btn.Parent = paletteGrid
                btn.ZIndex = 11

                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = btn

                btn.MouseButton1Click:Connect(function()
                    preview.BackgroundColor3 = col
                    paletteFrame.Visible = false
                    callback(col)
                end)
            end

            pickerBtn.MouseButton1Click:Connect(function()
                if paletteFrame.Visible then
                    paletteFrame.Visible = false
                else
                    local absPos = pickerBtn.AbsolutePosition
                    local absSize = pickerBtn.AbsoluteSize
                    paletteFrame.Position = UDim2.new(0, absPos.X - mainFrame.AbsolutePosition.X - 100, 0, absPos.Y - mainFrame.AbsolutePosition.Y - 160)
                    paletteFrame.Visible = true
                end
            end)

            -- Cerrar paleta al hacer clic fuera
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if paletteFrame.Visible then
                        local mousePos = Vector2.new(input.Position.X, input.Position.Y)
                        local listAbs = paletteFrame.AbsolutePosition
                        local listSize = paletteFrame.AbsoluteSize
                        if not (mousePos.X >= listAbs.X and mousePos.X <= listAbs.X + listSize.X and
                                mousePos.Y >= listAbs.Y and mousePos.Y <= listAbs.Y + listSize.Y) then
                            paletteFrame.Visible = false
                        end
                    end
                end
            end)

            return preview
        end

        return tab
    end

    -- Minimizar
    minimizeBtn.MouseButton1Click:Connect(function()
        window.Minimized = not window.Minimized
        if window.Minimized then
            mainFrame:TweenSize(UDim2.new(0, windowSize.X, 0, 48), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            tabBar.Visible = false
            contentArea.Visible = false
        else
            mainFrame:TweenSize(UDim2.new(0, windowSize.X, 0, windowSize.Y), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            tabBar.Visible = true
            contentArea.Visible = true
        end
    end)

    -- Minimizar con tecla
    UserInputService.InputBegan:Connect(function(k, gp)
        if gp then return end
        if k.KeyCode == window.MinimizeKey then
            window.Minimized = not window.Minimized
            if window.Minimized then
                mainFrame:TweenSize(UDim2.new(0, windowSize.X, 0, 48), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                tabBar.Visible = false
                contentArea.Visible = false
            else
                mainFrame:TweenSize(UDim2.new(0, windowSize.X, 0, windowSize.Y), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                tabBar.Visible = true
                contentArea.Visible = true
            end
        end
    end)

    -- Cerrar
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame:Destroy()
    end)

    -- Métodos públicos de la ventana
    function window:SetTheme(themeName)
        if themes[themeName] then
            self.Colors = themes[themeName]
            self.CurrentTheme = themeName
            refreshTheme()
            saveThemes()
        elseif self.CustomThemes[themeName] then
            self.Colors = self.CustomThemes[themeName]
            self.CurrentTheme = themeName
            refreshTheme()
            saveThemes()
        end
    end

    function window:GetThemes()
        local t = {}
        for name, _ in pairs(themes) do t[name] = true end
        for name, _ in pairs(self.CustomThemes) do t[name] = true end
        return t
    end

    function window:SaveCustomTheme(name, colors)
        self.CustomThemes[name] = colors
        self.CurrentTheme = name
        self.Colors = colors
        refreshTheme()
        saveThemes()
    end

    refreshTheme()
    return window
end

return RevUI
