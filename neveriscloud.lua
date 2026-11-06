--[[
    VELCLOUD.XD — Aimbot + Visuals + FreeCam + Crosshair + Config
    Архитектура: Табличная (_G.CC)
    BUILD: v0.7.1 (Anti-Kick Update)
]]

-- ===== ГЛАВНАЯ ТАБЛИЦА =====
_G.CC = {
    Flags = {},
    UI = { Tabs = {}, Elements = {} },
    Refs = {},
    Lib = nil
}

local CC = _G.CC
local Flags = CC.Flags
local UI = CC.UI

-- ===== KEY SYSTEM =====
local KEY_FILE = "velcloud_key.txt"
local MY_USERID = tostring(game:GetService("Players").LocalPlayer.UserId)
local MY_VERSION = "0.7.1"

_G.VelcloudKeyState = { key = nil, name = nil, valid = false, reason = "не активирован", expires = 0 }

local function simpleHash(str)
    local hash = 0
    for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 2147483647
    end
    return tostring(hash)
end

local function fetchKeys()
    local randomBuster = math.random(100000, 999999)
    local API_URL = "https://api.github.com/repos/xxqwl1337/neveriscloud/contents/keys.json?ref=main&t=" .. os.time() .. "&r=" .. randomBuster
    local success, data = pcall(function() return game:HttpGet(API_URL) end)
    if not success or not data then return nil end
    local decodeSuccess, json = pcall(function() return game:GetService("HttpService"):JSONDecode(data) end)
    if not decodeSuccess or not json or not json.content then return nil end
    local ok, decodedContent = pcall(function() return game:GetService("HttpService"):Base64Decode((json.content:gsub("%s+", ""))) end)
    if not ok or not decodedContent then return nil end
    local keysSuccess, keys = pcall(function() return game:GetService("HttpService"):JSONDecode(decodedContent) end)
    if not keysSuccess or not keys then return nil end
    return keys
end

local function validateKey(k, keys)
    if not k or k == "" then return false, "Пустой ключ", false end
    local entry = keys[k]
    if not entry then return false, "Ключ не найден (удален или неверный)", false end
    if entry.expires ~= 0 and os.time and os.time() > entry.expires then return false, "Срок ключа истёк", true end
    if entry.min_version then
        local current = tonumber((MY_VERSION:gsub("v", "")))
        local required = tonumber((tostring(entry.min_version):gsub("v", "")))
        if current and required and current < required then return false, "Обновите скрипт до v" .. tostring(entry.min_version), true end
    end
    if entry.hwid and entry.hwid ~= "" then
        if entry.hwid == "BANNED" then return false, "Ключ забанен", true end
        if entry.hwid ~= MY_USERID then return false, "Ключ привязан к другому аккаунту", true end
    end
    return true, entry, false
end

local function formatExpires(expires)
    if not expires or expires == 0 then return "бессрочно" end
    local ok, dateStr = pcall(function() return os.date("%d.%m.%y (%H:%M)", expires) end)
    return ok and dateStr or "неизвестно"
end

local function saveSessionKey(k, uid, expires)
    if not writefile then return end
    local token = simpleHash(k .. uid)
    pcall(writefile, KEY_FILE, token .. "|" .. uid .. "|" .. tostring(expires or 0) .. "|" .. k)
end

local function loadSessionKey()
    if not (isfile and readfile) then return nil, nil, nil, nil end
    local ok, data = pcall(function() if isfile(KEY_FILE) then return readfile(KEY_FILE) end end)
    if ok and data then 
        local parts = string.split(data:gsub("%s+", ""), "|")
        if #parts >= 4 then return parts[1], parts[2], tonumber(parts[3] or 0), parts[4] end
    end
    return nil, nil, nil, nil
end

local function deleteSavedKey()
    if isfile and delfile then pcall(function() if isfile(KEY_FILE) then delfile(KEY_FILE) end end) end
end

local function promptForKey()
    local sg = Instance.new("ScreenGui")
    sg.Name = "VelcloudPrompt_" .. math.random(1e6)
    sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true; sg.DisplayOrder = 999
    sg.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(400, 260); frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5); frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    frame.BorderSizePixel = 0; frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(60, 60, 60); stroke.Thickness = 1
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 0, 28); title.Position = UDim2.fromOffset(12, 12)
    title.BackgroundTransparency = 1; title.Text = "velcloud.xd — введи ключ"
    title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.BuilderSansBold; title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = frame
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -24, 0, 36); box.Position = UDim2.fromOffset(12, 52)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30); box.TextColor3 = Color3.new(1,1,1)
    box.PlaceholderText = "CLOUD-XXXX-XXXX"; box.PlaceholderColor3 = Color3.fromRGB(120,120,120)
    box.Font = Enum.Font.Code; box.TextSize = 14; box.ClearTextOnFocus = false; box.Text = ""
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.6, -12, 0, 36); btn.Position = UDim2.fromOffset(12, 100)
    btn.BackgroundColor3 = Color3.fromRGB(80, 200, 120); btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.BuilderSansBold; btn.TextSize = 14; btn.Text = "Активировать"; btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.4, -12, 0, 36); cancelBtn.Position = UDim2.fromOffset(12 + (0.6 * 400), 100)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); cancelBtn.TextColor3 = Color3.new(1,1,1)
    cancelBtn.Font = Enum.Font.BuilderSansBold; cancelBtn.TextSize = 14; cancelBtn.Text = "Отмена"; cancelBtn.Parent = frame
    Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -24, 0, 40); status.Position = UDim2.fromOffset(12, 148)
    status.BackgroundTransparency = 1; status.Text = ""; status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Font = Enum.Font.BuilderSansMedium; status.TextSize = 12; status.TextWrapped = true
    status.TextXAlignment = Enum.TextXAlignment.Left; status.Parent = frame
    
    local result = nil; local failCount = 0; local isLocked = false
    
    local function tryActivate()
        if isLocked then return end
        local k = box.Text
        if not k or k == "" then status.Text = "Введи ключ!"; status.TextColor3 = Color3.fromRGB(255, 100, 100); return end
        status.Text = "Проверка..."; status.TextColor3 = Color3.fromRGB(255, 255, 100)
        local keys = fetchKeys()
        if not keys then status.Text = "Ошибка: не удалось скачать ключи"; status.TextColor3 = Color3.fromRGB(255, 100, 100); return end
        local ok, entryOrReason, hardFail = validateKey(k, keys)
        if ok then
            status.Text = "Успешный вход: " .. tostring(entryOrReason.name) .. "!"; status.TextColor3 = Color3.fromRGB(100, 255, 100)
            result = k; task.wait(1); sg:Destroy()
        else
            status.Text = "отказ: " .. tostring(entryOrReason); status.TextColor3 = Color3.fromRGB(255, 100, 100); box.Text = ""
            if hardFail then warn("[velcloud.xd] Ключ отклонён (hard): " .. tostring(entryOrReason))
            else
                failCount = failCount + 1
                if failCount >= 3 then
                    isLocked = true; status.Text = "Слишком много попыток. Ждите 30 сек..."; task.wait(30)
                    isLocked = false; failCount = 0; status.Text = "Можно попробовать снова"
                end
            end
        end
    end
    
    btn.MouseButton1Click:Connect(tryActivate)
    box.FocusLost:Connect(function(enter) if enter then tryActivate() end end)
    cancelBtn.MouseButton1Click:Connect(function() sg:Destroy(); result = "CANCEL" end)

    while sg.Parent and not result do task.wait(0.1) end
    return result
end

local function quickLocalCheck()
    local savedHash, savedUid, savedExpires, savedKey = loadSessionKey()
    if not savedHash or not savedUid or not savedKey then return false end
    if savedUid ~= MY_USERID then return false end
    if savedExpires and savedExpires ~= 0 and os.time() > savedExpires then return false end
    return true, savedExpires, savedKey
end

local function requireKey()
    local isQuickOk, localExpires, savedKey = quickLocalCheck()
    if isQuickOk then
        local keys = fetchKeys()
        if not keys then 
            warn("[velcloud.xd] Нет интернета. Запуск в оффлайн-режиме.")
            _G.VelcloudKeyState = { key = nil, name = "Offline", valid = true, reason = "OK", expires = localExpires }; return true 
        end
        local ok, entryOrReason = validateKey(savedKey, keys)
        if ok then _G.VelcloudKeyState = { key = nil, name = entryOrReason.name, valid = true, reason = "OK", expires = entryOrReason.expires }; saveSessionKey(savedKey, MY_USERID, entryOrReason.expires); return true
        else print("[velcloud.xd] Сохраненный ключ отклонён сервером: " .. tostring(entryOrReason)); deleteSavedKey() end
    end
    
    local keys = fetchKeys()
    if not keys then 
        warn("[velcloud.xd] Не удалось скачать ключи с GitHub. Принудительный оффлайн-режим.")
        _G.VelcloudKeyState = { key = nil, name = "Offline", valid = true, reason = "OK", expires = 0 }
        return true 
    end
    
    local savedHash, savedUid, savedExpires, savedKey2 = loadSessionKey()
    if savedHash and savedUid and savedKey2 then
        if savedUid ~= MY_USERID then print("[velcloud.xd] Файл ключа принадлежит другому аккаунту. Удаляем."); deleteSavedKey()
        else
            local ok, entryOrReason = validateKey(savedKey2, keys)
            if ok then _G.VelcloudKeyState = { key = nil, name = entryOrReason.name, valid = true, reason = "OK", expires = entryOrReason.expires }; saveSessionKey(savedKey2, MY_USERID, entryOrReason.expires); return true
            else deleteSavedKey() end
        end
    end
    
    local entered = promptForKey()
    if not entered or entered == "CANCEL" then 
        _G.VelcloudKeyState = { key = nil, name = nil, valid = false, reason = "отменено", expires = 0 }; 
        return false 
    end
    
    keys = fetchKeys() or keys
    local ok, entry = validateKey(entered, keys)
    if ok then saveSessionKey(entered, MY_USERID, entry.expires); _G.VelcloudKeyState = { key = nil, name = entry.name, valid = true, reason = "OK", expires = entry.expires }; return true
    else print("[velcloud.xd] Ключ отклонён: " .. tostring(entry)); deleteSavedKey(); return false end
end

-- ТУТ УБРАН KICK, ПРОСТО RETURN
if not requireKey() then return end

local function keyRemainingText()
    local st = _G.VelcloudKeyState
    if not st or not st.valid then return "нет ключа" end
    if not st.expires or st.expires == 0 then return "бессрочно" end
    if st.expires - os.time() <= 0 then return "истёк" end
    return formatExpires(st.expires)
end
-- ===== END KEY SYSTEM =====

-- ===== ИНИЦИАЛИЗАЦИЯ БИБЛИОТЕКИ =====
CC.Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/main/neverisUI2.lua"))()

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Stats       = game:GetService("Stats")
local Lighting    = game:GetService("Lighting")
local LP          = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local Mouse       = LP:GetMouse()

UI.Window = CC.Lib:CreateWindow({
    Title = "velcloud.xd", Theme = "Velcloud", AccentColor = Color3.fromRGB(50, 100, 220),
    LogoID = 110034487018208, Size = {820, 480},
})
UI.Window:CreateTag("Rust Decoy", Color3.fromRGB(235, 80, 80), nil, "gamepad-2")
UI.Window:CreateTag("v0.7.1", Color3.fromRGB(150, 150, 150), nil, "git-branch")
UI.Window:CreateTag("Beta", Color3.fromRGB(235, 190, 60), nil, "flask-conical")
UI.Window:Notify({ Title = "Welcome", Text = "velcloud.xd v0.7.1 loaded", Icon = "check", Duration = 4 })

-- ===== СОСТОЯНИЕ =====
Flags.ESP = false; Flags.ESPMode = "Chams"
Flags.ESP_Sleeper = false
Flags.TeamCheck = true

Flags.ESPColor      = Color3.fromRGB(255, 0, 0)
Flags.SleeperColor  = Color3.fromRGB(0, 200, 255)
Flags.BoxColor      = Color3.fromRGB(255, 255, 255)
Flags.TextColor     = Color3.fromRGB(255, 255, 255)
Flags.LineColor     = Color3.fromRGB(255, 0, 0)
Flags.SkeletonColor = Color3.fromRGB(69, 0, 0)
Flags.TeamColor     = Color3.fromRGB(0, 255, 0)
Flags.NPCColor      = Color3.fromRGB(255, 165, 0)
Flags.AnimalColor   = Color3.fromRGB(255, 20, 147)

Flags.Box = false; Flags.Distance = false; Flags.Name = false; Flags.Health = false; Flags.Line = false
Flags.Skeleton = false; Flags.WeaponESP = false
Flags.MaxDistance = 600

Flags.ESP_NPC = false; Flags.NPCDistance = 200; Flags.NPC_Name = true; Flags.NPC_Box = true; Flags.NPC_Health = true; Flags.NPC_Distance = true
Flags.ESP_Animals = false; Flags.AnimalDistance = 500; Flags.Animal_Name = true; Flags.Animal_Box = true; Flags.Animal_Health = true; Flags.Animal_Distance = true

-- ===== AIMBOT STATE =====
Flags.AimbotEnabled = false
Flags.AimbotType = "Mouse"
Flags.AimbotKey = Enum.UserInputType.MouseButton2
Flags.AimbotBone = "Head"
Flags.AimbotIgnoreTeam = true
Flags.AimbotIgnoreSleepers = true
Flags.AimbotIgnoreNPC = true
Flags.AimbotIgnoreAnimals = true
Flags.AimbotVisibleCheck = true
Flags.AimbotFOV = 120
Flags.AimbotSmooth = 5
Flags.AimbotPrediction = 1.0
Flags.AimbotBulletSpeed = 450
Flags.AimbotHitChance = 100
Flags.AimbotDistanceLimit = 400
Flags.AimbotDrawFOV = false
Flags.AimbotDrawTarget = false
Flags.AimbotDrawTargetColor = Color3.fromRGB(255, 0, 0)
Flags.AimbotDrawFOVColor = Color3.fromRGB(255, 255, 255)
Flags.AimbotAutoSwitch = true

-- NEW FEATURES
Flags.DynamicPrediction = true
Flags.Ballistic = true
Flags.HumanoidCheck = true
Flags.NoSpread = false

Flags.FreeCam = false
Flags.CameraZoom = false; Flags.ZoomActive = false
Flags.FPSPing = false; Flags.Fullbright = false
Flags.WorldTimeEnabled = false; Flags.WorldTimeValue = 12
Flags.HitboxEnabled = false; Flags.HitboxSize = 2.0; Flags.HitboxTransparency = 50
Flags.NoRecoil = false
Flags.SkyColorEnabled = false; Flags.SkyColor = Color3.fromRGB(100, 150, 255)
Flags.WeaponColorEnabled = false; Flags.WeaponColor = Color3.fromRGB(255, 0, 255)
Flags.WeaponMaterial = Enum.Material.Neon
Flags.AspectRatioEnabled = false; Flags.AspectRatioMode = "16:9"; Flags.AspectRatioValue = 1
Flags.Crosshair = false; Flags.CrosshairType = "Cross"; Flags.CrosshairColor = Color3.fromRGB(0, 255, 0)
Flags.CrosshairSize = 10; Flags.CrosshairThickness = 1; Flags.CrosshairTransparency = 0; Flags.CrosshairDistance = 5
Flags.CrosshairDot = false; Flags.CrosshairOutline = false; Flags.CrosshairDotSize = 2
Flags.FOVEnabled = false; Flags.FOVValue = 70; Flags.DefaultFOV = 70
Flags.RemoveConstructions = false; Flags.RemoveDistance = 75
Flags.Spider = false; Flags.SpiderSpeed = 30
Flags.BindHUD = false

-- ===== УТИЛИТЫ =====
local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getVelocity(part)
    if not part then return Vector3.zero end
    return part.AssemblyLinearVelocity or part.Velocity or Vector3.zero
end

local function isAimHeld()
    local k = Flags.AimbotKey
    if typeof(k) == "EnumItem" then
        if k.EnumType == Enum.UserInputType then return UIS:IsMouseButtonPressed(k)
        elseif k.EnumType == Enum.KeyCode then return UIS:IsKeyDown(k) end
    end
    return false
end

-- ===== TEAM CACHE & CHECK =====
local _teammatesCache = {}; local _teammatesCacheTime = 0
local function cleanName(text)
    if not text or text == "" then return "" end
    local cleaned = text:gsub("^[%s%.•%-]+", ""); cleaned = cleaned:gsub("[%s%.•%-]+$", ""); return cleaned
end
local function refreshTeammatesCache()
    local now = os.clock(); if now - _teammatesCacheTime < 0.5 then return end; _teammatesCacheTime = now
    local pg = LP:FindFirstChild("PlayerGui"); if not pg then _teammatesCache = {}; return end
    local teamUI = pg:FindFirstChild("TeamUI"); if not teamUI then _teammatesCache = {}; return end
    local teamFrame = teamUI:FindFirstChild("Team"); if not teamFrame then _teammatesCache = {}; return end
    local newCache = {}
    for _, child in ipairs(teamFrame:GetChildren()) do
        if child:IsA("TextLabel") and child.Text ~= "" then
            local clean = cleanName(child.Text); if clean ~= "" then newCache[clean] = true end
        end
    end
    _teammatesCache = newCache
end
local function isTeammate(plr)
    if not plr or not LP then return false end; if plr == LP then return false end
    refreshTeammatesCache(); return _teammatesCache[plr.Name] == true or _teammatesCache[plr.DisplayName] == true
end

-- ===== BONE POSITION =====
local BONE_MAP = { Head = "Head", Chest = "UpperTorso", Pelvis = "LowerTorso", Nearest = nil }
local function getBonePosition(char, boneName)
    if not char then return nil end
    if boneName == "Nearest" then
        local head = char:FindFirstChild("Head"); local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        if head and hrp then
            local camPos = Camera.CFrame.Position
            local headDist = (head.Position - camPos).Magnitude; local hrpDist = (hrp.Position - camPos).Magnitude
            if headDist < hrpDist then return head else return hrp end
        end
        return head or hrp
    end
    local partName = BONE_MAP[boneName]; if not partName then return nil end
    local part = char:FindFirstChild(partName)
    if not part and partName == "UpperTorso" then part = char:FindFirstChild("Torso") end
    if not part and partName == "LowerTorso" then part = char:FindFirstChild("Torso") end
    return part
