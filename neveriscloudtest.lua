--[[
    CLOUDCLIENT — Aimbot + ESP + FreeCam + Crosshair + Visuals + Config
    Архитектура: Табличная (_G.CC)
    BUILD: v0.2.1.7
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
local KEY_LIST = {
    ["CLOUD-FOX-0001"]  = { name = "Fox",   expires = 0 },
    ["CLOUD-JACK-0002"] = { name = "Jack",  expires = 0 },
    ["CLOUD-FRND-0003"] = { name = "Друг1", expires = 0 },
}

local KEY_FILE = "cloudclient_key.txt"

_G.CloudKeyState = {
    key = nil, name = nil, expires = 0, valid = false, reason = "не активирован",
}

local function validateKey(k)
    if not k or k == "" then return false, "пустой ключ" end
    local entry = KEY_LIST[k]
    if not entry then return false, "неверный ключ" end
    if entry.expires ~= 0 and os.time and os.time() > entry.expires then
        return false, "ключ истёк"
    end
    return true, entry
end

local function loadSavedKey()
    if not (isfile and readfile) then return nil end
    local ok, data = pcall(function()
        if isfile(KEY_FILE) then return readfile(KEY_FILE) end
    end)
    if ok and data then return (data:gsub("%s+", "")) end
    return nil
end

local function saveKey(k)
    if not writefile then return end
    pcall(writefile, KEY_FILE, k)
end

local function setKeyState(k, ok, entry, reason)
    _G.CloudKeyState.key     = k
    _G.CloudKeyState.valid   = ok
    _G.CloudKeyState.reason  = reason or (ok and "OK" or "неверный ключ")
    if ok and entry then
        _G.CloudKeyState.name    = entry.name or "—"
        _G.CloudKeyState.expires = entry.expires or 0
    else
        _G.CloudKeyState.name    = nil
        _G.CloudKeyState.expires = 0
    end
end

local function promptForKey()
    local sg = Instance.new("ScreenGui")
    sg.Name = "KeyPrompt_" .. math.random(1e6)
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999
    sg.Parent = (gethui and gethui()) or game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(400, 200)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(60, 60, 60); stroke.Thickness = 1

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 0, 28); title.Position = UDim2.fromOffset(12, 12)
    title.BackgroundTransparency = 1
    title.Text = "cloudclient — введи ключ"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.BuilderSansBold; title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -24, 0, 36); box.Position = UDim2.fromOffset(12, 52)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.TextColor3 = Color3.new(1,1,1)
    box.PlaceholderText = "CLOUD-XXXX-XXXX"
    box.PlaceholderColor3 = Color3.fromRGB(120,120,120)
    box.Font = Enum.Font.Code; box.TextSize = 14
    box.ClearTextOnFocus = false; box.Text = ""
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 36); btn.Position = UDim2.fromOffset(12, 100)
    btn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.BuilderSansBold; btn.TextSize = 14
    btn.Text = "Активировать"; btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -24, 0, 28); status.Position = UDim2.fromOffset(12, 148)
    status.BackgroundTransparency = 1; status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Font = Enum.Font.BuilderSansMedium; status.TextSize = 12
    status.TextXAlignment = Enum.TextXAlignment.Left; status.Parent = frame

    local result = nil
    local function tryActivate()
        local k = box.Text
        local ok, entryOrReason = validateKey(k)
        if ok then
            status.Text = "OK — " .. tostring(entryOrReason.name)
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            result = k
            task.wait(0.4)
            sg:Destroy()
        else
            status.Text = "отказ: " .. tostring(entryOrReason)
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    btn.MouseButton1Click:Connect(tryActivate)
    box.FocusLost:Connect(function(enter) if enter then tryActivate() end end)

    while sg.Parent and not result do task.wait(0.1) end
    return result
end

local function requireKey()
    local saved = loadSavedKey()
    if saved then
        local ok, entryOrReason = validateKey(saved)
        if ok then
            setKeyState(saved, true, entryOrReason, "OK")
            return true
        end
        pcall(function() if delfile then delfile(KEY_FILE) end end)
    end
    local entered = promptForKey()
    if not entered then
        setKeyState(nil, false, nil, "отменено")
        return false
    end
    local ok, entry = validateKey(entered)
    if ok then
        saveKey(entered)
        setKeyState(entered, true, entry, "OK")
        return true
    end
    setKeyState(nil, false, nil, "неверный ключ")
    return false
end

if not requireKey() then
    pcall(function()
        game:GetService("Players").LocalPlayer:Kick("cloudclient: доступ не активирован")
    end)
    return
end

local function keyRemainingText()
    local st = _G.CloudKeyState
    if not st or not st.valid then return "нет ключа" end
    if st.expires == 0 then return "бессрочно" end
    if not os.time then return "—" end
    local left = st.expires - os.time()
    if left <= 0 then return "истёк" end
    local d = math.floor(left / 86400)
    local h = math.floor((left % 86400) / 3600)
    local m = math.floor((left % 3600) / 60)
    if d > 0 then return string.format("%dd %dh", d, h) end
    if h > 0 then return string.format("%dh %dm", h, m) end
    return string.format("%dm", m)
end
-- ===== END KEY SYSTEM =====

-- ===== ИНИЦИАЛИЗАЦИЯ БИБЛИОТЕКИ =====
CC.Lib = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/xxqwl1337/neveriscloud@main/neverisUI2.lua"))()

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Stats       = game:GetService("Stats")
local Lighting    = game:GetService("Lighting")
local LP          = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local Mouse       = LP:GetMouse()

UI.Window = CC.Lib:CreateWindow({
    Title = "cloudclient", Theme = "Vantix", AccentColor = Color3.fromRGB(255, 255, 255),
    LogoID = 110034487018208, Size = {820, 480},
})
UI.Window:CreateTag("Rust Decoy", Color3.fromRGB(100, 200, 100), nil, "gamepad-2")
UI.Window:CreateTag("Beta", Color3.fromRGB(255, 105, 180), nil, "flask-conical")
UI.Window:CreateTag("v0.2.1.7", Color3.fromRGB(150, 150, 150), nil, "git-branch")
UI.Window:CreateTag("Premium", Color3.fromRGB(255, 215, 0), nil, "crown")
UI.Window:Notify({ Title = "Welcome", Text = "cloudclient v0.2.1.7 loaded", Icon = "check", Duration = 4 })

-- ===== СОСТОЯНИЕ =====
Flags.ESP = false; Flags.ESPMode = "Chams"
Flags.Box = false; Flags.Distance = false; Flags.Name = false; Flags.Health = false; Flags.Line = false
Flags.Skeleton = false; Flags.WeaponESP = false
Flags.MaxDistance = 600
Flags.ESPColor = Color3.fromRGB(255, 0, 255)
Flags.TextColor = Color3.fromRGB(255, 255, 255)
Flags.BoxColor = Color3.fromRGB(255,255,255); Flags.LineColor = Color3.fromRGB(255,255,255)
Flags.SkeletonColor = Color3.fromRGB(0, 255, 0)
Flags.FreeCam = false
Flags.CameraZoom = false
Flags.ZoomActive = false
Flags.FPSPing = false; Flags.Fullbright = false
Flags.Crosshair = false; Flags.CrosshairColor = Color3.fromRGB(255, 255, 255); Flags.CrosshairSize = 10
Flags.CrosshairThickness = 1; Flags.CrosshairTransparency = 0; Flags.CrosshairDistance = 4
Flags.Aimbot = false; Flags.AimAssist = true; Flags.SilentAim = true; Flags.AimlockMode = false
Flags.AimPart = "Head"; Flags.AimSmooth = 5; Flags.AimFOV = 120; Flags.AimTeamCheck = true
Flags.AimKey = Enum.UserInputType.MouseButton2; Flags.AimPrediction = 0; Flags.HitChance = 100
Flags.HitboxEnabled = false; Flags.HitboxSize = 2.0; Flags.HitboxTransparency = 50
Flags.TriggerBot = false; Flags.TriggerDelay = 50; Flags.TriggerFOV = 15; Flags.TriggerTeamCheck = true
Flags.NoRecoil = false
Flags.RapidFire = false; Flags.RapidFireDelay = 50
Flags.SkyColorEnabled = false; Flags.SkyColor = Color3.fromRGB(100, 150, 255)
Flags.WeaponColorEnabled = false
Flags.WeaponColor = Color3.fromRGB(255, 0, 255)
Flags.WeaponMaterial = Enum.Material.Neon
Flags.AspectRatioEnabled = false; Flags.AspectRatioMode = "16:9"; Flags.AspectRatioValue = 1
-- FOV
Flags.FOVEnabled = false
Flags.FOVBindActive = false
Flags.FOVValue = 70
Flags.DefaultFOV = 70
-- REMOVE CONSTRUCTIONS
Flags.RemoveConstructions = false
Flags.RemoveDistance = 75

-- ===== УТИЛИТЫ =====
local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getAimPart(char)
    if not char then return nil end
    local part = char:FindFirstChild(Flags.AimPart) or char:FindFirstChild("Head")
    if not part then
        part = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    end
    return part
end

local function getVelocity(part)
    if not part then return Vector3.zero end
    return part.AssemblyLinearVelocity or part.Velocity or Vector3.zero
end

local function isAimHeld()
    local k = Flags.AimKey
    if typeof(k) == "EnumItem" then
        if k.EnumType == Enum.UserInputType then
            return UIS:IsMouseButtonPressed(k)
        elseif k.EnumType == Enum.KeyCode then
            return UIS:IsKeyDown(k)
        end
    end
    return false
end

