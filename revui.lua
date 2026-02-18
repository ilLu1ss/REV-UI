--[[
    RevUI - Librería de interfaz para exploits de Roblox
    Versión optimizada para entornos de inyección
    by: Asistente
]]

local RevUI = {}

-- Servicios
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Esperar a que el jugador local exista (útil si el script se ejecuta muy temprano)
local player = Players.LocalPlayer
if not player then
    player = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
end

-- Configuración de colores por defecto
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

-- Transparencia por defecto
local defaultTransparency = {
    bg = 0.2,
    surface = 0.2,
    surface2 = 0.2,
    primary = 0.1,
    success = 0.1,
    danger = 0.1,
    warning = 0.1
}

-- Función auxiliar para redondear
local function round(num)
    return math.floor(num + 0.5)
end

-- Función para crear una ventana
function RevUI:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "RevUI Window"
    local windowSize = config.Size or UDim2.new(0, 500, 0, 650)
    local windowPos = config.Position or UDim2.new(0.5, -250, 0.5, -325)
    local colors = config.Colors or defaultColors
    local transparency = config.Transparency or defaultTransparency
    local parent = config.Parent or CoreGui  -- Por defecto usa CoreGui (más seguro para exploits)

    -- Crear ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RevUI_" .. windowName
    screenGui.Parent = parent
    screenGui.ResetOnSpawn = false  -- Importante para que no desaparezca al morir
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999  -- Asegurar que esté por encima de otros elementos

    -- Ventana principal
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

    -- Área de pestañas
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -32, 0, 40)
    tabBar.Position = UDim2.new(0, 16, 0, 56)
    tabBar.BackgroundColor3 = colors.surface2
    tabBar.BackgroundTransparency = transparency.surface2
    tabBar.Parent = mainFrame

    local tabBarCorner = Instance.new("UICorner")
    tabBarCorner.CornerRadius = UDim.new(0, 10)
    tabBarCorner.Parent = tabBar

    -- Contenedor de contenido
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -32, 1, -140)
    contentArea.Position = UDim2.new(0, 16, 0, 104)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    -- Tabla para almacenar pestañas
    local tabs = {}
    local currentTab = nil

    -- Función para crear una pestaña
    function tabs:AddTab(tabName)
        local tabButton = Instance.new("TextButton")
        -- Para un número variable de pestañas, calculamos el ancho dinámicamente
        local tabCount = #self + 1
        local tabWidth = (tabBar.AbsoluteSize.X - (#self * 4)) / tabCount  -- Esto es solo referencia, usaremos UDim2 con escala
        tabButton.Size = UDim2.new(0, 100, 1, -4)  -- Ancho fijo por simplicidad
        tabButton.Position = UDim2.new(0, (#self) * 104 + 2, 0, 2)  -- Separación de 4 píxeles
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

        -- Contenedor de la pestaña (invisible hasta que se seleccione)
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

        -- Actualizar canvas cuando cambie el contenido
        local function updateCanvas()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

        -- Función para seleccionar esta pestaña
        local function select()
            if currentTab then
                currentTab.Button.BackgroundColor3 = colors.surface2
                currentTab.Button.BackgroundTransparency = transparency.surface2
                currentTab.Button.TextColor3 = colors.textMuted
                currentTab.Content.Visible = false
            end
            tabButton.BackgroundColor3 = colors.primary
            tabButton.BackgroundTransparency = transparency.primary
            tabButton.TextColor3 = colors.text
            tabContent.Visible = true
            currentTab = {Button = tabButton, Content = tabContent}
            updateCanvas()
        end

        tabButton.MouseButton1Click:Connect(select)

        -- Si es la primera pestaña, seleccionarla automáticamente
        if #self == 0 then
            select()
        end

        -- Métodos para añadir elementos
        local tab = {
            Button = tabButton,
            Content = tabContent,
            Layout = layout,
            AddButton = function(self, btnConfig)
                btnConfig = btnConfig or {}
                if type(btnConfig.Callback) ~= "function" then
                    btnConfig.Callback = function() end
                end
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

                btn.MouseButton1Click:Connect(btnConfig.Callback)
                updateCanvas()
                return btn
            end,
            AddToggle = function(self, toggleConfig)
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
                toggleBtn.BackgroundColor3 = toggleConfig.Default and colors.success or colors.surface2
                toggleBtn.BackgroundTransparency = toggleConfig.Default and transparency.success or transparency.surface2
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
                    toggleBtn.BackgroundTransparency = state and transparency.success or transparency.surface2
                    toggleBtn.Text = state and "ON" or "OFF"
                    callback(state)
                end)

                updateCanvas()
                return {
                    Set = function(_, newState)
                        state = newState
                        toggleBtn.BackgroundColor3 = state and colors.success or colors.surface2
                        toggleBtn.BackgroundTransparency = state and transparency.success or transparency.surface2
                        toggleBtn.Text = state and "ON" or "OFF"
                    end
                }
            end,
            AddSlider = function(self, sliderConfig)
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
                local increment = sliderConfig.Increment
                local callback = sliderConfig.Callback or function() end

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
                    if bgSize == 0 then return end
                    local rel = math.clamp((mousePos - bgPos) / bgSize, 0, 1)
                    local value = min + rel * range
                    if increment then
                        value = round(value / increment) * increment
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

                updateCanvas()
                return {
                    Set = function(_, newValue)
                        percent = (newValue - min) / range
                        bar.Size = UDim2.new(percent, 0, 1, 0)
                        valueLabel.Text = tostring(newValue) .. suffix
                    end
                }
            end,
            AddDropdown = function(self, dropdownConfig)
                dropdownConfig = dropdownConfig or {}
                local options = dropdownConfig.Options or {}
                if #options == 0 then
                    warn("RevUI: Dropdown sin opciones")
                    return
                end
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(0.9, 0, 0, 45)
                frame.BackgroundColor3 = colors.surface
                frame.BackgroundTransparency = transparency.surface
                frame.Parent = tabContent
                frame.ClipsDescendants = true

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 8)
                corner.Parent = frame

                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 1, 0)
                button.BackgroundTransparency = 1
                button.Text = (dropdownConfig.Name or "Dropdown") .. ": " .. (dropdownConfig.Default or options[1])
                button.TextColor3 = colors.text
                button.Font = Enum.Font.Gotham
                button.TextSize = 14
                button.Parent = frame

                local selected = dropdownConfig.Default or options[1]
                local callback = dropdownConfig.Callback or function() end

                -- Ventana emergente
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
                            btn.BackgroundTransparency = (btn.Text == opt) and transparency.primary or transparency.surface
                        end
                        updateCanvas()
                    end)

                    table.insert(optionButtons, optBtn)
                end

                local dropdownHeight = #options * 32 + 10
                dropdownFrame.Size = UDim2.new(1, 0, 0, dropdownHeight)

                button.MouseButton1Click:Connect(function()
                    if dropdownFrame.Visible then
                        dropdownFrame.Visible = false
                        frame.Size = UDim2.new(0.9, 0, 0, 45)
                    else
                        dropdownFrame.Visible = true
                        frame.Size = UDim2.new(0.9, 0, 0, 45 + dropdownHeight + 5)
                    end
                    updateCanvas()
                end)

                updateCanvas()
                return {
                    Set = function(_, newOpt)
                        selected = newOpt
                        button.Text = (dropdownConfig.Name or "Dropdown") .. ": " .. newOpt
                        for _, btn in ipairs(optionButtons) do
                            btn.BackgroundColor3 = (btn.Text == newOpt) and colors.primary or colors.surface
                            btn.BackgroundTransparency = (btn.Text == newOpt) and transparency.primary or transparency.surface
                        end
                    end
                }
            end,
            AddLabel = function(self, text)
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.9, 0, 0, 30)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = colors.textMuted
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.Parent = tabContent
                updateCanvas()
                return label
            end,
            AddParagraph = function(self, title, content)
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

                updateCanvas()
                return {
                    Set = function(_, newTitle, newContent)
                        titleLabel.Text = newTitle
                        contentLabel.Text = newContent
                    end
                }
            end
        }

        table.insert(self, tab)
        return tab
    end

    -- Funcionalidad de minimizar
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(mainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, windowSize.X.Offset, 0, 48)}):Play()
            tabBar.Visible = false
            contentArea.Visible = false
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.2), {Size = windowSize}):Play()
            tabBar.Visible = true
            contentArea.Visible = true
        end
    end)

    -- Cerrar
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Devolver la ventana con sus métodos
    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Tabs = tabs,
        AddTab = function(self, name) return tabs:AddTab(name) end,
        Destroy = function() screenGui:Destroy() end
    }