end

-- ===== ПРЕДСКАЗАНИЕ (Smart Aimbot) =====
local function getPredictedPosition(part, char)
    if not part then return Vector3.zero end
    local pos = part.Position
    
    -- Dynamic Prediction
    if Flags.DynamicPrediction then
        local dist = (pos - Camera.CFrame.Position).Magnitude
        if dist < 30 or dist > 500 then
            return pos
        end
    end

    local predFactor = Flags.AimbotPrediction or 0
    if predFactor <= 0 then return pos end

    local camPos = Camera.CFrame.Position
    local toTarget = pos - camPos
    local dist = toTarget.Magnitude
    if dist < 1 then return pos end

    local vel = getVelocity(part)
    local forward = toTarget.Unit
    local velPerp = vel - forward * vel:Dot(forward)
    local horizVel = Vector3.new(velPerp.X, 0, velPerp.Z)
    
    local bulletSpeed = math.max(50, Flags.AimbotBulletSpeed or 450)
    local t = dist / bulletSpeed

    -- Humanoid State Check (Прыжок)
    if Flags.HumanoidCheck and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
            if part.Name == "Head" then
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                if torso then pos = torso.Position + Vector3.new(0, 0.5, 0) end
            end
        end
    end

    -- Base Prediction
    local finalPos = pos + horizVel * t * predFactor

    -- Ballistic Prediction (Гравитация)
    if Flags.Ballistic then
        local g = 196.2
        local drop = 0.5 * g * t * t
        finalPos = finalPos + Vector3.new(0, drop, 0)
    end

    return finalPos
end

-- ===== ССЫЛКИ НА ПЕРЕМЕННЫЕ ЛОГИКИ =====
CC.Refs.CurrentTarget = nil; CC.Refs.CurrentTargetPart = nil
CC.Refs.weaponColorConn = nil; CC.Refs.lastWeaponModels = {}
CC.Refs.aspectConn = nil; CC.Refs.OriginalHitboxSizes = {}; CC.Refs.OriginalWeaponProps = {}
CC.Refs.freecamConn = nil; CC.Refs.freecamMouseConn = nil
CC.Refs.savedCamType = nil; CC.Refs.savedMouseBehavior = nil
CC.Refs.savedWS = 16; CC.Refs.savedJP = 50
CC.Refs.freecamPos = Vector3.new(0,0,0); CC.Refs.freecamYaw = 0; CC.Refs.freecamPitch = 0
CC.Refs.noRecoilConn = nil; CC.Refs.noRecoilShotConn = nil
CC.Refs.lockedCamCF = nil; CC.Refs.recoilActive = false; CC.Refs.recoilLastInput = 0
CC.Refs.savedMotorTransforms = {}
CC.Refs.origLight = { Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime, FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart, GlobalShadows=Lighting.GlobalShadows, Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient }
CC.Refs.origAtmosphere = nil; CC.Refs.origClouds = nil
CC.Refs.origSky = nil; CC.Refs.customSky = nil
CC.Refs.Drawings = {}; CC.Refs.Highlights = {}; CC.Refs.Skeletons = {}; CC.Refs.WeaponLabels = {}
CC.Refs.SleeperDrawings = {}; CC.Refs.SleeperHighlights = {}; CC.Refs.SleeperSkeletons = {}; CC.Refs.SleeperWeaponLabels = {}; CC.Refs.SleeperList = {}
CC.Refs.NPCHighlights = {}; CC.Refs.NPCList = {}; CC.Refs.NPCDrawings = {}
CC.Refs.AnimalHighlights = {}; CC.Refs.AnimalList = {}; CC.Refs.AnimalDrawings = {}
CC.Refs.HudPanel = nil; CC.Refs.BindHudPanel = nil
CC.Refs.fpsRow = nil; CC.Refs.pingRow = nil; CC.Refs.hpRow = nil; CC.Refs.posRow = nil; CC.Refs.onlineRow = nil
CC.Refs.hudFrames = 0; CC.Refs.hudLast = os.clock()

-- ===== FOV: HOOK-КОНТРОЛЛЕР =====
CC.Refs.DefaultFOV    = 70
CC.Refs.fovAnimValue  = Camera.FieldOfView
CC.Refs.gameWantsFOV  = Camera.FieldOfView
CC.Refs.fovAnimActive = false
CC.Refs.lastRealFOV   = Camera.FieldOfView
CC.Refs._fovWriting   = false
CC.Refs._fovReading   = false

local function getDesiredFOV()
    if Flags.CameraZoom and Flags.ZoomActive then return 35 end
    if Flags.FOVEnabled then return Flags.FOVValue end
    return nil
end
local function rawSetFOV(value)
    CC.Refs._fovWriting = true; pcall(function() Camera.FieldOfView = value end); CC.Refs._fovWriting = false
end
local hasHookMeta = (typeof(hookmetamethod) == "function")

if hasHookMeta then
    pcall(function()
        local ok, err = pcall(function()
            local oldNewIndex
            oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
                if key == "FieldOfView" and typeof(self) == "Instance" and self:IsA("Camera") then
                    CC.Refs.gameWantsFOV = value; CC.Refs.lastRealFOV  = value
                    if CC.Refs._fovWriting then return oldNewIndex(self, key, value) end
                    if getDesiredFOV() then return oldNewIndex(self, key, CC.Refs.fovAnimValue) end
                end
                return oldNewIndex(self, key, value)
            end)
        end)
        if not ok then warn("[velcloud.xd] FOV __newindex hook failed:", err) end
    end)
    pcall(function()
        local ok, err = pcall(function()
            local oldIndex
            oldIndex = hookmetamethod(game, "__index", function(self, key)
                if key == "FieldOfView" and typeof(self) == "Instance" and self:IsA("Camera") then
                    if CC.Refs._fovWriting or CC.Refs._fovReading then return oldIndex(self, key) end
                    if getDesiredFOV() then return CC.Refs.gameWantsFOV end
                end
                return oldIndex(self, key)
            end)
        end)
        if not ok then warn("[velcloud.xd] FOV __index hook failed:", err) end
    end)
end

local function startFOVController()
    if CC.Refs.zoomConn then return end
    if not CC.Refs.DefaultFOV or CC.Refs.DefaultFOV <= 0 then CC.Refs.DefaultFOV = Camera.FieldOfView; Flags.DefaultFOV = CC.Refs.DefaultFOV end
    CC.Refs.fovAnimValue = Camera.FieldOfView; CC.Refs.gameWantsFOV = Camera.FieldOfView
    CC.Refs.zoomConn = RunService.RenderStepped:Connect(function(dt)
        local target = getDesiredFOV()
        if not target then
            if math.abs(CC.Refs.fovAnimValue - CC.Refs.DefaultFOV) > 0.1 then
                CC.Refs.fovAnimActive = true
                local alpha = math.min(dt * 12, 1)
                CC.Refs.fovAnimValue = CC.Refs.fovAnimValue + (CC.Refs.DefaultFOV - CC.Refs.fovAnimValue) * alpha
                if math.abs(CC.Refs.fovAnimValue - CC.Refs.DefaultFOV) <= 0.1 then CC.Refs.fovAnimValue = CC.Refs.DefaultFOV; CC.Refs.fovAnimActive = false end
                rawSetFOV(CC.Refs.fovAnimValue)
            elseif CC.Refs.fovAnimActive then CC.Refs.fovAnimActive = false end
            return
        end
        CC.Refs.fovAnimActive = true
        local cur = CC.Refs.fovAnimValue
        if math.abs(cur - target) <= 0.01 then CC.Refs.fovAnimValue = target
        else
            local alpha = math.min(dt * 12, 1)
            CC.Refs.fovAnimValue = cur + (target - cur) * alpha
            if math.abs(CC.Refs.fovAnimValue - target) <= 0.1 then CC.Refs.fovAnimValue = target end
        end
        rawSetFOV(CC.Refs.fovAnimValue)
    end)
end
local function stopFOVController()
    if CC.Refs.zoomConn then CC.Refs.zoomConn:Disconnect(); CC.Refs.zoomConn = nil end
    CC.Refs.fovAnimActive = false
end
local function applyCameraZoom() startFOVController() end
applyCameraZoom()

-- ===== УТИЛИТА: проекция =====
local function fovWorldToViewport(pos)
    local realFov = getDesiredFOV() and CC.Refs.fovAnimValue or Camera.FieldOfView
    local rel = Camera.CFrame:PointToObjectSpace(pos)
    if rel.Z >= 0 then return Vector3.new(0, 0, -1) end
    local tanHalf = math.tan(math.rad(realFov) * 0.5)
    local vs = Camera.ViewportSize
    local aspect  = vs.X / vs.Y
    local nx = rel.X / (-rel.Z * tanHalf * aspect)
    local ny = rel.Y / (-rel.Z * tanHalf)
    local sx = (nx + 1) * 0.5 * vs.X; local sy = (1 - ny) * 0.5 * vs.Y
    return Vector3.new(sx, sy, -rel.Z)
end

-- ===== NO SPREAD =====
if hasHookMeta then
    pcall(function()
        local oldRandom = Random.new
        Random.new = function(seed)
            local rand = oldRandom(seed)
            if Flags.NoSpread then
                local oldNextNumber = rand.NextNumber
                rand.NextNumber = function(_, min, max) return min or 0 end
                local oldNextInteger = rand.NextInteger
                rand.NextInteger = function(_, min, max) return min or 0 end
            end
            return rand
        end
    end)
end

-- ===== REMOVE CONSTRUCTIONS =====
CC.Refs.CleanerConn = nil; CC.Refs.LastWallScan = 0; CC.Refs.HiddenWalls = {}
local hiddenFolder = Instance.new("Folder"); hiddenFolder.Name = "VEL_HiddenWalls"
local function toggleRemoveConstructions(state)
    Flags.RemoveConstructions = state
    if state then
        hiddenFolder.Parent = game:GetService("ReplicatedStorage")
        if CC.Refs.CleanerConn then CC.Refs.CleanerConn:Disconnect() end
        CC.Refs.CleanerConn = RunService.Heartbeat:Connect(function()
            if os.clock() - (CC.Refs.LastWallScan or 0) < 0.4 then return end
            CC.Refs.LastWallScan = os.clock()
            local char = LP.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); if not root then return end
            local params = OverlapParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {char}
            local partsInRadius = workspace:GetPartBoundsInRadius(root.Position, Flags.RemoveDistance, params)
            local destroyed = {}
            for _, part in ipairs(partsInRadius) do
                local model = part.Parent
                if model and model:IsA("Model") and not destroyed[model] then
                    local name = string.lower(model.Name)
                    if string.find(name, "wall", 1, true) and not string.find(name, "door") and not string.find(name, "roof") then
                        destroyed[model] = true
                        table.insert(CC.Refs.HiddenWalls, { model = model, originalParent = model.Parent })
                        model.Parent = hiddenFolder
                    end
                end
            end
        end)
    else
        if CC.Refs.CleanerConn then CC.Refs.CleanerConn:Disconnect(); CC.Refs.CleanerConn = nil end
        for _, data in ipairs(CC.Refs.HiddenWalls) do if data.model and data.model.Parent == hiddenFolder then data.model.Parent = data.originalParent end end
        CC.Refs.HiddenWalls = {}; hiddenFolder.Parent = nil
    end
end

-- ===== SPIDER =====
local spiderBV = nil
local spiderRayParams = RaycastParams.new(); spiderRayParams.FilterType = Enum.RaycastFilterType.Exclude; spiderRayParams.FilterDescendantsInstances = {LP.Character}
local function clearSpiderVelocity() if spiderBV then pcall(function() spiderBV:Destroy() end); spiderBV = nil end end
local function ensureSpiderBV(hrp)
    if spiderBV and spiderBV.Parent == hrp then return spiderBV end
    clearSpiderVelocity(); spiderBV = Instance.new("BodyVelocity")
    spiderBV.Name = "VEL_Spider"; spiderBV.MaxForce = Vector3.new(0, 15000, 0); spiderBV.P = 2000; spiderBV.Velocity = Vector3.zero; spiderBV.Parent = hrp
    return spiderBV
end
local function updateSpider()
    local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then clearSpiderVelocity(); return end
    if not Flags.Spider then clearSpiderVelocity(); return end
    spiderRayParams.FilterDescendantsInstances = {char}
    local origin = hrp.Position
    local dirs = { Camera.CFrame.LookVector, -Camera.CFrame.LookVector, Camera.CFrame.RightVector, -Camera.CFrame.RightVector }
    local hit = nil
    for _, dir in ipairs(dirs) do
        local flat = Vector3.new(dir.X, 0, dir.Z)
        if flat.Magnitude > 0.01 then
            local res = workspace:Raycast(origin, flat.Unit * 2.5, spiderRayParams)
            if res and res.Instance and res.Instance.CanCollide then hit = res; break end
        end
    end
    if not hit then clearSpiderVelocity(); return end
    local up = 0
    if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Space) then up = Flags.SpiderSpeed
    elseif UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then up = -Flags.SpiderSpeed end
    if up == 0 then if spiderBV then spiderBV.Velocity = Vector3.zero end; return end
    local bv = ensureSpiderBV(hrp); local curVel = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.zero
    bv.Velocity = Vector3.new(curVel.X, up, curVel.Z)
end
RunService.Heartbeat:Connect(updateSpider)
LP.CharacterAdded:Connect(function() task.wait(0.1); clearSpiderVelocity() end)
LP.CharacterRemoving:Connect(function() clearSpiderVelocity() end)
local function toggleSpider(state) Flags.Spider = state; if not state then clearSpiderVelocity() end end

-- ===== LIGHTING =====
CC.Refs.LightingOverride = false; CC.Refs.OrigLighting = {}; CC.Refs.DisabledScripts = {}
local function captureLighting()
    if CC.Refs.LightingOverride then return end; CC.Refs.LightingOverride = true
    CC.Refs.OrigLighting = { Ambient = Lighting.Ambient, Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, ColorShift_Bottom = Lighting.ColorShift_Bottom, ColorShift_Top = Lighting.ColorShift_Top, EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale, EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale, FogColor = Lighting.FogColor, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, GlobalShadows = Lighting.GlobalShadows, OutdoorAmbient = Lighting.OutdoorAmbient, ShadowSoftness = Lighting.ShadowSoftness, ExposureCompensation = Lighting.ExposureCompensation }
    local containers = {Lighting, LP:FindFirstChild("PlayerScripts"), game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")}
    for _, container in ipairs(containers) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    local src = obj.Source
                    if src and (string.find(src, "ClockTime") or string.find(src, "Atmosphere") or string.find(src, "Lighting")) then
                        if not obj.Disabled then obj.Disabled = true; table.insert(CC.Refs.DisabledScripts, obj) end
                    end
                end
            end
        end
    end
end
local function restoreLighting()
    if not CC.Refs.LightingOverride then return end; CC.Refs.LightingOverride = false
    for key, value in pairs(CC.Refs.OrigLighting) do if type(key) == "string" then pcall(function() Lighting[key] = value end) end end
    for _, obj in ipairs(CC.Refs.DisabledScripts) do if obj and obj.Parent then pcall(function() obj.Disabled = false end) end end
    CC.Refs.DisabledScripts = {}
end
local function applyFullbright()
    if not Flags.Fullbright then return end
    pcall(function() Lighting.Brightness = 2; Lighting.ClockTime = 12; Lighting.GlobalShadows = false; Lighting.FogEnd = 1e5; Lighting.FogStart = 0; Lighting.Ambient = Color3.fromRGB(178,178,178); Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178) end)
    for _, obj in ipairs(Lighting:GetChildren()) do if obj:IsA("Atmosphere") or obj:IsA("Clouds") then obj:Destroy() end end
end
local function applyWorldTime()
    if not Flags.WorldTimeEnabled then return end
    pcall(function() Lighting.ClockTime = Flags.WorldTimeValue; Lighting.Brightness = 1; Lighting.GlobalShadows = true; Lighting.Ambient = Color3.fromRGB(100,100,100); Lighting.OutdoorAmbient = Color3.fromRGB(100,100,100); Lighting.FogEnd = 1000 end)
end
task.spawn(function() while true do task.wait(0.05); if Flags.Fullbright then applyFullbright() elseif Flags.WorldTimeEnabled then applyWorldTime() end end end)
if hasHookMeta then
    local ok, err = pcall(function()
        local oldNewIndex
        oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
            if self == Lighting then
                if Flags.Fullbright or Flags.WorldTimeEnabled then
                    if key == "ClockTime" or key == "Brightness" or key == "GlobalShadows" or key == "Ambient" or key == "OutdoorAmbient" or key == "FogEnd" or key == "FogStart" then return end
                end
            end
            return oldNewIndex(self, key, value)
        end)
    end)
    if not ok then warn("[velcloud.xd] Lighting hook failed:", err) end
end

-- ===== SKY COLOR =====
local function setSkyColor(enabled, color)
    local lighting = Lighting
    if not CC.Refs.origSky then for _, child in ipairs(lighting:GetChildren()) do if child:IsA("Sky") then CC.Refs.origSky = child:Clone(); break end end end
    if enabled then
        if not CC.Refs.customSky then CC.Refs.customSky = Instance.new("Sky"); CC.Refs.customSky.Name = "VelcloudCustomSky"; CC.Refs.customSky.Parent = lighting end
        local c = color or Flags.SkyColor
        CC.Refs.customSky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"; CC.Refs.customSky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"; CC.Refs.customSky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"; CC.Refs.customSky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"; CC.Refs.customSky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"; CC.Refs.customSky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
        CC.Refs.customSky.SunAngularSize = 0; CC.Refs.customSky.MoonAngularSize = 0
        local cc = lighting:FindFirstChild("VelcloudSkyTint")
        if not cc then cc = Instance.new("ColorCorrectionEffect"); cc.Name = "VelcloudSkyTint"; cc.Parent = lighting end
        cc.TintColor = c; cc.Brightness = 0; cc.Contrast = 0; cc.Saturation = 0
    else
        if CC.Refs.customSky then CC.Refs.customSky:Destroy(); CC.Refs.customSky = nil end
        local cc = lighting:FindFirstChild("VelcloudSkyTint"); if cc then cc:Destroy() end
    end
end