-- ===== ССЫЛКИ НА ПЕРЕМЕННЫЕ ЛОГИКИ =====
CC.Refs.CurrentTarget = nil
CC.Refs.CurrentTargetPart = nil
CC.Refs.rapidFireConn = nil
CC.Refs.weaponColorConn = nil
CC.Refs.lastWeaponModels = {}
CC.Refs.aspectConn = nil
CC.Refs.OriginalHitboxSizes = {}
CC.Refs.OriginalWeaponProps = {}
CC.Refs.freecamConn = nil
CC.Refs.freecamMouseConn = nil
CC.Refs.savedCamType = nil
CC.Refs.savedMouseBehavior = nil
CC.Refs.savedWS = 16; CC.Refs.savedJP = 50
CC.Refs.freecamPos = Vector3.new(0,0,0)
CC.Refs.freecamYaw = 0; CC.Refs.freecamPitch = 0
CC.Refs.noRecoilConn = nil
CC.Refs.noRecoilShotConn = nil
CC.Refs.lockedCamCF = nil
CC.Refs.recoilActive = false
CC.Refs.recoilLastInput = 0
CC.Refs.savedMotorTransforms = {}
CC.Refs.origLight = { Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime, FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart, GlobalShadows=Lighting.GlobalShadows, Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient }
CC.Refs.origAtmosphere = nil; CC.Refs.origClouds = nil
CC.Refs.origSky = nil; CC.Refs.customSky = nil
CC.Refs.Drawings = {}; CC.Refs.Highlights = {}; CC.Refs.Skeletons = {}; CC.Refs.WeaponLabels = {}
CC.Refs.HudPanel = nil
CC.Refs.fpsRow = nil; CC.Refs.pingRow = nil; CC.Refs.hpRow = nil; CC.Refs.posRow = nil; CC.Refs.statusRow = nil
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
    if Flags.FOVEnabled and Flags.FOVBindActive then return Flags.FOVValue end
    return nil
end

local function rawSetFOV(value)
    CC.Refs._fovWriting = true
    pcall(function() Camera.FieldOfView = value end)
    CC.Refs._fovWriting = false
end

do
    local ok, err = pcall(function()
        local oldNewIndex
        oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
            if key == "FieldOfView" and typeof(self) == "Instance" and self:IsA("Camera") then
                CC.Refs.gameWantsFOV = value
                CC.Refs.lastRealFOV  = value
                if CC.Refs._fovWriting then return oldNewIndex(self, key, value) end
                if getDesiredFOV() then return oldNewIndex(self, key, CC.Refs.fovAnimValue) end
            end
            return oldNewIndex(self, key, value)
        end)
    end)
    if not ok then warn("[cloudclient] FOV __newindex hook failed:", err) end
end

do
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
    if not ok then warn("[cloudclient] FOV __index hook failed:", err) end
end

local function startFOVController()
    if CC.Refs.zoomConn then return end
    if not CC.Refs.DefaultFOV or CC.Refs.DefaultFOV <= 0 then
        CC.Refs.DefaultFOV = Camera.FieldOfView
        Flags.DefaultFOV = CC.Refs.DefaultFOV
    end
    CC.Refs.fovAnimValue = Camera.FieldOfView
    CC.Refs.gameWantsFOV = Camera.FieldOfView

    CC.Refs.zoomConn = RunService.RenderStepped:Connect(function(dt)
        local target = getDesiredFOV()
        if not target then
            if math.abs(CC.Refs.fovAnimValue - CC.Refs.DefaultFOV) > 0.1 then
                CC.Refs.fovAnimActive = true
                local alpha = math.min(dt * 12, 1)
                CC.Refs.fovAnimValue = CC.Refs.fovAnimValue + (CC.Refs.DefaultFOV - CC.Refs.fovAnimValue) * alpha
                if math.abs(CC.Refs.fovAnimValue - CC.Refs.DefaultFOV) <= 0.1 then
                    CC.Refs.fovAnimValue = CC.Refs.DefaultFOV
                    CC.Refs.fovAnimActive = false
                end
                rawSetFOV(CC.Refs.fovAnimValue)
            elseif CC.Refs.fovAnimActive then
                CC.Refs.fovAnimActive = false
            end
            return
        end
        CC.Refs.fovAnimActive = true
        local cur = CC.Refs.fovAnimValue
        if math.abs(cur - target) <= 0.01 then
            CC.Refs.fovAnimValue = target
        else
            local alpha = math.min(dt * 12, 1)
            CC.Refs.fovAnimValue = cur + (target - cur) * alpha
            if math.abs(CC.Refs.fovAnimValue - target) <= 0.1 then
                CC.Refs.fovAnimValue = target
            end
        end
        rawSetFOV(CC.Refs.fovAnimValue)
    end)
end

local function stopFOVController()
    if CC.Refs.zoomConn then CC.Refs.zoomConn:Disconnect(); CC.Refs.zoomConn = nil end
    CC.Refs.fovAnimActive = false
end

local function applyCameraZoom()
    startFOVController()
end
applyCameraZoom()

-- ===== УТИЛИТА: проекция с учётом нашего реального FOV =====
local function fovWorldToViewport(pos)
    local realFov
    if getDesiredFOV() then
        realFov = CC.Refs.fovAnimValue
    else
        realFov = Camera.FieldOfView
    end
    local rel = Camera.CFrame:PointToObjectSpace(pos)
    if rel.Z >= 0 then
        return Vector3.new(0, 0, -1)
    end
    local tanHalf = math.tan(math.rad(realFov) * 0.5)
    local vs = Camera.ViewportSize
    local aspect  = vs.X / vs.Y
    local nx = rel.X / (-rel.Z * tanHalf * aspect)
    local ny = rel.Y / (-rel.Z * tanHalf)
    local sx = (nx + 1) * 0.5 * vs.X
    local sy = (1 - ny) * 0.5 * vs.Y
    return Vector3.new(sx, sy, -rel.Z)
end

-- ===== REMOVE CONSTRUCTIONS (ПЕРЕНОС В ПАПКУ) =====
CC.Refs.CleanerConn = nil
CC.Refs.LastWallScan = 0
CC.Refs.HiddenWalls = {}

-- Создаем скрытую папку для стен (она не рендерится, если ее нет в workspace)
local hiddenFolder = Instance.new("Folder")
hiddenFolder.Name = "CC_HiddenWalls"

local function toggleRemoveConstructions(state)
    Flags.RemoveConstructions = state
    
    if state then
        hiddenFolder.Parent = game:GetService("ReplicatedStorage") -- Прячем в RS, чтобы не рендерилось
        
        if CC.Refs.CleanerConn then CC.Refs.CleanerConn:Disconnect() end
        CC.Refs.CleanerConn = RunService.Heartbeat:Connect(function()
            if os.clock() - (CC.Refs.LastWallScan or 0) < 0.4 then return end
            CC.Refs.LastWallScan = os.clock()

            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local params = OverlapParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {char}

            local partsInRadius = workspace:GetPartBoundsInRadius(root.Position, Flags.RemoveDistance, params)
            local destroyed = {}

            for _, part in ipairs(partsInRadius) do
                local model = part.Parent
                if model and model:IsA("Model") and not destroyed[model] then
                    local name = string.lower(model.Name)
                    if string.find(name, "wall", 1, true) and not string.find(name, "door") and not string.find(name, "roof") then
                        destroyed[model] = true
                        
                        -- СОХРАНЯЕМ И ПЕРЕНОСИМ
                        table.insert(CC.Refs.HiddenWalls, {
                            model = model,
                            originalParent = model.Parent
                        })
                        model.Parent = hiddenFolder
                    end
                end
            end
        end)
    else
        -- ВЫКЛЮЧАЕМ И ВОЗВРАЩАЕМ
        if CC.Refs.CleanerConn then
            CC.Refs.CleanerConn:Disconnect()
            CC.Refs.CleanerConn = nil
        end
        
        for _, data in ipairs(CC.Refs.HiddenWalls) do
            if data.model and data.model.Parent == hiddenFolder then
                data.model.Parent = data.originalParent
            end
        end
        CC.Refs.HiddenWalls = {}
        hiddenFolder.Parent = nil
    end
end

-- ===== WEAPON COLOR =====
local function applyWeaponColorToModel(model)
    if not model then return end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            if not CC.Refs.OriginalWeaponProps[part] then
                CC.Refs.OriginalWeaponProps[part] = { Color = part.Color, Material = part.Material, TextureID = part:IsA("MeshPart") and part.TextureID or nil }
            end
            if part:IsA("MeshPart") and Flags.WeaponMaterial == Enum.Material.Neon then part.TextureID = "" end
            part.Color = Flags.WeaponColor
            part.Material = Flags.WeaponMaterial
        end
    end
end

local function restoreWeaponColorFromModel(model)
    if not model then return end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local orig = CC.Refs.OriginalWeaponProps[part]
            if orig then
                part.Color = orig.Color; part.Material = orig.Material
                if orig.TextureID and part:IsA("MeshPart") then part.TextureID = orig.TextureID end
                CC.Refs.OriginalWeaponProps[part] = nil
            end
        end
    end
end

local function findWeaponModels()
    local models = {}
    local char = LP.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then table.insert(models, tool) end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Model") and (child:FindFirstChild("Handle") or child:FindFirstChild("GunComponents")) then table.insert(models, child) end
        end
    end
    local vm = Camera:FindFirstChild("Viewmodel") or Camera:FindFirstChild("ViewModel")
    if vm then
        table.insert(models, vm)
        for _, child in ipairs(vm:GetChildren()) do
            if child:IsA("Model") then table.insert(models, child) end
        end
    end
    return models
end

local function startWeaponColor()
    if CC.Refs.weaponColorConn then CC.Refs.weaponColorConn:Disconnect() end
    CC.Refs.weaponColorConn = RunService.Heartbeat:Connect(function()
        if not Flags.WeaponColorEnabled then
            for _, m in ipairs(CC.Refs.lastWeaponModels) do restoreWeaponColorFromModel(m) end
            CC.Refs.lastWeaponModels = {}
            return
        end
        local currentModels = findWeaponModels()
        for _, oldM in ipairs(CC.Refs.lastWeaponModels) do
            local stillEquipped = false
            for _, newM in ipairs(currentModels) do if oldM == newM then stillEquipped = true; break end end
            if not stillEquipped then restoreWeaponColorFromModel(oldM) end
        end
        CC.Refs.lastWeaponModels = currentModels
        for _, m in ipairs(currentModels) do applyWeaponColorToModel(m) end
    end)
