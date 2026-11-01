--[[
    Система ключей через GitHub Gist (с таймером)
]]
local KEYS_URL = "ВСТАВЬ_СЮДА_ССЫЛКУ_RAW_ИЗ_ШАГА_1"

local VantixUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neverisUI2.lua"))()

local Window = VantixUI:CreateWindow({
    Title = "cloudclient | Activation",
    Theme = "Vantix",
    AccentColor = Color3.fromRGB(255, 255, 255),
    LogoID = 110034487018208,
    Size = {380, 260},
})

local MainTab = Window:AddTab("Activation", "key")

local status = MainTab:AddLabel("Введите ключ", "info")
local keyBox = MainTab:AddTextBox({
    Title = "License Key",
    Placeholder = "XXXX-XXXX-XXXX",
    Default = "",
})

MainTab:AddButton({
    Title = "Activate",
    Text = "Activate",
    Icon = "key",
    Callback = function()
        local key = keyBox:Get()
        if not key or key == "" then
            status:Set("Введи ключ", "info")
            return
        end
        status:Set("Проверка...", "info")
        
        task.spawn(function()
            -- Скачиваем список ключей (добавляем ?t=os.time(), чтобы не кэшировалось)
            local success, keysList = pcall(function()
                return game:HttpGet(KEYS_URL .. "?t=" .. os.time())
            end)
            
            if not success or not keysList then
                status:Set("Ошибка: нет связи с GitHub", "info")
                return
            end
            
            local found = false
            local expireTime = 0
            
            -- Ищем ключ в списке
            for line in keysList:gmatch("[^\r\n]+") do
                local parts = {}
                for part in string.gmatch(line, "([^|]+)") do
                    table.insert(parts, part)
                end
                
                if #parts >= 2 then
                    local cleanKey = parts[1]:match("^%s*(.-)%s*$")
                    local timeStr = parts[2]:match("^%s*(.-)%s*$")
                    
                    if cleanKey == key then
                        found = true
                        expireTime = tonumber(timeStr) or 0
                        break
                    end
                end
            end
            
            if not found then
                status:Set("Неверный ключ!", "info")
                return
            end
            
            -- Проверка времени
            local now = os.time()
            if now > expireTime then
                status:Set("Срок действия ключа истек!", "info")
                return
            end
            
            -- Успех
            status:Set("Активация успешна!", "info")
            Window:Notify({ Title = "Success", Text = "Загрузка cloudclient...", Icon = "check", Duration = 2 })
            task.wait(1)
            Window:Destroy()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neveriscloud.lua?t=" .. os.time()))()
        end)
    end,
})