-- ===== WEAPON COLOR =====
local WEAPON_MATERIALS = { "Neon", "ForceField", "Glass", "Ice", "Marble", "Granite", "Metal", "DiamondPlate" }
local function saveOriginalProps(part)
    if CC.Refs.OriginalWeaponProps[part] then return end
    local specialMesh = part:FindFirstChildOfClass("SpecialMesh"); local surfaceApp = part:FindFirstChildOfClass("SurfaceAppearance")
    local decals = {}
    for _, child in ipairs(part:GetChildren()) do if child:IsA("Decal") or child:IsA("Texture") then decals[child] = child.Transparency end end
    CC.Refs.OriginalWeaponProps[part] = { Color = part.Color, Material = part.Material, TextureID = part:IsA("MeshPart") and part.TextureID or nil, SpecialMeshTexture = specialMesh and specialMesh.TextureId or nil, SpecialMeshId = specialMesh and specialMesh.MeshId or nil, SurfaceAppearanceClone = surfaceApp and surfaceApp:Clone() or nil, Decals = decals }
end
local function applyWeaponColorToModel(model)
    if not model then return end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            saveOriginalProps(part)
            if part:IsA("MeshPart") then pcall(function() part.TextureID = "" end) end
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("SpecialMesh") then pcall(function() child.TextureId = "" end); pcall(function() child.MeshId = "" end)
                elseif child:IsA("SurfaceAppearance") then pcall(function() child:Destroy() end)
                elseif child:IsA("Decal") or child:IsA("Texture") then pcall(function() child.Transparency = 1 end) end
            end
            pcall(function() part.Color = Flags.WeaponColor end); pcall(function() part.Material = Flags.WeaponMaterial end)
            task.defer(function() pcall(function() part.Color = Flags.WeaponColor end); pcall(function() part.Material = Flags.WeaponMaterial end) end)
        end
    end
end
local function restoreWeaponColorFromModel(model)
    if not model then return end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local orig = CC.Refs.OriginalWeaponProps[part]
            if orig then
                pcall(function() part.Color = orig.Color end); pcall(function() part.Material = orig.Material end)
                if orig.TextureID and part:IsA("MeshPart") then pcall(function() part.TextureID = orig.TextureID end) end
                if orig.SpecialMeshTexture then local sm = part:FindFirstChildOfClass("SpecialMesh"); if sm then pcall(function() sm.TextureId = orig.SpecialMeshTexture end) end end
                if orig.SpecialMeshId then local sm = part:FindFirstChildOfClass("SpecialMesh"); if sm then pcall(function() sm.MeshId = orig.SpecialMeshId end) end end
                if orig.SurfaceAppearanceClone then local current = part:FindFirstChildOfClass("SurfaceAppearance"); if current then current:Destroy() end; local newSA = orig.SurfaceAppearanceClone:Clone(); newSA.Parent = part end
                if orig.Decals then for decal, trans in pairs(orig.Decals) do if decal and decal.Parent then pcall(function() decal.Transparency = trans end) end end end
                CC.Refs.OriginalWeaponProps[part] = nil
            end
        end
    end
end
local BODY_PARTS = { Head = true, Torso = true, UpperTorso = true, LowerTorso = true, HumanoidRootPart = true, Humanoid = true, ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true, LeftUpperArm = true, RightUpperArm = true, LeftLowerArm = true, RightLowerArm = true, LeftHand = true, RightHand = true, LeftUpperLeg = true, RightUpperLeg = true, LeftLowerLeg = true, RightLowerLeg = true, LeftFoot = true, RightFoot = true }
local IGNORED_CLASSES = { Humanoid = true, Animator = true, HumanoidDescription = true, Accessory = true, ["Accoutrement"] = true, Shirt = true, Pants = true, ShirtGraphic = true, CharacterMesh = true, BodyColors = true, Script = true, LocalScript = true, ModuleScript = true, Sound = true, Animation = true, ParticleEmitter = true, Fire = true, Smoke = true, Sparkles = true, BillboardGui = true, SurfaceGui = true, Highlight = true, Folder = true }
local function collectHeldItems()
    local models = {}; local seen = {}; local char = LP.Character; if not char then return models end
    local function add(m) if m and typeof(m) == "Instance" and not seen[m] then seen[m] = true; table.insert(models, m) end end
    for _, child in ipairs(char:GetChildren()) do if child:IsA("Tool") then add(child) end end
    for _, child in ipairs(char:GetChildren()) do if child:IsA("Model") and not child:IsA("Tool") then if not BODY_PARTS[child.Name] and not IGNORED_CLASSES[child.ClassName] then local hasPart = false; for _, sub in ipairs(child:GetChildren()) do if sub:IsA("BasePart") then hasPart = true; break end end; if hasPart then add(child) end end end end
    for _, child in ipairs(char:GetChildren()) do if child:IsA("BasePart") and not BODY_PARTS[child.Name] then add(child) end end
    for _, child in ipairs(Camera:GetChildren()) do if child:IsA("Model") then add(child) end end
    return models
end
local function startWeaponColor()
    if CC.Refs.weaponColorConn then CC.Refs.weaponColorConn:Disconnect(); CC.Refs.weaponColorConn = nil end
    for _, m in ipairs(CC.Refs.lastWeaponModels) do restoreWeaponColorFromModel(m) end; CC.Refs.lastWeaponModels = {}
    CC.Refs.weaponColorConn = RunService.Heartbeat:Connect(function()
        if not Flags.WeaponColorEnabled then for _, m in ipairs(CC.Refs.lastWeaponModels) do restoreWeaponColorFromModel(m) end; CC.Refs.lastWeaponModels = {}; return end
        local currentModels = collectHeldItems()
        for _, oldM in ipairs(CC.Refs.lastWeaponModels) do local stillThere = false; for _, newM in ipairs(currentModels) do if oldM == newM then stillThere = true; break end end; if not stillThere then restoreWeaponColorFromModel(oldM) end end
        CC.Refs.lastWeaponModels = currentModels
        for _, m in ipairs(currentModels) do applyWeaponColorToModel(m) end
    end)
end

-- ===== ASPECT RATIO =====
local ASPECT_VALUES = { ["4:3"] = 0.75, ["16:9"] = 1.0 }
local function stopAspectRatio() if CC.Refs.aspectConn then CC.Refs.aspectConn:Disconnect(); CC.Refs.aspectConn = nil end end
local function startAspectRatio()
    stopAspectRatio(); if not Flags.AspectRatioEnabled then return end
    local res = ASPECT_VALUES[Flags.AspectRatioMode] or 1.0; Flags.AspectRatioValue = res
    CC.Refs.aspectConn = RunService.RenderStepped:Connect(function() if not Flags.AspectRatioEnabled then return end; Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, res, 0, 0, 0, 1) end)
end
local function applyAspectRatio() if Flags.AspectRatioEnabled then startAspectRatio() else stopAspectRatio() end end

-- ===== CROSSHAIR =====
local crossDrawings = { lines = {}, outline = {}, dot = Drawing.new("Square"), dotOutline = Drawing.new("Square"), circle = nil, circleOutline = nil, circleDot = nil, circleDotOutline = nil }
local function updateCrosshair()
    local showAny = Flags.Crosshair or Flags.CrosshairDot
    if not showAny then
        for _, d in pairs(crossDrawings.lines) do d.Visible = false end; for _, d in pairs(crossDrawings.outline) do d.Visible = false end
        if crossDrawings.circle then crossDrawings.circle.Visible = false end; if crossDrawings.circleOutline then crossDrawings.circleOutline.Visible = false end
        if crossDrawings.circleDot then crossDrawings.circleDot.Visible = false end; if crossDrawings.circleDotOutline then crossDrawings.circleDotOutline.Visible = false end
        return
    end
    local vs = Camera.ViewportSize; local cx = math.floor(vs.X / 2); local cy = math.floor(vs.Y / 2)
    local color = Flags.CrosshairColor; local trans = 1 - (Flags.CrosshairTransparency / 100); local cType = Flags.CrosshairType
    local thick = math.max(1, math.floor(Flags.CrosshairThickness)); if thick % 2 == 0 then thick = thick + 1 end
    local size = math.max(2, math.floor(Flags.CrosshairSize)); if size % 2 == 1 then size = size + 1 end
    local gap = math.max(0, math.floor(Flags.CrosshairDistance))
    for _, d in pairs(crossDrawings.lines) do d.Visible = false end; for _, d in pairs(crossDrawings.outline) do d.Visible = false end
    if crossDrawings.circle then crossDrawings.circle.Visible = false end; if crossDrawings.circleOutline then crossDrawings.circleOutline.Visible = false end
    if crossDrawings.circleDot then crossDrawings.circleDot.Visible = false end; if crossDrawings.circleDotOutline then crossDrawings.circleDotOutline.Visible = false end
    local function drawLine(index, x1, y1, x2, y2, isOutline)
        local tbl = isOutline and crossDrawings.outline or crossDrawings.lines
        if not tbl[index] then tbl[index] = Drawing.new("Line") end
        local line = tbl[index]
        line.Visible = true; line.From = Vector2.new(x1 + 0.5, y1 + 0.5); line.To = Vector2.new(x2 + 0.5, y2 + 0.5)
        line.Color = isOutline and Color3.new(0, 0, 0) or color; line.Thickness = isOutline and (thick + 1) or thick
        line.Transparency = isOutline and (trans * 0.7) or trans
    end
    if Flags.Crosshair then
        if cType == "Cross" then
            drawLine(1, cx, cy - gap - size, cx, cy - gap); if Flags.CrosshairOutline then drawLine(1, cx, cy - gap - size, cx, cy - gap, true) end
            drawLine(2, cx, cy + gap, cx, cy + gap + size); if Flags.CrosshairOutline then drawLine(2, cx, cy + gap, cx, cy + gap + size, true) end
            drawLine(3, cx - gap - size, cy, cx - gap, cy); if Flags.CrosshairOutline then drawLine(3, cx - gap - size, cy, cx - gap, cy, true) end
            drawLine(4, cx + gap, cy, cx + gap + size, cy); if Flags.CrosshairOutline then drawLine(4, cx + gap, cy, cx + gap + size, cy, true) end
        elseif cType == "T-Shape" then
            drawLine(1, cx, cy + gap, cx, cy + gap + size); if Flags.CrosshairOutline then drawLine(1, cx, cy + gap, cx, cy + gap + size, true) end
            drawLine(2, cx - gap - size, cy, cx - gap, cy); if Flags.CrosshairOutline then drawLine(2, cx - gap - size, cy, cx - gap, cy, true) end
            drawLine(3, cx + gap, cy, cx + gap + size, cy); if Flags.CrosshairOutline then drawLine(3, cx + gap, cy, cx + gap + size, cy, true) end
        elseif cType == "Circle" then
            if not crossDrawings.circle then crossDrawings.circle = Drawing.new("Circle"); crossDrawings.circle.Filled = false; crossDrawings.circle.NumSides = 32; crossDrawings.circleOutline = Drawing.new("Circle"); crossDrawings.circleOutline.Filled = false; crossDrawings.circleOutline.NumSides = 32 end
            if Flags.CrosshairOutline then crossDrawings.circleOutline.Visible = true; crossDrawings.circleOutline.Position = Vector2.new(cx + 0.5, cy + 0.5); crossDrawings.circleOutline.Radius = size + gap; crossDrawings.circleOutline.Thickness = thick + 1; crossDrawings.circleOutline.Color = Color3.new(0, 0, 0); crossDrawings.circleOutline.Transparency = trans * 0.5 end
            crossDrawings.circle.Visible = true; crossDrawings.circle.Position = Vector2.new(cx + 0.5, cy + 0.5); crossDrawings.circle.Radius = size + gap; crossDrawings.circle.Thickness = thick; crossDrawings.circle.Color = color; crossDrawings.circle.Transparency = trans
        end
    end
    if Flags.CrosshairDot then
        if not crossDrawings.circleDot then crossDrawings.circleDot = Drawing.new("Circle"); crossDrawings.circleDot.Filled = true; crossDrawings.circleDot.NumSides = 16; crossDrawings.circleDotOutline = Drawing.new("Circle"); crossDrawings.circleDotOutline.Filled = true; crossDrawings.circleDotOutline.NumSides = 16 end
        local dotSize = math.max(1, math.floor(Flags.CrosshairDotSize))
        if Flags.CrosshairOutline then crossDrawings.circleDotOutline.Visible = true; crossDrawings.circleDotOutline.Position = Vector2.new(cx + 0.5, cy + 0.5); crossDrawings.circleDotOutline.Radius = dotSize + 1; crossDrawings.circleDotOutline.Color = Color3.new(0, 0, 0); crossDrawings.circleDotOutline.Transparency = trans * 0.5 end
        crossDrawings.circleDot.Visible = true; crossDrawings.circleDot.Position = Vector2.new(cx + 0.5, cy + 0.5); crossDrawings.circleDot.Radius = dotSize; crossDrawings.circleDot.Color = color; crossDrawings.circleDot.Transparency = trans
    end
end
RunService.RenderStepped:Connect(updateCrosshair)

-- ===== ХИТБОКС =====
local function restoreHitbox(char)
    if not char then return end
    for part, size in pairs(CC.Refs.OriginalHitboxSizes) do if part and part.Parent then pcall(function() part.Size = size end); pcall(function() part.CanCollide = true end) end end
    for part in pairs(CC.Refs.OriginalHitboxSizes) do if part and not part.Parent then CC.Refs.OriginalHitboxSizes[part] = nil end end
end
local function restoreAllHitboxes() for _, plr in ipairs(Players:GetPlayers()) do if plr.Character then restoreHitbox(plr.Character) end end end
local function applyHitbox(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then return end
    local multiplier = Flags.HitboxSize or 2.0
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local name = part.Name
            if name == "Head" or name == "Torso" or name == "UpperTorso" or name == "LowerTorso" or name == "HumanoidRootPart" or name == "Left Arm" or name == "Right Arm" or name == "Left Leg" or name == "Right Leg" or name == "LeftUpperArm" or name == "RightUpperArm" or name == "LeftLowerArm" or name == "RightLowerArm" or name == "LeftUpperLeg" or name == "RightUpperLeg" or name == "LeftLowerLeg" or name == "RightLowerLeg" then
                if not CC.Refs.OriginalHitboxSizes[part] then CC.Refs.OriginalHitboxSizes[part] = part.Size end
                pcall(function() part.Size = CC.Refs.OriginalHitboxSizes[part] * multiplier end)
                if Flags.HitboxTransparency > 0 then pcall(function() part.Transparency = math.clamp(Flags.HitboxTransparency / 100, 0, 1) end) end
            end
        end
    end
end
local function updateHitboxes() for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then if Flags.HitboxEnabled and isAlive(plr.Character) then applyHitbox(plr.Character) else restoreHitbox(plr.Character) end end end end

-- ===== VISIBLE CHECK =====
local visRayParams = RaycastParams.new(); visRayParams.FilterType = Enum.RaycastFilterType.Exclude
local function isVisible(targetPart)
    if not targetPart then return false end
    visRayParams.FilterDescendantsInstances = {LP.Character, targetPart.Parent}
    local origin = Camera.CFrame.Position; local dir = (targetPart.Position - origin)
    local result = workspace:Raycast(origin, dir, visRayParams)
    return result == nil
end

-- ===== ПРОВЕРКА NPC/ANIMAL =====
local function isPlayerCharacter(obj) for _, p in ipairs(Players:GetPlayers()) do if p.Character == obj then return true end end; return false end
local function isNPCModel(model) local name = string.lower(model.Name); return name == "scientist" end
local function isAnimalModel(model) local name = string.lower(model.Name); return name == "bear" or name == "wolf" or name == "boar" or name == "stag" end

-- ===== ПОИСК ЦЕЛИ =====
local function getClosestTarget()
    local closest, closestPart; local shortest = math.huge
    local localRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not localRoot then return nil, nil end
    local localPos = localRoot.Position; local vs = Camera.ViewportSize; local center = Vector2.new(vs.X/2, vs.Y/2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isAlive(plr.Character) then
            if Flags.AimbotIgnoreTeam and isTeammate(plr) then continue end
            local char = plr.Character
            local part = getBonePosition(char, Flags.AimbotBone)
            if part then
                local dist = (part.Position - localPos).Magnitude
                if dist > Flags.AimbotDistanceLimit then continue end
                local sp = fovWorldToViewport(part.Position)
                if sp.Z > 0 then
                    local screenDist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                    if screenDist < Flags.AimbotFOV then
                        if Flags.AimbotVisibleCheck and not isVisible(part) then continue end
                        if dist < shortest then shortest = dist; closest = plr; closestPart = part end
                    end
                end
            end
        end
    end

    if not Flags.AimbotIgnoreNPC then
        for _, model in ipairs(CC.Refs.NPCList or {}) do
            if model.Parent and isAlive(model) and not isPlayerCharacter(model) and isNPCModel(model) then
                local part = getBonePosition(model, Flags.AimbotBone)
                if part then
                    local dist = (part.Position - localPos).Magnitude
                    if dist > Flags.AimbotDistanceLimit then continue end
                    local sp = fovWorldToViewport(part.Position)
                    if sp.Z > 0 then
                        local screenDist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                        if screenDist < Flags.AimbotFOV then
                            if Flags.AimbotVisibleCheck and not isVisible(part) then continue end
                            if dist < shortest then shortest = dist; closest = model; closestPart = part end
                        end
                    end
                end
            end
        end
    end

    if not Flags.AimbotIgnoreAnimals then
        for _, model in ipairs(CC.Refs.AnimalList or {}) do
            if model.Parent and isAlive(model) and not isPlayerCharacter(model) and isAnimalModel(model) then
                local part = getBonePosition(model, Flags.AimbotBone)
                if part then
                    local dist = (part.Position - localPos).Magnitude
                    if dist > Flags.AimbotDistanceLimit then continue end
                    local sp = fovWorldToViewport(part.Position)
                    if sp.Z > 0 then
                        local screenDist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                        if screenDist < Flags.AimbotFOV then
                            if Flags.AimbotVisibleCheck and not isVisible(part) then continue end
                            if dist < shortest then shortest = dist; closest = model; closestPart = part end
                        end
                    end
                end
            end
        end
    end
    return closest, closestPart
end

-- ===== AIMBOT LOGIC =====
RunService:BindToRenderStep("VelcloudAimbot", Enum.RenderPriority.Last.Value, function(dt)
    if not Flags.AimbotEnabled then CC.Refs.CurrentTargetPart = nil; if Camera.CameraType == Enum.CameraType.Scriptable then Camera.CameraType = Enum.CameraType.Custom end; return end
    local target, part = getClosestTarget()
    if Flags.AimbotAutoSwitch then
        if not part then CC.Refs.CurrentTarget = nil; CC.Refs.CurrentTargetPart = nil
        else CC.Refs.CurrentTarget = target; CC.Refs.CurrentTargetPart = part end
    else
        if not CC.Refs.CurrentTargetPart or not CC.Refs.CurrentTargetPart.Parent then CC.Refs.CurrentTarget = target; CC.Refs.CurrentTargetPart = part end
    end
    if not CC.Refs.CurrentTargetPart then if Camera.CameraType == Enum.CameraType.Scriptable then Camera.CameraType = Enum.CameraType.Custom end; return end
    if not isAimHeld() then if Camera.CameraType == Enum.CameraType.Scriptable then Camera.CameraType = Enum.CameraType.Custom end; return end
    if Flags.AimbotType == "Mouse" then
        local camPos = Camera.CFrame.Position; local targetPos = getPredictedPosition(CC.Refs.CurrentTargetPart, CC.Refs.CurrentTargetPart.Parent)
        local lookCF = CFrame.lookAt(camPos, targetPos); local base = 1 / math.max(1, Flags.AimbotSmooth)
        local alpha = 1 - (1 - base) ^ (dt * 60); Camera.CFrame = Camera.CFrame:Lerp(lookCF, alpha)
    end
end)

-- ===== DRAW FOV & TARGET =====
local drawFOV = Drawing.new("Circle"); drawFOV.Thickness = 1; drawFOV.Color = Color3.fromRGB(255, 255, 255); drawFOV.Filled = false; drawFOV.Visible = false; drawFOV.NumSides = 64
local drawTarget = Drawing.new("Circle"); drawTarget.Thickness = 2; drawTarget.Color = Color3.fromRGB(255, 0, 0); drawTarget.Filled = false; drawTarget.Visible = false; drawTarget.NumSides = 32
RunService.RenderStepped:Connect(function()
    if Flags.AimbotEnabled and Flags.AimbotDrawFOV then drawFOV.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); drawFOV.Radius = Flags.AimbotFOV; drawFOV.Color = Flags.AimbotDrawFOVColor; drawFOV.Visible = true
    else drawFOV.Visible = false end
    if Flags.AimbotEnabled and Flags.AimbotDrawTarget and CC.Refs.CurrentTargetPart then
        local sp = fovWorldToViewport(CC.Refs.CurrentTargetPart.Position)
        if sp.Z > 0 then drawTarget.Position = Vector2.new(sp.X, sp.Y); drawTarget.Radius = 20; drawTarget.Color = Flags.AimbotDrawTargetColor; drawTarget.Visible = true
        else drawTarget.Visible = false end
    else drawTarget.Visible = false end
end)

-- ===== FREECAM =====
local function stopFreeCam()
    if CC.Refs.freecamConn then CC.Refs.freecamConn:Disconnect(); CC.Refs.freecamConn = nil end
    if CC.Refs.freecamMouseConn then CC.Refs.freecamMouseConn:Disconnect(); CC.Refs.freecamMouseConn = nil end
    if CC.Refs.savedCamType then Camera.CameraType = CC.Refs.savedCamType; CC.Refs.savedCamType = nil end
    if CC.Refs.savedMouseBehavior then UIS.MouseBehavior = CC.Refs.savedMouseBehavior; CC.Refs.savedMouseBehavior = nil end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = CC.Refs.savedWS; hum.JumpPower = CC.Refs.savedJP end
    Flags.FreeCam = false
end
local function startFreeCam()
    if CC.Refs.freecamConn then return end
    CC.Refs.savedCamType = Camera.CameraType; Camera.CameraType = Enum.CameraType.Scriptable
    CC.Refs.savedMouseBehavior = UIS.MouseBehavior; UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
    CC.Refs.freecamPos = Camera.CFrame.Position
    local look = Camera.CFrame.LookVector
    CC.Refs.freecamYaw = math.atan2(-look.X, -look.Z); CC.Refs.freecamPitch = math.asin(math.clamp(look.Y, -1, 1))
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then CC.Refs.savedWS = hum.WalkSpeed; CC.Refs.savedJP = hum.JumpPower; hum.WalkSpeed = 0; hum.JumpPower = 0 end
    CC.Refs.freecamMouseConn = UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            CC.Refs.freecamYaw = CC.Refs.freecamYaw - input.Delta.X * 0.005
            CC.Refs.freecamPitch = math.clamp(CC.Refs.freecamPitch - input.Delta.Y * 0.005, -math.rad(89), math.rad(89))
        end
    end)
    CC.Refs.freecamConn = RunService.RenderStepped:Connect(function(dt)
        local speed = UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 150 or 50
        local cf = CFrame.fromEulerAnglesYXZ(CC.Refs.freecamPitch, CC.Refs.freecamYaw, 0)
        local move = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
        if move.Magnitude > 0 then CC.Refs.freecamPos = CC.Refs.freecamPos + move.Unit * speed * dt end
        Camera.CFrame = CFrame.new(CC.Refs.freecamPos) * cf
    end)
    Flags.FreeCam = true