end

-- ===== ASPECT RATIO =====
local ASPECT_VALUES = { ["4:3"] = 0.75, ["16:9"] = 1.0 }

local function stopAspectRatio()
    if CC.Refs.aspectConn then CC.Refs.aspectConn:Disconnect(); CC.Refs.aspectConn = nil end
end

local function startAspectRatio()
    stopAspectRatio()
    if not Flags.AspectRatioEnabled then return end
    local res = ASPECT_VALUES[Flags.AspectRatioMode] or 1.0
    Flags.AspectRatioValue = res
    CC.Refs.aspectConn = RunService.RenderStepped:Connect(function()
        if not Flags.AspectRatioEnabled then return end
        Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, res, 0, 0, 0, 1)
    end)
end

local function applyAspectRatio()
    if Flags.AspectRatioEnabled then startAspectRatio() else stopAspectRatio() end
end

-- ===== ХИТБОКС =====
local function restoreHitbox(char)
    if not char then return end
    for part, size in pairs(CC.Refs.OriginalHitboxSizes) do
        if part and part.Parent then pcall(function() part.Size = size end); pcall(function() part.CanCollide = true end) end
    end
    for part in pairs(CC.Refs.OriginalHitboxSizes) do if part and not part.Parent then CC.Refs.OriginalHitboxSizes[part] = nil end end
end

local function restoreAllHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do if plr.Character then restoreHitbox(plr.Character) end end
end

local function applyHitbox(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
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

local function updateHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            if Flags.HitboxEnabled and isAlive(plr.Character) then applyHitbox(plr.Character) else restoreHitbox(plr.Character) end
        end
    end
end

-- ===== SILENT AIM =====
pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if self == Mouse and Flags.Aimbot and Flags.SilentAim and not Flags.AimlockMode and CC.Refs.CurrentTargetPart then
            if math.random(1, 100) > Flags.HitChance then return oldIndex(self, key) end
            local targetPos = CC.Refs.CurrentTargetPart.Position
            if Flags.AimPrediction > 0 then targetPos = targetPos + (getVelocity(CC.Refs.CurrentTargetPart) * Flags.AimPrediction) end
            if key == "Hit" then return CFrame.new(targetPos)
            elseif key == "Target" then return CC.Refs.CurrentTargetPart
            elseif key == "UnitRay" then
                local origin = Camera.CFrame.Position
                local dir = (targetPos - origin).Unit
                return Ray.new(origin, dir * 1000)
            elseif key == "Origin" then return Camera.CFrame.Position
            elseif key == "Direction" then return (targetPos - Camera.CFrame.Position).Unit
            end
        end
        return oldIndex(self, key)
    end)
end)

pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if (method == "ScreenPointToRay" or method == "ViewportPointToRay") and self == Camera and Flags.Aimbot and Flags.SilentAim and not Flags.AimlockMode and CC.Refs.CurrentTargetPart then
            local targetPos = CC.Refs.CurrentTargetPart.Position
            if Flags.AimPrediction > 0 then targetPos = targetPos + (getVelocity(CC.Refs.CurrentTargetPart) * Flags.AimPrediction) end
            local origin = Camera.CFrame.Position
            local dir = (targetPos - origin).Unit
            return Ray.new(origin, dir * 1000)
        end
        return oldNamecall(self, ...)
    end)
end)

if hookfunction then
    pcall(function()
        local oldScreen = Camera.ScreenPointToRay
        hookfunction(oldScreen, function(self, x, y, depth)
            if self == Camera and Flags.Aimbot and Flags.SilentAim and not Flags.AimlockMode and CC.Refs.CurrentTargetPart then
                local targetPos = CC.Refs.CurrentTargetPart.Position
                if Flags.AimPrediction > 0 then targetPos = targetPos + (getVelocity(CC.Refs.CurrentTargetPart) * Flags.AimPrediction) end
                local origin = self.CFrame.Position
                local dir = (targetPos - origin).Unit
                return Ray.new(origin, dir * 1000)
            end
            return oldScreen(self, x, y, depth)
        end)
    end)
    pcall(function()
        local oldViewport = Camera.ViewportPointToRay
        hookfunction(oldViewport, function(self, x, y, depth)
            if self == Camera and Flags.Aimbot and Flags.SilentAim and not Flags.AimlockMode and CC.Refs.CurrentTargetPart then
                local targetPos = CC.Refs.CurrentTargetPart.Position
                if Flags.AimPrediction > 0 then targetPos = targetPos + (getVelocity(CC.Refs.CurrentTargetPart) * Flags.AimPrediction) end
                local origin = self.CFrame.Position
                local dir = (targetPos - origin).Unit
                return Ray.new(origin, dir * 1000)
            end
            return oldViewport(self, x, y, depth)
        end)
    end)
end

-- ===== ПОИСК ЦЕЛИ =====
local function getClosestTarget()
    local closest, closestPart
    local shortest = math.huge
    local localRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local localPos = localRoot and localRoot.Position or Vector3.zero
    local vs = Camera.ViewportSize
    local center = Vector2.new(vs.X/2, vs.Y/2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isAlive(plr.Character) then
            if Flags.AimTeamCheck and LP.Team and plr.Team and plr.Team == LP.Team then continue end
            local part = getAimPart(plr.Character)
            if part then
                local sp = fovWorldToViewport(part.Position)
                if sp.Z > 0 then
                    local screenDist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                    if screenDist < Flags.AimFOV then
                        local worldDist = (part.Position - localPos).Magnitude
                        if worldDist < shortest then shortest = worldDist; closest = plr; closestPart = part end
                    end
                end
            end
        end
    end
    return closest, closestPart
end

-- ===== AIM ASSIST + AIM LOCK =====
RunService:BindToRenderStep("CloudClientAimbot", Enum.RenderPriority.Last.Value, function(dt)
    if not Flags.Aimbot or not CC.Refs.CurrentTargetPart then
        if Camera.CameraType == Enum.CameraType.Scriptable then Camera.CameraType = Enum.CameraType.Custom end
        return
    end
    local aiming = isAimHeld()
    if Flags.AimlockMode and aiming then
        if Camera.CameraType ~= Enum.CameraType.Scriptable then Camera.CameraType = Enum.CameraType.Scriptable end
        local camPos = Camera.CFrame.Position
        local targetPos = CC.Refs.CurrentTargetPart.Position
        if Flags.AimPrediction > 0 then targetPos = targetPos + (getVelocity(CC.Refs.CurrentTargetPart) * Flags.AimPrediction) end
        Camera.CFrame = CFrame.lookAt(camPos, targetPos)
    elseif Flags.AimAssist and aiming then
        local camPos = Camera.CFrame.Position
        local targetPos = CC.Refs.CurrentTargetPart.Position
        if Flags.AimPrediction > 0 then targetPos = targetPos + (getVelocity(CC.Refs.CurrentTargetPart) * Flags.AimPrediction) end
        local lookCF = CFrame.lookAt(camPos, targetPos)
        local base = 1 / math.max(1, Flags.AimSmooth)
        local alpha = 1 - (1 - base) ^ (dt * 60)
        Camera.CFrame = Camera.CFrame:Lerp(lookCF, alpha)
    else
        if Camera.CameraType == Enum.CameraType.Scriptable then Camera.CameraType = Enum.CameraType.Custom end
    end
end)

-- ===== TRIGGER BOT =====
local triggerLastShot = 0
local triggerRayParams = RaycastParams.new()
triggerRayParams.FilterType = Enum.RaycastFilterType.Exclude
triggerRayParams.FilterDescendantsInstances = {LP.Character}

local function isCrosshairOnTarget(part)
    if not part then return false end
    local vs = Camera.ViewportSize
    local center = Vector2.new(vs.X/2, vs.Y/2)
    local sp = fovWorldToViewport(part.Position)
    if sp.Z <= 0 then return false end
    local dist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
    return dist <= Flags.TriggerFOV
end

local function tryTriggerShot()
    if not Flags.TriggerBot or not CC.Refs.CurrentTargetPart then return end
    if os.clock() - triggerLastShot < (Flags.TriggerDelay / 1000) then return end
    if UI.Window.Gui and UI.Window.Gui.Enabled then return end

    triggerRayParams.FilterDescendantsInstances = {LP.Character}
    local origin = Camera.CFrame.Position
    local dir = (CC.Refs.CurrentTargetPart.Position - origin)
    local ray = workspace:Raycast(origin, dir, triggerRayParams)
    if ray and ray.Instance then
        local hitChar = ray.Instance:FindFirstAncestorOfClass("Model")
        if hitChar ~= CC.Refs.CurrentTargetPart.Parent then return end
    end
    if not isCrosshairOnTarget(CC.Refs.CurrentTargetPart) then return end

    triggerLastShot = os.clock()
    local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
    if tool then tool:Activate(); return end

    if mouse1click then pcall(mouse1click)
    else
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 1)
            task.wait(0.01)
            vim:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 1)
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if Flags.Aimbot or Flags.TriggerBot then
        local _, part = getClosestTarget()
        CC.Refs.CurrentTargetPart = part
    else
        CC.Refs.CurrentTargetPart = nil
    end
    if Flags.TriggerBot then tryTriggerShot() end
end)

RunService.Heartbeat:Connect(function() if Flags.HitboxEnabled then updateHitboxes() end end)

-- ===== FOV CIRCLE =====
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1; fovCircle.Color = Color3.fromRGB(255,255,255)
fovCircle.Filled = false; fovCircle.Visible = false; fovCircle.NumSides = 64

RunService.RenderStepped:Connect(function()
    if Flags.Aimbot then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Radius = Flags.AimFOV; fovCircle.Visible = true
    elseif fovCircle.Visible then fovCircle.Visible = false end
end)

