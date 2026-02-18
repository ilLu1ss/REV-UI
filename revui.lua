--[[
    RevUILib - Librería de interfaz estilo REV HUB
    Basada en REV HUB EMOTES v1.2
    - Ventana arrastrable con minimizar/cerrar (tecla R para minimizar)
    - Pestañas superiores
    - Botones, Toggles, Sliders, Dropdowns, Labels, Paragraphs
    - Notificaciones animadas
    - Selector de estilos emergente (ideal para mixers)
    - Colores morados con transparencia
]]

local RevUILib = {}

-- Servicios
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Configuración por defecto (desde tu script)
local defaultColors = {
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
}

local defaultTransparency = {
    bg = 0.2,
    surface = 0.2,
    surface2 = 0.2,
    primary = 0.1
}

-- ========== SISTEMA DE NOTIFICACIONES ==========
local notificationHolder = nil

local function ensureNotificationHolder()
    if not notificationHolder or not notificationHolder.Parent then
        local screenGui = player:FindFirstChild("PlayerGui"):FindFirstChild("RevUILib_Notifications")
        if not screenGui then
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "RevUILib_Notifications"
            screenGui.Parent = player:WaitForChild("PlayerGui")
            screenGui.ResetOnSpawn = false
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        end
        notificationHolder = screenGui:FindFirstChild("NotificationHolder")
        if not notificationHolder then
            notificationHolder = Instance.new("Frame")
            notificationHolder.Name = "NotificationHolder"
            notificationHolder.Size = UDim2.new(0, 300, 1, -20)
            notificationHolder.Position = UDim2.new(1, -310, 0, 10)
            notificationHolder.BackgroundTransparency = 1
            notificationHolder.Parent = screenGui

            local layout = Instance.new("UIListLayout")
            layout.Parent = notificationHolder
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            layout.Padding = UDim.new(0, 8)
        end
    end
    return notificationHolder
end

