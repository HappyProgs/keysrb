--// KeySystem
local KeySystem = {}
KeySystem.__index = KeySystem

-- Конфигурация системы
local CONFIG = {
    GITHUB_RAW_URL = "https://raw.githubusercontent.com/HappyProgs/fkdsfk/refs/heads/main/keys.json",
    SCRIPT_NAME = "Key System",
    DEVELOPER_TG = "https://t.me/mamkabotik",
    LOGO_URL = "rbxassetid://7072717832"
}

local function simpleHash(str)
    local hash = 0
    for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 0x7FFFFFFF
    end
    return tostring(hash)
end

local function base64Decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (b:find(x)-1)
        for i = 6, 1, -1 do
            r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0')
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do
            c = c + (x:sub(i,i) == '1' and 2^(8-i) or 0)
        end
        return string.char(c)
    end))
end

local function validateKeyFormat(key)
    if not key or type(key) ~= "string" or #key < 3 then 
        return false 
    end
    return true
end

local function fetchKeysFromGitHub()
    local success, result = pcall(function()
        return game:HttpGet(CONFIG.GITHUB_RAW_URL, true)
    end)
    
    if success and result then
        return game:GetService("HttpService"):JSONDecode(result)
    end
    return nil
end

-- Проверка срока действия ключа
local function isKeyExpired(expiryDate)
    local currentTime = os.time()
    local expiryTime = os.time({
        year = tonumber(expiryDate:sub(1, 4)),
        month = tonumber(expiryDate:sub(6, 7)),
        day = tonumber(expiryDate:sub(9, 10)),
        hour = tonumber(expiryDate:sub(12, 13)),
        min = tonumber(expiryDate:sub(15, 16))
    })
    return currentTime > expiryTime
end

-- Создание интерфейса ключ-системы
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeySystemGUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    gradient.Rotation = 45
    gradient.Parent = mainFrame

    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = mainFrame
    shadow.ZIndex = -1

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    title.BorderSizePixel = 0
    title.Text = CONFIG.SCRIPT_NAME
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 40, 0, 40)
    logo.Position = UDim2.new(0, 15, 0, 10)
    logo.BackgroundTransparency = 1
    logo.Image = CONFIG.LOGO_URL
    logo.Parent = title

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0, 380, 0, 45)
    inputBox.Position = UDim2.new(0, 35, 0, 80)
    inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    inputBox.BorderSizePixel = 0
    inputBox.PlaceholderText = "Введите ваш ключ доступа..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 16
    inputBox.TextXAlignment = Enum.TextXAlignment.Center
    inputBox.Parent = mainFrame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputBox

    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(0, 380, 0, 45)
    submitButton.Position = UDim2.new(0, 35, 0, 140)
    submitButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    submitButton.BorderSizePixel = 0
    submitButton.Text = "АКТИВИРОВАТЬ ПРЕМИУМ"
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.Font = Enum.Font.GothamBold
    submitButton.TextSize = 18
    submitButton.Parent = mainFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = submitButton

    submitButton.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(
            submitButton,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(100, 140, 220)}
        ):Play()
    end)

    submitButton.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(
            submitButton,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(80, 120, 200)}
        ):Play()
    end)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 380, 0, 50)
    statusLabel.Position = UDim2.new(0, 35, 0, 200)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Введите ключ для активации"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 14
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame

    local contactLabel = Instance.new("TextLabel")
    contactLabel.Size = UDim2.new(1, 0, 0, 40)
    contactLabel.Position = UDim2.new(0, 0, 1, -40)
    contactLabel.BackgroundTransparency = 1
    contactLabel.Text = "Разработчик: " .. CONFIG.DEVELOPER_TG
    contactLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    contactLabel.Font = Enum.Font.Gotham
    contactLabel.TextSize = 12
    contactLabel.Parent = mainFrame

    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        InputBox = inputBox,
        SubmitButton = submitButton,
        StatusLabel = statusLabel
    }
end

-- Основная функция проверки ключа
function KeySystem.validate(key)
    if not validateKeyFormat(key) then
        return false, "Неверный формат ключа"
    end
    
    local keysData = fetchKeysFromGitHub()
    if not keysData then
        return false, "Ошибка подключения к серверу"
    end
    
    local keyData = keysData[key]
    
    if not keyData then
        return false, "Недействительный ключ"
    end
    
    if keyData.expires and isKeyExpired(keyData.expires) then
        return false, "Срок действия ключа истек"
    end
    
    return true, keyData.expires and "Ключ действителен до " .. keyData.expires or "Постоянный ключ"