-- ===== CROSSHAIR =====
local crossTop    = Drawing.new("Line"); crossTop.Visible = false
local crossBottom = Drawing.new("Line"); crossBottom.Visible = false
local crossLeft   = Drawing.new("Line"); crossLeft.Visible = false
local crossRight  = Drawing.new("Line"); crossRight.Visible = false

RunService.RenderStepped:Connect(function()
    if Flags.Crosshair then
        local cx, cy = math.floor(Camera.ViewportSize.X/2), math.floor(Camera.ViewportSize.Y/2)
        local sz = math.max(Flags.CrosshairSize, 4)
        local gap = math.max(Flags.CrosshairDistance, 0)
        local trans = 1 - (Flags.CrosshairTransparency / 100)
        crossTop.From = Vector2.new(cx, cy - gap); crossTop.To = Vector2.new(cx, math.max(cy - gap - sz, 0))
        crossBottom.From = Vector2.new(cx, cy + gap); crossBottom.To = Vector2.new(cx, cy + gap + sz)
        crossLeft.From = Vector2.new(cx - gap, cy); crossLeft.To = Vector2.new(math.max(cx - gap - sz, 0), cy)
        crossRight.From = Vector2.new(cx + gap, cy); crossRight.To = Vector2.new(cx + gap + sz, cy)
        for _, line in ipairs({crossTop, crossBottom, crossLeft, crossRight}) do
            line.Color = Flags.CrosshairColor; line.Thickness = Flags.CrosshairThickness
            line.Transparency = trans; line.Visible = true
        end
    else
        crossTop.Visible = false; crossBottom.Visible = false; crossLeft.Visible = false; crossRight.Visible = false
    end
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
local RECOIL_HOLD_TIME = 0.45

pcall(function()
    local camIndex
    camIndex = hookmetamethod(game, "__newindex", function(self, key, value)
        if self == Camera and key == "CFrame" and Flags.NoRecoil and CC.Refs.recoilActive and CC.Refs.lockedCamCF then
            return camIndex(self, key, CC.Refs.lockedCamCF)
        end
        return camIndex(self, key, value)
    end)
end)

pcall(function()
    local camIndexGet
    camIndexGet = hookmetamethod(game, "__index", function(self, key)
        if self == Camera and Flags.NoRecoil and CC.Refs.recoilActive and CC.Refs.lockedCamCF then
            if key == "CFrame" then return CC.Refs.lockedCamCF end
        end
        return camIndexGet(self, key)
    end)
end)

local function stopNoRecoil()
    if CC.Refs.noRecoilConn then
        pcall(function() RunService:UnbindFromRenderStep("CloudNoRecoil") end)
        CC.Refs.noRecoilConn = nil
    end
    if CC.Refs.noRecoilShotConn then pcall(function() CC.Refs.noRecoilShotConn:Disconnect() end); CC.Refs.noRecoilShotConn = nil end
    CC.Refs.recoilActive = false; CC.Refs.lockedCamCF = nil
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.CameraOffset = Vector3.zero end
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("Motor6D") and CC.Refs.savedMotorTransforms[d] then d.Transform = CC.Refs.savedMotorTransforms[d] end
        end
    end
end

local function startNoRecoil()
    pcall(function() RunService:UnbindFromRenderStep("CloudNoRecoil") end)
    if CC.Refs.noRecoilConn then return end
    CC.Refs.noRecoilShotConn = UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        CC.Refs.recoilLastInput = os.clock()
        CC.Refs.recoilActive = false
        CC.Refs.lockedCamCF = nil
    end)
    CC.Refs.noRecoilConn = RunService:BindToRenderStep("CloudNoRecoil", Enum.RenderPriority.Camera.Value + 1, function()
        if not Flags.NoRecoil then stopNoRecoil(); return end
        local char = LP.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local lmb  = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        if lmb then CC.Refs.recoilLastInput = os.clock() end
        local now      = os.clock()
        local shooting = lmb and (now - CC.Refs.recoilLastInput <= RECOIL_HOLD_TIME)
        if hum and hum.CameraOffset.Magnitude > 0.0001 then hum.CameraOffset = Vector3.zero end
        if char then
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("Motor6D") then
                    if not CC.Refs.savedMotorTransforms[d] then CC.Refs.savedMotorTransforms[d] = d.Transform end
                    if d.Transform ~= CC.Refs.savedMotorTransforms[d] then d.Transform = CC.Refs.savedMotorTransforms[d] end
                end
            end
        end
        if not shooting then
            if CC.Refs.recoilActive then CC.Refs.recoilActive = false; CC.Refs.lockedCamCF = nil end
            return
        end
        if not hrp then return end
        if not CC.Refs.recoilActive or not CC.Refs.lockedCamCF then
            CC.Refs.lockedCamCF  = Camera.CFrame
            CC.Refs.recoilActive = true
        else
            local rel = hrp.CFrame:ToObjectSpace(CC.Refs.lockedCamCF)
            CC.Refs.lockedCamCF = hrp.CFrame * rel
        end
        Camera.CFrame = CC.Refs.lockedCamCF
    end)
end

-- ===== RAPID FIRE =====
local function applyRapidFire()
    if CC.Refs.rapidFireConn then CC.Refs.rapidFireConn:Disconnect(); CC.Refs.rapidFireConn = nil end
    if not Flags.RapidFire then return end
    local lastShot = 0
    CC.Refs.rapidFireConn = RunService.Heartbeat:Connect(function()
        if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
        if UI.Window.Gui and UI.Window.Gui.Enabled then return end
        local now = os.clock()
        if now - lastShot < (Flags.RapidFireDelay / 1000) then return end
        lastShot = now
        if mouse1click then pcall(mouse1click)
        else
            local vim = game:GetService("VirtualInputManager")
            pcall(function()
                vim:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 1)
                task.wait(0.01)
                vim:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 1)
            end)
        end
    end)
end

-- ===== FULLBRIGHT =====
local FULLBRIGHT_VALUES = { Brightness=2, ClockTime=12, FogEnd=1e5, FogStart=0, GlobalShadows=false, Ambient=Color3.fromRGB(178,178,178), OutdoorAmbient=Color3.fromRGB(178,178,178) }

local function captureAtmosphere()
    CC.Refs.origAtmosphere = {}
    for _, atm in ipairs(Lighting:GetChildren()) do
        if atm:IsA("Atmosphere") then table.insert(CC.Refs.origAtmosphere, {obj=atm, Density=atm.Density, Offset=atm.Offset, Color=atm.Color, Decay=atm.Decay, Glare=atm.Glare, Haze=atm.Haze}) end
    end
    CC.Refs.origClouds = {}
    for _, cl in ipairs(Lighting:GetChildren()) do
        if cl:IsA("Clouds") then table.insert(CC.Refs.origClouds, {obj=cl, Cover=cl.Cover, Density=cl.Density, Color=cl.Color, Enabled=cl.Enabled}) end
    end
end
captureAtmosphere()

local function applyFullbrightOnce()
    for key, val in pairs(FULLBRIGHT_VALUES) do if Lighting[key] ~= val then pcall(function() Lighting[key] = val end) end end
    for _, atm in ipairs(Lighting:GetChildren()) do
        if atm:IsA("Atmosphere") then
            if atm.Density ~= 0 then pcall(function() atm.Density = 0 end) end
            if atm.Haze ~= 0 then pcall(function() atm.Haze = 0 end) end
            if atm.Glare ~= 0 then pcall(function() atm.Glare = 0 end) end
        end
    end
    for _, cl in ipairs(Lighting:GetChildren()) do
        if cl:IsA("Clouds") then
            if cl.Cover ~= 0 then pcall(function() cl.Cover = 0 end) end
            if cl.Density ~= 0 then pcall(function() cl.Density = 0 end) end
        end
    end
end

local function restoreLighting()
    for key, val in pairs(CC.Refs.origLight) do pcall(function() Lighting[key] = val end) end
    if CC.Refs.origAtmosphere then
        for _, a in ipairs(CC.Refs.origAtmosphere) do
            if a.obj and a.obj.Parent then pcall(function() a.obj.Density=a.Density; a.obj.Offset=a.Offset; a.obj.Color=a.Color; a.obj.Decay=a.Decay; a.obj.Glare=a.Glare; a.obj.Haze=a.Haze end) end
        end
    end
    if CC.Refs.origClouds then
        for _, c in ipairs(CC.Refs.origClouds) do
            if c.obj and c.obj.Parent then pcall(function() c.obj.Cover=c.Cover; c.obj.Density=c.Density; c.obj.Color=c.Color; c.obj.Enabled=c.Enabled end) end
        end
    end
end

local function setFullbright(state)
    if state then captureAtmosphere(); applyFullbrightOnce() else restoreLighting() end
end

task.spawn(function()
    while true do
        task.wait(0.25)
        if Flags.Fullbright then applyFullbrightOnce() end
    end
end)

-- ===== SKY COLOR =====
local function setSkyColor(enabled, color)
    local lighting = Lighting
    if not CC.Refs.origSky then
        for _, child in ipairs(lighting:GetChildren()) do if child:IsA("Sky") then CC.Refs.origSky = child:Clone(); break end end
    end
    if enabled then
        if not CC.Refs.customSky then
            CC.Refs.customSky = Instance.new("Sky")
            CC.Refs.customSky.Name = "CloudClientCustomSky"
            CC.Refs.customSky.Parent = lighting
        end
        local c = color or Flags.SkyColor
        CC.Refs.customSky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
        CC.Refs.customSky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
        CC.Refs.customSky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
        CC.Refs.customSky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
        CC.Refs.customSky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
        CC.Refs.customSky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
        CC.Refs.customSky.SunAngularSize = 0; CC.Refs.customSky.MoonAngularSize = 0
        local cc = lighting:FindFirstChild("CloudClientSkyTint")
        if not cc then cc = Instance.new("ColorCorrectionEffect"); cc.Name = "CloudClientSkyTint"; cc.Parent = lighting end
        cc.TintColor = c; cc.Brightness = 0; cc.Contrast = 0; cc.Saturation = 0
    else
        if CC.Refs.customSky then CC.Refs.customSky:Destroy(); CC.Refs.customSky = nil end
        local cc = lighting:FindFirstChild("CloudClientSkyTint")
        if cc then cc:Destroy() end
    end
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