end
LP.CharacterAdded:Connect(function() task.wait(0.1); if CC.Refs.freecamConn then stopFreeCam() end end)

-- ===== NO RECOIL =====
local noRecoilRenderConn = nil; local noRecoilMotorCache = {}
local function startNoRecoil()
    if noRecoilRenderConn then noRecoilRenderConn:Disconnect() end; noRecoilMotorCache = {}
    noRecoilRenderConn = RunService.RenderStepped:Connect(function()
        if not Flags.NoRecoil then return end
        local char = LP.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        if hum.CameraOffset.Magnitude > 0.001 then hum.CameraOffset = Vector3.zero end
        local isShooting = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("Motor6D") then
                if part.Name == "Neck" or part.Name == "RightShoulder" or part.Name == "LeftShoulder" then
                    if isShooting then
                        if not noRecoilMotorCache[part] then noRecoilMotorCache[part] = part.Transform end
                        if part.Transform ~= noRecoilMotorCache[part] then part.Transform = noRecoilMotorCache[part] end
                    else noRecoilMotorCache[part] = nil end
                end
            end
        end
    end)
end
local function stopNoRecoil()
    if noRecoilRenderConn then noRecoilRenderConn:Disconnect(); noRecoilRenderConn = nil end; noRecoilMotorCache = {}
    local char = LP.Character; if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.CameraOffset = Vector3.zero end end
end

-- ===== ESP DRAWINGS =====
local function createDrawings(plr)
    if plr == LP or CC.Refs.Drawings[plr] then return end
    local d = {}
    d.Box      = Drawing.new("Square"); d.Box.Thickness=1; d.Box.Filled=false; d.Box.Visible=false
    d.Name     = Drawing.new("Text"); d.Name.Size=14; d.Name.Center=true; d.Name.Outline=true; d.Name.Visible=false
    d.Health   = Drawing.new("Text"); d.Health.Size=12; d.Health.Center=true; d.Health.Outline=true; d.Health.Visible=false
    d.Line     = Drawing.new("Line"); d.Line.Thickness=1; d.Line.Visible=false
    d.Distance = Drawing.new("Text"); d.Distance.Size=12; d.Distance.Center=true; d.Distance.Outline=true; d.Distance.Visible=false
    d.Weapon   = Drawing.new("Text"); d.Weapon.Size=12; d.Weapon.Center=true; d.Weapon.Outline=true; d.Weapon.Visible=false
    CC.Refs.Drawings[plr] = d
end
local function clearHighlight(plr) if CC.Refs.Highlights[plr] then pcall(function() CC.Refs.Highlights[plr]:Destroy() end); CC.Refs.Highlights[plr] = nil end end
local function removeDrawings(plr)
    if CC.Refs.Drawings[plr] then for _,o in pairs(CC.Refs.Drawings[plr]) do if o then pcall(function() o:Remove() end) end end; CC.Refs.Drawings[plr]=nil end
    clearHighlight(plr)
    if CC.Refs.Skeletons[plr] then for _,l in pairs(CC.Refs.Skeletons[plr].lines) do pcall(function() l:Remove() end) end; CC.Refs.Skeletons[plr]=nil end
    if CC.Refs.WeaponLabels[plr] then pcall(function() CC.Refs.WeaponLabels[plr]:Remove() end); CC.Refs.WeaponLabels[plr]=nil end
end
local function applyHighlight(plr)
    if plr == LP then return end
    local char = plr.Character; local want = Flags.ESP and Flags.MaxDistance > 0
    if not want or not char or not isAlive(char) then clearHighlight(plr); return end
    local hl = CC.Refs.Highlights[plr]
    if not hl or not hl.Parent then
        if hl then pcall(function() hl:Destroy() end) end
        hl = Instance.new("Highlight"); hl.Name = "VelcloudESP"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char; CC.Refs.Highlights[plr] = hl
    end
    if hl.DepthMode ~= Enum.HighlightDepthMode.AlwaysOnTop then hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end
    local useTeam = Flags.TeamCheck and isTeammate(plr)
    local color = useTeam and Flags.TeamColor or Flags.ESPColor
    if Flags.ESPMode == "Chams" then hl.FillColor = color; hl.FillTransparency = 0; hl.OutlineColor = color; hl.OutlineTransparency = 1
    else hl.FillColor = color; hl.FillTransparency = 1; hl.OutlineColor = color; hl.OutlineTransparency = 0 end
