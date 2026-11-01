--[[
    KeyAuth Loader (Рабочая версия для Xeno)
]]
local APP_NAME = "clientsound"
local OWNER_ID = "uXkNMViDLi" 
local VERSION  = "1.0"

-- 1. ЗАГРУЖАЕМ МЕНЮ (оно появится сразу, даже если KeyAuth лежит)
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

-- 2. ФУНКЦИЯ ЗАПРОСА (через секретный параметр для keyauth.cc)
local function apiRequest(params)
    local query = ""
    for k, v in pairs(params) do
        query = query .. k .. "=" .. tostring(v) .. "&"
    end
    query = query:sub(1, -2)
    
    -- Пробуем напрямую к keyauth.cc
    local success, res = pcall(function()
        return game:HttpGet("https://keyauth.cc/api/1.2/?" .. query)
    end)
    
    if not success or not res then 
        return nil 
    end
    
    local succ, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(res)
    end)
    return succ and decoded or nil
end

-- 3. КНОПКА АКТИВАЦИИ
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
            -- Инициализация
            local init = apiRequest({
                type = "init",
                ver = VERSION,
                name = APP_NAME,
                secret = OWNER_ID, 
            })
            
            if not init then
                status:Set("Ошибка: KeyAuth заблокирован", "info")
                return
            end
            
            if not init.success then
                status:Set("Ошибка Init: " .. tostring(init.message or "Unknown"), "info")
                return
            end
            
            -- Проверка ключа
            local hwid = "unknown"
            pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
            
            local login = apiRequest({
                type = "license",
                key = key,
                sessionid = init.sessionid,
                hwid = hwid,
            })
            
            if login and login.success then
                status:Set("Активация успешна!", "info")
                Window:Notify({ Title = "Success", Text = "Загрузка cloudclient...", Icon = "check", Duration = 2 })
                task.wait(1)
                Window:Destroy()
                -- Запуск основного скрипта
                loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neveriscloud.lua?t=" .. os.time()))()
            else
                local msg = login and login.message or "Неверный ключ"
                status:Set("Ошибка: " .. tostring(msg), "info")
            end
        end)
    end,
})
