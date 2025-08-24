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

-- Создание красивого интерфейса
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

    -- Градиентный фон
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    gradient.Rotation = 45
    gradient.Parent = mainFrame

    -- Тень
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

    -- Заголовок
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

    -- Логотип
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 40, 0, 40)
    logo.Position = UDim2.new(0, 15, 0, 10)
    logo.BackgroundTransparency = 1
    logo.Image = CONFIG.LOGO_URL
    logo.Parent = title

    -- Поле ввода ключа
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

    -- Кнопка активации
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

    -- Анимация кнопки
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

    -- Статус
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

    -- Контакты разработчика
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

-- Инициализация системы ключей
function KeySystem.init()
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
            -- Здесь запускайте ваш чит
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