local function clearHighlight(plr)
    if CC.Refs.Highlights[plr] then pcall(function() CC.Refs.Highlights[plr]:Destroy() end); CC.Refs.Highlights[plr] = nil end
end

local function removeDrawings(plr)
    if CC.Refs.Drawings[plr] then
        for _,o in pairs(CC.Refs.Drawings[plr]) do if o then pcall(function() o:Remove() end) end end
        CC.Refs.Drawings[plr]=nil
    end
    clearHighlight(plr)
    if CC.Refs.Skeletons[plr] then for _,l in pairs(CC.Refs.Skeletons[plr].lines) do pcall(function() l:Remove() end) end; CC.Refs.Skeletons[plr]=nil end
    if CC.Refs.WeaponLabels[plr] then pcall(function() CC.Refs.WeaponLabels[plr]:Remove() end); CC.Refs.WeaponLabels[plr]=nil end
end

local function applyHighlight(plr)
    if plr == LP then return end
    local char = plr.Character
    local want = Flags.ESP and Flags.MaxDistance > 0
    if not want or not char or not isAlive(char) then clearHighlight(plr); return end
    local hl = CC.Refs.Highlights[plr]
    if not hl or not hl.Parent then
        if hl then pcall(function() hl:Destroy() end) end
        hl = Instance.new("Highlight")
        hl.Name = "CloudClientESP"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char
        CC.Refs.Highlights[plr] = hl
    end
    if hl.DepthMode ~= Enum.HighlightDepthMode.AlwaysOnTop then hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end
    if Flags.ESPMode == "Chams" then hl.FillColor = Flags.ESPColor; hl.FillTransparency = 0; hl.OutlineColor = Flags.ESPColor; hl.OutlineTransparency = 1
    else hl.FillColor = Flags.ESPColor; hl.FillTransparency = 1; hl.OutlineColor = Flags.ESPColor; hl.OutlineTransparency = 0 end
end

