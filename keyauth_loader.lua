--[[
    KeyAuth Loader (Universal) для cloudclient
]]
local APP_NAME = "clientsound"
local OWNER_ID = "uXkNMViDLi" 
local VERSION  = "1.0"

local VantixUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neverisUI2.lua"))()

-- ===== ФУНКЦИЯ ЗАПРОСА =====
local function apiRequest(params)
    local body = ""
    for k, v in pairs(params) do
        body = body .. k .. "=" .. tostring(v) .. "&"
    end
    body = body:sub(1, -2)
    
    local urls = {
        "https://keyauth.cc/api/1.3/",
        "https://keyauth.win/api/1.3/"
    }
    
    for _, url in ipairs(urls) do
        local success, res = pcall(function()
            if syn and syn.request then
                return syn.request({
                    Url = url,
                    Method = "POST",
                    Body = body,
                    Headers = {["Content-Type"] = "application/x-www-form-urlencoded"}
                }).Body
            elseif http and http.request then
                return http.request({
                    Url = url,
                    Method = "POST",
                    Body = body
                }).Body
            else
                return game:HttpGet(url .. "?" .. body)
            end
        end)
        
        if success and res then
            print("[KeyAuth Debug] Ответ от " .. url .. ": " .. res)
            local succ, decoded = pcall(function()
                return game:GetService("HttpService"):JSONDecode(res)
            end)
            if succ and decoded then return decoded end
        else
            warn("[KeyAuth Debug] Ошибка запроса к " .. url .. ": " .. tostring(res))
        end
    end
    return nil
end

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
            -- 1. Инициализация (в новых версиях API 1.3 api_key не нужен)
            local init = apiRequest({
                type = "init",
                ver = VERSION,
                name = APP_NAME,
                ownerid = OWNER_ID,
            })
            
            if not init then
                status:Set("Ошибка: сервера KeyAuth недоступны (блок в Xeno)", "info")
                return
            end
            
            if not init.success then
                status:Set("Ошибка Init: " .. tostring(init.message or "Unknown"), "info")
                return
            end
            
            -- 2. Проверка ключа
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
                loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neveriscloud.lua?t=" .. os.time()))()
            else
                local msg = login and login.message or "Нет ответа от сервера"
                status:Set("Неверный ключ: " .. tostring(msg), "info")
            end
        end)
    end,
})
