--// KeySystem.lua
local KeySystem = {}
KeySystem.__index = KeySystem

-- Конфиг
local CONFIG = {
    GITHUB_RAW_URL = "https://raw.githubusercontent.com/HappyProgs/fkdsfk/refs/heads/main/keys.json", -- ссылка на json с ключами
    SAVE_FILE = "ultrahack_key.txt", -- имя файла для сохранения ключа
}

-- Проверка формата ключа
local function validateKeyFormat(key)
    return key and type(key) == "string" and #key >= 3
end

-- Забираем ключи с GitHub
local function fetchKeysFromGitHub()
    local success, result = pcall(function()
        return game:HttpGet(CONFIG.GITHUB_RAW_URL, true)
    end)
    if success and result then
        return game:GetService("HttpService"):JSONDecode(result)
    end
    return nil
end

-- Проверка истечения
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

-- Валидация ключа
function KeySystem.validate(key)
    if not validateKeyFormat(key) then
        return false, "Неверный формат ключа"
    end

    local keysData = fetchKeysFromGitHub()
    if not keysData then
        return false, "Ошибка загрузки ключей"
    end

    local keyData = keysData[key]
    if not keyData then
        return false, "Недействительный ключ"
    end

    if keyData.expires and isKeyExpired(keyData.expires) then
        return false, "Ключ истёк"
    end

    return true, keyData.expires and ("Действует до " .. keyData.expires) or "Постоянный ключ"
end

-- Сохраняем ключ
local function saveKey(key)
    if writefile then
        writefile(CONFIG.SAVE_FILE, key)
    end
end

-- Загружаем ключ
local function loadKey()
    if isfile and isfile(CONFIG.SAVE_FILE) then
        return readfile(CONFIG.SAVE_FILE)
    end
    return nil
end

-- GUI для ввода
local function createGUI(onKeySuccess)
    local player = game.Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeySystemGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 220)
    frame.Position = UDim2.new(0.5, -200, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Введите ключ"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 22
    title.Parent = frame

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 300, 0, 40)
    input.Position = UDim2.new(0.5, -150, 0, 60)
    input.PlaceholderText = "Введите ключ..."
    input.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 300, 0, 40)
    button.Position = UDim2.new(0.5, -150, 0, 110)
    button.Text = "Активировать"
    button.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 300, 0, 40)
    status.Position = UDim2.new(0.5, -150, 0, 160)
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(200,200,200)
    status.BackgroundTransparency = 1
    status.Parent = frame

    button.MouseButton1Click:Connect(function()
        local key = input.Text
        status.Text = "Проверка..."
        local success, msg = KeySystem.validate(key)
        if success then
            status.Text = "✅ " .. msg
            status.TextColor3 = Color3.fromRGB(100,255,100)
            saveKey(key)
            task.wait(1)
            screenGui:Destroy()
            onKeySuccess()
        else
            status.Text = "✗ " .. msg
            status.TextColor3 = Color3.fromRGB(255,100,100)
        end
    end)
end

-- Запуск
function KeySystem.init(onKeySuccess)
    local saved = loadKey()
    if saved then
        local success, msg = KeySystem.validate(saved)
        if success then
            print("Ключ уже сохранён: " .. msg)
            onKeySuccess()
            return
        else
            warn("Старый ключ не подходит: " .. msg)
        end
    end
    createGUI(onKeySuccess)
end

return KeySystem
