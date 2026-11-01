--[[
    KeyAuth Loader (API 1.3) для cloudclient (POST Request)
]]
local APP_NAME = "clientsound"  -- Название приложения с твоего скрина
local OWNER_ID = "uXkNMViDLi"   -- Твой ACCOUNT OWNER ID
local API_KEY  = "6a95279f8ec58a0a69a4abb0cf1ca9e8cc63b4e9e25865cbfe9b054a8006973c" -- APPLICATION SECRET
local VERSION  = "1.0"

local VantixUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neverisUI2.lua"))()

-- ===== ФУНКЦИЯ ЗАПРОСА К KEYAUTH (POST) =====
local function apiRequest(params)
    local body = ""
    for k, v in pairs(params) do
        body = body .. k .. "=" .. tostring(v) .. "&"
    end
    body = body:sub(1, -2)
    
    local success, res = pcall(function()
        -- В Xeno обычно доступен syn.request или http.request
        if syn and syn.request then
            return syn.request({
                Url = "https://keyauth.win/api/1.3/",
                Method = "POST",
                Body = body,
                Headers = {["Content-Type"] = "application/x-www-form-urlencoded"}
            }).Body
        elseif http and http.request then
            return http.request({
                Url = "https://keyauth.win/api/1.3/",
                Method = "POST",
                Body = body,
                Headers = {["Content-Type"] = "application/x-www-form-urlencoded"}
            }).Body
        elseif request then
            return request({
                Url = "https://keyauth.win/api/1.3/",
                Method = "POST",
                Body = body
            }).Body
        else
            -- Если POST нет, пробуем GET
            return game:HttpGet("https://keyauth.win/api/1.3/?" .. body)
        end
    end)
    
    if not success or not res then return nil end
    
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
                status:Set("Ошибка Init: " .. tostring(init and init.message or "Нет ответа"), "info")
                return
            end
            
            -- 2. Проверка лицензии
            local hwid = "unknown"
            pcall(function()
                hwid = game:GetService("RbxAnalyticsService"):GetClientId()
            end)
            
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
                -- Если ошибка все еще про OwnerID, значит ключи из панели не подходят
                status:Set("Неверный ключ: " .. tostring(login and login.message or "Invalid"), "info")
            end
        end)
    end,
})