function RevUILib:Notify(config)
    config = config or {}
    local message = config.Content or "Notificación"
    local duration = config.Time or 3
    local type = config.Type or "info" -- success, error, warning, info
    local colors = config.Colors or defaultColors

    local holder = ensureNotificationHolder()

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 50)
    notif.BackgroundColor3 = colors.surface
    notif.BackgroundTransparency = defaultTransparency.surface
    notif.Parent = holder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif

    local colorBar = Instance.new("Frame")
    colorBar.Size = UDim2.new(0, 4, 1, 0)
    colorBar.BackgroundColor3 = type == "success" and colors.success or
        type == "error" and colors.danger or
        type == "warning" and colors.warning or
        colors.primary
    colorBar.Parent = notif

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -16, 1, 0)
    msg.Position = UDim2.new(0, 12, 0, 0)
    msg.BackgroundTransparency = 1
    msg.Text = message
    msg.TextColor3 = colors.text
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 12
    msg.TextWrapped = true
    msg.Parent = notif

    notif.Position = UDim2.new(1, 0, 0, 0)
    notif:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)

    task.delay(duration, function()
        notif:TweenPosition(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
        task.delay(0.3, notif.Destroy, notif)
    end)
end

-- ========== CREACIÓN DE VENTANA PRINCIPAL ==========
function RevUILib:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "RevUILib Window"
    local windowSize = config.Size or UDim2.new(0, 500, 0, 650)
    local windowPos = config.Position or UDim2.new(0.5, -250, 0.5, -325)
    local colors = config.Colors or defaultColors
    local transparency = config.Transparency or defaultTransparency
    local keybind = config.Keybind or Enum.KeyCode.R -- Tecla para minimizar

    -- ScreenGui principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RevUILib_" .. windowName
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Marco principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = windowSize
    mainFrame.Position = windowPos
    mainFrame.BackgroundColor3 = colors.bg
    mainFrame.BackgroundTransparency = transparency.bg
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame

    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 48)
    titleBar.BackgroundColor3 = colors.surface
    titleBar.BackgroundTransparency = transparency.surface
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
    titleText.TextColor3 = colors.text
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.Parent = titleBar

    -- Botón minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    minimizeBtn.Position = UDim2.new(1, -72, 0.5, -16)
    minimizeBtn.BackgroundColor3 = colors.surface2
    minimizeBtn.BackgroundTransparency = transparency.surface2
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = colors.textMuted
    minimizeBtn.Font = Enum.Font.Gotham
    minimizeBtn.TextSize = 18
    minimizeBtn.Parent = titleBar

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minimizeBtn

    -- Botón cerrar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -16)
    closeBtn.BackgroundColor3 = colors.surface2
    closeBtn.BackgroundTransparency = transparency.surface2
    closeBtn.Text = "×"
    closeBtn.TextColor3 = colors.danger
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
    tabBar.BackgroundColor3 = colors.surface2
    tabBar.BackgroundTransparency = transparency.surface2
    tabBar.Parent = mainFrame

    local tabBarCorner = Instance.new("UICorner")
    tabBarCorner.CornerRadius = UDim.new(0, 10)
    tabBarCorner.Parent = tabBar

    -- Área de contenido
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -32, 1, -140)
    contentArea.Position = UDim2.new(0, 16, 0, 104)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    -- Tabla para almacenar pestañas
    local tabs = {}
    local currentTab = nil
    local minimized = false

    -- Función para minimizar/restaurar
    local function toggleMinimize()
        minimized = not minimized
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, windowSize.X.Offset, 0, 48), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            tabBar.Visible = false
            contentArea.Visible = false
        else
            mainFrame:TweenSize(windowSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            tabBar.Visible = true
            contentArea.Visible = true
        end
    end

    minimizeBtn.MouseButton1Click:Connect(toggleMinimize)
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    -- Atajo de teclado para minimizar
    UserInputService.InputBegan:Connect(function(k, gp)
        if gp then return end
        if k.KeyCode == keybind then
            toggleMinimize()
        end
    end)

    -- ========== SISTEMA DE PESTAÑAS ==========
    local function addTab(tabName)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0.15, -2, 1, -4)
        tabButton.Position = UDim2.new(#tabs * 0.15, 2, 0, 2)
        tabButton.BackgroundColor3 = colors.surface2
        tabButton.BackgroundTransparency = transparency.surface2
        tabButton.Text = tabName
        tabButton.TextColor3 = colors.textMuted
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.TextSize = 12
        tabButton.Parent = tabBar

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = tabButton

        -- Contenedor de la pestaña
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = colors.primary
        tabContent.Visible = false
        tabContent.Parent = contentArea

        local layout = Instance.new("UIListLayout")
        layout.Parent = tabContent
        layout.Padding = UDim.new(0, 8)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        -- Función para seleccionar esta pestaña
        local function select()
            if currentTab then
                currentTab.Button.BackgroundColor3 = colors.surface2
                currentTab.Button.TextColor3 = colors.textMuted
                currentTab.Content.Visible = false
            end
            tabButton.BackgroundColor3 = colors.primary
            tabButton.BackgroundTransparency = transparency.primary
            tabButton.TextColor3 = colors.text
            tabContent.Visible = true
            currentTab = {Button = tabButton, Content = tabContent}
        end

        tabButton.MouseButton1Click:Connect(select)

        -- Si es la primera pestaña, seleccionarla
        if #tabs == 0 then select() end

        -- Métodos para añadir elementos a la pestaña
        local tab = {
            Button = tabButton,
            Content = tabContent,
            Layout = layout
        }

        -- Botón
        function tab:AddButton(btnConfig)
            btnConfig = btnConfig or {}
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = colors.surface
            btn.BackgroundTransparency = transparency.surface
            btn.Text = btnConfig.Name or "Button"
            btn.TextColor3 = colors.text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Parent = tabContent

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn

            if btnConfig.Callback then
                btn.MouseButton1Click:Connect(btnConfig.Callback)
            end

            tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            return btn
        end

        -- Toggle
        function tab:AddToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0.9, 0, 0, 45)
            frame.BackgroundColor3 = colors.surface
            frame.BackgroundTransparency = transparency.surface
            frame.Parent = tabContent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = toggleConfig.Name or "Toggle"
            label.TextColor3 = colors.text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.Parent = frame

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 40, 0, 30)
            toggleBtn.Position = UDim2.new(1, -52, 0.5, -15)
            toggleBtn.BackgroundColor3 = (toggleConfig.Default and colors.success) or colors.surface2
            toggleBtn.BackgroundTransparency = (toggleConfig.Default and 0.1) or transparency.surface2
            toggleBtn.Text = toggleConfig.Default and "ON" or "OFF"
            toggleBtn.TextColor3 = colors.text
            toggleBtn.Font = Enum.Font.GothamBold
            toggleBtn.TextSize = 12
            toggleBtn.Parent = frame

            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggleBtn

            local state = toggleConfig.Default or false
            local callback = toggleConfig.Callback or function() end

            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                toggleBtn.BackgroundColor3 = state and colors.success or colors.surface2
                toggleBtn.Text = state and "ON" or "OFF"
                callback(state)
            end)

            tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            return {
                Set = function(_, newState)
                    state = newState
                    toggleBtn.BackgroundColor3 = state and colors.success or colors.surface2
                    toggleBtn.Text = state and "ON" or "OFF"
                end
            }
        end

        -- Slider (como el tuyo)
        function tab:AddSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0.9, 0, 0, 70)
            frame.BackgroundColor3 = colors.surface
            frame.BackgroundTransparency = transparency.surface
            frame.Parent = tabContent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -24, 0, 24)
            label.Position = UDim2.new(0, 12, 0, 8)
            label.BackgroundTransparency = 1
            label.Text = sliderConfig.Name or "Slider"
            label.TextColor3 = colors.text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.GothamSemibold
            label.TextSize = 14
            label.Parent = frame

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 50, 0, 24)
            valueLabel.Position = UDim2.new(1, -62, 0, 8)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(sliderConfig.Default or 0) .. (sliderConfig.Suffix or "")
            valueLabel.TextColor3 = colors.primary
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 14
            valueLabel.Parent = frame

            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(1, -24, 0, 4)
            sliderBg.Position = UDim2.new(0, 12, 0, 44)
            sliderBg.BackgroundColor3 = colors.surface2
            sliderBg.BackgroundTransparency = transparency.surface2
            sliderBg.Parent = frame

            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(1, 0)
            sliderCorner.Parent = sliderBg

            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 10
            local default = sliderConfig.Default or min
            local suffix = sliderConfig.Suffix or ""
            local callback = sliderConfig.Callback or function() end
            local increment = sliderConfig.Increment or (max - min) / 100

            local range = max - min
            local percent = (default - min) / range
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(percent, 0, 1, 0)
            bar.BackgroundColor3 = colors.primary
            bar.BackgroundTransparency = transparency.primary
            bar.Parent = sliderBg

            local barCorner = Instance.new("UICorner")
            barCorner.CornerRadius = UDim.new(1, 0)
            barCorner.Parent = bar

            local dragging = false
            local function updateFromMouse(input)
                local mousePos = UserInputService:GetMouseLocation().X
                local bgPos = sliderBg.AbsolutePosition.X
                local bgSize = sliderBg.AbsoluteSize.X
                local rel = math.clamp((mousePos - bgPos) / bgSize, 0, 1)
                local value = min + rel * range
                if increment then
                    value = math.round(value / increment) * increment
                    rel = (value - min) / range
                end
                bar.Size = UDim2.new(rel, 0, 1, 0)
                valueLabel.Text = tostring(value) .. suffix
                callback(value)
            end

            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateFromMouse(input)
                end
            end)

            sliderBg.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateFromMouse(input)
                end
            end)

            tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            return {
                Set = function(_, newValue)
                    local newPercent = (newValue - min) / range
                    bar.Size = UDim2.new(newPercent, 0, 1, 0)
                    valueLabel.Text = tostring(newValue) .. suffix
                end
            }
        end

        -- Dropdown
        function tab:AddDropdown(dropdownConfig)
            dropdownConfig = dropdownConfig or {}
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0.9, 0, 0, 45)
            frame.BackgroundColor3 = colors.surface
            frame.BackgroundTransparency = transparency.surface
            frame.Parent = tabContent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = frame

            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 1, 0)
            button.BackgroundTransparency = 1
            button.Text = (dropdownConfig.Name or "Dropdown") .. ": " .. (dropdownConfig.Default or "Select")
            button.TextColor3 = colors.text
            button.Font = Enum.Font.Gotham
            button.TextSize = 14
            button.Parent = frame

            local options = dropdownConfig.Options or {}
            local callback = dropdownConfig.Callback or function() end
            local selected = dropdownConfig.Default or options[1]

            -- Dropdown frame
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
            dropdownFrame.Position = UDim2.new(0, 0, 1, 0)
            dropdownFrame.BackgroundColor3 = colors.surface2
            dropdownFrame.BackgroundTransparency = transparency.surface2
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.Visible = false
            dropdownFrame.Parent = frame

            local dropdownCorner = Instance.new("UICorner")
            dropdownCorner.CornerRadius = UDim.new(0, 8)
            dropdownCorner.Parent = dropdownFrame

            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = dropdownFrame
            listLayout.Padding = UDim.new(0, 2)
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

            local optionButtons = {}
            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(0.95, 0, 0, 30)
                optBtn.BackgroundColor3 = (opt == selected) and colors.primary or colors.surface
                optBtn.BackgroundTransparency = (opt == selected) and transparency.primary or transparency.surface
                optBtn.Text = opt
                optBtn.TextColor3 = colors.text
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 12
                optBtn.Parent = dropdownFrame

                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 6)
                optCorner.Parent = optBtn

                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    button.Text = (dropdownConfig.Name or "Dropdown") .. ": " .. opt
                    dropdownFrame.Visible = false
                    frame.Size = UDim2.new(0.9, 0, 0, 45)
                    callback(opt)
                    for _, btn in ipairs(optionButtons) do
                        btn.BackgroundColor3 = (btn.Text == opt) and colors.primary or colors.surface
                    end
                end)

                table.insert(optionButtons, optBtn)
            end

            local dropdownHeight = #options * 32 + 10
            dropdownFrame.Size = UDim2.new(1, 0, 0, math.min(200, dropdownHeight)) -- máximo 200

            button.MouseButton1Click:Connect(function()
                if dropdownFrame.Visible then
                    dropdownFrame.Visible = false
                    frame.Size = UDim2.new(0.9, 0, 0, 45)
                else
                    dropdownFrame.Visible = true
                    frame.Size = UDim2.new(0.9, 0, 0, 45 + dropdownFrame.Size.Y.Offset + 5)
                end
            end)

            tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            return {
                Set = function(_, newOpt)
                    selected = newOpt
                    button.Text = (dropdownConfig.Name or "Dropdown") .. ": " .. newOpt
                end
            }
        end

        -- Label simple
        function tab:AddLabel(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.9, 0, 0, 30)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = colors.textMuted
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.Parent = tabContent

            tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            return label
        end

        -- Párrafo con título
        function tab:AddParagraph(title, content)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0.9, 0, 0, 60)
            frame.BackgroundColor3 = colors.surface
            frame.BackgroundTransparency = transparency.surface
            frame.Parent = tabContent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = frame

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -24, 0, 24)
            titleLabel.Position = UDim2.new(0, 12, 0, 8)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = colors.text
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 14
            titleLabel.Parent = frame

            local contentLabel = Instance.new("TextLabel")
            contentLabel.Size = UDim2.new(1, -24, 0, 20)
            contentLabel.Position = UDim2.new(0, 12, 0, 32)
            contentLabel.BackgroundTransparency = 1
            contentLabel.Text = content
            contentLabel.TextColor3 = colors.textMuted
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.Font = Enum.Font.Gotham
            contentLabel.TextSize = 12
            contentLabel.Parent = frame

            tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            return {
                Set = function(_, newTitle, newContent)
                    titleLabel.Text = newTitle
                    contentLabel.Text = newContent
                end
            }
        end

        table.insert(tabs, tab)
        return tab
    end

    -- ========== SELECTOR DE ESTILOS EMERGENTE (para mixers) ==========
    local stylePicker = Instance.new("Frame")
    stylePicker.Name = "StylePicker"
    stylePicker.Size = UDim2.new(0, 250, 0, 300)
    stylePicker.Position = UDim2.new(0.5, -125, 0.5, -150)
    stylePicker.BackgroundColor3 = colors.surface
    stylePicker.BackgroundTransparency = 0.1
    stylePicker.Visible = false
    stylePicker.ZIndex = 10
    stylePicker.Parent = screenGui

    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 12)
    pickerCorner.Parent = stylePicker

    local pickerTitle = Instance.new("TextLabel")
    pickerTitle.Size = UDim2.new(1, -20, 0, 40)
    pickerTitle.Position = UDim2.new(0, 10, 0, 10)
    pickerTitle.BackgroundTransparency = 1
    pickerTitle.Text = "Selecciona un estilo"
    pickerTitle.TextColor3 = colors.text
    pickerTitle.Font = Enum.Font.GothamBold
    pickerTitle.TextSize = 16
    pickerTitle.Parent = stylePicker

    local pickerList = Instance.new("ScrollingFrame")
    pickerList.Size = UDim2.new(1, -20, 1, -70)
    pickerList.Position = UDim2.new(0, 10, 0, 50)
    pickerList.BackgroundTransparency = 1
    pickerList.BorderSizePixel = 0
    pickerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    pickerList.ScrollBarThickness = 4
    pickerList.ScrollBarImageColor3 = colors.primary
    pickerList.Parent = stylePicker

    local pickerLayout = Instance.new("UIListLayout")
    pickerLayout.Parent = pickerList
    pickerLayout.Padding = UDim.new(0, 5)
    pickerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local closePickerBtn = Instance.new("TextButton")
    closePickerBtn.Size = UDim2.new(0, 30, 0, 30)
    closePickerBtn.Position = UDim2.new(1, -40, 0, 10)
    closePickerBtn.BackgroundColor3 = colors.danger
    closePickerBtn.BackgroundTransparency = 0.2
    closePickerBtn.Text = "×"
    closePickerBtn.TextColor3 = colors.text
    closePickerBtn.Font = Enum.Font.GothamBold
    closePickerBtn.TextSize = 18
    closePickerBtn.Parent = stylePicker

    local closePickerCorner = Instance.new("UICorner")
    closePickerCorner.CornerRadius = UDim.new(0, 8)
    closePickerCorner.Parent = closePickerBtn
    closePickerBtn.MouseButton1Click:Connect(function() stylePicker.Visible = false end)

    -- Función para mostrar el selector con opciones
    function RevUILib:ShowStylePicker(config)
        config = config or {}
        local title = config.Title or "Selecciona una opción"
        local options = config.Options or {}
        local currentValue = config.Current or options[1]
        local callback = config.Callback or function() end
        local colors = config.Colors or defaultColors

        pickerTitle.Text = title

        -- Limpiar opciones anteriores
        for _, child in ipairs(pickerList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        -- Crear botones para cada opción
        for _, opt in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.9, 0, 0, 35)
            btn.BackgroundColor3 = (opt == currentValue) and colors.primary or colors.surface2
            btn.BackgroundTransparency = 0.2
            btn.Text = opt
            btn.TextColor3 = colors.text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Parent = pickerList

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                callback(opt)
                stylePicker.Visible = false
            end)
        end

        pickerList.CanvasSize = UDim2.new(0, 0, 0, #options * 40 + 10)
        stylePicker.Visible = true
    end

    -- Retornar objeto ventana con métodos públicos
    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Tabs = tabs,
        AddTab = addTab,
        Minimize = toggleMinimize,
        Destroy = function() screenGui:Destroy() end,
        ShowStylePicker = RevUILib.ShowStylePicker -- El mismo que el de la librería
    }
    return window
end

return RevUILib