end

-- Функция очистки старых GUI
local function clearOldGUIs()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name == "KeySystemGUI" or gui.Name:match("^UltraHack_")) then
            pcall(function() gui:Destroy() end)
        end
    end
end

-- Функция запуска меню чита
local function launchMainMenu()
   --// Сервисы
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local cam = WS.CurrentCamera

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraHack_" .. HttpService:GenerateGUID(false)
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 450)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "🔥 STEAL A BRAINROT ULTRA FIXED"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Левая панель
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 120, 1, -45)
SideBar.Position = UDim2.new(0, 0, 0, 45)
SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 6)
SideCorner.Parent = SideBar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 8)
SideLayout.FillDirection = Enum.FillDirection.Vertical
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = SideBar

-- Контентная зона
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -130, 1, -45)
ContentFrame.Position = UDim2.new(0, 130, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

--// Система вкладок
local Tabs = {}
local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = SideBar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = content

    Tabs[name] = {Btn = btn, Frame = content}
    
    btn.MouseButton1Click:Connect(function()
        for tabName, tab in pairs(Tabs) do
            tab.Frame.Visible = (tabName == name)
            tab.Btn.BackgroundColor3 = tabName == name and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)
        end
    end)
    
    return content
end

-- Функция создания кнопки с состоянием
local function createToggleButton(parent, text, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 35)
    btn.Text = text .. (defaultState and ": ВКЛ" or ": ВЫКЛ")
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(120, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        local newState = not defaultState
        defaultState = newState
        btn.Text = text .. (newState and ": ВКЛ" or ": ВЫКЛ")
        btn.BackgroundColor3 = newState and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(120, 60, 60)
        callback(newState)
    end)
    
    return {Button = btn, State = defaultState}
end

-- Функция создания слайдера
local function createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 15)
    slider.Position = UDim2.new(0, 0, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 7)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 7)
    fillCorner.Parent = fill
    
    local value = default
    local dragging = false
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = UIS:GetMouseLocation()
            local relative = math.clamp((pos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * relative)
            fill.Size = UDim2.new(relative, 0, 1, 0)
            label.Text = text .. ": " .. value
            callback(value)
        end
    end)
    
    return {Value = value}
end

--// Вкладки
local movementTab = createTab("🚀 Движение")
local visualsTab = createTab("👁 Визуалы")
local grappleTab = createTab("🪢 Граппл")
local bindsTab = createTab("⌨️ Бинды")
local devTab = createTab("👨‍💻 Разработчик")

--// ПЕРЕМЕННЫЕ
local flying = false
local flySpeed = 50
local speedHackEnabled = false
local speedMultiplier = 50
local noclipEnabled = false
local espEnabled = false
local espNames = true
local espDistance = true
local grappling = false
local grappleSpeed = 100
local tpDistance = 500

-- Бинды по умолчанию (только меню)
local bindKeys = {
    Fly = nil,
    Speed = nil,
    Grapple = nil,
    Noclip = nil,
    ESP = nil
}

