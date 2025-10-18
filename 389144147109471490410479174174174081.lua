
-- Sistema de Load Única - Previne recarregar múltiplas vezes
if _G.UnifiedScriptLoaded then
    warn("⚠️ Script já foi carregado! Use: _G.UnifiedScriptLoaded = false para recarregar")
    return
end

_G.UnifiedScriptLoaded = true
print("✅ Script carregado com sucesso!")
-- ESP Premium Otimizado v3.1
local ESP = {
    Enabled = false,
    Players = false,
    NPCs = false,
    Box = false,
    Filled = false,
    Name = false,
    Distance = false,
    Health = false,
    HealthBar = false,
    HealthText = false,
    Tracers = false,
    TeamCheck = false,
    UseTeamColor = false,
    PlayerDistance = 1000,
    NPCDistance = 500,
    BoxColor = Color3.fromRGB(255, 50, 50),
    NPCColor = Color3.fromRGB(255, 200, 0),
    VisibleColor = Color3.fromRGB(0, 255, 0),
    NotVisibleColor = Color3.fromRGB(255, 0, 0),
    UseVisibilityCheck = false,
    TracerColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 2,
    TextSize = 13
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local drawings = {}
local npcCache = {}
local connections = {}

-- Otimização: Cache de componentes
local componentCache = setmetatable({}, {__mode = "k"})

-- GUI Principal
local gui = Instance.new("ScreenGui")
gui.Name = "ESPPremium"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true

if gethui then
    gui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(gui)
    gui.Parent = game.CoreGui
else
    gui.Parent = game.CoreGui
end

-- Frame Principal (reduzido e mais elegante)
local main = Instance.new("Frame")
main.Parent = gui
main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
main.BorderSizePixel = 0
main.Position = UDim2.new(0.015, 0, 0.3, 0)
main.Size = UDim2.new(0, 300, 0, 420)
main.Active = true
main.ClipsDescendants = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainShadow = Instance.new("ImageLabel")
mainShadow.Parent = main
mainShadow.BackgroundTransparency = 1
mainShadow.Position = UDim2.new(0, -15, 0, -15)
mainShadow.Size = UDim2.new(1, 30, 1, 30)
mainShadow.ZIndex = 0
mainShadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
mainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
mainShadow.ImageTransparency = 0.5

-- Header Minimalista
local header = Instance.new("Frame")
header.Parent = main
header.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
header.BorderSizePixel = 0
header.Size = UDim2.new(1, 0, 0, 50)

local headerGradient = Instance.new("UIGradient")
headerGradient.Parent = header
headerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 18))
}
headerGradient.Rotation = 90

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerAccent = Instance.new("Frame")
headerAccent.Parent = header
headerAccent.BackgroundColor3 = Color3.fromRGB(88, 166, 255)
headerAccent.BorderSizePixel = 0
headerAccent.Size = UDim2.new(1, 0, 0, 2)
headerAccent.Position = UDim2.new(0, 0, 1, -2)

local accentGradient = Instance.new("UIGradient")
accentGradient.Parent = headerAccent
accentGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 166, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 190, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 166, 255))
}

-- Sistema de arrastar otimizado
local dragging, dragStart, startPos = false, nil, nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

local dragConnection = UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Título com ícone
local icon = Instance.new("TextLabel")
icon.Parent = header
icon.BackgroundTransparency = 1
icon.Position = UDim2.new(0, 15, 0, 0)
icon.Size = UDim2.new(0, 30, 1, 0)
icon.Font = Enum.Font.GothamBold
icon.Text = "⚡"
icon.TextColor3 = Color3.fromRGB(88, 166, 255)
icon.TextSize = 20