-- ===== SKELETON =====
local SKELETON_CONNECTIONS = { {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"} }
local R6_CONNECTIONS = { {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"} }

local function ensureSkeleton(plr, isR15)
    local sk = CC.Refs.Skeletons[plr]
    local conns = isR15 and SKELETON_CONNECTIONS or R6_CONNECTIONS
    if sk and #sk.lines == #conns then return end
    if sk then for _,l in pairs(sk.lines) do pcall(function() l:Remove() end) end end
    local lines = {}
    for i = 1, #conns do local l = Drawing.new("Line"); l.Thickness=1; l.Visible=false; lines[i] = l end
    CC.Refs.Skeletons[plr] = {lines = lines, conns = conns}
end

local function updateSkeleton(plr, char)
    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    ensureSkeleton(plr, isR15)
    local sk = CC.Refs.Skeletons[plr]
    if not sk then return end
    for i, conn in ipairs(sk.conns) do
        local p1 = char:FindFirstChild(conn[1]); local p2 = char:FindFirstChild(conn[2]); local line = sk.lines[i]
        if p1 and p2 then
            local s1 = fovWorldToViewport(p1.Position); local s2 = fovWorldToViewport(p2.Position)
            if s1.Z > 0 and s2.Z > 0 then line.From = Vector2.new(s1.X, s1.Y); line.To = Vector2.new(s2.X, s2.Y); line.Color = Flags.SkeletonColor; line.Visible = true
            elseif line.Visible then line.Visible = false end
        elseif line.Visible then line.Visible = false end
    end
end

-- ===== WEAPON ESP =====
local WEAPON_IGNORE = { Handle = true, Grip = true, Attachment = true, Attachment1 = true, ["LeftGrip"] = true, ["RightGrip"] = true, ["Tool"] = true, Head = true, Torso = true, UpperTorso = true, LowerTorso = true, ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true, LeftUpperArm = true, RightUpperArm = true, LeftLowerArm = true, RightLowerArm = true, LeftUpperLeg = true, RightUpperLeg = true, LeftLowerLeg = true, RightLowerLeg = true, HumanoidRootPart = true, Humanoid = true, [""] = true, ["None"] = true, ["Nil"] = true, ["Part"] = true, ["Mesh"] = true }

local function isMeaningfulName(name)
    if not name or name == "" then return false end
    if WEAPON_IGNORE[name] then return false end
    if #name < 2 then return false end
    if tonumber(name) then return false end
    return true
end

local function getWeaponName(char)
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    if isMeaningfulName(tool.Name) then return tool.Name end
    for _, child in ipairs(tool:GetChildren()) do if child:IsA("BasePart") and isMeaningfulName(child.Name) then return child.Name end end
    return nil
end

local function updateHighlightDistance(plr, dist, visible)
    local hl = CC.Refs.Highlights[plr]
    if not hl or not hl.Parent then return end
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
    local localRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then hideAll(); return end
    local localPos = localRoot.Position
    local vs = Camera.ViewportSize
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
        if Flags.Box and hS.Z > 0 and fS.Z > 0 then
            local h = math.abs(hS.Y - fS.Y); local w = h * 0.5
            d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(sx - w/2, hS.Y); d.Box.Color = Flags.BoxColor
            if not d.Box.Visible then d.Box.Visible = true end
        elseif d.Box.Visible then d.Box.Visible = false end
        if Flags.Name then d.Name.Text = plr.Name; d.Name.Position = Vector2.new(sx, hS.Y-18); d.Name.Color = Flags.TextColor; if not d.Name.Visible then d.Name.Visible = true end
        elseif d.Name.Visible then d.Name.Visible = false end
        if Flags.Health then d.Health.Text = "HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth); d.Health.Position = Vector2.new(sx, fS.Y+2); d.Health.Color = Flags.TextColor; if not d.Health.Visible then d.Health.Visible = true end
        elseif d.Health.Visible then d.Health.Visible = false end
        if Flags.Distance then d.Distance.Text = math.floor(dist).."m"; d.Distance.Position = Vector2.new(sx, fS.Y+18); d.Distance.Color = Flags.TextColor; if not d.Distance.Visible then d.Distance.Visible = true end
        elseif d.Distance.Visible then d.Distance.Visible = false end
        if Flags.Line then d.Line.From = Vector2.new(vs.X/2, vs.Y); d.Line.To = Vector2.new(sx, sy); d.Line.Color = Flags.LineColor; if not d.Line.Visible then d.Line.Visible = true end
        elseif d.Line.Visible then d.Line.Visible = false end
        if Flags.WeaponESP then
            local weaponName = getWeaponName(char)
            if weaponName then d.Weapon.Text = "["..weaponName.."]"; d.Weapon.Position = Vector2.new(sx, fS.Y + 34); d.Weapon.Color = Flags.TextColor; if not d.Weapon.Visible then d.Weapon.Visible = true end
            elseif d.Weapon.Visible then d.Weapon.Visible = false end
        elseif d.Weapon.Visible then d.Weapon.Visible = false end
        if Flags.Skeleton then updateSkeleton(plr, char)
        else local sk = CC.Refs.Skeletons[plr]; if sk then for _,l in pairs(sk.lines) do if l.Visible then l.Visible=false end end end end
        updateHighlightDistance(plr, dist, true)
    end
end

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

-- ===== FPS/PING HUD =====
local StatsService = game:GetService("Stats")

local function createHud()
    CC.Refs.HudPanel = CC.Lib:CreateNewWindow({ Title = "Stats", Name = "CloudClientStats", Size = {220}, Minimizable = true })
    CC.Refs.HudPanel:AddHeader("Performance")
    CC.Refs.fpsRow  = CC.Refs.HudPanel:AddRow("FPS")
    CC.Refs.pingRow = CC.Refs.HudPanel:AddRow("Ping")
    CC.Refs.HudPanel:AddSeparator()
    CC.Refs.HudPanel:AddHeader("Player")
    CC.Refs.hpRow   = CC.Refs.HudPanel:AddRow("Health")
    CC.Refs.posRow  = CC.Refs.HudPanel:AddRow("Position", { Style = "Vertical", AccentKey = "white", ValueColorKey = "text" })
    CC.Refs.HudPanel:AddSeparator()
    CC.Refs.HudPanel:AddHeader("Status")
    CC.Refs.statusRow = CC.Refs.HudPanel:AddRow("State")
    CC.Refs.statusRow:Set("Idle")
end

local function destroyHud()
    if CC.Refs.HudPanel then pcall(function() CC.Refs.HudPanel:Destroy() end); CC.Refs.HudPanel = nil end
    CC.Refs.fpsRow, CC.Refs.pingRow, CC.Refs.hpRow, CC.Refs.posRow, CC.Refs.statusRow = nil, nil, nil, nil, nil
end

task.spawn(function()
    while true do
        if Flags.FPSPing then
            if not CC.Refs.HudPanel then createHud() end
            CC.Refs.hudFrames = CC.Refs.hudFrames + 1
            local now = os.clock()
            if now - CC.Refs.hudLast >= 1 then
                if CC.Refs.fpsRow then CC.Refs.fpsRow:Set(CC.Refs.hudFrames) end
                CC.Refs.hudFrames, CC.Refs.hudLast = 0, now
                local ok, ping = pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() end)
                if CC.Refs.pingRow then CC.Refs.pingRow:Set(ok and ping and (math.floor(ping).." ms") or "n/a") end
            end
            local char = LP.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if root and CC.Refs.posRow then local p = root.Position; CC.Refs.posRow:Set(string.format("%d, %d, %d", p.X, p.Y, p.Z)) end
            if hum and CC.Refs.hpRow then CC.Refs.hpRow:Set(string.format("%d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))) end
            if CC.Refs.statusRow then CC.Refs.statusRow:Set(Flags.ESP and "ESP on" or "ESP off") end
        elseif CC.Refs.HudPanel then destroyHud() end
        task.wait(0.1)
    end
end)

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
    if not Flags.ESP or Flags.MaxDistance <= 0 then hideAll(); return end
    local ok, err = pcall(updateESP)
    if not ok then warn("[cloudclient] ESP error, hiding:", err); pcall(hideAll) end
end)

-- ===== UI: AIMBOT =====
UI.Tabs.Aimbot = UI.Window:AddTab("Aimbot", "crosshair")

UI.Elements.aimbotToggle = UI.Tabs.Aimbot:AddToggle({Title="Aimbot", Icon="crosshair", Default=false, Callback=function(s) Flags.Aimbot=s end})
UI.Elements.aimAssistToggle = UI.Tabs.Aimbot:AddToggle({Title="Aim Assist", Subtitle="Двигает камеру на цель", Icon="eye", Default=true, Callback=function(s) Flags.AimAssist=s end})
UI.Elements.silentAimToggle = UI.Tabs.Aimbot:AddToggle({Title="Silent Aim", Subtitle="Хук Mouse.Hit / UnitRay / ScreenPointToRay", Icon="crosshair", Default=true, Callback=function(s) Flags.SilentAim=s end})
UI.Elements.aimlockToggle = UI.Tabs.Aimbot:AddToggle({Title="Aim Lock (rage)", Subtitle="Только при зажатой кнопке", Icon="lock", Default=false, Callback=function(s) Flags.AimlockMode=s end})
UI.Elements.aimSmoothSlider = UI.Tabs.Aimbot:AddSlider({Title="Smoothness", Icon="activity", Min=1, Max=100, Default=5, Callback=function(v) Flags.AimSmooth=v end})
UI.Elements.aimFovSlider = UI.Tabs.Aimbot:AddSlider({Title="Aim FOV", Icon="circle", Min=20, Max=400, Default=120, Callback=function(v) Flags.AimFOV=v end})
UI.Elements.aimPredSlider = UI.Tabs.Aimbot:AddSlider({Title="Prediction", Icon="trending-up", Min=0, Max=0.5, Default=0, Callback=function(v) Flags.AimPrediction=v end})
UI.Elements.aimChanceSlider = UI.Tabs.Aimbot:AddSlider({Title="Hit Chance %", Icon="percent", Min=0, Max=100, Default=100, Callback=function(v) Flags.HitChance=v end})
UI.Elements.aimPartDropdown = UI.Tabs.Aimbot:AddDropdown({Title="Target Part", Icon="user", Options={"Head","HumanoidRootPart","UpperTorso"}, Default="Head", Callback=function(s) Flags.AimPart=s end})
UI.Elements.teamCheckToggle = UI.Tabs.Aimbot:AddToggle({Title="Team Check", Icon="users", Default=true, Callback=function(s) Flags.AimTeamCheck=s end})
UI.Elements.aimKeyDropdown = UI.Tabs.Aimbot:AddDropdown({ Title = "Aim Key", Icon="mouse-pointer", Options = {"MouseButton2","MouseButton1","LeftShift","Q","E","C"}, Default = "MouseButton2", Callback = function(s) Flags.AimKey = Enum.UserInputType[s] or Enum.KeyCode[s] or Enum.UserInputType.MouseButton2 end })

UI.Tabs.Aimbot:AddSeparator(); UI.Tabs.Aimbot:AddLabel("TRIGGER BOT", "crosshair"); UI.Tabs.Aimbot:AddSeparator()

UI.Elements.triggerBotToggle = UI.Tabs.Aimbot:AddToggle({Title="Trigger Bot", Subtitle="Авто-выстрел при наведении", Icon="crosshair", Default=false, Callback=function(s) Flags.TriggerBot=s end})
UI.Elements.triggerFovSlider = UI.Tabs.Aimbot:AddSlider({Title="Trigger FOV", Icon="circle", Min=1, Max=60, Default=15, Callback=function(v) Flags.TriggerFOV=v end})
UI.Elements.triggerDelaySlider = UI.Tabs.Aimbot:AddSlider({Title="Trigger Delay (ms)", Icon="clock", Min=0, Max=500, Default=50, Callback=function(v) Flags.TriggerDelay=v end})
UI.Elements.triggerTeamToggle = UI.Tabs.Aimbot:AddToggle({Title="Trigger Team Check", Icon="users", Default=true, Callback=function(s) Flags.TriggerTeamCheck=s end})

UI.Tabs.Aimbot:AddSeparator(); UI.Tabs.Aimbot:AddLabel("HITBOX EXPANDER", "box"); UI.Tabs.Aimbot:AddSeparator()

UI.Elements.hitboxToggle = UI.Tabs.Aimbot:AddToggle({Title="Hitbox Expander", Icon="box", Default=false, Callback=function(s) Flags.HitboxEnabled=s; if not s then restoreAllHitboxes() end end})
UI.Elements.hitboxSizeSlider = UI.Tabs.Aimbot:AddSlider({Title="Hitbox Size", Icon="ruler", Min=1, Max=5, Default=2, Callback=function(v) Flags.HitboxSize=v end})
UI.Elements.hitboxTranspSlider = UI.Tabs.Aimbot:AddSlider({Title="Hitbox Transparency %", Icon="eye-off", Min=0, Max=100, Default=50, Callback=function(v) Flags.HitboxTransparency=v end})

UI.Tabs.Aimbot:AddSeparator(); UI.Tabs.Aimbot:AddLabel("COMBAT", "target"); UI.Tabs.Aimbot:AddSeparator()

UI.Elements.noRecoilToggle = UI.Tabs.Aimbot:AddToggle({ Title="No Recoil", Subtitle="Компенсация отдачи без ломки ходьбы", Icon="target", Default=false, Callback=function(s) Flags.NoRecoil = s; if s then startNoRecoil() else stopNoRecoil() end end })
UI.Elements.rapidFireToggle = UI.Tabs.Aimbot:AddToggle({Title="Rapid Fire", Subtitle="Авто-выстрел при зажатии ЛКМ", Icon="zap", Default=false, Callback=function(s) Flags.RapidFire=s; applyRapidFire() end})
UI.Elements.rapidFireDelaySlider = UI.Tabs.Aimbot:AddSlider({Title="Rapid Fire Delay (ms)", Icon="clock", Min=10, Max=300, Default=50, Callback=function(v) Flags.RapidFireDelay=v; if Flags.RapidFire then applyRapidFire() end end})

-- ===== UI: ESP =====
UI.Tabs.ESP = UI.Window:AddTab("ESP", "eye")

UI.Tabs.ESP:AddSeparator(); UI.Tabs.ESP:AddLabel("ESP COLOR", "palette"); UI.Tabs.ESP:AddSeparator()

UI.Elements.espColorPicker = UI.Tabs.ESP:AddColorPicker({Title="ESP Color", Icon="palette", Default=Flags.ESPColor, Callback=function(c) Flags.ESPColor=c; for _,hl in pairs(CC.Refs.Highlights) do if hl and hl.Parent then hl.FillColor = c; hl.OutlineColor = c end end end})
UI.Elements.textColorPicker = UI.Tabs.ESP:AddColorPicker({Title="Text Color", Icon="type", Default=Flags.TextColor, Callback=function(c) Flags.TextColor=c end})
UI.Elements.boxColorPicker = UI.Tabs.ESP:AddColorPicker({Title="Box Color", Icon="square", Default=Flags.BoxColor, Callback=function(c) Flags.BoxColor=c end})
UI.Elements.lineColorPicker = UI.Tabs.ESP:AddColorPicker({Title="Line Color", Icon="move", Default=Flags.LineColor, Callback=function(c) Flags.LineColor=c end})
UI.Elements.skelColorPicker = UI.Tabs.ESP:AddColorPicker({Title="Skeleton Color", Icon="bone", Default=Flags.SkeletonColor, Callback=function(c) Flags.SkeletonColor=c end})

UI.Tabs.ESP:AddSeparator(); UI.Tabs.ESP:AddLabel("ESP SYSTEM", "eye"); UI.Tabs.ESP:AddSeparator()

UI.Elements.espToggle = UI.Tabs.ESP:AddToggle({Title="ESP", Icon="eye", Default=false, Callback=function(s) Flags.ESP=s; for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end end})
UI.Elements.espModeDropdown = UI.Tabs.ESP:AddDropdown({Title="ESP Mode", Icon="layers", Options={"Chams","Glow"}, Default="Chams", Callback=function(v) Flags.ESPMode = v; for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end end})

UI.Elements.boxToggle = UI.Tabs.ESP:AddToggle({Title="Box", Icon="box", Default=false, Callback=function(s) Flags.Box=s end})
UI.Elements.nameToggle = UI.Tabs.ESP:AddToggle({Title="Name", Icon="user", Default=false, Callback=function(s) Flags.Name=s end})
UI.Elements.healthToggle = UI.Tabs.ESP:AddToggle({Title="Health", Icon="heart", Default=false, Callback=function(s) Flags.Health=s end})
UI.Elements.distToggle = UI.Tabs.ESP:AddToggle({Title="Distance", Icon="ruler", Default=false, Callback=function(s) Flags.Distance=s end})
UI.Elements.lineToggle = UI.Tabs.ESP:AddToggle({Title="Line", Icon="move", Default=false, Callback=function(s) Flags.Line=s end})
UI.Elements.skeletonToggle = UI.Tabs.ESP:AddToggle({Title="Skeleton", Icon="bone", Default=false, Callback=function(s) Flags.Skeleton=s end})
UI.Elements.weaponToggle = UI.Tabs.ESP:AddToggle({Title="Weapon ESP", Icon="sword", Default=false, Callback=function(s) Flags.WeaponESP=s end})

UI.Elements.espDistSlider = UI.Tabs.ESP:AddSlider({Title="ESP Distance", Icon="ruler", Min=250, Max=2000, Default=600, Callback=function(v) Flags.MaxDistance=v; for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end end})

-- ===== UI: VISUALS =====
UI.Tabs.Visuals = UI.Window:AddTab("Visuals", "palette")

UI.Tabs.Visuals:AddSeparator(); UI.Tabs.Visuals:AddLabel("WEAPON SKIN", "paintbrush"); UI.Tabs.Visuals:AddSeparator()

UI.Elements.weaponColorToggle = UI.Tabs.Visuals:AddToggle({Title="Enable Weapon Color", Subtitle="Неон на любое оружие", Icon="palette", Default=false, Callback=function(s) Flags.WeaponColorEnabled=s; if s then startWeaponColor() else for _, m in ipairs(CC.Refs.lastWeaponModels) do restoreWeaponColorFromModel(m) end; CC.Refs.lastWeaponModels = {}; if CC.Refs.weaponColorConn then CC.Refs.weaponColorConn:Disconnect(); CC.Refs.weaponColorConn = nil end end end})

UI.Elements.weaponColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="Neon Color", Icon="droplet", Default=Flags.WeaponColor, Callback=function(c) Flags.WeaponColor=c; if Flags.WeaponColorEnabled then for _, m in ipairs(CC.Refs.lastWeaponModels) do applyWeaponColorToModel(m) end end end})

UI.Elements.materialDropdown = UI.Tabs.Visuals:AddDropdown({ Title="Material", Icon="gem", Options={"Neon", "ForceField"}, Default="Neon", Callback=function(s) Flags.WeaponMaterial = Enum.Material[s] or Enum.Material.Neon; if Flags.WeaponColorEnabled then for _, m in ipairs(CC.Refs.lastWeaponModels) do applyWeaponColorToModel(m) end end end })

UI.Tabs.Visuals:AddSeparator(); UI.Tabs.Visuals:AddLabel("ASPECT RATIO", "monitor"); UI.Tabs.Visuals:AddSeparator()

UI.Elements.aspectToggle = UI.Tabs.Visuals:AddToggle({Title="Aspect Ratio", Subtitle="Сжатие вертикали камеры", Icon="monitor", Default=false, Callback=function(s) Flags.AspectRatioEnabled = s; applyAspectRatio() end})

UI.Elements.aspectModeDropdown = UI.Tabs.Visuals:AddDropdown({ Title="Ratio", Icon="rectangle-horizontal", Options={"4:3", "16:9"}, Default="16:9", Callback=function(v) Flags.AspectRatioMode = v; if Flags.AspectRatioEnabled then startAspectRatio() end end })

UI.Tabs.Visuals:AddSeparator(); UI.Tabs.Visuals:AddLabel("SKY COLOR", "cloud"); UI.Tabs.Visuals:AddSeparator()

UI.Elements.skyColorToggle = UI.Tabs.Visuals:AddToggle({Title="Custom Sky Color", Icon="cloud", Default=false, Callback=function(s) Flags.SkyColorEnabled=s; setSkyColor(s, Flags.SkyColor) end})
UI.Elements.skyColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="Sky Color", Icon="palette", Default=Flags.SkyColor, Callback=function(c) Flags.SkyColor=c; if Flags.SkyColorEnabled then setSkyColor(true, c) end end})