--// БЕЗОПАСНЫЙ ОБХОД
local function setupSafeBypass()
    -- Безопасный обход без хукметаметода
    RS.Heartbeat:Connect(function()
        if speedHackEnabled and hrp then
            -- Плавное сбрасывание velocity
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
        
        if flying and hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

--// ФУНКЦИИ
local flyConn, speedConn, noclipConn, espConn, grappleConn

function setFlying(state)
    flying = state
    if state then
        flyConn = RS.Heartbeat:Connect(function(dt)
            if not flying or not hrp or not hum or hum.Health <= 0 then return end
            
            local moveDirection = Vector3.new(0, 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * flySpeed
                hrp.CFrame = hrp.CFrame + moveDirection * dt
            end
            
            -- Безопасное сбрасывание velocity
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
    end
end

function setSpeed(state)
    speedHackEnabled = state
    if state then
        speedConn = RS.Heartbeat:Connect(function(dt)
            if not speedHackEnabled or not hum or not hrp then return end
            
            -- Безопасное изменение скорости
            hum.WalkSpeed = 16
            
            if hum.MoveDirection.Magnitude > 0 then
                local moveDir = hum.MoveDirection.Unit
                local additionalMove = moveDir * speedMultiplier * dt
                
                -- Применяем движение с проверкой коллизий
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                rayParams.FilterDescendantsInstances = {char}
                
                local rayResult = workspace:Raycast(hrp.Position, additionalMove, rayParams)
                
                if not rayResult then
                    hrp.CFrame = hrp.CFrame + additionalMove
                end
            end
            
            -- Безопасное сбрасывание velocity
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end)
    else
        if speedConn then speedConn:Disconnect() speedConn = nil end
        if hum then
            hum.WalkSpeed = 16
        end
    end
end

function setNoclip(state)
    noclipEnabled = state
    if state then
        noclipConn = RS.Stepped:Connect(function()
            if not noclipEnabled or not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end
end

function safeTP(distance)
    if not hrp then return end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {char}
    
    local steps = math.ceil(math.abs(distance) / 5)
    local stepSize = distance / steps
    
    for i = 1, steps do
        local newPos = hrp.Position + Vector3.new(0, stepSize, 0)
        local rayResult = workspace:Raycast(newPos, Vector3.new(0, -1000, 0), rayParams)
        
        if rayResult then
            hrp.CFrame = CFrame.new(newPos)
            task.wait(0.01)
        else
            break
        end
    end
end

local espObjects = {}
function updateESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
    
    if not espEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local char = player.Character
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if hum and hum.Health > 0 and root then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 50, 50)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.6
                highlight.Parent = char
                table.insert(espObjects, highlight)
                
                if espNames or espDistance then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 250, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
                    billboard.Adornee = root
                    billboard.AlwaysOnTop = true
                    billboard.Parent = char
                    
                    local text = player.Name
                    if espDistance and hrp then
                        local dist = (root.Position - hrp.Position).Magnitude
                        text = text .. " [" .. math.floor(dist) .. "m]"
                    end
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.Text = text
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.BackgroundTransparency = 0.4
                    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 14
                    label.Parent = billboard
                    
                    table.insert(espObjects, billboard)
                end
            end
        end
    end
end

function setESP(state)
    espEnabled = state
    if state then
        espConn = RS.Heartbeat:Connect(function()
            updateESP()
        end)
    else
        if espConn then espConn:Disconnect() espConn = nil end
        for _, obj in pairs(espObjects) do
            pcall(function() obj:Destroy() end)
        end
        espObjects = {}
    end
end

function setGrapple(state)
    grappling = state
    if state then
        grappleConn = RS.Heartbeat:Connect(function()
            if not grappling or not hrp then return end
            
            -- Граппл как спидхак
            if hum.MoveDirection.Magnitude > 0 then
                local moveDir = hum.MoveDirection.Unit
                local additionalMove = moveDir * grappleSpeed * 0.03
                
                -- Применяем движение
                hrp.CFrame = hrp.CFrame + additionalMove
                
                -- Безопасное сбрасывание velocity
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if grappleConn then grappleConn:Disconnect() grappleConn = nil end
    end
end

--// СОЗДАНИЕ ЭЛЕМЕНТОВ ИНТЕРФЕЙСА
local flyToggle = createToggleButton(movementTab, "Полёт", flying, function(state)
    flying = state
    setFlying(state)
end)

local flySpeedSlider = createSlider(movementTab, "Скорость полёта", 10, 200, flySpeed, function(value)
    flySpeed = value
end)

local speedToggle = createToggleButton(movementTab, "Скорость", speedHackEnabled, function(state)
    speedHackEnabled = state
    setSpeed(state)
end)

local speedSlider = createSlider(movementTab, "Множитель скорости", 10, 150, speedMultiplier, function(value)
    speedMultiplier = value
end)

local noclipToggle = createToggleButton(movementTab, "Ноклип", noclipEnabled, function(state)
    noclipEnabled = state
    setNoclip(state)
end)

local tpSlider = createSlider(movementTab, "Высота ТП", 10, 1000, tpDistance, function(value)
    tpDistance = value
    tpUpBtn.Text = "⬆️ ТП Вверх (" .. value .. "m)"
    tpDownBtn.Text = "⬇️ ТП Вниз (" .. value .. "m)"
end)

local tpUpBtn = Instance.new("TextButton")
tpUpBtn.Size = UDim2.new(0, 220, 0, 35)
tpUpBtn.Text = "⬆️ ТП Вверх (" .. tpDistance .. "m)"
tpUpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tpUpBtn.TextColor3 = Color3.new(1, 1, 1)
tpUpBtn.Font = Enum.Font.Gotham
tpUpBtn.TextSize = 14
tpUpBtn.Parent = movementTab

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 6)
tpCorner.Parent = tpUpBtn

tpUpBtn.MouseButton1Click:Connect(function()
    safeTP(tpDistance)
end)

local tpDownBtn = tpUpBtn:Clone()
tpDownBtn.Text = "⬇️ ТП Вниз (" .. tpDistance .. "m)"
tpDownBtn.Parent = movementTab
tpDownBtn.MouseButton1Click:Connect(function()
    safeTP(-tpDistance)
end)

local espToggle = createToggleButton(visualsTab, "ESP", espEnabled, function(state)
    espEnabled = state
    setESP(state)
end)

local namesToggle = createToggleButton(visualsTab, "Показывать имена", espNames, function(state)
    espNames = state
    if espEnabled then updateESP() end
end)

local distanceToggle = createToggleButton(visualsTab, "Показывать дистанцию", espDistance, function(state)
    espDistance = state
    if espEnabled then updateESP() end
end)

local grappleToggle = createToggleButton(grappleTab, "Граппл-спид", grappling, function(state)
    grappling = state
    setGrapple(state)
end)

local grappleSpeedSlider = createSlider(grappleTab, "Скорость граппла", 50, 300, grappleSpeed, function(value)
    grappleSpeed = value
end)

--// РАЗДЕЛ БИНДОВ
local bindLabels = {
    Fly = "Полёт",
    Speed = "Скорость",
    Grapple = "Граппл",
    Noclip = "Ноклип",
    ESP = "ESP"
}

local binding = false
local currentBinding = nil

local function createBindSetting(parent, name)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Text = bindLabels[name] .. ":"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 30)
    btn.Position = UDim2.new(1, -90, 0.5, -15)
    btn.Text = bindKeys[name] and bindKeys[name].Name or "Нет"
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        if not binding then
            binding = true
            currentBinding = name
            btn.Text = "..."
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        end
    end)
    
    return {Button = btn, Name = name}
end

local bindSettings = {}
local bindFrame = Instance.new("Frame")
bindFrame.Size = UDim2.new(1, 0, 0, 200)
bindFrame.BackgroundTransparency = 1
bindFrame.Parent = bindsTab

bindSettings.Fly = createBindSetting(bindFrame, "Fly")
bindSettings.Speed = createBindSetting(bindFrame, "Speed")
bindSettings.Grapple = createBindSetting(bindFrame, "Grapple")
bindSettings.Noclip = createBindSetting(bindFrame, "Noclip")
bindSettings.ESP = createBindSetting(bindFrame, "ESP")

-- Обработка назначения биндов
UIS.InputBegan:Connect(function(input)
    if binding and input.UserInputType == Enum.UserInputType.Keyboard then
        binding = false
        bindKeys[currentBinding] = input.KeyCode
        bindSettings[currentBinding].Button.Text = input.KeyCode.Name
        bindSettings[currentBinding].Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        currentBinding = nil
    end
    
    -- Обработка нажатий биндов
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        elseif bindKeys.Fly and input.KeyCode == bindKeys.Fly then
            flying = not flying
            setFlying(flying)
            flyToggle.Button.Text = "Полёт" .. (flying and ": ВКЛ" or ": ВЫКЛ")
            flyToggle.Button.BackgroundColor3 = flying and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(120, 60, 60)
        elseif bindKeys.Speed and input.KeyCode == bindKeys.Speed then
            speedHackEnabled = not speedHackEnabled
            setSpeed(speedHackEnabled)
            speedToggle.Button.Text = "Скорость" .. (speedHackEnabled and ": ВКЛ" or ": ВЫКЛ")
            speedToggle.Button.BackgroundColor3 = speedHackEnabled and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(120, 60, 60)
        elseif bindKeys.Grapple and input.KeyCode == bindKeys.Grapple then
            grappling = not grappling
            setGrapple(grappling)
            grappleToggle.Button.Text = "Граппл-спид" .. (grappling and ": ВКЛ" or ": ВЫКЛ")
            grappleToggle.Button.BackgroundColor3 = grappling and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(120, 60, 60)
        elseif bindKeys.Noclip and input.KeyCode == bindKeys.Noclip then
            noclipEnabled = not noclipEnabled
            setNoclip(noclipEnabled)
            noclipToggle.Button.Text = "Ноклип" .. (noclipEnabled and ": ВКЛ" or ": ВЫКЛ")
            noclipToggle.Button.BackgroundColor3 = noclipEnabled and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(120, 60, 60)
        elseif bindKeys.ESP and input.KeyCode == bindKeys.ESP then
            espEnabled = not espEnabled
            setESP(espEnabled)
            espToggle.Button.Text = "ESP" .. (espEnabled and ": ВКЛ" or ": ВЫКЛ")
            espToggle.Button.BackgroundColor3 = espEnabled and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(120, 60, 60)
        end
    end
end)

--// РАЗДЕЛ РАЗРАБОТЧИКА
local devFrame = Instance.new("Frame")
devFrame.Size = UDim2.new(1, 0, 1, 0)
devFrame.BackgroundTransparency = 1
devFrame.Parent = devTab

local devTitle = Instance.new("TextLabel")
devTitle.Size = UDim2.new(1, 0, 0, 30)
devTitle.Text = "👨‍💻 Разработчик"
devTitle.TextColor3 = Color3.new(1, 1, 1)
devTitle.Font = Enum.Font.GothamBold
devTitle.TextSize = 16
devTitle.BackgroundTransparency = 1
devTitle.Parent = devFrame

local devText = Instance.new("TextLabel")
devText.Size = UDim2.new(1, 0, 0, 100)
devText.Position = UDim2.new(0, 0, 0, 40)
devText.Text = "По вопросам и предложениям:\nTelegram: @mamkabotik\n\nЧит обновляется регулярно\nдля работы с последней версией игры."
devText.TextColor3 = Color3.new(1, 1, 1)
devText.Font = Enum.Font.Gotham
devText.TextSize = 14
devText.BackgroundTransparency = 1
devText.TextYAlignment = Enum.TextYAlignment.Top
devText.Parent = devFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 200, 0, 35)
copyBtn.Position = UDim2.new(0, 0, 0, 150)
copyBtn.Text = "📋 Скопировать Telegram"
copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Font = Enum.Font.Gotham
copyBtn.TextSize = 14
copyBtn.Parent = devFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 6)
copyCorner.Parent = copyBtn