local title = Instance.new("TextLabel")
title.Parent = header
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 45, 0, 0)
title.Size = UDim2.new(1, -90, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "ESP PREMIUM"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local version = Instance.new("TextLabel")
version.Parent = header
version.BackgroundTransparency = 1
version.Position = UDim2.new(0, 45, 0, 20)
version.Size = UDim2.new(1, -90, 0, 15)
version.Font = Enum.Font.Gotham
version.Text = "v3.1"
version.TextColor3 = Color3.fromRGB(120, 120, 120)
version.TextSize = 11
version.TextXAlignment = Enum.TextXAlignment.Left

-- Botão X melhorado
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = header
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.BorderSizePixel = 0
closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "x"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.AutoButtonColor = false

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

local function disableAndClose()
    ESP.Enabled = false
    for char, e in pairs(drawings) do
        pcall(function()
            for _, d in pairs(e) do
                if d and d.Remove then
                    d.Visible = false
                    d:Remove()
                end
            end
        end)
    end
    drawings = {}
    npcCache = {}
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    if dragConnection then dragConnection:Disconnect() end
    connections = {}
    gui:Destroy()
end

closeBtn.MouseButton1Click:Connect(disableAndClose)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
end)

-- Container de Tabs
local tabsContainer = Instance.new("Frame")
tabsContainer.Parent = main
tabsContainer.BackgroundTransparency = 1
tabsContainer.Position = UDim2.new(0, 10, 0, 58)
tabsContainer.Size = UDim2.new(1, -20, 0, 36)

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.Parent = tabsContainer
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsLayout.Padding = UDim.new(0, 8)

-- Função para criar tabs
local currentTab = "ESP"
local function createTab(name)
    local tab = Instance.new("TextButton")
    tab.Parent = tabsContainer
    tab.BackgroundColor3 = name == currentTab and Color3.fromRGB(88, 166, 255) or Color3.fromRGB(28, 28, 28)
    tab.BorderSizePixel = 0
    tab.Size = UDim2.new(0, 135, 1, 0)
    tab.Font = Enum.Font.GothamBold
    tab.Text = name
    tab.TextColor3 = name == currentTab and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    tab.TextSize = 13
    tab.AutoButtonColor = false
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tab
    
    return tab
end

local espTab = createTab("ESP")
local configTab = createTab("CONFIG")

-- Páginas otimizadas
local function createPage()
    local page = Instance.new("ScrollingFrame")
    page.Parent = main
    page.BackgroundTransparency = 1
    page.Position = UDim2.new(0, 10, 0, 102)
    page.Size = UDim2.new(1, -20, 1, -112)
    page.ScrollBarThickness = 4
    page.BorderSizePixel = 0
    page.ScrollBarImageColor3 = Color3.fromRGB(88, 166, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    return page, layout
end

local espPage, espLayout = createPage()
local configPage, configLayout = createPage()
configPage.Visible = false

-- Sistema de Tabs
local function switchTab(name, tab, page)
    currentTab = name
    espTab.BackgroundColor3 = name == "ESP" and Color3.fromRGB(88, 166, 255) or Color3.fromRGB(28, 28, 28)
    espTab.TextColor3 = name == "ESP" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    configTab.BackgroundColor3 = name == "CONFIG" and Color3.fromRGB(88, 166, 255) or Color3.fromRGB(28, 28, 28)
    configTab.TextColor3 = name == "CONFIG" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    espPage.Visible = name == "ESP"
    configPage.Visible = name == "CONFIG"
end

espTab.MouseButton1Click:Connect(function() switchTab("ESP", espTab, espPage) end)
configTab.MouseButton1Click:Connect(function() switchTab("CONFIG", configTab, configPage) end)

-- Funções otimizadas de criação de elementos
local function createSection(parent, name)
    local section = Instance.new("Frame")
    section.Parent = parent
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 28)
    
    local label = Instance.new("TextLabel")
    label.Parent = section
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.Text = name
    label.TextColor3 = Color3.fromRGB(88, 166, 255)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local line = Instance.new("Frame")
    line.Parent = section
    line.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    line.BorderSizePixel = 0
    line.Position = UDim2.new(0, 0, 1, -1)
    line.Size = UDim2.new(1, 0, 0, 1)
    
    return section
