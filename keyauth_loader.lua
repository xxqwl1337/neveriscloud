--[[
    CLOUDCLIENT — Key System (Без таймера в лоадере)
]]
local VantixUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neverisUI2.lua"))()

-- ===== БАЗА КЛЮЧЕЙ =====
local ValidKeys = {
    ["KEYAUTH-JmXl4r-4Te4Yv-We7tcT-U1hzqU-Pvkpuc-eztXLy"] = true,
    ["TEST-KEY-DEMO"] = true
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
            if not ValidKeys[key] then
                status:Set("Неверный ключ!", "info")
                return
            end
            
            -- ТУТ МЫ ПРОСТО ПЕРЕДАЕМ ФЕЙКОВОЕ ВРЕМЯ (30 ДНЕЙ), ЧТОБЫ В НАСТРОЙКАХ ПИСАЛО КРАСИВО
            getgenv().CloudClientExpireTime = os.time() + 2592000 -- 30 дней
            getgenv().CloudClientKey = key
            
            status:Set("Активация успешна!", "info")
            Window:Notify({ Title = "Success", Text = "Загрузка...", Icon = "check", Duration = 2 })
            task.wait(1)
            Window:Destroy()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neveriscloud.lua?t=" .. os.time()))()
        end)
    end,
})
