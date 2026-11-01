--[[
    CLOUDCLIENT — Key System (С таймером)
]]
local VantixUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neverisUI2.lua"))()

-- ===== БАЗА КЛЮЧЕЙ (С ДАТОЙ) =====
-- Формат: ["КЛЮЧ"] = Время_окончания
-- 1767225600 = 1 Января 2026 (можешь поменять на другую цифру)
local ValidKeys = {
    ["KEYAUTH-JmXl4r-4Te4Yv-We7tcT-U1hzqU-Pvkpuc-eztXLy"] = 1767225600,
    ["TEST-KEY-DEMO"] = 1767225600
}

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
            local expireTime = ValidKeys[key]
            
            -- 1. Если ключа нет в базе
            if not expireTime then
                status:Set("Неверный ключ!", "info")
                return
            end
            
            -- 2. Проверка срока действия
            local now = os.time()
            if now > expireTime then
                status:Set("Срок действия ключа истек!", "info")
                return
            end
            
            -- 3. Всё ок
            status:Set("Активация успешна!", "info")
            Window:Notify({ Title = "Success", Text = "Загрузка...", Icon = "check", Duration = 2 })
            task.wait(1)
            Window:Destroy()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neveriscloud.lua?t=" .. os.time()))()
        end)
    end,
})
