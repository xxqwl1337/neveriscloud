--[[
    CLOUDCLIENT — Key System (Hardcoded)
]]

local VantixUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neverisUI2.lua"))()

-- ===== БАЗА КЛЮЧЕЙ =====
-- Формат: ["КЛЮЧ"] = Время_окончания (Unix Timestamp)
-- 1767225600 = 1 Января 2026 (это ~30 дней с текущего момента)
local ValidKeys = {
    ["KEYAUTH-JmXl4r-4Te4Yv-We7tcT-U1hzqU-Pvkpuc-eztXLy"] = 2082758400, -- 1 января 2036
    ["TEST-KEY-DEMO"] = 2082758400
}

-- ===== МЕНЮ АКТИВАЦИИ =====
local Window = VantixUI:CreateWindow({
    Title = "cloudclient | Activation",
    Theme = "Vantix",
    AccentColor = Color3.fromRGB(255, 255, 255),
    LogoID = 110034487018208,
    Size = {380, 260},
})

local MainTab = Window:AddTab("Activation", "key")

local status = MainTab:AddLabel("Введите ключ для доступа", "info")
local keyBox = MainTab:AddTextBox({
    Title = "License Key",
    Placeholder = "XXXX-XXXX-XXXX-XXXX",
    Default = "",
})

MainTab:AddButton({
    Title = "Activate",
    Text = "Activate",
    Icon = "key",
    Callback = function()
        local key = keyBox:Get()
        
        -- Проверка на пустоту
        if not key or key == "" then
            status:Set("Пожалуйста, введите ключ", "info")
            return
        end
        
        status:Set("Проверка...", "info")
        
        task.spawn(function()
            -- Ищем ключ в нашей базе
            local expireTime = ValidKeys[key]
            
            if not expireTime then
                status:Set("Неверный ключ!", "info")
                return
            end
            
            -- Проверяем, не истек ли срок
            local currentTime = os.time()
            if currentTime > expireTime then
                status:Set("Срок действия ключа истек!", "info")
                return
            end
            
            -- Если всё ок
            status:Set("Активация успешна!", "info")
            Window:Notify({ 
                Title = "Success", 
                Text = "Загрузка cloudclient...", 
                Icon = "check", 
                Duration = 2 
            })
            
            task.wait(1)
            Window:Destroy()
            
            -- Запускаем основной скрипт
            loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neveriscloud.lua?t=" .. os.time()))()
        end)
    end,
})