end
local SKELETON_CONNECTIONS = { {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"} }
local R6_CONNECTIONS = { {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"} }
local function ensureSkeleton(plr, isR15)
    local sk = CC.Refs.Skeletons[plr]; local conns = isR15 and SKELETON_CONNECTIONS or R6_CONNECTIONS
    if sk and #sk.lines == #conns then return end
    if sk then for _,l in pairs(sk.lines) do pcall(function() l:Remove() end) end end
    local lines = {}; for i = 1, #conns do local l = Drawing.new("Line"); l.Thickness=1; l.Visible=false; lines[i] = l end
    CC.Refs.Skeletons[plr] = {lines = lines, conns = conns}
end
local function updateSkeleton(plr, char)
    local isR15 = char:FindFirstChild("UpperTorso") ~= nil; ensureSkeleton(plr, isR15)
    local sk = CC.Refs.Skeletons[plr]; if not sk then return end
    local useTeam = Flags.TeamCheck and isTeammate(plr); local color = useTeam and Flags.TeamColor or Flags.SkeletonColor
    for i, conn in ipairs(sk.conns) do
        local p1 = char:FindFirstChild(conn[1]); local p2 = char:FindFirstChild(conn[2]); local line = sk.lines[i]
        if p1 and p2 then
            local s1 = fovWorldToViewport(p1.Position); local s2 = fovWorldToViewport(p2.Position)
            if s1.Z > 0 and s2.Z > 0 then line.From = Vector2.new(s1.X, s1.Y); line.To = Vector2.new(s2.X, s2.Y); line.Color = color; line.Visible = true
            elseif line.Visible then line.Visible = false end
        elseif line.Visible then line.Visible = false end
    end
end
local WEAPON_IGNORE = { Handle = true, Grip = true, Attachment = true, Attachment1 = true, ["LeftGrip"] = true, ["RightGrip"] = true, ["Tool"] = true, Head = true, Torso = true, UpperTorso = true, LowerTorso = true, ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true, LeftUpperArm = true, RightUpperArm = true, LeftLowerArm = true, RightLowerArm = true, LeftUpperLeg = true, RightUpperLeg = true, LeftLowerLeg = true, RightLowerLeg = true, HumanoidRootPart = true, Humanoid = true, [""] = true, ["None"] = true, ["Nil"] = true, ["Part"] = true, ["Mesh"] = true }
local function isMeaningfulName(name) if not name or name == "" then return false end; if WEAPON_IGNORE[name] then return false end; if #name < 2 then return false end; if tonumber(name) then return false end; return true end
local function getWeaponName(char)
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool"); if not tool then return nil end
    if isMeaningfulName(tool.Name) then return tool.Name end
    for _, child in ipairs(tool:GetChildren()) do if child:IsA("BasePart") and isMeaningfulName(child.Name) then return child.Name end end
    return nil
end
local function updateHighlightDistance(plr, dist, visible)
    local hl = CC.Refs.Highlights[plr]; if not hl or not hl.Parent then return end
    local inRange = Flags.ESP and Flags.MaxDistance > 0 and visible and dist <= Flags.MaxDistance
    if hl.Enabled ~= inRange then hl.Enabled = inRange end
end
local function hideAll()
    for _,d in pairs(CC.Refs.Drawings) do
        if d.Box.Visible then d.Box.Visible=false end; if d.Name.Visible then d.Name.Visible=false end
        if d.Health.Visible then d.Health.Visible=false end; if d.Line.Visible then d.Line.Visible=false end
        if d.Distance.Visible then d.Distance.Visible=false end; if d.Weapon.Visible then d.Weapon.Visible=false end
    end
    for _,sk in pairs(CC.Refs.Skeletons) do for _,l in pairs(sk.lines) do if l.Visible then l.Visible=false end end end
    for _,hl in pairs(CC.Refs.Highlights) do if hl and hl.Parent and hl.Enabled then hl.Enabled = false end end
end
local function updateESP()
    if not Flags.ESP or Flags.MaxDistance <= 0 then hideAll(); return end
    local localRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not localRoot then hideAll(); return end
    local localPos = localRoot.Position; local vs = Camera.ViewportSize
    for plr, d in pairs(CC.Refs.Drawings) do
        local char = plr.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then
            if d.Box.Visible then d.Box.Visible=false end; if d.Name.Visible then d.Name.Visible=false end; if d.Health.Visible then d.Health.Visible=false end
            if d.Line.Visible then d.Line.Visible=false end; if d.Distance.Visible then d.Distance.Visible=false end; if d.Weapon.Visible then d.Weapon.Visible=false end
            local sk = CC.Refs.Skeletons[plr]; if sk then for _,l in pairs(sk.lines) do if l.Visible then l.Visible=false end end end
            updateHighlightDistance(plr, math.huge, false); continue
        end
        local dist = (root.Position - localPos).Magnitude
        if dist > Flags.MaxDistance then
            if d.Box.Visible then d.Box.Visible=false end; if d.Name.Visible then d.Name.Visible=false end; if d.Health.Visible then d.Health.Visible=false end
            if d.Line.Visible then d.Line.Visible=false end; if d.Distance.Visible then d.Distance.Visible=false end; if d.Weapon.Visible then d.Weapon.Visible=false end
            local sk = CC.Refs.Skeletons[plr]; if sk then for _,l in pairs(sk.lines) do if l.Visible then l.Visible=false end end end
            updateHighlightDistance(plr, dist, false); continue
        end
        local sp = fovWorldToViewport(root.Position)
        if sp.Z <= 0 then
            if d.Box.Visible then d.Box.Visible=false end; if d.Name.Visible then d.Name.Visible=false end; if d.Health.Visible then d.Health.Visible=false end
            if d.Line.Visible then d.Line.Visible=false end; if d.Distance.Visible then d.Distance.Visible=false end; if d.Weapon.Visible then d.Weapon.Visible=false end
            local sk = CC.Refs.Skeletons[plr]; if sk then for _,l in pairs(sk.lines) do if l.Visible then l.Visible=false end end end
            updateHighlightDistance(plr, dist, false); continue
        end
        local sx, sy = sp.X, sp.Y
        local headPart = char:FindFirstChild("Head") or root
        local headPos = headPart.Position + Vector3.new(0,1.5,0); local feetPos = root.Position - Vector3.new(0,2.5,0)
        local hS = fovWorldToViewport(headPos); local fS = fovWorldToViewport(feetPos)
        local useTeam = Flags.TeamCheck and isTeammate(plr)
        local boxColor = useTeam and Flags.TeamColor or Flags.BoxColor
        local textColor = useTeam and Flags.TeamColor or Flags.TextColor
        local lineColor = useTeam and Flags.TeamColor or Flags.LineColor
        if Flags.Box and hS.Z > 0 and fS.Z > 0 then
            local h = math.abs(hS.Y - fS.Y); local w = h * 0.5
            d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(sx - w/2, hS.Y); d.Box.Color = boxColor
            if not d.Box.Visible then d.Box.Visible = true end
        elseif d.Box.Visible then d.Box.Visible = false end
        if Flags.Name then d.Name.Text = plr.Name; d.Name.Position = Vector2.new(sx, hS.Y-18); d.Name.Color = textColor; if not d.Name.Visible then d.Name.Visible = true end
        elseif d.Name.Visible then d.Name.Visible = false end
        if Flags.Health then d.Health.Text = "HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth); d.Health.Position = Vector2.new(sx, fS.Y+2); d.Health.Color = textColor; if not d.Health.Visible then d.Health.Visible = true end
        elseif d.Health.Visible then d.Health.Visible = false end
        if Flags.Distance then d.Distance.Text = math.floor(dist).."m"; d.Distance.Position = Vector2.new(sx, fS.Y+18); d.Distance.Color = textColor; if not d.Distance.Visible then d.Distance.Visible = true end
        elseif d.Distance.Visible then d.Distance.Visible = false end
        if Flags.Line then d.Line.From = Vector2.new(vs.X/2, vs.Y); d.Line.To = Vector2.new(sx, sy); d.Line.Color = lineColor; if not d.Line.Visible then d.Line.Visible = true end
        elseif d.Line.Visible then d.Line.Visible = false end
        if Flags.WeaponESP then
            local weaponName = getWeaponName(char)
            if weaponName then d.Weapon.Text = "["..weaponName.."]"; d.Weapon.Position = Vector2.new(sx, fS.Y + 34); d.Weapon.Color = textColor; if not d.Weapon.Visible then d.Weapon.Visible = true end
            elseif d.Weapon.Visible then d.Weapon.Visible = false end
        elseif d.Weapon.Visible then d.Weapon.Visible = false end
        if Flags.Skeleton then updateSkeleton(plr, char)
        else local sk = CC.Refs.Skeletons[plr]; if sk then for _,l in pairs(sk.lines) do if l.Visible then l.Visible=false end end end end
        updateHighlightDistance(plr, dist, true)
        local hl = CC.Refs.Highlights[plr]
        if hl and hl.Parent then
            local wantTeam = Flags.TeamCheck and isTeammate(plr); local wantColor = wantTeam and Flags.TeamColor or Flags.ESPColor
            if hl.FillColor ~= wantColor then
                hl.FillColor = wantColor
                if Flags.ESPMode == "Chams" then hl.FillTransparency = 0; hl.OutlineColor = wantColor; hl.OutlineTransparency = 1
                else hl.FillTransparency = 1; hl.OutlineColor = wantColor; hl.OutlineTransparency = 0 end
            end
        end
    end
end

-- ===== SLEEPER ESP =====
CC.Refs.SleeperList = {}; CC.Refs.SleeperDrawings = {}; CC.Refs.SleeperHighlights = {}; CC.Refs.SleeperSkeletons = {}
local function refreshSleeperList()
    if not Flags.ESP_Sleeper then CC.Refs.SleeperList = {}; return end
    local result = {}; local root = workspace:FindFirstChild("SleepingPlayers")
    if root then for _, obj in ipairs(root:GetChildren()) do if obj:IsA("Model") and obj.Name == "Sleeper" then local hum = obj:FindFirstChildOfClass("Humanoid"); if hum then result[#result+1] = obj end end end end
    CC.Refs.SleeperList = result
end
local function createSleeperDrawing(model)
    if CC.Refs.SleeperDrawings[model] then return CC.Refs.SleeperDrawings[model] end
    local d = {}
    d.Box = Drawing.new("Square"); d.Box.Thickness=1; d.Box.Filled=false; d.Box.Visible=false
    d.Name = Drawing.new("Text"); d.Name.Size=14; d.Name.Center=true; d.Name.Outline=true; d.Name.Visible=false
    d.Health = Drawing.new("Text"); d.Health.Size=12; d.Health.Center=true; d.Health.Outline=true; d.Health.Visible=false
    d.Line = Drawing.new("Line"); d.Line.Thickness=1; d.Line.Visible=false
    d.Distance = Drawing.new("Text"); d.Distance.Size=12; d.Distance.Center=true; d.Distance.Outline=true; d.Distance.Visible=false
    d.Weapon = Drawing.new("Text"); d.Weapon.Size=12; d.Weapon.Center=true; d.Weapon.Outline=true; d.Weapon.Visible=false
    CC.Refs.SleeperDrawings[model] = d; return d
end
local function removeSleeperDrawing(model)
    local d = CC.Refs.SleeperDrawings[model]
    if d then for _, o in pairs(d) do pcall(function() o:Remove() end) end; CC.Refs.SleeperDrawings[model] = nil end
    local hl = CC.Refs.SleeperHighlights[model]; if hl then pcall(function() hl:Destroy() end); CC.Refs.SleeperHighlights[model] = nil end
    local sk = CC.Refs.SleeperSkeletons[model]; if sk then for _, l in pairs(sk.lines) do pcall(function() l:Remove() end) end; CC.Refs.SleeperSkeletons[model] = nil end
end
local function ensureSleeperSkeleton(model, isR15)
    local sk = CC.Refs.SleeperSkeletons[model]; local conns = isR15 and SKELETON_CONNECTIONS or R6_CONNECTIONS
    if sk and #sk.lines == #conns then return end
    if sk then for _,l in pairs(sk.lines) do pcall(function() l:Remove() end) end end
    local lines = {}; for i = 1, #conns do local l = Drawing.new("Line"); l.Thickness=1; l.Visible=false; lines[i] = l end
    CC.Refs.SleeperSkeletons[model] = {lines = lines, conns = conns}
end
local function updateSleeperSkeleton(model)
    local isR15 = model:FindFirstChild("UpperTorso") ~= nil; ensureSleeperSkeleton(model, isR15)
    local sk = CC.Refs.SleeperSkeletons[model]; if not sk then return end
    for i, conn in ipairs(sk.conns) do
        local p1 = model:FindFirstChild(conn[1]); local p2 = model:FindFirstChild(conn[2]); local line = sk.lines[i]
        if p1 and p2 then
            local s1 = fovWorldToViewport(p1.Position); local s2 = fovWorldToViewport(p2.Position)
            if s1.Z > 0 and s2.Z > 0 then line.From = Vector2.new(s1.X, s1.Y); line.To = Vector2.new(s2.X, s2.Y); line.Color = Flags.SleeperColor; line.Visible = true
            elseif line.Visible then line.Visible = false end
        elseif line.Visible then line.Visible = false end
    end
end
local function hideAllSleepers()
    for _, d in pairs(CC.Refs.SleeperDrawings) do d.Box.Visible = false; d.Name.Visible = false; d.Health.Visible = false; d.Distance.Visible = false; d.Line.Visible = false; d.Weapon.Visible = false end
    for _, hl in pairs(CC.Refs.SleeperHighlights) do if hl and hl.Parent then hl.Enabled = false end end
    for _, sk in pairs(CC.Refs.SleeperSkeletons) do for _, l in pairs(sk.lines) do if l.Visible then l.Visible = false end end end
end
local function updateSleeperESP()
    if not Flags.ESP_Sleeper then hideAllSleepers(); return end
    local localRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not localRoot then hideAllSleepers(); return end
    local localPos = localRoot.Position; local vs = Camera.ViewportSize; local list = CC.Refs.SleeperList or {}; local alive = {}; local sleeperColor = Flags.SleeperColor
    for _, model in ipairs(list) do
        if model.Parent then
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("Head")
            if root and root:IsA("BasePart") then
                local hum = model:FindFirstChildOfClass("Humanoid"); local dist = (root.Position - localPos).Magnitude
                if dist <= Flags.MaxDistance then
                    alive[model] = true
                    local hl = CC.Refs.SleeperHighlights[model]
                    if not hl or not hl.Parent then
                        if hl then pcall(function() hl:Destroy() end) end
                        hl = Instance.new("Highlight"); hl.Name = "VelcloudSleeper"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = model; CC.Refs.SleeperHighlights[model] = hl
                    end
                    if hl.FillColor ~= sleeperColor then hl.FillColor = sleeperColor; hl.OutlineColor = sleeperColor end
                    if Flags.ESPMode == "Chams" then hl.FillTransparency = 0; hl.OutlineTransparency = 1
                    else hl.FillTransparency = 1; hl.OutlineTransparency = 0 end
                    hl.Enabled = true
                    local head = model:FindFirstChild("Head"); local d = createSleeperDrawing(model); local sp = fovWorldToViewport(root.Position)
                    if head and sp.Z > 0 then
                        local hS = fovWorldToViewport(head.Position + Vector3.new(0, 1.5, 0)); local fS = fovWorldToViewport(root.Position - Vector3.new(0, 2.5, 0))
                        if hS.Z > 0 and fS.Z > 0 then
                            local h = math.abs(hS.Y - fS.Y); local w = h * 0.5
                            if Flags.Box then d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(sp.X - w/2, hS.Y); d.Box.Color = sleeperColor; d.Box.Visible = true else d.Box.Visible = false end
                            if Flags.Name then d.Name.Text = model.Name; d.Name.Position = Vector2.new(sp.X, hS.Y-18); d.Name.Color = sleeperColor; d.Name.Visible = true else d.Name.Visible = false end
                            if Flags.Health then if hum then d.Health.Text = "HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth); d.Health.Position = Vector2.new(sp.X, fS.Y+2); d.Health.Color = sleeperColor; d.Health.Visible = true else d.Health.Visible = false end else d.Health.Visible = false end
                            if Flags.Distance then d.Distance.Text = math.floor(dist).."m"; d.Distance.Position = Vector2.new(sp.X, fS.Y+18); d.Distance.Color = sleeperColor; d.Distance.Visible = true else d.Distance.Visible = false end
                            if Flags.Line then d.Line.From = Vector2.new(vs.X/2, vs.Y); d.Line.To = Vector2.new(sp.X, sp.Y); d.Line.Color = sleeperColor; d.Line.Visible = true else d.Line.Visible = false end
                            if Flags.WeaponESP then local weaponName = getWeaponName(model); if weaponName then d.Weapon.Text = "["..weaponName.."]"; d.Weapon.Position = Vector2.new(sp.X, fS.Y + 34); d.Weapon.Color = sleeperColor; d.Weapon.Visible = true else d.Weapon.Visible = false end else d.Weapon.Visible = false end
                        else d.Box.Visible = false; d.Name.Visible = false; d.Health.Visible = false; d.Distance.Visible = false; d.Line.Visible = false; d.Weapon.Visible = false end
                    else d.Box.Visible = false; d.Name.Visible = false; d.Health.Visible = false; d.Distance.Visible = false; d.Line.Visible = false; d.Weapon.Visible = false end
                    if Flags.Skeleton then updateSleeperSkeleton(model) else local sk = CC.Refs.SleeperSkeletons[model]; if sk then for _, l in pairs(sk.lines) do if l.Visible then l.Visible = false end end end end
                end
            end
        end
    end
    for model, d in pairs(CC.Refs.SleeperDrawings) do if not alive[model] then removeSleeperDrawing(model) end end
    for model, hl in pairs(CC.Refs.SleeperHighlights) do if not alive[model] and hl then pcall(function() hl:Destroy() end); CC.Refs.SleeperHighlights[model] = nil end end
end
task.spawn(function() while true do task.wait(0.5); pcall(refreshSleeperList) end end)
RunService.RenderStepped:Connect(function() pcall(updateSleeperESP) end)

-- ===== NPC ESP =====
CC.Refs.NPCList = {}; CC.Refs.NPCDrawings = {}; CC.Refs.NPCHighlights = {}
local function isPlayerChar(obj) for _, p in ipairs(Players:GetPlayers()) do if p.Character == obj then return true end end; return false end
local function refreshNPCList()
    if not Flags.ESP_NPC then CC.Refs.NPCList = {}; return end
    local result = {}; local seen = {}
    local rootFolders = { workspace:FindFirstChild("GeneratedMonuments"), workspace:FindFirstChild("Junkpiles") }
    for _, root in ipairs(rootFolders) do
        if root then
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("Model") and not isPlayerChar(obj) then
                    local name = string.lower(obj.Name)
                    if name == "scientist" then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 and not seen[obj] then seen[obj] = true; table.insert(result, obj) end
                    end
                end
            end
        end
    end
    CC.Refs.NPCList = result
end
local function createNPCDrawing(model)
    if CC.Refs.NPCDrawings[model] then return CC.Refs.NPCDrawings[model] end
    local d = {}
    d.Box = Drawing.new("Square"); d.Box.Thickness=1; d.Box.Filled=false; d.Box.Visible=false
    d.Name = Drawing.new("Text"); d.Name.Size=13; d.Name.Center=true; d.Name.Outline=true; d.Name.Visible=false
    d.Health = Drawing.new("Text"); d.Health.Size=11; d.Health.Center=true; d.Health.Outline=true; d.Health.Visible=false
    d.Distance = Drawing.new("Text"); d.Distance.Size=11; d.Distance.Center=true; d.Distance.Outline=true; d.Distance.Visible=false
    CC.Refs.NPCDrawings[model] = d; return d
end
local function removeNPCDrawing(model)
    local d = CC.Refs.NPCDrawings[model]
    if d then for _, o in pairs(d) do pcall(function() o:Remove() end) end; CC.Refs.NPCDrawings[model] = nil end
    local hl = CC.Refs.NPCHighlights[model]; if hl then pcall(function() hl:Destroy() end); CC.Refs.NPCHighlights[model] = nil end
end
local function hideAllNPC()
    for _, d in pairs(CC.Refs.NPCDrawings) do d.Box.Visible = false; d.Name.Visible = false; d.Health.Visible = false; d.Distance.Visible = false end
    for _, hl in pairs(CC.Refs.NPCHighlights) do if hl and hl.Parent then hl.Enabled = false end end
end
local function updateNPCESP()
    if not Flags.ESP_NPC or Flags.NPCDistance <= 0 then hideAllNPC(); return end
    local localRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not localRoot then hideAllNPC(); return end
    local localPos = localRoot.Position; local npcs = CC.Refs.NPCList or {}; local alive = {}
    for _, model in ipairs(npcs) do
        if model.Parent then
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("Head")
            if root and root:IsA("BasePart") then
                local dist = (root.Position - localPos).Magnitude
                if dist <= Flags.NPCDistance then
                    alive[model] = true; local hum = model:FindFirstChildOfClass("Humanoid"); local isDead = not hum or hum.Health <= 0
                    local hl = CC.Refs.NPCHighlights[model]
                    if not hl or not hl.Parent then
                        if hl then pcall(function() hl:Destroy() end) end
                        hl = Instance.new("Highlight"); hl.Name = "VelcloudNPC"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = model; CC.Refs.NPCHighlights[model] = hl
                    end
                    if isDead then if hl.FillColor ~= Color3.fromRGB(90,90,90) then hl.FillColor = Color3.fromRGB(90,90,90); hl.OutlineColor = Color3.fromRGB(60,60,60) end; hl.FillTransparency = 0.6; hl.OutlineTransparency = 0.3
                    else if hl.FillColor ~= Flags.NPCColor then hl.FillColor = Flags.NPCColor; hl.OutlineColor = Flags.NPCColor end; hl.FillTransparency = 0.4; hl.OutlineTransparency = 0 end
                    hl.Enabled = true
                    local head = model:FindFirstChild("Head")
                    if head then
                        local d = createNPCDrawing(model); local hS = fovWorldToViewport(head.Position + Vector3.new(0, 1, 0)); local fS = fovWorldToViewport(root.Position - Vector3.new(0, 2.5, 0)); local sp = fovWorldToViewport(root.Position)
                        if sp.Z > 0 and hS.Z > 0 and fS.Z > 0 then
                            local h = math.abs(hS.Y - fS.Y); local w = h * 0.5
                            if Flags.NPC_Box then d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(sp.X - w/2, hS.Y); d.Box.Color = isDead and Color3.fromRGB(120,120,120) or Flags.NPCColor; d.Box.Visible = true else d.Box.Visible = false end
                            if Flags.NPC_Name then d.Name.Text = model.Name .. (isDead and " [DEAD]" or ""); d.Name.Position = Vector2.new(sp.X, hS.Y - 16); d.Name.Color = isDead and Color3.fromRGB(150,150,150) or Flags.NPCColor; d.Name.Visible = true else d.Name.Visible = false end
                            if Flags.NPC_Health then if hum then d.Health.Text = isDead and "DEAD" or ("HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)); d.Health.Position = Vector2.new(sp.X, fS.Y + 2); d.Health.Color = isDead and Color3.fromRGB(150,150,150) or Flags.NPCColor; d.Health.Visible = true else d.Health.Visible = false end else d.Health.Visible = false end
                            if Flags.NPC_Distance then d.Distance.Text = math.floor(dist).."m"; d.Distance.Position = Vector2.new(sp.X, fS.Y + 18); d.Distance.Color = isDead and Color3.fromRGB(150,150,150) or Flags.NPCColor; d.Distance.Visible = true else d.Distance.Visible = false end
                        else d.Box.Visible = false; d.Name.Visible = false; d.Health.Visible = false; d.Distance.Visible = false end
                    end
                end
            end
        end
    end
    for model, d in pairs(CC.Refs.NPCDrawings) do if not alive[model] then removeNPCDrawing(model) end end
    for model, hl in pairs(CC.Refs.NPCHighlights) do if not alive[model] and hl then pcall(function() hl:Destroy() end); CC.Refs.NPCHighlights[model] = nil end end
end
task.spawn(function() while true do task.wait(3); pcall(refreshNPCList) end end)
RunService.RenderStepped:Connect(function() pcall(updateNPCESP) end)

-- ===== ANIMALS ESP =====
CC.Refs.AnimalList = {}; CC.Refs.AnimalDrawings = {}; CC.Refs.AnimalHighlights = {}
local TARGET_ANIMAL_NAME = "bear"
local function isTargetAnimalName(name) return string.lower(name) == TARGET_ANIMAL_NAME end
local function refreshAnimalList()
    if not Flags.ESP_Animals then CC.Refs.AnimalList = {}; return end
    local result = {}; local root = workspace:FindFirstChild("Animals")
    if root then for _, obj in ipairs(root:GetDescendants()) do if obj:IsA("Model") and not isPlayerChar(obj) and isTargetAnimalName(obj.Name) then local hum = obj:FindFirstChildOfClass("Humanoid"); if hum then result[#result+1] = obj end end end end
    CC.Refs.AnimalList = result
end
local function createAnimalDrawing(model)
    if CC.Refs.AnimalDrawings[model] then return CC.Refs.AnimalDrawings[model] end
    local d = {}
    d.Box = Drawing.new("Square"); d.Box.Thickness=1; d.Box.Filled=false; d.Box.Visible=false
    d.Name = Drawing.new("Text"); d.Name.Size=13; d.Name.Center=true; d.Name.Outline=true; d.Name.Visible=false
    d.Health = Drawing.new("Text"); d.Health.Size=11; d.Health.Center=true; d.Health.Outline=true; d.Health.Visible=false
    d.Distance = Drawing.new("Text"); d.Distance.Size=11; d.Distance.Center=true; d.Distance.Outline=true; d.Distance.Visible=false
    CC.Refs.AnimalDrawings[model] = d; return d
end
local function removeAnimalDrawing(model)
    local d = CC.Refs.AnimalDrawings[model]
    if d then for _, o in pairs(d) do pcall(function() o:Remove() end) end; CC.Refs.AnimalDrawings[model] = nil end
    local hl = CC.Refs.AnimalHighlights[model]; if hl then pcall(function() hl:Destroy() end); CC.Refs.AnimalHighlights[model] = nil end
end
local function hideAllAnimals()
    for _, d in pairs(CC.Refs.AnimalDrawings) do d.Box.Visible = false; d.Name.Visible = false; d.Health.Visible = false; d.Distance.Visible = false end
    for _, hl in pairs(CC.Refs.AnimalHighlights) do if hl and hl.Parent then hl.Enabled = false end end
end
local function updateAnimalESP()
    if not Flags.ESP_Animals or Flags.AnimalDistance <= 0 then hideAllAnimals(); return end
    local localRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not localRoot then hideAllAnimals(); return end
    local localPos = localRoot.Position; local animals = CC.Refs.AnimalList or {}; local alive = {}
    for _, model in ipairs(animals) do
        if model.Parent then
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("Head")
            if root and root:IsA("BasePart") then
                local dist = (root.Position - localPos).Magnitude
                if dist <= Flags.AnimalDistance then
                    alive[model] = true; local hum = model:FindFirstChildOfClass("Humanoid"); local isDead = not hum or hum.Health <= 0
                    local hl = CC.Refs.AnimalHighlights[model]
                    if not hl or not hl.Parent then
                        if hl then pcall(function() hl:Destroy() end) end
                        hl = Instance.new("Highlight"); hl.Name = "VelcloudAnimal"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = model; CC.Refs.AnimalHighlights[model] = hl
                    end
                    if isDead then if hl.FillColor ~= Color3.fromRGB(90,90,90) then hl.FillColor = Color3.fromRGB(90,90,90); hl.OutlineColor = Color3.fromRGB(60,60,60) end; hl.FillTransparency = 0.6; hl.OutlineTransparency = 0.3
                    else if hl.FillColor ~= Flags.AnimalColor then hl.FillColor = Flags.AnimalColor; hl.OutlineColor = Flags.AnimalColor end; hl.FillTransparency = 0.4; hl.OutlineTransparency = 0 end
                    hl.Enabled = true
                    local head = model:FindFirstChild("Head")
                    if head then
                        local d = createAnimalDrawing(model); local hS = fovWorldToViewport(head.Position + Vector3.new(0, 1, 0)); local fS = fovWorldToViewport(root.Position - Vector3.new(0, 2.5, 0)); local sp = fovWorldToViewport(root.Position)
                        if sp.Z > 0 and hS.Z > 0 and fS.Z > 0 then
                            local h = math.abs(hS.Y - fS.Y); local w = h * 0.5
                            if Flags.Animal_Box then d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(sp.X - w/2, hS.Y); d.Box.Color = isDead and Color3.fromRGB(120,120,120) or Flags.AnimalColor; d.Box.Visible = true else d.Box.Visible = false end
                            if Flags.Animal_Name then d.Name.Text = model.Name .. (isDead and " [DEAD]" or ""); d.Name.Position = Vector2.new(sp.X, hS.Y - 16); d.Name.Color = isDead and Color3.fromRGB(150,150,150) or Flags.AnimalColor; d.Name.Visible = true else d.Name.Visible = false end
                            if Flags.Animal_Health then if hum then d.Health.Text = isDead and "DEAD" or ("HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)); d.Health.Position = Vector2.new(sp.X, fS.Y + 2); d.Health.Color = isDead and Color3.fromRGB(150,150,150) or Flags.AnimalColor; d.Health.Visible = true else d.Health.Visible = false end else d.Health.Visible = false end
                            if Flags.Animal_Distance then d.Distance.Text = math.floor(dist).."m"; d.Distance.Position = Vector2.new(sp.X, fS.Y + 18); d.Distance.Color = isDead and Color3.fromRGB(150,150,150) or Flags.AnimalColor; d.Distance.Visible = true else d.Distance.Visible = false end
                        else d.Box.Visible = false; d.Name.Visible = false; d.Health.Visible = false; d.Distance.Visible = false end
                    end
                end
            end
        end
    end
    for model, d in pairs(CC.Refs.AnimalDrawings) do if not alive[model] then removeAnimalDrawing(model) end end
    for model, hl in pairs(CC.Refs.AnimalHighlights) do if not alive[model] and hl then pcall(function() hl:Destroy() end); CC.Refs.AnimalHighlights[model] = nil end end
end
task.spawn(function() while true do task.wait(3); pcall(refreshAnimalList) end end)
RunService.RenderStepped:Connect(function() pcall(updateAnimalESP) end)

-- ===== ХУКИ ИГРОКОВ =====
local function hookPlayer(plr)
    if plr == LP then return end
    createDrawings(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.2); applyHighlight(plr) end)
    plr.CharacterRemoving:Connect(function() clearHighlight(plr) end)
    applyHighlight(plr)
end
for _,plr in ipairs(Players:GetPlayers()) do hookPlayer(plr) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(removeDrawings)

-- ===== FPS/PING/ONLINE HUD =====
local StatsService = game:GetService("Stats")
local fpsCounter = 0; local lastFpsCheck = os.clock(); local currentFps = 0
RunService.RenderStepped:Connect(function()
    if Flags.FPSPing then
        fpsCounter = fpsCounter + 1; local now = os.clock()
        if now - lastFpsCheck >= 1 then currentFps = fpsCounter; fpsCounter = 0; lastFpsCheck = now end
    else fpsCounter = 0; currentFps = 0 end
end)
local function createHud()
    CC.Refs.HudPanel = CC.Lib:CreateNewWindow({ Title = "Stats", Name = "VelcloudStats", Size = {220}, Minimizable = true, Position = UDim2.new(1, -240, 0, 20), OnClose = function() if UI.Elements.statsHudToggle then UI.Elements.statsHudToggle:Set(false) end end })
    CC.Refs.HudPanel:AddHeader("Performance"); CC.Refs.fpsRow = CC.Refs.HudPanel:AddRow("FPS"); CC.Refs.pingRow = CC.Refs.HudPanel:AddRow("Ping")
    CC.Refs.HudPanel:AddSeparator(); CC.Refs.HudPanel:AddHeader("Player"); CC.Refs.hpRow = CC.Refs.HudPanel:AddRow("Health"); CC.Refs.posRow = CC.Refs.HudPanel:AddRow("Position", { Style = "Vertical", AccentKey = "white", ValueColorKey = "text" })
    CC.Refs.HudPanel:AddSeparator(); CC.Refs.HudPanel:AddHeader("Status"); CC.Refs.onlineRow = CC.Refs.HudPanel:AddRow("Online"); CC.Refs.onlineRow:Set("0")
end
local function destroyHud()
    if CC.Refs.HudPanel then pcall(function() CC.Refs.HudPanel:Destroy() end); CC.Refs.HudPanel = nil end
    CC.Refs.fpsRow, CC.Refs.pingRow, CC.Refs.hpRow, CC.Refs.posRow, CC.Refs.onlineRow = nil, nil, nil, nil, nil
end
task.spawn(function()
    while true do
        if Flags.FPSPing then
            if not CC.Refs.HudPanel then createHud() end
            if CC.Refs.fpsRow then CC.Refs.fpsRow:Set(tostring(currentFps)) end
            local ok, ping = pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() end)
            if CC.Refs.pingRow then CC.Refs.pingRow:Set(ok and ping and (math.floor(ping).." ms") or "n/a") end
            local char = LP.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and CC.Refs.posRow then local p = root.Position; CC.Refs.posRow:Set(string.format("%d, %d, %d", p.X, p.Y, p.Z)) end
            if hum and CC.Refs.hpRow then CC.Refs.hpRow:Set(string.format("%d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))) end
            if CC.Refs.onlineRow then CC.Refs.onlineRow:Set(tostring(#Players:GetPlayers())) end
        elseif CC.Refs.HudPanel then destroyHud() end
        task.wait(0.2)
    end
end)

-- ===== BIND HUD =====
local function getBindString(keyEnum)
    if not keyEnum then return "NONE" end
    if typeof(keyEnum) == "EnumItem" then
        if keyEnum == Enum.KeyCode.Unknown or keyEnum == Enum.UserInputType.None then return "NONE" end
        local name = keyEnum.Name; name = name:gsub("MouseButton", "M"):gsub("Left", "L"):gsub("Right", "R"); return name
    end
    return tostring(keyEnum)
end
local function createBindHud()
    CC.Refs.BindHudPanel = CC.Lib:CreateNewWindow({ Title = "Binds", Name = "VelcloudBinds", Size = {240}, Minimizable = true, Position = UDim2.new(1, -500, 0, 20), OnClose = function() if UI.Elements.bindHudToggle then UI.Elements.bindHudToggle:Set(false) end end })
    local body = CC.Refs.BindHudPanel.Body or CC.Refs.BindHudPanel.Gui:FindFirstChild("Body", true) or CC.Refs.BindHudPanel.Gui
    local container = Instance.new("Frame"); container.Name = "CustomBindList"; container.BackgroundTransparency = 1; container.Size = UDim2.new(1, -24, 0, 0); container.Position = UDim2.new(0, 12, 0, 45); container.AutomaticSize = Enum.AutomaticSize.Y; container.ZIndex = 10; container.Parent = body
    local layout = Instance.new("UIListLayout", container); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 4)
    local function updateBinds()
        if not CC.Refs.BindHudPanel or not container.Parent then return end
        for _, child in ipairs(container:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
        local function safeGet(elem) if elem and elem.Get then return elem:Get() end; return nil end
        local function drawRow(name, state, keyEnum)
            local bindStr = getBindString(keyEnum)
            local row = Instance.new("TextLabel"); row.Size = UDim2.new(1, 0, 0, 20); row.BackgroundTransparency = 1; row.Font = Enum.Font.BuilderSansMedium; row.TextSize = 12; row.TextXAlignment = Enum.TextXAlignment.Left; row.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(150, 150, 150); row.Text = string.format("%s [%s]", name, bindStr); row.Parent = container
            local statusLbl = Instance.new("TextLabel"); statusLbl.Size = UDim2.new(0.4, 0, 1, 0); statusLbl.Position = UDim2.new(0.6, 0, 0, 0); statusLbl.BackgroundTransparency = 1; statusLbl.Font = Enum.Font.BuilderSansBold; statusLbl.TextSize = 12; statusLbl.TextXAlignment = Enum.TextXAlignment.Right; statusLbl.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100); statusLbl.Text = state and "ON" or "OFF"; statusLbl.Parent = row
        end
        drawRow("ESP", Flags.ESP, safeGet(UI.Elements.keybindESP))
        drawRow("Aimbot", Flags.AimbotEnabled, Flags.AimbotKey)
        drawRow("FreeCam", Flags.FreeCam, safeGet(UI.Elements.keybindFreecam))
        drawRow("No Recoil", Flags.NoRecoil, safeGet(UI.Elements.keybindNoRecoil))
        drawRow("FOV", Flags.FOVEnabled, safeGet(UI.Elements.keybindFOV))
        drawRow("Spider", Flags.Spider, safeGet(UI.Elements.keybindSpider))
        drawRow("Fullbright", Flags.Fullbright, safeGet(UI.Elements.keybindFullbright))
        drawRow("Cam Zoom", Flags.CameraZoom, safeGet(UI.Elements.keybindCameraZoom))
        drawRow("Walls", Flags.RemoveConstructions, safeGet(UI.Elements.keybindRemoveConstructions))
    end
    task.spawn(function() task.wait(1); while CC.Refs.BindHudPanel do pcall(updateBinds); task.wait(0.5) end end)
end
local function destroyBindHud() if CC.Refs.BindHudPanel then pcall(function() CC.Refs.BindHudPanel:Destroy() end); CC.Refs.BindHudPanel = nil end end

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
    if Flags.ESP and Flags.MaxDistance > 0 then local ok, err = pcall(updateESP); if not ok then warn("[velcloud.xd] ESP error:", err); pcall(hideAll) end
    else hideAll() end
end)

-- ===== UI: AIMBOT =====
UI.Tabs.Aimbot = UI.Window:AddTab("Aimbot", "crosshair")
UI.Tabs.Aimbot:AddLabel("AIMBOT SYSTEM", "crosshair")
UI.Tabs.Aimbot:AddSeparator()

UI.Elements.aimbotEnabled = UI.Tabs.Aimbot:AddToggle({Title="Aimbot", Icon="crosshair", Default=false, Callback=function(s) Flags.AimbotEnabled=s end})
UI.Elements.aimbotType = UI.Tabs.Aimbot:AddDropdown({Title="Aimbot Type", Icon="layers", Options={"Mouse", "Silent"}, Default="Mouse", Callback=function(v) Flags.AimbotType=v end})
UI.Elements.aimbotBone = UI.Tabs.Aimbot:AddDropdown({Title="Bone", Icon="user", Options={"Nearest", "Head", "Chest", "Pelvis"}, Default="Head", Callback=function(v) Flags.AimbotBone=v end})
UI.Elements.aimbotKey = UI.Tabs.Aimbot:AddDropdown({Title="Aim Key", Icon="mouse-pointer", Options={"MouseButton2","MouseButton1","LeftShift","Q","E","C"}, Default="MouseButton2", Callback=function(s) Flags.AimbotKey = Enum.UserInputType[s] or Enum.KeyCode[s] or Enum.UserInputType.MouseButton2 end})
UI.Elements.aimbotVisibleCheck = UI.Tabs.Aimbot:AddToggle({Title="Visible Check", Icon="eye", Default=true, Callback=function(s) Flags.AimbotVisibleCheck=s end})
UI.Elements.aimbotAutoSwitch = UI.Tabs.Aimbot:AddToggle({Title="Auto Switch", Icon="repeat", Default=true, Callback=function(s) Flags.AimbotAutoSwitch=s end})

UI.Tabs.Aimbot:AddSeparator()
UI.Tabs.Aimbot:AddLabel("SMART AIMBOT SYSTEM", "cpu")
UI.Tabs.Aimbot:AddSeparator()

UI.Elements.dynamicPred = UI.Tabs.Aimbot:AddToggle({Title = "Dynamic Prediction", Subtitle = "Отключает предсказание в упор (< 30м) и на дальняке (> 500м)", Icon = "activity", Default = true, Callback = function(s) Flags.DynamicPrediction = s end})
UI.Elements.ballisticToggle = UI.Tabs.Aimbot:AddToggle({Title="Ballistic Prediction", Subtitle="Учёт гравитации пули", Icon="trending-down", Default=true, Callback=function(s) Flags.Ballistic=s end})
UI.Elements.humanoidCheckToggle = UI.Tabs.Aimbot:AddToggle({Title="Humanoid State Check", Subtitle="Аим по прыгающим (в грудь)", Icon="user", Default=true, Callback=function(s) Flags.HumanoidCheck=s end})
UI.Elements.noSpreadToggle = UI.Tabs.Aimbot:AddToggle({Title="No Spread", Subtitle="Убирает разброс оружия", Icon="crosshair", Default=false, Callback=function(s) Flags.NoSpread=s end})

UI.Tabs.Aimbot:AddSeparator()

UI.Elements.aimbotFOV = UI.Tabs.Aimbot:AddSlider({Title="Target FOV", Icon="circle", Min=1, Max=400, Default=120, Callback=function(v) Flags.AimbotFOV=v end})
UI.Elements.aimbotSmooth = UI.Tabs.Aimbot:AddSlider({Title="Mouse Aimbot Time", Icon="activity", Min=1, Max=100, Default=5, Callback=function(v) Flags.AimbotSmooth=v end})
UI.Elements.aimbotPrediction = UI.Tabs.Aimbot:AddSlider({Title="Aim Prediction", Subtitle="0=выкл · 1=норма · >1 если промах перед целью", Icon="trending-up", Min=0, Max=2, Step=0.1, Default=1.0, Callback=function(v) Flags.AimbotPrediction=v end})
UI.Elements.aimbotBulletSpeed = UI.Tabs.Aimbot:AddSlider({Title="Bullet Speed", Subtitle="Лук ~90 · Ревик ~450 · Автомат ~375", Icon="wind", Min=50, Max=800, Step=25, Default=450, Callback=function(v) Flags.AimbotBulletSpeed=v end})
UI.Elements.aimbotHitChance = UI.Tabs.Aimbot:AddSlider({Title="Hit Chance %", Icon="percent", Min=0, Max=100, Default=100, Callback=function(v) Flags.AimbotHitChance=v end})
UI.Elements.aimbotDistanceLimit = UI.Tabs.Aimbot:AddSlider({Title="Distance Limit", Icon="ruler", Min=1, Max=600, Default=400, Callback=function(v) Flags.AimbotDistanceLimit=v end})

UI.Tabs.Aimbot:AddSeparator()

UI.Elements.aimbotDrawFOV = UI.Tabs.Aimbot:AddToggle({Title="Draw FOV", Icon="circle", Default=false, Callback=function(s) Flags.AimbotDrawFOV=s end})
UI.Elements.aimbotDrawFOVColor = UI.Tabs.Aimbot:AddColorPicker({Title="Draw FOV Color", Icon="palette", Default=Flags.AimbotDrawFOVColor, Callback=function(c) Flags.AimbotDrawFOVColor=c end})
UI.Elements.aimbotDrawTarget = UI.Tabs.Aimbot:AddToggle({Title="Draw Target", Icon="crosshair", Default=false, Callback=function(s) Flags.AimbotDrawTarget=s end})
UI.Elements.aimbotDrawTargetColor = UI.Tabs.Aimbot:AddColorPicker({Title="Draw Target Color", Icon="palette", Default=Flags.AimbotDrawTargetColor, Callback=function(c) Flags.AimbotDrawTargetColor=c end})

UI.Tabs.Aimbot:AddSeparator()
UI.Tabs.Aimbot:AddLabel("IGNORE", "users")
UI.Tabs.Aimbot:AddSeparator()

UI.Elements.aimbotIgnoreTeam = UI.Tabs.Aimbot:AddToggle({Title="Ignore Team", Icon="users", Default=true, Callback=function(s) Flags.AimbotIgnoreTeam=s end})
UI.Elements.aimbotIgnoreSleepers = UI.Tabs.Aimbot:AddToggle({Title="Ignore Sleepers", Icon="bed", Default=true, Callback=function(s) Flags.AimbotIgnoreSleepers=s end})
UI.Elements.aimbotIgnoreNPC = UI.Tabs.Aimbot:AddToggle({Title="Ignore NPC", Icon="users", Default=true, Callback=function(s) Flags.AimbotIgnoreNPC=s end})
UI.Elements.aimbotIgnoreAnimals = UI.Tabs.Aimbot:AddToggle({Title="Ignore Animals", Icon="paw-print", Default=true, Callback=function(s) Flags.AimbotIgnoreAnimals=s end})

UI.Tabs.Aimbot:AddSeparator()
UI.Tabs.Aimbot:AddLabel("HITBOX EXPANDER", "box")
UI.Tabs.Aimbot:AddSeparator()

UI.Elements.hitboxToggle = UI.Tabs.Aimbot:AddToggle({Title="Hitbox Expander", Icon="box", Default=false, Callback=function(s) Flags.HitboxEnabled=s; if not s then restoreAllHitboxes() end end})
UI.Elements.hitboxSizeSlider = UI.Tabs.Aimbot:AddSlider({Title="Hitbox Size", Icon="ruler", Min=1, Max=5, Step=0.1, Default=2, Callback=function(v) Flags.HitboxSize=v end})
UI.Elements.hitboxTranspSlider = UI.Tabs.Aimbot:AddSlider({Title="Hitbox Transparency %", Icon="eye-off", Min=0, Max=100, Default=50, Callback=function(v) Flags.HitboxTransparency=v end})

-- ===== UI: VISUALS =====
UI.Tabs.Visuals = UI.Window:AddTab("Visuals", "eye")
UI.Tabs.Visuals:AddLabel("ESP PLAYER", "user")
UI.Tabs.Visuals:AddSeparator()

UI.Elements.espToggle = UI.Tabs.Visuals:AddToggle({Title="Esp Player", Icon="eye", Default=false, Callback=function(s) Flags.ESP=s; for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end end})
UI.Elements.espColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="Esp Color", Icon="palette", Default=Flags.ESPColor, Callback=function(c)
    Flags.ESPColor=c
    for plr, hl in pairs(CC.Refs.Highlights) do
        if hl and hl.Parent then local useTeam = Flags.TeamCheck and isTeammate(plr); if not useTeam then hl.FillColor = c; hl.OutlineColor = c end end
    end
end})
UI.Elements.espModeDropdown = UI.Tabs.Visuals:AddDropdown({Title="Esp Player Mode", Icon="layers", Options={"Chams","Glow"}, Default="Chams", Callback=function(v) Flags.ESPMode = v; for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end end})
UI.Elements.keybindESP = UI.Tabs.Visuals:AddKeybind({Title = "ESP Keybind", Icon = "eye", Callback = function() UI.Elements.espToggle:Set(not Flags.ESP) end})

UI.Tabs.Visuals:AddSeparator()

UI.Elements.espDistSlider = UI.Tabs.Visuals:AddSlider({Title="Distance Player", Icon="ruler", Min=250, Max=2500, Default=Flags.MaxDistance, Callback=function(v) Flags.MaxDistance=v; for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end end})

UI.Tabs.Visuals:AddSeparator()

UI.Elements.sleeperToggle = UI.Tabs.Visuals:AddToggle({Title="Sleeper", Icon="bed", Default=false, Callback=function(s) Flags.ESP_Sleeper=s end})
UI.Elements.sleeperColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="Color Sleeper", Icon="palette", Default=Flags.SleeperColor, Callback=function(c)
    Flags.SleeperColor=c
    for _,hl in pairs(CC.Refs.SleeperHighlights) do if hl and hl.Parent then hl.FillColor = c; hl.OutlineColor = c end end
end})

UI.Tabs.Visuals:AddSeparator()

UI.Elements.boxToggle = UI.Tabs.Visuals:AddToggle({Title="Box", Icon="box", Default=false, Callback=function(s) Flags.Box=s end})
UI.Elements.boxColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="Box Color", Icon="square", Default=Flags.BoxColor, Callback=function(c) Flags.BoxColor=c end})

UI.Elements.nameToggle = UI.Tabs.Visuals:AddToggle({Title="Name", Icon="user", Default=false, Callback=function(s) Flags.Name=s end})
UI.Elements.healthToggle = UI.Tabs.Visuals:AddToggle({Title="Health", Icon="heart", Default=false, Callback=function(s) Flags.Health=s end})
UI.Elements.distToggle = UI.Tabs.Visuals:AddToggle({Title="Distance", Icon="ruler", Default=false, Callback=function(s) Flags.Distance=s end})
UI.Elements.weaponToggle = UI.Tabs.Visuals:AddToggle({Title="Weapon", Icon="sword", Default=false, Callback=function(s) Flags.WeaponESP=s end})
UI.Elements.textColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="Text Color", Icon="type", Default=Flags.TextColor, Callback=function(c) Flags.TextColor=c end})