UI.Tabs.Visuals:AddSeparator(); UI.Tabs.Visuals:AddLabel("CROSSHAIR", "crosshair"); UI.Tabs.Visuals:AddSeparator()

UI.Elements.crosshairToggle = UI.Tabs.Visuals:AddToggle({Title="Enable Crosshair", Icon="crosshair", Default=false, Callback=function(s) Flags.Crosshair=s end})
UI.Elements.crosshairColorPicker = UI.Tabs.Visuals:AddColorPicker({Title="Crosshair Color", Icon="palette", Default=Flags.CrosshairColor, Callback=function(c) Flags.CrosshairColor=c end})
UI.Elements.crosshairSizeSlider = UI.Tabs.Visuals:AddSlider({Title="Size (Длина линий)", Icon="ruler", Min=4, Max=30, Default=10, Callback=function(v) Flags.CrosshairSize=v end})
UI.Elements.crosshairDistSlider = UI.Tabs.Visuals:AddSlider({Title="Distance (Отступ)", Icon="move", Min=0, Max=30, Default=4, Callback=function(v) Flags.CrosshairDistance=v end})
UI.Elements.crosshairThickSlider = UI.Tabs.Visuals:AddSlider({Title="Thickness (Толщина)", Icon="minus", Min=1, Max=5, Default=1, Callback=function(v) Flags.CrosshairThickness=v end})
UI.Elements.crosshairTranspSlider = UI.Tabs.Visuals:AddSlider({Title="Transparency (Прозрачность)", Icon="eye-off", Min=0, Max=100, Default=0, Callback=function(v) Flags.CrosshairTransparency=v end})

-- ===== UI: OTHER =====
UI.Tabs.Other = UI.Window:AddTab("Other", "box")
UI.Elements.fullbrightToggle = UI.Tabs.Other:AddToggle({Title="Fullbright", Icon="sun", Default=false, Callback=function(s) Flags.Fullbright=s; setFullbright(s) end})

-- ===== UI: LOOT =====
UI.Tabs.Loot = UI.Window:AddTab("Loot", "package")

UI.Tabs.Loot:AddSeparator()
UI.Tabs.Loot:AddLabel("COMING SOON", "clock")
UI.Tabs.Loot:AddSeparator()

-- ===== UI: MISC =====
UI.Tabs.Misc = UI.Window:AddTab("Misc", "settings-2")

UI.Tabs.Misc:AddLabel("PLAYER", "user")
UI.Tabs.Misc:AddSeparator()

UI.Elements.freecamToggle = UI.Tabs.Misc:AddToggle({Title="FreeCam", Subtitle="WASD + Space/Ctrl", Icon="camera", Default=false, Callback=function(s) Flags.FreeCam=s; if s then startFreeCam() else stopFreeCam() end end})
UI.Elements.keybindFreecam = UI.Tabs.Misc:AddKeybind({Title = "FreeCam Keybind", Icon = "keyboard", Callback = function() UI.Elements.freecamToggle:Set(not Flags.FreeCam) end})

UI.Tabs.Misc:AddSeparator()

-- zoom
UI.Elements.cameraZoomToggle = UI.Tabs.Misc:AddToggle({Title="Camera Zoom", Subtitle="Зажми бинд чтобы приблизить", Icon="zoom-in", Default=false, Callback=function(s) Flags.CameraZoom=s end})
UI.Elements.keybindCameraZoom = UI.Tabs.Misc:AddKeybind({Title = "Camera Zoom Keybind", Icon = "keyboard", Default = Enum.KeyCode.LeftAlt})

-- пустая строка-разделитель между zoom и fov
UI.Tabs.Misc:AddSeparator()
UI.Tabs.Misc:AddSeparator()

-- fov
UI.Elements.fovToggle = UI.Tabs.Misc:AddToggle({Title="FOV Changer", Subtitle="Фиксирует FOV, отключение → дефолт", Icon="focus", Default=false, Callback=function(s)
    Flags.FOVEnabled = s
    if s then
        Flags.FOVValue = math.clamp(Flags.FOVValue, Flags.DefaultFOV, 120)
        CC.Refs.fovSettled = false
    end
end})

UI.Elements.fovSlider = UI.Tabs.Misc:AddSlider({Title="FOV Value", Icon="move-horizontal", Min=70, Max=120, Default=70, Callback=function(v)
    Flags.FOVValue = v
    CC.Refs.fovSettled = false
end})

-- БИНД ДЛЯ FOV
UI.Elements.keybindFOV = UI.Tabs.Misc:AddKeybind({
    Title = "FOV Keybind",
    Subtitle = "Зажми для активации FOV",
    Icon = "keyboard",
    Default = Enum.KeyCode.C,
    Callback = function(key, pressed)
        if pressed then
            Flags.FOVBindActive = true
        else
            Flags.FOVBindActive = false
        end
    end
})

UI.Tabs.Misc:AddSeparator()

-- REMOVE CONSTRUCTIONS
UI.Elements.removeConstructionsToggle = UI.Tabs.Misc:AddToggle({
    Title = "Remove Constructions",
    Subtitle = "Скрывает стены вокруг тебя",
    Icon = "box",
    Default = false,
    Callback = function(s)
        toggleRemoveConstructions(s)
    end
})

UI.Elements.removeDistanceSlider = UI.Tabs.Misc:AddSlider({
    Title = "Remove Distance",
    Icon = "ruler",
    Min = 50, Max = 150, Default = 75,
    Callback = function(v) Flags.RemoveDistance = v end
})

-- БИНД ДЛЯ REMOVE CONSTRUCTIONS
UI.Elements.keybindRemoveConstructions = UI.Tabs.Misc:AddKeybind({
    Title = "Remove Constructions Keybind",
    Subtitle = "Вкл/Выкл стены",
    Icon = "keyboard",
    Default = Enum.KeyCode.V,
    Callback = function()
        UI.Elements.removeConstructionsToggle:Set(not Flags.RemoveConstructions)
    end
})

-- ===== UI: SETTINGS =====
UI.Tabs.Settings = UI.Window:AddTab("Settings", "settings")

UI.Elements.keyInfoLabel = UI.Tabs.Settings:AddLabel( string.format("Ключ: %s | до: %s", _G.CloudKeyState.key or "—", keyRemainingText()), "key" )

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
UI.Elements.statsHudToggle = UI.Tabs.Settings:AddToggle({Title="Stats HUD", Icon="gauge", Default=false, Callback=function(s) Flags.FPSPing=s end})

UI.Tabs.Settings:AddSeparator(); UI.Tabs.Settings:AddLabel("KEYBINDS", "keyboard"); UI.Tabs.Settings:AddSeparator()