end

-- Función para notificaciones
function RevUI:Notify(config)
    config = config or {}
    local message = config.Content or "Notificación"
    local duration = config.Time or 3
    local type = config.Type or "info"
    local colors = config.Colors or defaultColors
    local transparency = config.Transparency or defaultTransparency
    local parent = config.Parent or CoreGui

    local screenGui = parent:FindFirstChild("RevUI_Notifications")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "RevUI_Notifications"
        screenGui.Parent = parent
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.DisplayOrder = 1000
    end

    local holder = screenGui:FindFirstChild("NotificationHolder")
    if not holder then
        holder = Instance.new("Frame")
        holder.Name = "NotificationHolder"
        holder.Size = UDim2.new(0, 300, 1, -20)
        holder.Position = UDim2.new(1, -310, 0, 10)
        holder.BackgroundTransparency = 1
        holder.Parent = screenGui

        local layout = Instance.new("UIListLayout")
        layout.Parent = holder
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.Padding = UDim.new(0, 8)
    end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 50)
    notif.BackgroundColor3 = colors.surface
    notif.BackgroundTransparency = 0.2
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

-- Función para crear una ventana emergente (modal)
function RevUI:CreateModal(config)
    config = config or {}
    local title = config.Title or "Modal"
    local content = config.Content or ""
    local buttons = config.Buttons or {{Text = "OK", Callback = function() end}}
    local colors = config.Colors or defaultColors
    local transparency = config.Transparency or defaultTransparency
    local parent = config.Parent or CoreGui

    local screenGui = parent:FindFirstChild("RevUI_Modals")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "RevUI_Modals"
        screenGui.Parent = parent
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.DisplayOrder = 1001
    end

    local modal = Instance.new("Frame")
    modal.Size = UDim2.new(0, 350, 0, 200)
    modal.Position = UDim2.new(0.5, -175, 0.5, -100)
    modal.BackgroundColor3 = colors.bg
    modal.BackgroundTransparency = transparency.bg
    modal.BorderSizePixel = 0
    modal.Parent = screenGui

    local modalCorner = Instance.new("UICorner")
    modalCorner.CornerRadius = UDim.new(0, 16)
    modalCorner.Parent = modal

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -32, 0, 40)
    titleLabel.Position = UDim2.new(0, 16, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = colors.text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Parent = modal

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -32, 0, 60)
    contentLabel.Position = UDim2.new(0, 16, 0, 60)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = colors.textMuted
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 14
    contentLabel.TextWrapped = true
    contentLabel.Parent = modal

    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -32, 0, 40)
    buttonFrame.Position = UDim2.new(0, 16, 1, -56)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = modal

    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.Parent = buttonFrame
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    buttonLayout.Padding = UDim.new(0, 10)

    for _, btnConfig in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 0, 36)
        btn.BackgroundColor3 = btnConfig.Color or colors.primary
        btn.BackgroundTransparency = btnConfig.Transparency or transparency.primary
        btn.Text = btnConfig.Text or "OK"
        btn.TextColor3 = colors.text
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.Parent = buttonFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            if btnConfig.Callback then btnConfig.Callback() end
            modal:Destroy()
        end)
    end

    return modal
end

return RevUI