UI.Elements.lineToggle = UI.Tabs.Visuals:AddToggle({Title="Line", Icon="move", Default=false, Callback=function(s) Flags.Line=s end})
UI.Elements.lineColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="Line Color", Icon="move", Default=Flags.LineColor, Callback=function(c) Flags.LineColor=c end})

UI.Elements.skeletonToggle = UI.Tabs.Visuals:AddToggle({Title="Skeleton", Icon="bone", Default=false, Callback=function(s) Flags.Skeleton=s end})
UI.Elements.skelColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="Skeleton Color", Icon="bone", Default=Flags.SkeletonColor, Callback=function(c) Flags.SkeletonColor=c end})

UI.Tabs.Visuals:AddSeparator()
UI.Tabs.Visuals:AddLabel("TEAM CHECK", "users")
UI.Tabs.Visuals:AddSeparator()

UI.Elements.teamCheckVisualToggle = UI.Tabs.Visuals:AddToggle({Title="Team Check", Subtitle="Работает если включен Esp Player", Icon="users", Default=true, Callback=function(s)
    Flags.TeamCheck=s
    for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
end})
UI.Elements.teamColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="Team Color", Icon="palette", Default=Flags.TeamColor, Callback=function(c)
    Flags.TeamColor=c
    for plr, hl in pairs(CC.Refs.Highlights) do
        if hl and hl.Parent then local useTeam = Flags.TeamCheck and isTeammate(plr); if useTeam then hl.FillColor = c; hl.OutlineColor = c end end
    end