end

local function createToggle(parent, name, key, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, 40)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("Frame")
    toggle.Parent = frame
    toggle.BackgroundColor3 = ESP[key] and Color3.fromRGB(88, 166, 255) or Color3.fromRGB(45, 45, 45)
    toggle.BorderSizePixel = 0
    toggle.Position = UDim2.new(1, -48, 0.5, -10)
    toggle.Size = UDim2.new(0, 42, 0, 20)
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local circle = Instance.new("Frame")
    circle.Parent = toggle
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Position = ESP[key] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.Size = UDim2.new(0, 16, 0, 16)
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""
    
    btn.MouseButton1Click:Connect(function()
        ESP[key] = not ESP[key]
        TweenService:Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = ESP[key] and Color3.fromRGB(88, 166, 255) or Color3.fromRGB(45, 45, 45)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = ESP[key] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        if callback then callback(ESP[key]) end
    end)
end

local function createSlider(parent, name, key, min, max, suffix)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, 55)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 8)
    label.Size = UDim2.new(1, -24, 0, 16)
    label.Font = Enum.Font.Gotham
    label.Text = name .. ": " .. ESP[key] .. suffix
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = frame
    sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sliderBg.BorderSizePixel = 0
    sliderBg.Position = UDim2.new(0, 12, 0, 32)
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBg
    sliderFill.BackgroundColor3 = Color3.fromRGB(88, 166, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Size = UDim2.new((ESP[key] - min) / (max - min), 0, 1, 0)
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderDragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true
        end
    end)
    
    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end))
    
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            ESP[key] = value
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = name .. ": " .. value .. suffix
        end
    end))
end

local function createColorPicker(parent, name, key)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, 40)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local colorBox = Instance.new("Frame")
    colorBox.Parent = frame
    colorBox.BackgroundColor3 = ESP[key]
    colorBox.BorderSizePixel = 0
    colorBox.Position = UDim2.new(1, -36, 0.5, -12)
    colorBox.Size = UDim2.new(0, 28, 0, 24)
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 6)
    colorCorner.Parent = colorBox
    
    local colorStroke = Instance.new("UIStroke")
    colorStroke.Color = Color3.fromRGB(60, 60, 60)
    colorStroke.Thickness = 1
    colorStroke.Parent = colorBox
    
    local btn = Instance.new("TextButton")
    btn.Parent = colorBox
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""
    
    btn.MouseButton1Click:Connect(function()
        local colors = {
            Color3.fromRGB(255, 50, 50),
            Color3.fromRGB(255, 150, 0),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(88, 166, 255),
            Color3.fromRGB(150, 0, 255),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(255, 255, 255),
        }
        
        local currentIndex = 1
        for i, color in ipairs(colors) do
            if ESP[key] == color then
                currentIndex = i
                break
            end
        end
        
        currentIndex = currentIndex % #colors + 1
        ESP[key] = colors[currentIndex]
        TweenService:Create(colorBox, TweenInfo.new(0.2), {BackgroundColor3 = ESP[key]}):Play()
    end)
end

-- Criar Interface ESP
createSection(espPage, "GERAL")
createToggle(espPage, "ESP Ativado", "Enabled")
createToggle(espPage, "Mostrar Jogadores", "Players")
createToggle(espPage, "Mostrar NPCs", "NPCs")
createToggle(espPage, "Verificar Time", "TeamCheck")

createSection(espPage, "VISUAL")
createToggle(espPage, "Caixa", "Box")
createToggle(espPage, "Caixa Preenchida", "Filled")
createToggle(espPage, "Nome", "Name")
createToggle(espPage, "Distância", "Distance")
createToggle(espPage, "HP (Texto)", "HealthText")
createToggle(espPage, "Barra de HP", "HealthBar")
createToggle(espPage, "Linhas (Tracers)", "Tracers")

