--[[
    KeyAuth Loader (API 1.3) для cloudclient
]]
local APP_NAME = "clientsound"  -- Название приложения с твоего скрина
local OWNER_ID = "uXkNMViDLi" -- Твой ID (скопируй из панели)
local API_KEY  = "6a95279f8ec58a0a69a4abb0cf1ca9e8cc63b4e9e25865cbfe9b054a8006973c"  -- Если есть, если нет - оставь пустым ""
local VERSION  = "1.0"

local VantixUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neverisUI2.lua"))()

-- ===== ФУНКЦИЯ ЗАПРОСА К KEYAUTH 1.3 =====
local function apiRequest(params)
    local query = ""
    for k, v in pairs(params) do
        query = query .. k .. "=" .. tostring(v) .. "&"
    end
    query = query:sub(1, -2)
    
    -- В API 1.3 используется POST через HttpPost (если поддерживается экзекутором)
    -- Если нет - через GET
    local ok, res = pcall(function()
        return game:HttpGet("https://keyauth.win/api/1.3/?" .. query)
    end)
    
    if not ok or not res then return nil end
    local succ, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(res)
    end)
    return succ and decoded or nil
end

-- ===== МЕНЮ АКТИВАЦИИ =====
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
            -- 1. Инициализация сессии
            local init = apiRequest({
                type = "init",
                ver = VERSION,
                name = APP_NAME,
                ownerid = OWNER_ID,
                api_key = API_KEY,
            })
            
            if not init or not init.success then
                status:Set("Ошибка Init: " .. tostring(init and init.message or "Unknown"), "info")
                return
            end
            
            -- 2. Проверка лицензии
            local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
            local login = apiRequest({
                type = "license",
                key = key,
                sessionid = init.sessionid,
                hwid = hwid,
                api_key = API_KEY,
            })
            
            if login and login.success then
                status:Set("Активация успешна!", "info")
                Window:Notify({ Title = "Success", Text = "Загрузка cloudclient...", Icon = "check", Duration = 2 })
                task.wait(1)
                Window:Destroy()
                
                -- Загрузка основного скрипта
                loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neveriscloud.lua?t=" .. os.time()))()
            else
                status:Set("Неверный ключ: " .. tostring(login and login.message or "Invalid"), "info")
            end
        end)
    end,
})