end})

UI.Tabs.Visuals:AddSeparator()
UI.Tabs.Visuals:AddLabel("OTHER VISUALS", "sparkles")
UI.Tabs.Visuals:AddSeparator()

-- NPC
UI.Elements.espNpcToggle = UI.Tabs.Visuals:AddToggle({Title="Esp NPC", Icon="users", Default=false, Callback=function(s) Flags.ESP_NPC=s end})
UI.Elements.npcColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="NPC Color", Icon="palette", Default=Flags.NPCColor, Callback=function(c) Flags.NPCColor=c end})
UI.Elements.npcDistSlider = UI.Tabs.Visuals:AddSlider({Title="NPC Distance", Icon="ruler", Min=100, Max=500, Default=Flags.NPCDistance, Callback=function(v) Flags.NPCDistance=v end})

UI.Elements.npcElementsDropdown = UI.Tabs.Visuals:AddMultiDropdown({
    Title = "NPC Elements", Subtitle = "Что рисовать на NPC", Icon = "layers", Options = {"Name", "Box", "Health", "Distance"}, Default = {"Name", "Box", "Health", "Distance"},
    Callback = function(selected) Flags.NPC_Name = selected["Name"] == true; Flags.NPC_Box = selected["Box"] == true; Flags.NPC_Health = selected["Health"] == true; Flags.NPC_Distance = selected["Distance"] == true end
})

UI.Tabs.Visuals:AddSeparator()

-- Animals
UI.Elements.espAnimalsToggle = UI.Tabs.Visuals:AddToggle({Title="Esp Animals", Icon="paw-print", Default=false, Callback=function(s) Flags.ESP_Animals=s end})
UI.Elements.animalColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="Animal Color", Icon="palette", Default=Flags.AnimalColor, Callback=function(c) Flags.AnimalColor=c end})
UI.Elements.animalDistSlider = UI.Tabs.Visuals:AddSlider({Title="Animal Distance", Icon="ruler", Min=250, Max=1000, Default=Flags.AnimalDistance, Callback=function(v) Flags.AnimalDistance=v end})

UI.Elements.animalElementsDropdown = UI.Tabs.Visuals:AddMultiDropdown({
    Title = "Animal Elements", Subtitle = "Что рисовать на животных", Icon = "layers", Options = {"Name", "Box", "Health", "Distance"}, Default = {"Name", "Box", "Health", "Distance"},
    Callback = function(selected) Flags.Animal_Name = selected["Name"] == true; Flags.Animal_Box = selected["Box"] == true; Flags.Animal_Health = selected["Health"] == true; Flags.Animal_Distance = selected["Distance"] == true end
})

-- ===== UI: LOOT =====
UI.Tabs.Loot = UI.Window:AddTab("Loot", "package")
UI.Tabs.Loot:AddSeparator()
UI.Tabs.Loot:AddLabel("COMING SOON", "clock")
UI.Tabs.Loot:AddSeparator()

-- ===== UI: WORLD =====
UI.Tabs.World = UI.Window:AddTab("World", "sun")
UI.Tabs.World:AddLabel("SKY", "cloud")
UI.Tabs.World:AddSeparator()

UI.Elements.skyColorToggle = UI.Tabs.World:AddToggle({ Title = "Custom Sky Color", Subtitle = "Перекрашивает небо", Icon = "cloud", Default = false, Callback = function(s) Flags.SkyColorEnabled = s; setSkyColor(s, Flags.SkyColor) end })
UI.Elements.skyColorPicker = UI.Tabs.World:AddColorPicker({ Title = "Sky Color", Icon = "palette", Default = Flags.SkyColor, Callback = function(c) Flags.SkyColor = c; if Flags.SkyColorEnabled then setSkyColor(true, c) end end })

UI.Tabs.World:AddSeparator()
UI.Tabs.World:AddLabel("LIGHTING", "sun")
UI.Tabs.World:AddSeparator()

UI.Elements.fullbrightToggle = UI.Tabs.World:AddToggle({ Title = "Fullbright", Subtitle = "Освещает всё вокруг, небо не мигает", Icon = "sun", Default = false, Callback = function(s) Flags.Fullbright = s; pcall(function() if s then captureLighting(); applyFullbright() else if not Flags.WorldTimeEnabled then restoreLighting() end end end) end })
UI.Elements.keybindFullbright = UI.Tabs.World:AddKeybind({ Title = "Fullbright Keybind", Icon = "keyboard", Default = Enum.KeyCode.Unknown, Callback = function() UI.Elements.fullbrightToggle:Set(not Flags.Fullbright) end })

UI.Tabs.World:AddSeparator()

UI.Elements.worldTimeToggle = UI.Tabs.World:AddToggle({ Title = "World Time", Subtitle = "Фиксирует время суток", Icon = "sun-moon", Default = false, Callback = function(s) Flags.WorldTimeEnabled = s; pcall(function() if s then captureLighting(); applyWorldTime() else if not Flags.Fullbright then restoreLighting() end end end) end })
UI.Elements.worldTimeSlider = UI.Tabs.World:AddSlider({ Title = "Hour (1-24)", Icon = "clock", Min = 1, Max = 24, Default = 12, Callback = function(v) Flags.WorldTimeValue = v; pcall(function() if Flags.WorldTimeEnabled then applyWorldTime() end end) end })

UI.Tabs.World:AddSeparator()
UI.Tabs.World:AddLabel("WEAPON SKIN", "paintbrush")
UI.Tabs.World:AddSeparator()

UI.Elements.weaponColorToggle = UI.Tabs.World:AddToggle({ Title = "Enable Weapon Color", Subtitle = "Неон на любое оружие", Icon = "palette", Default = false, Callback = function(s) Flags.WeaponColorEnabled = s; if s then startWeaponColor() else for _, m in ipairs(CC.Refs.lastWeaponModels) do restoreWeaponColorFromModel(m) end; CC.Refs.lastWeaponModels = {}; if CC.Refs.weaponColorConn then CC.Refs.weaponColorConn:Disconnect(); CC.Refs.weaponColorConn = nil end end end })
UI.Elements.weaponColorPicker = UI.Tabs.World:AddColorPicker({ Title = "Neon Color", Icon = "droplet", Default = Flags.WeaponColor, Callback = function(c) Flags.WeaponColor = c; if Flags.WeaponColorEnabled then for _, m in ipairs(CC.Refs.lastWeaponModels) do applyWeaponColorToModel(m) end end end })
UI.Elements.materialDropdown = UI.Tabs.World:AddDropdown({ Title = "Material", Icon = "gem", Options = WEAPON_MATERIALS, Default = "Neon", Callback = function(s) Flags.WeaponMaterial = Enum.Material[s] or Enum.Material.Neon; if Flags.WeaponColorEnabled then for _, m in ipairs(CC.Refs.lastWeaponModels) do applyWeaponColorToModel(m) end end end })

-- ===== UI: MISC =====
UI.Tabs.Misc = UI.Window:AddTab("Misc", "settings-2")
UI.Tabs.Misc:AddLabel("PLAYER", "user")
UI.Tabs.Misc:AddSeparator()

UI.Elements.freecamToggle = UI.Tabs.Misc:AddToggle({Title="FreeCam", Subtitle="WASD + Space/Ctrl", Icon="camera", Default=false, Callback=function(s) Flags.FreeCam=s; if s then startFreeCam() else stopFreeCam() end end})
UI.Elements.keybindFreecam = UI.Tabs.Misc:AddKeybind({Title = "FreeCam Keybind", Icon = "keyboard", Callback = function() UI.Elements.freecamToggle:Set(not Flags.FreeCam) end})

UI.Tabs.Misc:AddSeparator()

UI.Elements.noRecoilToggle = UI.Tabs.Misc:AddToggle({ Title="No Recoil", Subtitle="Стрельба на ходу без тряски", Icon="target", Default=false, Callback=function(s) Flags.NoRecoil = s; if s then startNoRecoil() else stopNoRecoil() end end })
UI.Elements.keybindNoRecoil = UI.Tabs.Misc:AddKeybind({Title = "No Recoil Keybind", Icon = "keyboard", Callback = function() UI.Elements.noRecoilToggle:Set(not Flags.NoRecoil) end})

UI.Tabs.Misc:AddSeparator()

UI.Elements.cameraZoomToggle = UI.Tabs.Misc:AddToggle({Title="Camera Zoom", Subtitle="Зажми бинд чтобы приблизить", Icon="zoom-in", Default=false, Callback=function(s) Flags.CameraZoom=s end})
UI.Elements.keybindCameraZoom = UI.Tabs.Misc:AddKeybind({Title = "Camera Zoom Keybind", Icon = "keyboard", Default = Enum.KeyCode.Unknown})

UI.Tabs.Misc:AddSeparator()

UI.Elements.fovToggle = UI.Tabs.Misc:AddToggle({Title="FOV Changer", Subtitle="Фиксирует FOV, отключение → дефолт", Icon="focus", Default=false, Callback=function(s)
    Flags.FOVEnabled = s
    if s then Flags.FOVValue = math.clamp(Flags.FOVValue, Flags.DefaultFOV, 120); CC.Refs.fovSettled = false end
end})
UI.Elements.fovSlider = UI.Tabs.Misc:AddSlider({Title="FOV Value", Icon="move-horizontal", Min=70, Max=120, Default=70, Callback=function(v) Flags.FOVValue = v; CC.Refs.fovSettled = false end})
UI.Elements.keybindFOV = UI.Tabs.Misc:AddKeybind({ Title = "FOV Keybind", Subtitle = "Вкл/Выкл FOV", Icon = "keyboard", Default = Enum.KeyCode.Unknown, Callback = function() UI.Elements.fovToggle:Set(not Flags.FOVEnabled) end })

UI.Tabs.Misc:AddSeparator()

UI.Elements.removeConstructionsToggle = UI.Tabs.Misc:AddToggle({ Title = "Remove Constructions", Subtitle = "Скрывает стены вокруг тебя", Icon = "box", Default = false, Callback = function(s) toggleRemoveConstructions(s) end })
UI.Elements.removeDistanceSlider = UI.Tabs.Misc:AddSlider({ Title = "Remove Distance", Icon = "ruler", Min = 50, Max = 150, Default = 75, Callback = function(v) Flags.RemoveDistance = v end })
UI.Elements.keybindRemoveConstructions = UI.Tabs.Misc:AddKeybind({ Title = "Remove Constructions Keybind", Subtitle = "Вкл/Выкл стены", Icon = "keyboard", Default = Enum.KeyCode.Unknown, Callback = function() UI.Elements.removeConstructionsToggle:Set(not Flags.RemoveConstructions) end })

UI.Tabs.Misc:AddSeparator()

UI.Elements.spiderToggle = UI.Tabs.Misc:AddToggle({ Title = "Spider", Subtitle = "Лазание по стенам (W/Space вверх, S/Ctrl вниз)", Icon = "move-vertical", Default = false, Callback = function(s) toggleSpider(s) end })
UI.Elements.spiderSpeedSlider = UI.Tabs.Misc:AddSlider({ Title = "Spider Speed", Icon = "activity", Min = 15, Max = 40, Default = 30, Callback = function(v) Flags.SpiderSpeed = v end })
UI.Elements.keybindSpider = UI.Tabs.Misc:AddKeybind({ Title = "Spider Keybind", Subtitle = "Вкл/Выкл Spider", Icon = "keyboard", Default = Enum.KeyCode.Unknown, Callback = function() UI.Elements.spiderToggle:Set(not Flags.Spider) end })

UI.Tabs.Misc:AddSeparator()
UI.Tabs.Misc:AddLabel("ASPECT RATIO", "monitor")
UI.Tabs.Misc:AddSeparator()

UI.Elements.aspectToggle = UI.Tabs.Misc:AddToggle({Title="Aspect Ratio", Subtitle="Сжатие вертикали камеры", Icon="monitor", Default=false, Callback=function(s) Flags.AspectRatioEnabled = s; applyAspectRatio() end})
UI.Elements.aspectModeDropdown = UI.Tabs.Misc:AddDropdown({ Title="Ratio", Icon="rectangle-horizontal", Options={"4:3", "16:9"}, Default="16:9", Callback=function(v) Flags.AspectRatioMode = v; if Flags.AspectRatioEnabled then startAspectRatio() end end })

UI.Tabs.Misc:AddSeparator()
UI.Tabs.Misc:AddLabel("CROSSHAIR SYSTEM", "crosshair")
UI.Tabs.Misc:AddSeparator()