UI.Elements.keybindESP = UI.Tabs.Settings:AddKeybind({Title = "ESP Keybind", Icon = "eye", Callback = function() UI.Elements.espToggle:Set(not Flags.ESP) end})
UI.Elements.keybindFullbright = UI.Tabs.Settings:AddKeybind({Title = "Fullbright Keybind", Icon = "sun", Callback = function() UI.Elements.fullbrightToggle:Set(not Flags.Fullbright) end})
UI.Elements.keybindTrigger = UI.Tabs.Settings:AddKeybind({Title = "Trigger Bot Keybind", Icon = "crosshair", Callback = function() UI.Elements.triggerBotToggle:Set(not Flags.TriggerBot) end})
UI.Elements.keybindHitbox = UI.Tabs.Settings:AddKeybind({Title = "Hitbox Keybind", Icon = "box", Callback = function() UI.Elements.hitboxToggle:Set(not Flags.HitboxEnabled) end})
UI.Elements.keybindNoRecoil = UI.Tabs.Settings:AddKeybind({Title = "No Recoil Keybind", Icon = "target", Callback = function() UI.Elements.noRecoilToggle:Set(not Flags.NoRecoil) end})
UI.Elements.keybindHideUI = UI.Tabs.Settings:AddKeybind({ Title = "Hide UI Keybind", Icon = "keyboard", Default = Enum.KeyCode.Delete, Callback = function() local sg = UI.Window.Gui; if sg then sg.Enabled = not sg.Enabled end end })

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not Flags.CameraZoom then return end
    local zoomBind = UI.Elements.keybindCameraZoom and UI.Elements.keybindCameraZoom:Get()
    if zoomBind and input.KeyCode == zoomBind then
        Flags.ZoomActive = true
    end
end)

UIS.InputEnded:Connect(function(input, gpe)
    local zoomBind = UI.Elements.keybindCameraZoom and UI.Elements.keybindCameraZoom:Get()
    if zoomBind and input.KeyCode == zoomBind then
        Flags.ZoomActive = false
    end
end)

UI.buildConfig = function(name)
    local cfg = UI.Window.ConfigManager:CreateConfig(name)

    cfg:RegisterElement("Aimbot", UI.Elements.aimbotToggle)
    cfg:RegisterElement("AimAssist", UI.Elements.aimAssistToggle)
    cfg:RegisterElement("SilentAim", UI.Elements.silentAimToggle)
    cfg:RegisterElement("Aimlock", UI.Elements.aimlockToggle)
    cfg:RegisterElement("AimSmooth", UI.Elements.aimSmoothSlider)
    cfg:RegisterElement("AimFOV", UI.Elements.aimFovSlider)
    cfg:RegisterElement("AimPrediction", UI.Elements.aimPredSlider)
    cfg:RegisterElement("HitChance", UI.Elements.aimChanceSlider)
    cfg:RegisterElement("AimPart", UI.Elements.aimPartDropdown)
    cfg:RegisterElement("TeamCheck", UI.Elements.teamCheckToggle)
    cfg:RegisterElement("AimKey", UI.Elements.aimKeyDropdown)

    cfg:RegisterElement("TriggerBot", UI.Elements.triggerBotToggle)
    cfg:RegisterElement("TriggerFOV", UI.Elements.triggerFovSlider)
    cfg:RegisterElement("TriggerDelay", UI.Elements.triggerDelaySlider)
    cfg:RegisterElement("TriggerTeam", UI.Elements.triggerTeamToggle)

    cfg:RegisterElement("Hitbox", UI.Elements.hitboxToggle)
    cfg:RegisterElement("HitboxSize", UI.Elements.hitboxSizeSlider)
    cfg:RegisterElement("HitboxTransp", UI.Elements.hitboxTranspSlider)

    cfg:RegisterElement("ESP", UI.Elements.espToggle)
    cfg:RegisterElement("ESPMode", UI.Elements.espModeDropdown)
    cfg:RegisterElement("Box", UI.Elements.boxToggle)
    cfg:RegisterElement("Name", UI.Elements.nameToggle)
    cfg:RegisterElement("Health", UI.Elements.healthToggle)
    cfg:RegisterElement("Distance", UI.Elements.distToggle)
    cfg:RegisterElement("Line", UI.Elements.lineToggle)
    cfg:RegisterElement("Skeleton", UI.Elements.skeletonToggle)
    cfg:RegisterElement("Weapon", UI.Elements.weaponToggle)
    cfg:RegisterElement("ESPDistance", UI.Elements.espDistSlider)
    cfg:RegisterElement("ESPColor", UI.Elements.espColorPicker)
    cfg:RegisterElement("TextColor", UI.Elements.textColorPicker)
    cfg:RegisterElement("BoxColor", UI.Elements.boxColorPicker)
    cfg:RegisterElement("LineColor", UI.Elements.lineColorPicker)
    cfg:RegisterElement("SkelColor", UI.Elements.skelColorPicker)

    cfg:RegisterElement("Crosshair", UI.Elements.crosshairToggle)
    cfg:RegisterElement("CrosshairColor", UI.Elements.crosshairColorPicker)
    cfg:RegisterElement("CrosshairSize", UI.Elements.crosshairSizeSlider)
    cfg:RegisterElement("CrosshairDistance", UI.Elements.crosshairDistSlider)
    cfg:RegisterElement("CrosshairThick", UI.Elements.crosshairThickSlider)
    cfg:RegisterElement("CrosshairTransp", UI.Elements.crosshairTranspSlider)

    cfg:RegisterElement("WeaponColorOn", UI.Elements.weaponColorToggle)
    cfg:RegisterElement("WeaponColorPick", UI.Elements.weaponColorPicker)
    cfg:RegisterElement("WeaponMat", UI.Elements.materialDropdown)

    cfg:RegisterElement("AspectRatio", UI.Elements.aspectToggle)
    cfg:RegisterElement("AspectRatioMode", UI.Elements.aspectModeDropdown)

    cfg:RegisterElement("SkyColorEnabled", UI.Elements.skyColorToggle)
    cfg:RegisterElement("SkyColorPicker", UI.Elements.skyColorPicker)

    cfg:RegisterElement("FreeCam", UI.Elements.freecamToggle)
    cfg:RegisterElement("CameraZoom", UI.Elements.cameraZoomToggle)
    cfg:RegisterElement("FOVEnabled", UI.Elements.fovToggle)
    cfg:RegisterElement("FOVValue", UI.Elements.fovSlider)
    cfg:RegisterElement("NoRecoil", UI.Elements.noRecoilToggle)
    cfg:RegisterElement("RapidFire", UI.Elements.rapidFireToggle)
    cfg:RegisterElement("RapidFireDelay", UI.Elements.rapidFireDelaySlider)

    cfg:RegisterElement("Fullbright", UI.Elements.fullbrightToggle)
    cfg:RegisterElement("StatsHUD", UI.Elements.statsHudToggle)

    cfg:RegisterElement("BindFreecam",    UI.Elements.keybindFreecam)
    cfg:RegisterElement("BindCameraZoom", UI.Elements.keybindCameraZoom)
    cfg:RegisterElement("BindESP",        UI.Elements.keybindESP)
    cfg:RegisterElement("BindFullbright", UI.Elements.keybindFullbright)
    cfg:RegisterElement("BindTrigger",    UI.Elements.keybindTrigger)
    cfg:RegisterElement("BindHitbox",     UI.Elements.keybindHitbox)
    cfg:RegisterElement("BindNoRecoil",   UI.Elements.keybindNoRecoil)
    cfg:RegisterElement("BindHideUI",     UI.Elements.keybindHideUI)

    cfg:RegisterElement("RemoveWall", UI.Elements.removeConstructionsToggle)
    cfg:RegisterElement("RemoveDist", UI.Elements.removeDistanceSlider)
    cfg:RegisterElement("BindRemoveWall", UI.Elements.keybindRemoveConstructions)
    cfg:RegisterElement("BindFOV", UI.Elements.keybindFOV)

    return cfg
end

UI.Tabs.Settings:AddSeparator()
UI.Tabs.Settings:AddLabel("SYSTEM CONFIG", "save")
UI.Tabs.Settings:AddSeparator()

UI.Window.ConfigManager:SetFolder("cloudclient_configs")

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

        -- ===== СБРОС ВСЕХ СОСТОЯНИЙ В ДЕФОЛТ ПЕРЕД ЗАГРУЗКОЙ =====
        UI.Elements.aspectToggle:Set(false)
        UI.Elements.aspectModeDropdown:Set("16:9")

        Flags.HitboxEnabled = false; Flags.HitboxSize = 2.0; Flags.HitboxTransparency = 50
        Flags.TriggerBot = false; Flags.TriggerDelay = 50; Flags.TriggerFOV = 15; Flags.TriggerTeamCheck = true
        Flags.NoRecoil = false; Flags.RapidFire = false
        Flags.SkyColorEnabled = false; Flags.SkyColor = Color3.fromRGB(100, 150, 255)
        Flags.RemoveConstructions = false

        -- FOV сброс
        Flags.FOVEnabled = false
        Flags.FOVValue = 70
        CC.Refs.fovSettled = false
        pcall(function() UI.Elements.fovToggle:Set(false) end)
        pcall(function() UI.Elements.fovSlider:Set(70) end)
        
        pcall(function() UI.Elements.removeConstructionsToggle:Set(false) end)

        UI.buildConfig(name):Load()

        if Flags.FreeCam then if not CC.Refs.freecamConn then startFreeCam() end
        else if CC.Refs.freecamConn then stopFreeCam() end end
        if Flags.NoRecoil then startNoRecoil() else stopNoRecoil() end
        applyRapidFire()
        if Flags.HitboxEnabled then updateHitboxes() else restoreAllHitboxes() end
        setFullbright(Flags.Fullbright)
        setSkyColor(Flags.SkyColorEnabled, Flags.SkyColor)
        CC.Refs.fovSettled = false
        for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
        if not Flags.FPSPing and CC.Refs.HudPanel then destroyHud()
        elseif Flags.FPSPing and not CC.Refs.HudPanel then createHud() end

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
        task.wait(30)
        pcall(function()
            UI.Elements.keyInfoLabel:Set(string.format("Ключ: %s | до: %s", _G.CloudKeyState.key or "—", keyRemainingText()))
        end)
    end
end)