copyBtn.MouseButton1Click:Connect(function()
    setclipboard("https://t.me/mamkabotik")
    copyBtn.Text = "✅ Скопировано!"
    wait(1)
    copyBtn.Text = "📋 Скопировать Telegram"
end)

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(0, 220, 0, 35)
unloadBtn.Position = UDim2.new(0, 0, 0, 200)
unloadBtn.Text = "❌ Выгрузить меню"
unloadBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
unloadBtn.TextColor3 = Color3.new(1, 1, 1)
unloadBtn.Font = Enum.Font.Gotham
unloadBtn.TextSize = 14
unloadBtn.Parent = devFrame

local unloadCorner = Instance.new("UICorner")
unloadCorner.CornerRadius = UDim.new(0, 6)
unloadCorner.Parent = unloadBtn

unloadBtn.MouseButton1Click:Connect(function()
    setFlying(false)
    setSpeed(false)
    setNoclip(false)
    setESP(false)
    setGrapple(false)
    ScreenGui:Destroy()
end)

--// АВТОМАТИЧЕСКОЕ ОБНОВЛЕНИЕ
lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
    hum = newChar:WaitForChild("Humanoid")
    
    if flying then setFlying(true) end
    if speedHackEnabled then setSpeed(true) end
    if noclipEnabled then setNoclip(true) end
    if grappling then setGrapple(true) end
    if espEnabled then setESP(true) end