createSection(espPage, "DISTÂNCIA")
createSlider(espPage, "Jogadores", "PlayerDistance", 100, 3000, "m")
createSlider(espPage, "NPCs", "NPCDistance", 100, 2000, "m")

-- Criar Interface CONFIG
createSection(configPage, "VISIBILIDADE")
createToggle(configPage, "Checar Visibilidade", "UseVisibilityCheck")
createColorPicker(configPage, "Cor Visível", "VisibleColor")
createColorPicker(configPage, "Cor Não Visível", "NotVisibleColor")

createSection(configPage, "CORES")
createToggle(configPage, "Usar Cor do Time", "UseTeamColor")
createColorPicker(configPage, "Cor Jogadores", "BoxColor")
createColorPicker(configPage, "Cor NPCs", "NPCColor")
createColorPicker(configPage, "Cor Linhas", "TracerColor")

createSection(configPage, "CONFIGURAÇÕES")
createSlider(configPage, "Espessura da Linha", "BoxThickness", 1, 5, "px")
createSlider(configPage, "Tamanho do Texto", "TextSize", 10, 20, "px")

-- Tecla Toggle
table.insert(connections, UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        main.Visible = not main.Visible
    end
end))

-- Sistema ESP (igual ao anterior)
local function newESP(char, isNPC)
    if drawings[char] then return end
    
    local e = {
        box = Drawing.new("Square"),
        boxFill = Drawing.new("Square"),
        name = Drawing.new("Text"),
        dist = Drawing.new("Text"),
        hp = Drawing.new("Text"),
        hpBar = Drawing.new("Square"),
        hpOut = Drawing.new("Square"),
        tracer = Drawing.new("Line"),
        npc = isNPC,
        char = char
    }
    
    e.box.Thickness = ESP.BoxThickness
    e.box.Filled = false
    e.box.Transparency = 1
    e.box.ZIndex = 2
    e.box.Visible = false
    
    e.boxFill.Filled = true
    e.boxFill.Transparency = 0.15
    e.boxFill.ZIndex = 1
    e.boxFill.Visible = false
    
    e.name.Size = ESP.TextSize
    e.name.Center = true
    e.name.Outline = true
    e.name.ZIndex = 2
    e.name.Visible = false
    
    e.dist.Size = ESP.TextSize - 1
    e.dist.Center = true
    e.dist.Outline = true
    e.dist.ZIndex = 2
    e.dist.Visible = false
    
    e.hp.Size = ESP.TextSize - 1
    e.hp.Center = true
    e.hp.Outline = true
    e.hp.ZIndex = 2
    e.hp.Visible = false
    
    e.hpOut.Filled = false
    e.hpOut.Thickness = 1
    e.hpOut.Color = Color3.new(0, 0, 0)
    e.hpOut.Transparency = 1
    e.hpOut.ZIndex = 1
    e.hpOut.Visible = false
    
    e.hpBar.Filled = true
    e.hpBar.Transparency = 1
    e.hpBar.ZIndex = 2
    e.hpBar.Visible = false
    
    e.tracer.Thickness = 1
    e.tracer.Transparency = 0.7
    e.tracer.ZIndex = 1
    e.tracer.Visible = false
    
    drawings[char] = e
end

local function removeESP(char)
    if drawings[char] then
        pcall(function()
            for _, d in pairs(drawings[char]) do
                if d and d.Remove then
                    d.Visible = false
                    d:Remove()
                end
            end
        end)
        drawings[char] = nil
    end
end

local function isNPC(m)
    return m:IsA("Model") and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(m)
end

local function isVisible(from, to, character)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, character, Camera}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    
    local direction = (to - from)
    local distance = direction.Magnitude
    local result = Workspace:Raycast(from, direction.Unit * distance, params)
    
    if not result then return true end
    if result.Instance then
        return result.Instance:IsDescendantOf(character)
    end
    return false