UI.Elements.crosshairToggle = UI.Tabs.Misc:AddToggle({Title="Enable Crosshair", Icon="crosshair", Default=false, Callback=function(s) Flags.Crosshair=s end})
UI.Elements.crosshairType = UI.Tabs.Misc:AddDropdown({Title="Style", Icon="shape", Options={"Cross", "T-Shape", "Circle"}, Default="Cross", Callback=function(s) Flags.CrosshairType=s end})
UI.Elements.crosshairOutlineToggle = UI.Tabs.Misc:AddToggle({Title="Outline (Обводка)", Icon="square", Default=false, Callback=function(s) Flags.CrosshairOutline=s end})
UI.Elements.crosshairDotToggle = UI.Tabs.Misc:AddToggle({Title="Center Dot", Icon="circle", Default=false, Callback=function(s) Flags.CrosshairDot=s end})
UI.Elements.crosshairColorPicker = UI.Tabs.Misc:AddColorPicker({Title="Crosshair Color", Icon="palette", Default=Flags.CrosshairColor, Callback=function(c) Flags.CrosshairColor=c end})
UI.Elements.crosshairSizeSlider = UI.Tabs.Misc:AddSlider({Title="Size (Длина)", Icon="ruler", Min=2, Max=40, Default=10, Callback=function(v) Flags.CrosshairSize=v end})
UI.Elements.crosshairDistSlider = UI.Tabs.Misc:AddSlider({Title="Gap (Отступ)", Icon="move", Min=0, Max=30, Default=5, Callback=function(v) Flags.CrosshairDistance=v end})
UI.Elements.crosshairThickSlider = UI.Tabs.Misc:AddSlider({Title="Thickness (Толщина)", Icon="minus", Min=1, Max=6, Default=1, Callback=function(v) Flags.CrosshairThickness=v end})
UI.Elements.crosshairTranspSlider = UI.Tabs.Misc:AddSlider({Title="Transparency (Прозрачность)", Icon="eye-off", Min=0, Max=100, Default=0, Callback=function(v) Flags.CrosshairTransparency=v end})
UI.Elements.crosshairDotSizeSlider = UI.Tabs.Misc:AddSlider({Title="Dot Size", Icon="circle", Min=1, Max=10, Default=2, Callback=function(v) Flags.CrosshairDotSize=v end})

-- ===== UI: SETTINGS =====
UI.Tabs.Settings = UI.Window:AddTab("Settings", "settings")
UI.Elements.keyInfoLabel = UI.Tabs.Settings:AddLabel( string.format("Ключ: %s | до: %s", _G.VelcloudKeyState.name or "—", keyRemainingText()), "key" )
UI.Tabs.Settings:AddSeparator()

local themeNames = {}
for name in pairs(CC.Lib.Themes) do table.insert(themeNames, name) end
table.sort(themeNames)

UI.Tabs.Settings:AddDropdown({Title="Theme", Icon="swatch-book", Options=themeNames, Default=UI.Window:GetTheme(), Callback=function(s) UI.Window:SetTheme(s) end})
UI.Tabs.Settings:AddDropdown({Title="Accent Color", Icon="droplet", Options={"White","Blue","Red","Green","Purple"}, Default="White", Callback=function(s)
    local colors = { White=Color3.fromRGB(255,255,255), Blue=Color3.fromRGB(64,156,255), Red=Color3.fromRGB(230,70,70), Green=Color3.fromRGB(80,210,120), Purple=Color3.fromRGB(170,110,240) }
    CC.Lib:SetAccentColor(colors[s])
end})

UI.Tabs.Settings:AddSeparator()
UI.Elements.statsHudToggle = UI.Tabs.Settings:AddToggle({Title="Stats HUD", Icon="gauge", Default=false, Callback=function(s) Flags.FPSPing = s; if s then if not CC.Refs.HudPanel then createHud() end else destroyHud() end end})
UI.Elements.bindHudToggle = UI.Tabs.Settings:AddToggle({Title="Bind HUD", Icon="list", Default=false, Callback=function(s) Flags.BindHUD = s; if s then if not CC.Refs.BindHudPanel then createBindHud() end else destroyBindHud() end end})

UI.Tabs.Settings:AddSeparator(); UI.Tabs.Settings:AddLabel("KEYBINDS", "keyboard"); UI.Tabs.Settings:AddSeparator()
UI.Elements.keybindHideUI = UI.Tabs.Settings:AddKeybind({ Title = "Hide UI Keybind", Icon = "keyboard", Default = Enum.KeyCode.Delete, Callback = function() local sg = UI.Window.Gui; if sg then sg.Enabled = not sg.Enabled end end })

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not Flags.CameraZoom then return end
    local zoomBind = UI.Elements.keybindCameraZoom and UI.Elements.keybindCameraZoom:Get()
    if zoomBind and zoomBind ~= Enum.KeyCode.Unknown and input.KeyCode == zoomBind then Flags.ZoomActive = true end
end)
UIS.InputEnded:Connect(function(input, gpe)
    local zoomBind = UI.Elements.keybindCameraZoom and UI.Elements.keybindCameraZoom:Get()
    if zoomBind and zoomBind ~= Enum.KeyCode.Unknown and input.KeyCode == zoomBind then Flags.ZoomActive = false end
end)

UI.buildConfig = function(name)
    local cfg = UI.Window.ConfigManager:CreateConfig(name)
    cfg:RegisterElement("AimbotEnabled", UI.Elements.aimbotEnabled)
    cfg:RegisterElement("AimbotType", UI.Elements.aimbotType)
    cfg:RegisterElement("AimbotBone", UI.Elements.aimbotBone)
    cfg:RegisterElement("DynamicPrediction", UI.Elements.dynamicPred)
    cfg:RegisterElement("Ballistic", UI.Elements.ballisticToggle)
    cfg:RegisterElement("HumanoidCheck", UI.Elements.humanoidCheckToggle)
    cfg:RegisterElement("NoSpread", UI.Elements.noSpreadToggle)
    cfg:RegisterElement("AimbotIgnoreTeam", UI.Elements.aimbotIgnoreTeam)
    cfg:RegisterElement("AimbotIgnoreSleepers", UI.Elements.aimbotIgnoreSleepers)
    cfg:RegisterElement("AimbotIgnoreNPC", UI.Elements.aimbotIgnoreNPC)
    cfg:RegisterElement("AimbotIgnoreAnimals", UI.Elements.aimbotIgnoreAnimals)
    cfg:RegisterElement("AimbotVisibleCheck", UI.Elements.aimbotVisibleCheck)
    cfg:RegisterElement("AimbotFOV", UI.Elements.aimbotFOV)
    cfg:RegisterElement("AimbotSmooth", UI.Elements.aimbotSmooth)
    cfg:RegisterElement("AimbotPrediction", UI.Elements.aimbotPrediction)
    cfg:RegisterElement("AimbotBulletSpeed", UI.Elements.aimbotBulletSpeed)
    cfg:RegisterElement("AimbotHitChance", UI.Elements.aimbotHitChance)
    cfg:RegisterElement("AimbotDistanceLimit", UI.Elements.aimbotDistanceLimit)
    cfg:RegisterElement("AimbotDrawFOV", UI.Elements.aimbotDrawFOV)
    cfg:RegisterElement("AimbotDrawFOVColor", UI.Elements.aimbotDrawFOVColor)
    cfg:RegisterElement("AimbotDrawTarget", UI.Elements.aimbotDrawTarget)
    cfg:RegisterElement("AimbotDrawTargetColor", UI.Elements.aimbotDrawTargetColor)
    cfg:RegisterElement("AimbotAutoSwitch", UI.Elements.aimbotAutoSwitch)
    cfg:RegisterElement("AimbotKey", UI.Elements.aimbotKey)
    cfg:RegisterElement("Hitbox", UI.Elements.hitboxToggle)
    cfg:RegisterElement("HitboxSize", UI.Elements.hitboxSizeSlider)
    cfg:RegisterElement("HitboxTransp", UI.Elements.hitboxTranspSlider)
    cfg:RegisterElement("ESP", UI.Elements.espToggle)
    cfg:RegisterElement("ESPMode", UI.Elements.espModeDropdown)
    cfg:RegisterElement("ESPDistance", UI.Elements.espDistSlider)
    cfg:RegisterElement("ESPColor", UI.Elements.espColorPicker)
    cfg:RegisterElement("Sleeper", UI.Elements.sleeperToggle)
    cfg:RegisterElement("ColorSleeper", UI.Elements.sleeperColorPicker)
    cfg:RegisterElement("TeamCheckVisual", UI.Elements.teamCheckVisualToggle)
    cfg:RegisterElement("TeamColor", UI.Elements.teamColorPicker)
    cfg:RegisterElement("Box", UI.Elements.boxToggle)
    cfg:RegisterElement("Name", UI.Elements.nameToggle)
    cfg:RegisterElement("Health", UI.Elements.healthToggle)
    cfg:RegisterElement("Distance", UI.Elements.distToggle)
    cfg:RegisterElement("Line", UI.Elements.lineToggle)
    cfg:RegisterElement("Skeleton", UI.Elements.skeletonToggle)
    cfg:RegisterElement("Weapon", UI.Elements.weaponToggle)
    cfg:RegisterElement("TextColor", UI.Elements.textColorPicker)
    cfg:RegisterElement("BoxColor", UI.Elements.boxColorPicker)
    cfg:RegisterElement("LineColor", UI.Elements.lineColorPicker)
    cfg:RegisterElement("SkelColor", UI.Elements.skelColorPicker)
    cfg:RegisterElement("ESPNPC", UI.Elements.espNpcToggle)
    cfg:RegisterElement("NPCColor", UI.Elements.npcColorPicker)
    cfg:RegisterElement("NPCDistance", UI.Elements.npcDistSlider)
    cfg:RegisterElement("NPCElements", UI.Elements.npcElementsDropdown)
    cfg:RegisterElement("ESPAnimals", UI.Elements.espAnimalsToggle)
    cfg:RegisterElement("AnimalColor", UI.Elements.animalColorPicker)
    cfg:RegisterElement("AnimalDistance", UI.Elements.animalDistSlider)
    cfg:RegisterElement("AnimalElements", UI.Elements.animalElementsDropdown)
    cfg:RegisterElement("CrosshairOn", UI.Elements.crosshairToggle)
    cfg:RegisterElement("CrosshairType", UI.Elements.crosshairType)
    cfg:RegisterElement("CrosshairOutline", UI.Elements.crosshairOutlineToggle)
    cfg:RegisterElement("CrosshairDot", UI.Elements.crosshairDotToggle)
    cfg:RegisterElement("CrosshairColor", UI.Elements.crosshairColorPicker)
    cfg:RegisterElement("CrosshairSize", UI.Elements.crosshairSizeSlider)
    cfg:RegisterElement("CrosshairDistance", UI.Elements.crosshairDistSlider)
    cfg:RegisterElement("CrosshairThick", UI.Elements.crosshairThickSlider)
    cfg:RegisterElement("CrosshairTransp", UI.Elements.crosshairTranspSlider)
    cfg:RegisterElement("CrosshairDotSize", UI.Elements.crosshairDotSizeSlider)
    cfg:RegisterElement("WeaponColorOn", UI.Elements.weaponColorToggle)
    cfg:RegisterElement("WeaponColorPick", UI.Elements.weaponColorPicker)
    cfg:RegisterElement("WeaponMat", UI.Elements.materialDropdown)
    cfg:RegisterElement("AspectRatio", UI.Elements.aspectToggle)
    cfg:RegisterElement("AspectRatioMode", UI.Elements.aspectModeDropdown)
    cfg:RegisterElement("SkyColorEnabled", UI.Elements.skyColorToggle)
    cfg:RegisterElement("SkyColorPicker", UI.Elements.skyColorPicker)
    cfg:RegisterElement("Fullbright", UI.Elements.fullbrightToggle)
    cfg:RegisterElement("BindFullbright", UI.Elements.keybindFullbright)
    cfg:RegisterElement("WorldTime", UI.Elements.worldTimeToggle)
    cfg:RegisterElement("WorldTimeValue", UI.Elements.worldTimeSlider)
    cfg:RegisterElement("FreeCam", UI.Elements.freecamToggle)
    cfg:RegisterElement("CameraZoom", UI.Elements.cameraZoomToggle)
    cfg:RegisterElement("FOVEnabled", UI.Elements.fovToggle)
    cfg:RegisterElement("FOVValue", UI.Elements.fovSlider)
    cfg:RegisterElement("NoRecoil", UI.Elements.noRecoilToggle)
    cfg:RegisterElement("StatsHUD", UI.Elements.statsHudToggle)
    cfg:RegisterElement("BindHUD", UI.Elements.bindHudToggle)
    cfg:RegisterElement("BindESP",        UI.Elements.keybindESP)
    cfg:RegisterElement("BindFreecam",    UI.Elements.keybindFreecam)
    cfg:RegisterElement("BindCameraZoom", UI.Elements.keybindCameraZoom)
    cfg:RegisterElement("BindNoRecoil",   UI.Elements.keybindNoRecoil)
    cfg:RegisterElement("BindHideUI",     UI.Elements.keybindHideUI)
    cfg:RegisterElement("RemoveWall", UI.Elements.removeConstructionsToggle)
    cfg:RegisterElement("RemoveDist", UI.Elements.removeDistanceSlider)
    cfg:RegisterElement("BindRemoveWall", UI.Elements.keybindRemoveConstructions)
    cfg:RegisterElement("BindFOV", UI.Elements.keybindFOV)
    cfg:RegisterElement("Spider", UI.Elements.spiderToggle)
    cfg:RegisterElement("SpiderSpeed", UI.Elements.spiderSpeedSlider)
    cfg:RegisterElement("BindSpider", UI.Elements.keybindSpider)
    return cfg
end

UI.Tabs.Settings:AddSeparator()
UI.Tabs.Settings:AddLabel("SYSTEM CONFIG", "save")
UI.Tabs.Settings:AddSeparator()

UI.Window.ConfigManager:SetFolder("velcloud_configs")

UI.Elements.configNameBox = UI.Tabs.Settings:AddTextBox({ Title = "Config Name", Placeholder = "Enter name...", Default = "default" })
UI.Elements.savedConfigs = UI.Tabs.Settings:AddDropdown({ Title = "Saved Configs", Options = UI.Window.ConfigManager:GetConfigs() })

UI.Tabs.Settings:AddButton({Title="Save Config", Text="Save", Callback=function()
    local ok, err = pcall(function()
        local name = UI.Elements.configNameBox:Get()
        if not name or name == "" then error("empty name") end
        UI.buildConfig(name):Save()
        UI.Elements.savedConfigs:SetOptions(UI.Window.ConfigManager:GetConfigs())
        UI.Window:Notify({Title="Config", Text="Сохранён: "..name, Duration=2})
    end)
    if not ok then warn("[config] save:", err); UI.Window:Notify({Title="Config", Text="Ошибка: "..tostring(err), Duration=4}) end
end})

UI.Tabs.Settings:AddButton({Title="Load Config", Text="Load", Callback=function()
    local ok, err = pcall(function()
        local name = UI.Elements.savedConfigs:Get()
        if not name or name == "" then error("no config") end
        UI.Elements.configNameBox:Set(name)
        UI.buildConfig(name):Load()
        if Flags.FreeCam then if not CC.Refs.freecamConn then startFreeCam() end
        else if CC.Refs.freecamConn then stopFreeCam() end end
        if Flags.NoRecoil then startNoRecoil() else stopNoRecoil() end
        if Flags.HitboxEnabled then updateHitboxes() else restoreAllHitboxes() end
        if Flags.Spider then toggleSpider(true) else toggleSpider(false) end

        if not Flags.ESP_NPC then
            for model, d in pairs(CC.Refs.NPCDrawings or {}) do for _, o in pairs(d) do pcall(function() o:Remove() end) end end
            CC.Refs.NPCDrawings = {}; for model, hl in pairs(CC.Refs.NPCHighlights or {}) do pcall(function() hl:Destroy() end) end
            CC.Refs.NPCHighlights = {}; CC.Refs.NPCList = {}
        end

        if not Flags.ESP_Animals then
            for model, d in pairs(CC.Refs.AnimalDrawings or {}) do for _, o in pairs(d) do pcall(function() o:Remove() end) end end
            CC.Refs.AnimalDrawings = {}; for model, hl in pairs(CC.Refs.AnimalHighlights or {}) do pcall(function() hl:Destroy() end) end
            CC.Refs.AnimalHighlights = {}; CC.Refs.AnimalList = {}
        end

        if not Flags.ESP_Sleeper then
            for model, d in pairs(CC.Refs.SleeperDrawings or {}) do for _, o in pairs(d) do pcall(function() o:Remove() end) end end
            CC.Refs.SleeperDrawings = {}; for model, hl in pairs(CC.Refs.SleeperHighlights or {}) do pcall(function() hl:Destroy() end) end
            CC.Refs.SleeperHighlights = {}; for model, sk in pairs(CC.Refs.SleeperSkeletons or {}) do for _, l in pairs(sk.lines) do pcall(function() l:Remove() end) end end
            CC.Refs.SleeperSkeletons = {}; CC.Refs.SleeperList = {}
        end

        setSkyColor(Flags.SkyColorEnabled, Flags.SkyColor)
        if Flags.Fullbright or Flags.WorldTimeEnabled then
            captureLighting()
            if Flags.Fullbright then applyFullbright() end
            if Flags.WorldTimeEnabled then applyWorldTime() end
        else restoreLighting() end

        if Flags.WeaponColorEnabled then
            if not CC.Refs.weaponColorConn then startWeaponColor() end
            for _, m in ipairs(CC.Refs.lastWeaponModels) do applyWeaponColorToModel(m) end
        else
            for _, m in ipairs(CC.Refs.lastWeaponModels) do restoreWeaponColorFromModel(m) end
            CC.Refs.lastWeaponModels = {}; if CC.Refs.weaponColorConn then CC.Refs.weaponColorConn:Disconnect(); CC.Refs.weaponColorConn = nil end
        end

        CC.Refs.fovSettled = false
        for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
        if not Flags.FPSPing and CC.Refs.HudPanel then destroyHud()
        elseif Flags.FPSPing and not CC.Refs.HudPanel then createHud() end
        if not Flags.BindHUD and CC.Refs.BindHudPanel then destroyBindHud()
        elseif Flags.BindHUD and not CC.Refs.BindHudPanel then createBindHud() end
        UI.Window:Notify({Title="Config", Text="Загружен: "..name, Duration=2})
    end)
    if not ok then warn("[config] load:", err); UI.Window:Notify({Title="Config", Text="Ошибка: "..tostring(err), Duration=4}) end
end})

UI.Tabs.Settings:AddButton({Title="Delete Config", Text="Delete", Risky=true, Callback=function()
    local ok, err = pcall(function()
        local name = UI.Elements.savedConfigs:Get()
        if not name or name == "" then return end
        UI.Window.ConfigManager:DeleteConfig(name)
        UI.Elements.savedConfigs:SetOptions(UI.Window.ConfigManager:GetConfigs())
        UI.Window:Notify({Title="Config", Text="Удалён: "..name, Duration=2})
    end)
    if not ok then warn("[config] delete:", err) end
end})

task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            local displayName = _G.VelcloudKeyState.name or "—"
            if displayName == "Загрузка..." then displayName = "Проверка..." end
            UI.Elements.keyInfoLabel:Set(string.format("Ключ: %s | до: %s", displayName, keyRemainingText()))
        end)
    end
end)
