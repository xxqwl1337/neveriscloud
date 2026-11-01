--[[
    CLOUDCLIENT — Key System (Без таймера)
]]
local VantixUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neveriscloud.lua"))()

-- ===== БАЗА КЛЮЧЕЙ =====
-- Просто список ключей. Если ключ есть в списке - пускает. Если удалить - не пускает.
local ValidKeys = {
    ["KEYAUTH-JmXl4r-4Te4Yv-We7tcT-U1hzqU-Pvkpuc-eztXLy"] = true,
    ["TEST-KEY-DEMO"] = true,
    ["VIP-KEY-2026"] = true
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
        
        if not key or key == "" then
            status:Set("Пожалуйста, введите ключ", "info")
            return
        end
        
        status:Set("Проверка...", "info")
        
        task.spawn(function()
            -- Проверяем только наличие ключа в списке (без дат)
            if not ValidKeys[key] then
                status:Set("Неверный ключ!", "info")
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