end

-- Jogadores
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(connections, p.CharacterAdded:Connect(function(c)
            task.wait(0.3)
            if c and c.Parent then newESP(c, false) end
        end))
        if p.Character then newESP(p.Character, false) end
    end
end

table.insert(connections, Players.PlayerAdded:Connect(function(p)
    table.insert(connections, p.CharacterAdded:Connect(function(c)
        task.wait(0.3)
        if c and c.Parent then newESP(c, false) end
    end))
end))

table.insert(connections, Players.PlayerRemoving:Connect(function(p)
    if p.Character then removeESP(p.Character) end
end))

-- NPCs com cache otimizado
local function addNPC(m)
    if not isNPC(m) or npcCache[m] then return end
    npcCache[m] = true
    newESP(m, true)
    
    local conn = m.AncestryChanged:Connect(function(_, parent)
        if not parent then
            removeESP(m)
            npcCache[m] = nil
        end
    end)
    table.insert(connections, conn)
end

for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("Model") then addNPC(v) end
end

table.insert(connections, Workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Model") then
        task.wait(0.2)
        addNPC(d)
    elseif d:IsA("Humanoid") or d.Name == "HumanoidRootPart" then
        task.wait(0.2)
        if d.Parent and d.Parent:IsA("Model") then addNPC(d.Parent) end
    end
end))

-- Update Loop Otimizado
local lastUpdate = tick()
local updateInterval = 1/60 -- 60 FPS

