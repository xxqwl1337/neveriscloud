--[[
    KeyAuth Loader (через официальную Roblox-библиотеку)
]]
local APP_NAME = "clientsound"
local OWNER_ID = "uXkNMViDLi"
local VERSION  = "1.0"

-- Загружаем официальную KeyAuth библиотеку для Roblox
local KeyAuth = loadstring(game:HttpGet("https://raw.githubusercontent.com/KeyAuth/KeyAuth-Roblox-Example/main/keyauth.lua"))()

-- Инициализируем
KeyAuth.app_data = {
    name = APP_NAME,
    ownerid = OWNER_ID,
    version = VERSION
}

local VantixUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neverisUI2.lua"))()

-- ===== МЕНЮ =====
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
            local hwid = "unknown"
            pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
            
            -- 1. Инициализация
            local init = KeyAuth.init()
            if not init then
                status:Set("Ошибка: KeyAuth не инициализировался", "info")
                return
            end
            
            -- 2. Проверка ключа
            local login = KeyAuth.license(key)
            if login then
                status:Set("Активация успешна!", "info")
                Window:Notify({ Title = "Success", Text = "Загрузка cloudclient...", Icon = "check", Duration = 2 })
                task.wait(1)
                Window:Destroy()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neveriscloud.lua?t=" .. os.time()))()
            else
                status:Set("Неверный ключ!", "info")
            end
        end)
    end,
})