end)

--// ЗАЩИТА ОТ ОШИБОК
RS.Heartbeat:Connect(function()
    if not char or not char.Parent then
        char = lp.Character
        if char then
            hrp = char:FindFirstChild("HumanoidRootPart")
            hum = char:FindFirstChild("Humanoid")
        end
    end
    
    if hum and hum.Health <= 0 then
        setFlying(false)
        setSpeed(false)
        setGrapple(false)
    end
end)

--// ИНИЦИАЛИЗАЦИЯ
setupSafeBypass()
Tabs["🚀 Движение"].Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Tabs["🚀 Движение"].Frame.Visible = true
end

-- Инициализация системы ключей
function KeySystem.init()
    -- Очищаем старые GUI
    clearOldGUIs()
    
    -- Создаём GUI ключ-системы
    local gui = createGUI()
    
    gui.SubmitButton.MouseButton1Click:Connect(function()
        local key = gui.InputBox.Text
        gui.StatusLabel.Text = "Проверка ключа..."
        gui.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        local success, message = KeySystem.validate(key)
        
        if success then
            gui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            gui.StatusLabel.Text = "✓ " .. message
            wait(2)
            gui.ScreenGui:Destroy()
            launchMainMenu()
            print("Чит успешно активирован!")
        else
            gui.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            gui.StatusLabel.Text = "✗ " .. message
        end
    end)
end

-- Автозапуск системы
KeySystem.init()

return KeySystem