table.insert(connections, RunService.RenderStepped:Connect(function()
    local now = tick()
    if now - lastUpdate < updateInterval then return end
    lastUpdate = now
    
    if not ESP.Enabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, e in pairs(drawings) do
            e.box.Visible = false
            e.boxFill.Visible = false
            e.name.Visible = false
            e.dist.Visible = false
            e.hp.Visible = false
            e.hpBar.Visible = false
            e.hpOut.Visible = false
            e.tracer.Visible = false
        end
        return
    end
    
    local lRoot = LocalPlayer.Character.HumanoidRootPart
    local viewportSize = Camera.ViewportSize
    
    for char, e in pairs(drawings) do
        if not char or not char.Parent or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
            e.box.Visible = false
            e.boxFill.Visible = false
            e.name.Visible = false
            e.dist.Visible = false
            e.hp.Visible = false
            e.hpBar.Visible = false
            e.hpOut.Visible = false
            e.tracer.Visible = false
            continue
        end
        
        local root = char.HumanoidRootPart
        local hum = char.Humanoid
        local head = char:FindFirstChild("Head")
        
        if hum.Health <= 0 or not head then
            e.box.Visible = false
            e.boxFill.Visible = false
            e.name.Visible = false
            e.dist.Visible = false
            e.hp.Visible = false
            e.hpBar.Visible = false
            e.hpOut.Visible = false
            e.tracer.Visible = false
            continue
        end
        
        local dist = (lRoot.Position - root.Position).Magnitude
        local maxDist = e.npc and ESP.NPCDistance or ESP.PlayerDistance
        
        if dist > maxDist then
            e.box.Visible = false
            e.boxFill.Visible = false
            e.name.Visible = false
            e.dist.Visible = false
            e.hp.Visible = false
            e.hpBar.Visible = false
            e.hpOut.Visible = false
            e.tracer.Visible = false
            continue
        end
        
        if (e.npc and not ESP.NPCs) or (not e.npc and not ESP.Players) then
            e.box.Visible = false
            e.boxFill.Visible = false
            e.name.Visible = false
            e.dist.Visible = false
            e.hp.Visible = false
            e.hpBar.Visible = false
            e.hpOut.Visible = false
            e.tracer.Visible = false
            continue
        end
        
        if not e.npc and ESP.TeamCheck then
            local p = Players:GetPlayerFromCharacter(char)
            if p and p.Team == LocalPlayer.Team then
                e.box.Visible = false
                e.boxFill.Visible = false
                e.name.Visible = false
                e.dist.Visible = false
                e.hp.Visible = false
                e.hpBar.Visible = false
                e.hpOut.Visible = false
                e.tracer.Visible = false
                continue
            end
        end
        
        local vec, onScreen = Camera:WorldToViewportPoint(root.Position)
        
        if onScreen then
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            local h = math.abs(headPos.Y - legPos.Y)
            local w = h / 2
            
            local col = e.npc and ESP.NPCColor or ESP.BoxColor
            
            if ESP.UseVisibilityCheck then
                local targetPos = head.Position
                local visible = isVisible(Camera.CFrame.Position, targetPos, char)
                col = visible and ESP.VisibleColor or ESP.NotVisibleColor
            elseif not e.npc and ESP.UseTeamColor then
                local p = Players:GetPlayerFromCharacter(char)
                if p and p.TeamColor then 
                    col = p.TeamColor.Color 
                end
            end
            
            e.box.Thickness = ESP.BoxThickness
            e.name.Size = ESP.TextSize
            e.dist.Size = ESP.TextSize - 1
            e.hp.Size = ESP.TextSize - 1
            
            if ESP.Box then
                e.box.Size = Vector2.new(w, h)
                e.box.Position = Vector2.new(vec.X - w/2, vec.Y - h/2)
                e.box.Color = col
                e.box.Visible = true
                
                if ESP.Filled then
                    e.boxFill.Size = Vector2.new(w, h)
                    e.boxFill.Position = Vector2.new(vec.X - w/2, vec.Y - h/2)
                    e.boxFill.Color = col
                    e.boxFill.Visible = true
                else
                    e.boxFill.Visible = false
                end
            else
                e.box.Visible = false
                e.boxFill.Visible = false
            end
            
            if ESP.Name then
                e.name.Text = char.Name
                e.name.Position = Vector2.new(vec.X, headPos.Y - 18)
                e.name.Color = col
                e.name.Visible = true
            else
                e.name.Visible = false
            end
            
            if ESP.Distance then
                e.dist.Text = math.floor(dist) .. "m"
                e.dist.Position = Vector2.new(vec.X, legPos.Y + 5)
                e.dist.Color = Color3.new(1, 1, 1)
                e.dist.Visible = true
            else
                e.dist.Visible = false
            end
            
            if ESP.HealthText then
                local pct = math.floor((hum.Health / hum.MaxHealth) * 100)
                e.hp.Text = pct .. "%"
                e.hp.Position = Vector2.new(vec.X, legPos.Y + 18)
                e.hp.Color = Color3.fromRGB(255 - pct * 2.55, pct * 2.55, 0)
                e.hp.Visible = true
            else
                e.hp.Visible = false
            end
            
            if ESP.HealthBar then
                local pct = hum.Health / hum.MaxHealth
                local barX = vec.X - w/2 - 6
                local barY = vec.Y - h/2
                
                e.hpOut.Size = Vector2.new(3, h)
                e.hpOut.Position = Vector2.new(barX, barY)
                e.hpOut.Visible = true
                
                local hpH = h * pct
                e.hpBar.Size = Vector2.new(2, hpH)
                e.hpBar.Position = Vector2.new(barX + 0.5, barY + (h - hpH))
                e.hpBar.Color = Color3.fromRGB(255 - pct * 255, pct * 255, 0)
                e.hpBar.Visible = true
            else
                e.hpBar.Visible = false
                e.hpOut.Visible = false
            end
            
            if ESP.Tracers then
                e.tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                e.tracer.To = Vector2.new(vec.X, vec.Y)
                e.tracer.Color = ESP.TracerColor
                e.tracer.Visible = true
            else
                e.tracer.Visible = false
            end
        else
            e.box.Visible = false
            e.boxFill.Visible = false
            e.name.Visible = false
            e.dist.Visible = false
            e.hp.Visible = false
            e.hpBar.Visible = false
            e.hpOut.Visible = false
            e.tracer.Visible = false
        end
    end
end))
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurações
local Config = {
    DefaultSpeed = 16,
    MinSpeed = 0,
    MaxSpeed = 500,
    ToggleKey = Enum.KeyCode.P
}

local currentSpeed = Config.DefaultSpeed
local guiVisible = true

-- Criação da GUI
local function createGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SpeedControlGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 220, 0, 150)
    frame.Position = UDim2.new(0.5, -110, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    
    -- Arredondamento de cantos
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Sombra
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = 0
    shadow.Parent = frame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    header.BorderSizePixel = 0
    header.Parent = frame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    -- Corrige cantos inferiores do header
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 8)
    headerFix.Position = UDim2.new(0, 0, 1, -8)
    headerFix.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header
    
    local label = Instance.new("TextLabel")
    label.Name = "Title"
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = "⚡ Speed Control"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = header
    
    -- TextBox para velocidade
    local textBox = Instance.new("TextBox")
    textBox.Name = "SpeedInput"
    textBox.Size = UDim2.new(0, 200, 0, 40)
    textBox.Position = UDim2.new(0, 10, 0, 45)
    textBox.Text = tostring(Config.DefaultSpeed)
    textBox.PlaceholderText = "Digite a velocidade"
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.ClearTextOnFocus = false
    textBox.Parent = frame
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 6)
    textBoxCorner.Parent = textBox
    
    -- Botão reset
    local button = Instance.new("TextButton")
    button.Name = "ResetButton"
    button.Size = UDim2.new(0, 200, 0, 35)
    button.Position = UDim2.new(0, 10, 0, 95)
    button.Text = "🔄 Resetar Velocidade"
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = frame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    gui.Parent = playerGui
    
    return gui, textBox, button
end

-- Funções auxiliares
local function setSpeed(newSpeed)
    if newSpeed < Config.MinSpeed then newSpeed = Config.MinSpeed end
    if newSpeed > Config.MaxSpeed then newSpeed = Config.MaxSpeed end
    
    currentSpeed = newSpeed
    
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = currentSpeed
        end
    end
end

local function animateButton(button, color)
    local tween = TweenService:Create(
        button,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = color}
    )
    tween:Play()
end

-- Inicialização
local gui, textBox, button = createGui()

-- Eventos da TextBox
textBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newSpeed = tonumber(textBox.Text)
        if newSpeed then
            setSpeed(newSpeed)
        else
            textBox.Text = tostring(currentSpeed)
        end
    end
end)

-- Eventos do Botão
button.MouseEnter:Connect(function()
    animateButton(button, Color3.fromRGB(80, 80, 80))
end)

button.MouseLeave:Connect(function()
    animateButton(button, Color3.fromRGB(60, 60, 60))
end)

button.MouseButton1Click:Connect(function()
    animateButton(button, Color3.fromRGB(100, 100, 100))
    task.wait(0.1)
    animateButton(button, Color3.fromRGB(80, 80, 80))
    
    setSpeed(Config.DefaultSpeed)
    textBox.Text = tostring(Config.DefaultSpeed)
end)

-- Mantém a velocidade constante
RunService.Stepped:Connect(function()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= currentSpeed then
            humanoid.WalkSpeed = currentSpeed
        end
    end
end)

-- Toggle da GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Config.ToggleKey and not gameProcessed then
        guiVisible = not guiVisible
        gui.Enabled = guiVisible
    end
end)

-- Aplica velocidade ao spawnar
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = currentSpeed
end)

-- Configuração inicial
setSpeed(Config.DefaultSpeed)

loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()


loadstring(game:HttpGet("https://raw.githubusercontent.com/L4BIBKAZI/L4BIB-HUB/refs/heads/main/Weak%20Legacy%202"))()
