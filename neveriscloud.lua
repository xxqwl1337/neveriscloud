--[[
    CLOUDCLIENT — Aimbot + ESP + FreeCam + AutoRun/Spider + Crosshair + Config
]]

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

local VantixUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neverisUI2.lua"))()

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Stats       = game:GetService("Stats")
local Lighting    = game:GetService("Lighting")
local LP          = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local Mouse       = LP:GetMouse()

local Window = VantixUI:CreateWindow({
    Title = "cloudclient", Theme = "Vantix", AccentColor = Color3.fromRGB(255, 255, 255),
    LogoID = 110034487018208, Size = {820, 480},
})
Window:CreateTag("Rust Decoy", Color3.fromRGB(100, 200, 100), nil, "gamepad-2")
Window:CreateTag("Beta", Color3.fromRGB(255, 105, 180), nil, "flask-conical")
Window:CreateTag("v1.0", Color3.fromRGB(150, 150, 150), nil, "git-branch")
Window:CreateTag("Premium", Color3.fromRGB(255, 215, 0), nil, "crown")
Window:Notify({ Title = "Welcome", Text = "cloudclient loaded", Icon = "check", Duration = 4 })

-- ===== СОСТОЯНИЕ =====
local Flags = {
    ESP = false, ESPMode = "Chams",
    Box = false, Distance = false, Name = false, Health = false, Line = false,
    Skeleton = false, WeaponESP = false,
    MaxDistance = 600,
    ESPColor = Color3.fromRGB(255, 0, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    BoxColor = Color3.fromRGB(255,255,255), LineColor = Color3.fromRGB(255,255,255),
    SkeletonColor = Color3.fromRGB(0, 255, 0),
    FreeCam = false, AutoRun = false, Spider = false, SpiderSpeed = 20,
    FPSPing = false, Fullbright = false,
    Crosshair = false, CrosshairColor = Color3.fromRGB(255, 255, 255), CrosshairSize = 10,
    CrosshairThickness = 1, CrosshairTransparency = 0, CrosshairDistance = 4,
    Aimbot = false, AimAssist = true, SilentAim = true, AimlockMode = false,
    AimPart = "Head", AimSmooth = 5, AimFOV = 120, AimTeamCheck = true,
    AimKey = Enum.UserInputType.MouseButton2, AimPrediction = 0, HitChance = 100,
    HitboxEnabled = false, HitboxSize = 2.0, HitboxTransparency = 50,
    TriggerBot = false, TriggerDelay = 50, TriggerFOV = 15, TriggerTeamCheck = true,
    NoRecoil = false,
    SkyColorEnabled = false, SkyColor = Color3.fromRGB(100, 150, 255),
}

local CurrentTarget, CurrentTargetPart = nil, nil

local freecamToggle, espToggle, fullbrightToggle, autoRunToggle, spiderToggle
local hitboxToggle, triggerBotToggle, noRecoilToggle, skyColorToggle

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

local function syncUI(element, state)
    if element and element.Set then
        pcall(function() element:Set(state) end)
    elseif element and element.set then
        pcall(function() element.set(state) end)
    end
end

local function syncBind(element, key)
    if element and element.Set then
        pcall(function() element:Set(key) end)
    elseif element and element.set then
        pcall(function() element.set(key) end)
    end
end

local function getBind(element)
    if element and element.Get then return element:Get()
    elseif element and element.get then return element.get()
    elseif element and element.Value then return element.Value
    end
    return nil
end

-- ===== ХИТБОКС =====
local OriginalHitboxSizes = {}
local function restoreHitbox(char)
    if not char then return end
    for part, size in pairs(OriginalHitboxSizes) do
        if part and part.Parent then
            pcall(function() part.Size = size end)
            pcall(function() part.CanCollide = true end)
        end
    end
    for part in pairs(OriginalHitboxSizes) do
        if part and not part.Parent then OriginalHitboxSizes[part] = nil end
    end
end
local function restoreAllHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then restoreHitbox(plr.Character) end
    end
end
local function applyHitbox(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local multiplier = Flags.HitboxSize or 2.0
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local name = part.Name
            if name == "Head" or name == "Torso" or name == "UpperTorso" or name == "LowerTorso"
               or name == "HumanoidRootPart" or name == "Left Arm" or name == "Right Arm"
               or name == "Left Leg" or name == "Right Leg"
               or name == "LeftUpperArm" or name == "RightUpperArm"
               or name == "LeftLowerArm" or name == "RightLowerArm"
               or name == "LeftUpperLeg" or name == "RightUpperLeg"
               or name == "LeftLowerLeg" or name == "RightLowerLeg" then
                if not OriginalHitboxSizes[part] then
                    OriginalHitboxSizes[part] = part.Size
                end
                pcall(function() part.Size = OriginalHitboxSizes[part] * multiplier end)
                if Flags.HitboxTransparency > 0 then
                    pcall(function() part.Transparency = math.clamp(Flags.HitboxTransparency / 100, 0, 1) end)
                end
            end
        end
    end
end
local function updateHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            if Flags.HitboxEnabled and isAlive(plr.Character) then
                applyHitbox(plr.Character)
            else
                restoreHitbox(plr.Character)
            end
        end
    end
end

-- ===== SILENT AIM =====
local silentHookOk = pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if self == Mouse and Flags.Aimbot and Flags.SilentAim and not Flags.AimlockMode and CurrentTargetPart then
            if math.random(1, 100) > Flags.HitChance then return oldIndex(self, key) end
            local targetPos = CurrentTargetPart.Position
            if Flags.AimPrediction > 0 then
                targetPos = targetPos + (getVelocity(CurrentTargetPart) * Flags.AimPrediction)
            end
            if key == "Hit" then return CFrame.new(targetPos)
            elseif key == "Target" then return CurrentTargetPart
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
if not silentHookOk then warn("[cloudclient] Silent Aim __index hook FAILED") end

local namecallOk = pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if (method == "ScreenPointToRay" or method == "ViewportPointToRay")
            and self == Camera
            and Flags.Aimbot and Flags.SilentAim and not Flags.AimlockMode and CurrentTargetPart then
            local targetPos = CurrentTargetPart.Position
            if Flags.AimPrediction > 0 then
                targetPos = targetPos + (getVelocity(CurrentTargetPart) * Flags.AimPrediction)
            end
            local origin = Camera.CFrame.Position
            local dir = (targetPos - origin).Unit
            return Ray.new(origin, dir * 1000)
        end
        return oldNamecall(self, ...)
    end)
end)
if not namecallOk then warn("[cloudclient] Silent Aim __namecall hook FAILED") end

if hookfunction then
    pcall(function()
        local oldScreen = Camera.ScreenPointToRay
        hookfunction(oldScreen, function(self, x, y, depth)
            if self == Camera and Flags.Aimbot and Flags.SilentAim and not Flags.AimlockMode and CurrentTargetPart then
                local targetPos = CurrentTargetPart.Position
                if Flags.AimPrediction > 0 then
                    targetPos = targetPos + (getVelocity(CurrentTargetPart) * Flags.AimPrediction)
                end
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
            if self == Camera and Flags.Aimbot and Flags.SilentAim and not Flags.AimlockMode and CurrentTargetPart then
                local targetPos = CurrentTargetPart.Position
                if Flags.AimPrediction > 0 then
                    targetPos = targetPos + (getVelocity(CurrentTargetPart) * Flags.AimPrediction)
                end
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
                local sp = Camera:WorldToScreenPoint(part.Position)
                if sp.Z > 0 then
                    local screenDist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                    if screenDist < Flags.AimFOV then
                        local worldDist = (part.Position - localPos).Magnitude
                        if worldDist < shortest then
                            shortest = worldDist
                            closest = plr
                            closestPart = part
                        end
                    end
                end
            end
        end
    end
    return closest, closestPart
end

-- ===== AIM ASSIST + AIM LOCK =====
RunService:BindToRenderStep("CloudClientAimbot", Enum.RenderPriority.Last.Value, function(dt)
    if not Flags.Aimbot or not CurrentTargetPart then
        if Camera.CameraType == Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Custom
        end
        return
    end

    local aiming = UIS:IsMouseButtonPressed(Flags.AimKey)

    if Flags.AimlockMode and aiming then
        if Camera.CameraType ~= Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Scriptable
        end
        local camPos = Camera.CFrame.Position
        local targetPos = CurrentTargetPart.Position
        if Flags.AimPrediction > 0 then
            targetPos = targetPos + (getVelocity(CurrentTargetPart) * Flags.AimPrediction)
        end
        Camera.CFrame = CFrame.lookAt(camPos, targetPos)
    elseif Flags.AimAssist and aiming then
        local camPos = Camera.CFrame.Position
        local targetPos = CurrentTargetPart.Position
        if Flags.AimPrediction > 0 then
            targetPos = targetPos + (getVelocity(CurrentTargetPart) * Flags.AimPrediction)
        end
        local lookCF = CFrame.lookAt(camPos, targetPos)
        local base = 1 / math.max(1, Flags.AimSmooth)
        local alpha = 1 - (1 - base) ^ (dt * 60)
        Camera.CFrame = Camera.CFrame:Lerp(lookCF, alpha)
    else
        if Camera.CameraType == Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Custom
        end
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
    local sp = Camera:WorldToViewportPoint(part.Position)
    if sp.Z <= 0 then return false end
    local dist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
    return dist <= Flags.TriggerFOV
end

local function tryTriggerShot()
    if not Flags.TriggerBot then return end
    if not CurrentTargetPart then return end
    if os.clock() - triggerLastShot < (Flags.TriggerDelay / 1000) then return end
    if Window.Gui and Window.Gui.Enabled then return end

    triggerRayParams.FilterDescendantsInstances = {LP.Character}
    local origin = Camera.CFrame.Position
    local dir = (CurrentTargetPart.Position - origin)
    local ray = workspace:Raycast(origin, dir, triggerRayParams)
    if ray and ray.Instance then
        local hitChar = ray.Instance:FindFirstAncestorOfClass("Model")
        if hitChar ~= CurrentTargetPart.Parent then return end
    end

    if not isCrosshairOnTarget(CurrentTargetPart) then return end

    triggerLastShot = os.clock()

    local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
        return
    end

    if mouse1click then
        pcall(mouse1click)
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
        CurrentTargetPart = part
    else
        CurrentTargetPart = nil
    end
    if Flags.TriggerBot then tryTriggerShot() end
end)

RunService.Heartbeat:Connect(function()
    if Flags.HitboxEnabled then updateHitboxes() end
end)

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
            line.Color = Flags.CrosshairColor
            line.Thickness = Flags.CrosshairThickness
            line.Transparency = trans
            line.Visible = true
        end
    else
        crossTop.Visible = false; crossBottom.Visible = false
        crossLeft.Visible = false; crossRight.Visible = false
    end
end)

-- ===== FREECAM =====
local freecamConn, freecamMouseConn, savedCamType, savedMouseBehavior = nil, nil, nil, nil
local savedWS, savedJP = 16, 50
local freecamPos = Vector3.new(0,0,0); local freecamYaw, freecamPitch = 0, 0

local function stopFreeCam()
    if freecamConn then freecamConn:Disconnect(); freecamConn = nil end
    if freecamMouseConn then freecamMouseConn:Disconnect(); freecamMouseConn = nil end
    if savedCamType then Camera.CameraType = savedCamType; savedCamType = nil end
    if savedMouseBehavior then UIS.MouseBehavior = savedMouseBehavior; savedMouseBehavior = nil end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = savedWS; hum.JumpPower = savedJP end
    Flags.FreeCam = false
end

local function startFreeCam()
    if freecamConn then return end
    savedCamType = Camera.CameraType; Camera.CameraType = Enum.CameraType.Scriptable
    savedMouseBehavior = UIS.MouseBehavior; UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
    freecamPos = Camera.CFrame.Position
    local look = Camera.CFrame.LookVector
    freecamYaw = math.atan2(-look.X, -look.Z); freecamPitch = math.asin(math.clamp(look.Y, -1, 1))
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then savedWS = hum.WalkSpeed; savedJP = hum.JumpPower; hum.WalkSpeed = 0; hum.JumpPower = 0 end
    freecamMouseConn = UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            freecamYaw = freecamYaw - input.Delta.X * 0.005
            freecamPitch = math.clamp(freecamPitch - input.Delta.Y * 0.005, -math.rad(89), math.rad(89))
        end
    end)
    freecamConn = RunService.RenderStepped:Connect(function(dt)
        local speed = UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 150 or 50
        local cf = CFrame.fromEulerAnglesYXZ(freecamPitch, freecamYaw, 0)
        local move = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
        if move.Magnitude > 0 then freecamPos = freecamPos + move.Unit * speed * dt end
        Camera.CFrame = CFrame.new(freecamPos) * cf
    end)
    Flags.FreeCam = true
end

LP.CharacterAdded:Connect(function()
    task.wait(0.1)
    if freecamConn then
        stopFreeCam()
        syncUI(freecamToggle, false)
    end
end)

-- ===== AUTORUN =====
local defaultWalkSpeed = 16
local autoRunActive = false
local function captureDefaultWalkSpeed()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then defaultWalkSpeed = hum.WalkSpeed end
end
captureDefaultWalkSpeed()
LP.CharacterAdded:Connect(function() task.wait(0.5); captureDefaultWalkSpeed() end)

local function applyAutoRun()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Flags.AutoRun then
        autoRunActive = true
        hum.WalkSpeed = 20
        local look = Camera.CFrame.LookVector
        local dir = Vector3.new(look.X, 0, look.Z)
        if dir.Magnitude > 0.01 then hum:Move(dir.Unit, false) end
    elseif autoRunActive then
        hum.WalkSpeed = defaultWalkSpeed
        autoRunActive = false
    end
end

-- ===== SPIDER =====
local spiderBV = nil
local spiderRayParams = RaycastParams.new()
spiderRayParams.FilterType = Enum.RaycastFilterType.Exclude
spiderRayParams.FilterDescendantsInstances = {LP.Character}

local function clearSpiderVelocity()
    if spiderBV then spiderBV:Destroy(); spiderBV = nil end
end

local function updateSpider()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then clearSpiderVelocity(); return end
    if not Flags.Spider then clearSpiderVelocity(); return end

    spiderRayParams.FilterDescendantsInstances = {char}
    local origin = hrp.Position
    local dirs = {
        Camera.CFrame.LookVector, -Camera.CFrame.LookVector,
        Camera.CFrame.RightVector, -Camera.CFrame.RightVector,
    }
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
    elseif UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then up = -Flags.SpiderSpeed
    end

    if up ~= 0 then
        if not spiderBV then
            spiderBV = Instance.new("BodyVelocity")
            spiderBV.MaxForce = Vector3.new(0, math.huge, 0)
            spiderBV.P = 5000
            spiderBV.Parent = hrp
        end
        spiderBV.Velocity = Vector3.new(0, up, 0)
    else
        clearSpiderVelocity()
    end
end

-- ===== NO RECOIL (ИДЕАЛЬНЫЙ) =====
local noRecoilActive = false
local savedRecoilCFrame = nil
local lastShotTime = 0

local function resetNoRecoilState()
    noRecoilActive = false
    savedRecoilCFrame = nil
    lastShotTime = 0
end

-- Ловим момент выстрела
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        savedRecoilCFrame = Camera.CFrame
        lastShotTime = os.clock()
    end
end)

-- Ловим движения мыши, чтобы обновлять точку прицела во время стрельбы
UIS.InputChanged:Connect(function(input, gpe)
    if gpe then return end
    if not Flags.NoRecoil then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        -- Если игрок сам двигает мышкой во время стрельбы, сдвигаем точку сохранения
        -- (чтобы блокировка отдачи не мешала целиться)
        if os.clock() - lastShotTime <= 0.2 and savedRecoilCFrame then
            local delta = input.Delta
            -- Вращаем сохранённый CFrame на движение мыши
            local newCF = savedRecoilCFrame * CFrame.Angles(-math.rad(delta.Y * 0.1), -math.rad(delta.X * 0.1), 0)
            -- Защита от вылета за полюс
            local pitch = math.asin(math.clamp(newCF.LookVector.Y, -1, 1))
            if math.abs(pitch) < math.rad(89) then
                savedRecoilCFrame = newCF
            end
        end
    end
end)

-- Каждый кадр возвращаем камеру к сохранённой точке (убираем отдачу)
RunService.RenderStepped:Connect(function()
    if not Flags.NoRecoil then
        if noRecoilActive then resetNoRecoilState() end
        return
    end
    noRecoilActive = true

    -- Работаем только пока идёт стрельба (0.2 секунды после выстрела)
    if os.clock() - lastShotTime > 0.2 then return end
    if not savedRecoilCFrame then return end

    -- Принудительно ставим камеру туда, где она была до выстрела
    -- (это убивает визуальную отдачу, пуля летит точно в точку)
    Camera.CFrame = savedRecoilCFrame
end)

-- ===== FULLBRIGHT =====
local origLight = {
    Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime,
    FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart,
    GlobalShadows=Lighting.GlobalShadows, Ambient=Lighting.Ambient,
    OutdoorAmbient=Lighting.OutdoorAmbient,
}
local FULLBRIGHT_VALUES = {
    Brightness=2, ClockTime=12, FogEnd=1e5, FogStart=0,
    GlobalShadows=false, Ambient=Color3.fromRGB(178,178,178), OutdoorAmbient=Color3.fromRGB(178,178,178),
}
local origAtmosphere, origClouds = nil, nil

local function captureAtmosphere()
    origAtmosphere = {}
    for _, atm in ipairs(Lighting:GetChildren()) do
        if atm:IsA("Atmosphere") then
            table.insert(origAtmosphere, {obj=atm, Density=atm.Density, Offset=atm.Offset,
                Color=atm.Color, Decay=atm.Decay, Glare=atm.Glare, Haze=atm.Haze})
        end
    end
    origClouds = {}
    for _, cl in ipairs(Lighting:GetChildren()) do
        if cl:IsA("Clouds") then
            table.insert(origClouds, {obj=cl, Cover=cl.Cover, Density=cl.Density, Color=cl.Color, Enabled=cl.Enabled})
        end
    end
end
captureAtmosphere()

local function applyFullbrightOnce()
    for key, val in pairs(FULLBRIGHT_VALUES) do
        if Lighting[key] ~= val then pcall(function() Lighting[key] = val end) end
    end
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
    for key, val in pairs(origLight) do pcall(function() Lighting[key] = val end) end
    if origAtmosphere then
        for _, a in ipairs(origAtmosphere) do
            if a.obj and a.obj.Parent then
                pcall(function()
                    a.obj.Density=a.Density; a.obj.Offset=a.Offset; a.obj.Color=a.Color
                    a.obj.Decay=a.Decay; a.obj.Glare=a.Glare; a.obj.Haze=a.Haze
                end)
            end
        end
    end
    if origClouds then
        for _, c in ipairs(origClouds) do
            if c.obj and c.obj.Parent then
                pcall(function()
                    c.obj.Cover=c.Cover; c.obj.Density=c.Density; c.obj.Color=c.Color; c.obj.Enabled=c.Enabled
                end)
            end
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
local origSky = nil
local customSky = nil

local function setSkyColor(enabled, color)
    local lighting = Lighting
    if not origSky then
        for _, child in ipairs(lighting:GetChildren()) do
            if child:IsA("Sky") then
                origSky = child:Clone()
                break
            end
        end
    end

    if enabled then
        if not customSky then
            customSky = Instance.new("Sky")
            customSky.Name = "CloudClientCustomSky"
            customSky.Parent = lighting
        end
        local c = color or Flags.SkyColor
        customSky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
        customSky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
        customSky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
        customSky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
        customSky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
        customSky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
        customSky.SunAngularSize = 0
        customSky.MoonAngularSize = 0

        local cc = lighting:FindFirstChild("CloudClientSkyTint")
        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "CloudClientSkyTint"
            cc.Parent = lighting
        end
        cc.TintColor = c
        cc.Brightness = 0
        cc.Contrast = 0
        cc.Saturation = 0
    else
        if customSky then
            customSky:Destroy(); customSky = nil
        end
        local cc = lighting:FindFirstChild("CloudClientSkyTint")
        if cc then cc:Destroy() end
    end
end

-- ===== ESP DRAWINGS =====
local Drawings, Highlights, Skeletons, WeaponLabels = {}, {}, {}, {}

local function createDrawings(plr)
    if plr == LP or Drawings[plr] then return end
    local d = {}
    d.Box      = Drawing.new("Square"); d.Box.Thickness=1; d.Box.Filled=false; d.Box.Visible=false
    d.Name     = Drawing.new("Text"); d.Name.Size=14; d.Name.Center=true; d.Name.Outline=true; d.Name.Visible=false
    d.Health   = Drawing.new("Text"); d.Health.Size=12; d.Health.Center=true; d.Health.Outline=true; d.Health.Visible=false
    d.Line     = Drawing.new("Line"); d.Line.Thickness=1; d.Line.Visible=false
    d.Distance = Drawing.new("Text"); d.Distance.Size=12; d.Distance.Center=true; d.Distance.Outline=true; d.Distance.Visible=false
    d.Weapon   = Drawing.new("Text"); d.Weapon.Size=12; d.Weapon.Center=true; d.Weapon.Outline=true; d.Weapon.Visible=false
    Drawings[plr] = d
end

local function clearHighlight(plr)
    if Highlights[plr] then pcall(function() Highlights[plr]:Destroy() end); Highlights[plr] = nil end
end

local function removeDrawings(plr)
    if Drawings[plr] then
        for _,o in pairs(Drawings[plr]) do if o then pcall(function() o:Remove() end) end end
        Drawings[plr]=nil
    end
    clearHighlight(plr)
    if Skeletons[plr] then
        for _,l in pairs(Skeletons[plr].lines) do pcall(function() l:Remove() end) end
        Skeletons[plr]=nil
    end
    if WeaponLabels[plr] then pcall(function() WeaponLabels[plr]:Remove() end); WeaponLabels[plr]=nil end
end

-- ===== ESP HIGHLIGHT =====
local function applyHighlight(plr)
    if plr == LP then return end
    local char = plr.Character
    local want = Flags.ESP and Flags.MaxDistance > 0
    if not want or not char or not isAlive(char) then clearHighlight(plr); return end
    local hl = Highlights[plr]
    if not hl or not hl.Parent then
        if hl then pcall(function() hl:Destroy() end) end
        hl = Instance.new("Highlight")
        hl.Name = "CloudClientESP"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- [FIX] Видно через стены!
        hl.Parent = char
        Highlights[plr] = hl
    end
    if hl.DepthMode ~= Enum.HighlightDepthMode.AlwaysOnTop then
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    if Flags.ESPMode == "Chams" then
        hl.FillColor = Flags.ESPColor; hl.FillTransparency = 0
        hl.OutlineColor = Flags.ESPColor; hl.OutlineTransparency = 1
    else
        hl.FillColor = Flags.ESPColor; hl.FillTransparency = 1
        hl.OutlineColor = Flags.ESPColor; hl.OutlineTransparency = 0
    end
end

-- ===== SKELETON =====
local SKELETON_CONNECTIONS = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},
}
local R6_CONNECTIONS = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local function ensureSkeleton(plr, isR15)
    local sk = Skeletons[plr]
    local conns = isR15 and SKELETON_CONNECTIONS or R6_CONNECTIONS
    if sk and #sk.lines == #conns then return end
    if sk then for _,l in pairs(sk.lines) do pcall(function() l:Remove() end) end end
    local lines = {}
    for i = 1, #conns do
        local l = Drawing.new("Line"); l.Thickness=1; l.Visible=false
        lines[i] = l
    end
    Skeletons[plr] = {lines = lines, conns = conns}
end

local function updateSkeleton(plr, char)
    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    ensureSkeleton(plr, isR15)
    local sk = Skeletons[plr]
    if not sk then return end
    local conns = sk.conns
    for i, conn in ipairs(conns) do
        local p1 = char:FindFirstChild(conn[1])
        local p2 = char:FindFirstChild(conn[2])
        local line = sk.lines[i]
        if p1 and p2 then
            local s1 = Camera:WorldToViewportPoint(p1.Position)
            local s2 = Camera:WorldToViewportPoint(p2.Position)
            if s1.Z > 0 and s2.Z > 0 then
                line.From = Vector2.new(s1.X, s1.Y); line.To = Vector2.new(s2.X, s2.Y)
                line.Color = Flags.SkeletonColor; line.Visible = true
            elseif line.Visible then line.Visible = false end
        elseif line.Visible then line.Visible = false end
    end
end

-- ===== WEAPON ESP =====
local WEAPON_IGNORE = {
    Handle = true, Grip = true, Attachment = true, Attachment1 = true,
    ["LeftGrip"] = true, ["RightGrip"] = true, ["Tool"] = true,
    Head = true, Torso = true, UpperTorso = true, LowerTorso = true,
    ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true,
    LeftUpperArm = true, RightUpperArm = true, LeftLowerArm = true, RightLowerArm = true,
    LeftUpperLeg = true, RightUpperLeg = true, LeftLowerLeg = true, RightLowerLeg = true,
    HumanoidRootPart = true, Humanoid = true,
    [""] = true, ["None"] = true, ["Nil"] = true, ["Part"] = true, ["Mesh"] = true,
}

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
    for _, child in ipairs(tool:GetChildren()) do
        if child:IsA("BasePart") and isMeaningfulName(child.Name) then return child.Name end
    end
    return nil
end

local function updateHighlightDistance(plr, dist, visible)
    local hl = Highlights[plr]
    if not hl or not hl.Parent then return end
    local inRange = Flags.ESP and Flags.MaxDistance > 0 and visible and dist <= Flags.MaxDistance
    if hl.Enabled ~= inRange then hl.Enabled = inRange end
end

-- ===== ОСНОВНОЙ ESP ЦИКЛ =====
local function hideAll()
    for _,d in pairs(Drawings) do
        if d.Box.Visible then d.Box.Visible=false end
        if d.Name.Visible then d.Name.Visible=false end
        if d.Health.Visible then d.Health.Visible=false end
        if d.Line.Visible then d.Line.Visible=false end
        if d.Distance.Visible then d.Distance.Visible=false end
        if d.Weapon.Visible then d.Weapon.Visible=false end
    end
    for _,sk in pairs(Skeletons) do
        for _,l in pairs(sk.lines) do if l.Visible then l.Visible=false end end
    end
    for _,hl in pairs(Highlights) do if hl and hl.Parent and hl.Enabled then hl.Enabled = false end end
end

local function updateESP()
    if not Flags.ESP or Flags.MaxDistance <= 0 then hideAll(); return end
    local localRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then hideAll(); return end
    local localPos = localRoot.Position
    local vs = Camera.ViewportSize

    for plr, d in pairs(Drawings) do
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then
            if d.Box.Visible then d.Box.Visible=false end
            if d.Name.Visible then d.Name.Visible=false end
            if d.Health.Visible then d.Health.Visible=false end
            if d.Line.Visible then d.Line.Visible=false end
            if d.Distance.Visible then d.Distance.Visible=false end
            if d.Weapon.Visible then d.Weapon.Visible=false end
            local sk = Skeletons[plr]
            if sk then for _,l in pairs(sk.lines) do if l.Visible then l.Visible=false end end end
            updateHighlightDistance(plr, math.huge, false)
            continue
        end
        local dist = (root.Position - localPos).Magnitude
        if dist > Flags.MaxDistance then
            if d.Box.Visible then d.Box.Visible=false end
            if d.Name.Visible then d.Name.Visible=false end
            if d.Health.Visible then d.Health.Visible=false end
            if d.Line.Visible then d.Line.Visible=false end
            if d.Distance.Visible then d.Distance.Visible=false end
            if d.Weapon.Visible then d.Weapon.Visible=false end
            local sk = Skeletons[plr]
            if sk then for _,l in pairs(sk.lines) do if l.Visible then l.Visible=false end end end
            updateHighlightDistance(plr, dist, false)
            continue
        end
        local sp = Camera:WorldToViewportPoint(root.Position)
        if sp.Z <= 0 then
            if d.Box.Visible then d.Box.Visible=false end
            if d.Name.Visible then d.Name.Visible=false end
            if d.Health.Visible then d.Health.Visible=false end
            if d.Line.Visible then d.Line.Visible=false end
            if d.Distance.Visible then d.Distance.Visible=false end
            if d.Weapon.Visible then d.Weapon.Visible=false end
            local sk = Skeletons[plr]
            if sk then for _,l in pairs(sk.lines) do if l.Visible then l.Visible=false end end end
            updateHighlightDistance(plr, dist, false)
            continue
        end

        local sx, sy = sp.X, sp.Y
        local headPart = char:FindFirstChild("Head") or root
        local headPos = headPart.Position + Vector3.new(0,1.5,0)
        local feetPos = root.Position - Vector3.new(0,2.5,0)
        local hS = Camera:WorldToViewportPoint(headPos)
        local fS = Camera:WorldToViewportPoint(feetPos)

        if Flags.Box and hS.Z > 0 and fS.Z > 0 then
            local h = math.abs(hS.Y - fS.Y); local w = h * 0.5
            d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(sx - w/2, hS.Y)
            d.Box.Color = Flags.BoxColor
            if not d.Box.Visible then d.Box.Visible = true end
        elseif d.Box.Visible then d.Box.Visible = false end

        if Flags.Name then
            d.Name.Text = plr.Name; d.Name.Position = Vector2.new(sx, hS.Y-18)
            d.Name.Color = Flags.TextColor
            if not d.Name.Visible then d.Name.Visible = true end
        elseif d.Name.Visible then d.Name.Visible = false end

        if Flags.Health then
            d.Health.Text = "HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
            d.Health.Position = Vector2.new(sx, fS.Y+2)
            d.Health.Color = Flags.TextColor
            if not d.Health.Visible then d.Health.Visible = true end
        elseif d.Health.Visible then d.Health.Visible = false end

        if Flags.Distance then
            d.Distance.Text = math.floor(dist).."m"
            d.Distance.Position = Vector2.new(sx, fS.Y+18)
            d.Distance.Color = Flags.TextColor
            if not d.Distance.Visible then d.Distance.Visible = true end
        elseif d.Distance.Visible then d.Distance.Visible = false end

        if Flags.Line then
            d.Line.From = Vector2.new(vs.X/2, vs.Y); d.Line.To = Vector2.new(sx, sy)
            d.Line.Color = Flags.LineColor
            if not d.Line.Visible then d.Line.Visible = true end
        elseif d.Line.Visible then d.Line.Visible = false end

        if Flags.WeaponESP then
            local weaponName = getWeaponName(char)
            if weaponName then
                d.Weapon.Text = "["..weaponName.."]"
                d.Weapon.Position = Vector2.new(sx, fS.Y + 34)
                d.Weapon.Color = Flags.TextColor
                if not d.Weapon.Visible then d.Weapon.Visible = true end
            elseif d.Weapon.Visible then d.Weapon.Visible = false end
        elseif d.Weapon.Visible then d.Weapon.Visible = false end

        if Flags.Skeleton then updateSkeleton(plr, char)
        else
            local sk = Skeletons[plr]
            if sk then for _,l in pairs(sk.lines) do if l.Visible then l.Visible=false end end end
        end

        updateHighlightDistance(plr, dist, true)
    end
end

-- ===== ХУКИ ИГРОКОВ =====
local function hookPlayer(plr)
    if plr == LP then return end
    createDrawings(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.2)
        applyHighlight(plr)
    end)
    plr.CharacterRemoving:Connect(function() clearHighlight(plr) end)
    applyHighlight(plr)
end
for _,plr in ipairs(Players:GetPlayers()) do hookPlayer(plr) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(removeDrawings)

-- ===== FPS/PING HUD =====
local StatsService = game:GetService("Stats")
local HudPanel, fpsRow, pingRow, hpRow, posRow, statusRow
local hudFrames, hudLast = 0, os.clock()

local function createHud()
    HudPanel = VantixUI:CreateNewWindow({
        Title = "Stats", Name = "CloudClientStats", Size = {220}, Minimizable = true,
    })
    HudPanel:AddHeader("Performance")
    fpsRow  = HudPanel:AddRow("FPS")
    pingRow = HudPanel:AddRow("Ping")
    HudPanel:AddSeparator()
    HudPanel:AddHeader("Player")
    hpRow   = HudPanel:AddRow("Health")
    posRow  = HudPanel:AddRow("Position", { Style = "Vertical", AccentKey = "white", ValueColorKey = "text" })
    HudPanel:AddSeparator()
    HudPanel:AddHeader("Status")
    statusRow = HudPanel:AddRow("State")
    statusRow:Set("Idle")
end

local function destroyHud()
    if HudPanel then pcall(function() HudPanel:Destroy() end); HudPanel = nil end
    fpsRow, pingRow, hpRow, posRow, statusRow = nil, nil, nil, nil, nil
end

task.spawn(function()
    while true do
        if Flags.FPSPing then
            if not HudPanel then createHud() end
            hudFrames = hudFrames + 1
            local now = os.clock()
            if now - hudLast >= 1 then
                if fpsRow then fpsRow:Set(hudFrames) end
                hudFrames, hudLast = 0, now
                local ok, ping = pcall(function()
                    return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
                end)
                if pingRow then pingRow:Set(ok and ping and (math.floor(ping).." ms") or "n/a") end
            end
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if root and posRow then
                local p = root.Position
                posRow:Set(string.format("%d, %d, %d", p.X, p.Y, p.Z))
            end
            if hum and hpRow then
                hpRow:Set(string.format("%d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth)))
            end
            if statusRow then statusRow:Set(Flags.ESP and "ESP on" or "ESP off") end
        elseif HudPanel then destroyHud() end
        RunService.Heartbeat:Wait()
    end
end)

-- ===== AUTORUN / SPIDER TIMER =====
RunService.Stepped:Connect(function()
    applyAutoRun()
    updateSpider()
end)

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
    if not Flags.ESP or Flags.MaxDistance <= 0 then 
        hideAll() 
        return 
    end
    local ok, err = pcall(updateESP)
    if not ok then
        warn("[cloudclient] ESP error, hiding:", err)
        pcall(hideAll)
    end
end)

-- ===== UI: AIMBOT =====
local AimbotTab = Window:AddTab("Aimbot", "crosshair")

local aimbotToggle = AimbotTab:AddToggle({Title="Aimbot", Icon="crosshair", Default=false, Callback=function(s) Flags.Aimbot=s end})
local aimAssistToggle = AimbotTab:AddToggle({Title="Aim Assist", Subtitle="Двигает камеру на цель", Icon="eye", Default=true, Callback=function(s) Flags.AimAssist=s end})
local silentAimToggle = AimbotTab:AddToggle({Title="Silent Aim", Subtitle="Хук Mouse.Hit / UnitRay / ScreenPointToRay", Icon="crosshair", Default=true, Callback=function(s) Flags.SilentAim=s end})
local aimlockToggle = AimbotTab:AddToggle({Title="Aim Lock (rage)", Subtitle="Только при зажатой кнопке", Icon="lock", Default=false, Callback=function(s) Flags.AimlockMode=s end})
local aimSmoothSlider = AimbotTab:AddSlider({Title="Smoothness", Icon="activity", Min=1, Max=100, Default=5, Callback=function(v) Flags.AimSmooth=v end})
local aimFovSlider = AimbotTab:AddSlider({Title="Aim FOV", Icon="circle", Min=20, Max=400, Default=120, Callback=function(v) Flags.AimFOV=v end})
local aimPredSlider = AimbotTab:AddSlider({Title="Prediction", Icon="trending-up", Min=0, Max=0.5, Default=0, Callback=function(v) Flags.AimPrediction=v end})
local aimChanceSlider = AimbotTab:AddSlider({Title="Hit Chance %", Icon="percent", Min=0, Max=100, Default=100, Callback=function(v) Flags.HitChance=v end})
local aimPartDropdown = AimbotTab:AddDropdown({Title="Target Part", Icon="user", Options={"Head","HumanoidRootPart","UpperTorso"}, Default="Head", Callback=function(s) Flags.AimPart=s end})
local teamCheckToggle = AimbotTab:AddToggle({Title="Team Check", Icon="users", Default=true, Callback=function(s) Flags.AimTeamCheck=s end})
local aimKeyBind = AimbotTab:AddKeybind({Title="Aim Key", Icon="mouse-pointer", Default=Enum.UserInputType.MouseButton2, Callback=function(k) if k and k.UserInputType then Flags.AimKey=k.UserInputType end end})

AimbotTab:AddSeparator(); AimbotTab:AddLabel("TRIGGER BOT", "crosshair"); AimbotTab:AddSeparator()

triggerBotToggle = AimbotTab:AddToggle({Title="Trigger Bot", Subtitle="Авто-выстрел при наведении", Icon="crosshair", Default=false, Callback=function(s) Flags.TriggerBot=s end})
local triggerFovSlider = AimbotTab:AddSlider({Title="Trigger FOV", Icon="circle", Min=1, Max=60, Default=15, Callback=function(v) Flags.TriggerFOV=v end})
local triggerDelaySlider = AimbotTab:AddSlider({Title="Trigger Delay (ms)", Icon="clock", Min=0, Max=500, Default=50, Callback=function(v) Flags.TriggerDelay=v end})
local triggerTeamToggle = AimbotTab:AddToggle({Title="Trigger Team Check", Icon="users", Default=true, Callback=function(s) Flags.TriggerTeamCheck=s end})

AimbotTab:AddSeparator(); AimbotTab:AddLabel("HITBOX EXPANDER", "box"); AimbotTab:AddSeparator()

hitboxToggle = AimbotTab:AddToggle({Title="Hitbox Expander", Icon="box", Default=false, Callback=function(s)
    Flags.HitboxEnabled=s
    if not s then restoreAllHitboxes() end
end})
local hitboxSizeSlider = AimbotTab:AddSlider({Title="Hitbox Size", Icon="ruler", Min=1, Max=5, Default=2, Callback=function(v) Flags.HitboxSize=v end})
local hitboxTranspSlider = AimbotTab:AddSlider({Title="Hitbox Transparency %", Icon="eye-off", Min=0, Max=100, Default=50, Callback=function(v) Flags.HitboxTransparency=v end})

-- ===== UI: VISUALS =====
local VisualsTab = Window:AddTab("Visuals", "eye")

VisualsTab:AddSeparator(); VisualsTab:AddLabel("ESP COLOR", "palette"); VisualsTab:AddSeparator()

local espColorPicker = VisualsTab:AddColorPicker({Title="ESP Color", Icon="palette", Default=Flags.ESPColor, Callback=function(c)
    Flags.ESPColor=c
    for _,hl in pairs(Highlights) do
        if hl and hl.Parent then hl.FillColor = c; hl.OutlineColor = c end
    end
end})
local textColorPicker = VisualsTab:AddColorPicker({Title="Text Color", Icon="type", Default=Flags.TextColor, Callback=function(c) Flags.TextColor=c end})
local boxColorPicker = VisualsTab:AddColorPicker({Title="Box Color", Icon="square", Default=Flags.BoxColor, Callback=function(c) Flags.BoxColor=c end})
local lineColorPicker = VisualsTab:AddColorPicker({Title="Line Color", Icon="move", Default=Flags.LineColor, Callback=function(c) Flags.LineColor=c end})
local skelColorPicker = VisualsTab:AddColorPicker({Title="Skeleton Color", Icon="bone", Default=Flags.SkeletonColor, Callback=function(c) Flags.SkeletonColor=c end})

VisualsTab:AddSeparator(); VisualsTab:AddLabel("ESP SYSTEM", "eye"); VisualsTab:AddSeparator()

espToggle = VisualsTab:AddToggle({Title="ESP", Icon="eye", Default=false, Callback=function(s)
    Flags.ESP=s
    for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
end})
local espModeDropdown = VisualsTab:AddDropdown({Title="ESP Mode", Icon="layers", Options={"Chams","Glow"}, Default="Chams", Callback=function(v)
    Flags.ESPMode = v
    for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
end})

local boxToggle = VisualsTab:AddToggle({Title="Box", Icon="box", Default=false, Callback=function(s) Flags.Box=s end})
local nameToggle = VisualsTab:AddToggle({Title="Name", Icon="user", Default=false, Callback=function(s) Flags.Name=s end})
local healthToggle = VisualsTab:AddToggle({Title="Health", Icon="heart", Default=false, Callback=function(s) Flags.Health=s end})
local distToggle = VisualsTab:AddToggle({Title="Distance", Icon="ruler", Default=false, Callback=function(s) Flags.Distance=s end})
local lineToggle = VisualsTab:AddToggle({Title="Line", Icon="move", Default=false, Callback=function(s) Flags.Line=s end})
local skeletonToggle = VisualsTab:AddToggle({Title="Skeleton", Icon="bone", Default=false, Callback=function(s) Flags.Skeleton=s end})
local weaponToggle = VisualsTab:AddToggle({Title="Weapon ESP", Icon="sword", Default=false, Callback=function(s) Flags.WeaponESP=s end})

local espDistSlider = VisualsTab:AddSlider({Title="ESP Distance", Icon="ruler", Min=250, Max=2000, Default=600, Callback=function(v)
    Flags.MaxDistance=v
    for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
end})

-- ===== UI: PLAYER =====
local PlayerTab = Window:AddTab("Player", "user")
freecamToggle = PlayerTab:AddToggle({Title="FreeCam", Subtitle="WASD + Space/Ctrl", Icon="camera", Default=false, Callback=function(s)
    Flags.FreeCam=s
    if s then startFreeCam() else stopFreeCam() end
end})

PlayerTab:AddSeparator(); PlayerTab:AddLabel("COMBAT", "crosshair"); PlayerTab:AddSeparator()
noRecoilToggle = PlayerTab:AddToggle({Title="No Recoil", Subtitle="Компенсация отдачи", Icon="target", Default=false, Callback=function(s)
    Flags.NoRecoil=s
    if not s then resetNoRecoilState() end
end})

PlayerTab:AddSeparator(); PlayerTab:AddLabel("MOVEMENT", "move"); PlayerTab:AddSeparator()
autoRunToggle = PlayerTab:AddToggle({Title="AutoRun", Icon="zap", Default=false, Callback=function(s) Flags.AutoRun=s end})
spiderToggle = PlayerTab:AddToggle({Title="Spider", Subtitle="W/Space вверх, S/Ctrl вниз", Icon="arrow-up", Default=false, Callback=function(s)
    Flags.Spider=s
    if not s then clearSpiderVelocity() end
end})
local spiderSpeedSlider = PlayerTab:AddSlider({Title="Spider Speed", Icon="gauge", Min=15, Max=30, Default=20, Callback=function(v) Flags.SpiderSpeed=v end})

-- ===== UI: OTHER =====
local OtherTab = Window:AddTab("Other", "box")
fullbrightToggle = OtherTab:AddToggle({Title="Fullbright", Icon="sun", Default=false, Callback=function(s)
    Flags.Fullbright=s
    setFullbright(s)
end})

OtherTab:AddSeparator(); OtherTab:AddLabel("SKY", "cloud"); OtherTab:AddSeparator()

skyColorToggle = OtherTab:AddToggle({Title="Custom Sky Color", Icon="cloud", Default=false, Callback=function(s)
    Flags.SkyColorEnabled=s
    setSkyColor(s, Flags.SkyColor)
end})
local skyColorPicker = OtherTab:AddColorPicker({Title="Sky Color", Icon="palette", Default=Flags.SkyColor, Callback=function(c)
    Flags.SkyColor=c
    if Flags.SkyColorEnabled then setSkyColor(true, c) end
end})

-- ===== UI: CROSSHAIR =====
local CrosshairTab = Window:AddTab("Crosshair", "crosshair")

local crosshairToggle = CrosshairTab:AddToggle({Title="Enable Crosshair", Icon="crosshair", Default=false, Callback=function(s) Flags.Crosshair=s end})

CrosshairTab:AddSeparator()

local crosshairColorPicker = CrosshairTab:AddColorPicker({Title="Color", Icon="palette", Default=Flags.CrosshairColor, Callback=function(c) Flags.CrosshairColor=c end})
local crosshairSizeSlider = CrosshairTab:AddSlider({Title="Size (Длина линий)", Icon="ruler", Min=4, Max=30, Default=10, Callback=function(v) Flags.CrosshairSize=v end})
local crosshairDistSlider = CrosshairTab:AddSlider({Title="Distance (Отступ от центра)", Icon="move", Min=0, Max=30, Default=4, Callback=function(v) Flags.CrosshairDistance=v end})
local crosshairThickSlider = CrosshairTab:AddSlider({Title="Thickness (Толщина)", Icon="minus", Min=1, Max=5, Default=1, Callback=function(v) Flags.CrosshairThickness=v end})
local crosshairTranspSlider = CrosshairTab:AddSlider({Title="Transparency (Прозрачность)", Icon="eye-off", Min=0, Max=100, Default=0, Callback=function(v) Flags.CrosshairTransparency=v end})

-- ===== UI: SETTINGS =====
local SettingsTab = Window:AddTab("Settings", "settings")

-- ===== 1. КЛЮЧ =====
local keyInfoLabel = SettingsTab:AddLabel(
    string.format("Ключ: %s | до: %s",
        _G.CloudKeyState.key or "—",
        keyRemainingText()),
    "key"
)

SettingsTab:AddSeparator()

-- ===== 2. THEME / ACCENT =====
local themeNames = {}
for name in pairs(VantixUI.Themes) do table.insert(themeNames, name) end
table.sort(themeNames)

SettingsTab:AddDropdown({Title="Theme", Icon="swatch-book", Options=themeNames, Default=Window:GetTheme(), Callback=function(s) Window:SetTheme(s) end})
SettingsTab:AddDropdown({Title="Accent Color", Icon="droplet", Options={"White","Blue","Red","Green","Purple"}, Default="White", Callback=function(s)
    local colors = {
        White=Color3.fromRGB(255,255,255), Blue=Color3.fromRGB(64,156,255),
        Red=Color3.fromRGB(230,70,70),     Green=Color3.fromRGB(80,210,120),
        Purple=Color3.fromRGB(170,110,240),
    }
    VantixUI:SetAccentColor(colors[s])
end})

-- ===== 3. STATS HUD =====
SettingsTab:AddSeparator()
local statsHudToggle = SettingsTab:AddToggle({Title="Stats HUD", Icon="gauge", Default=false, Callback=function(s) Flags.FPSPing=s end})

-- ===== 4. SYSTEM CONFIG =====
SettingsTab:AddSeparator()
SettingsTab:AddLabel("SYSTEM CONFIG", "save")
SettingsTab:AddSeparator()

Window.ConfigManager:SetFolder("cloudclient_configs")

local configNameBox = SettingsTab:AddTextBox({
    Title = "Config Name",
    Placeholder = "Enter name...",
    Default = "default",
})

local savedConfigs = SettingsTab:AddDropdown({
    Title = "Saved Configs",
    Options = Window.ConfigManager:GetConfigs(),
})

local function buildConfig(name)
    local cfg = Window.ConfigManager:CreateConfig(name)

    -- Aimbot
    cfg:RegisterElement("Aimbot", aimbotToggle)
    cfg:RegisterElement("AimAssist", aimAssistToggle)
    cfg:RegisterElement("SilentAim", silentAimToggle)
    cfg:RegisterElement("Aimlock", aimlockToggle)
    cfg:RegisterElement("AimSmooth", aimSmoothSlider)
    cfg:RegisterElement("AimFOV", aimFovSlider)
    cfg:RegisterElement("AimPrediction", aimPredSlider)
    cfg:RegisterElement("HitChance", aimChanceSlider)
    cfg:RegisterElement("AimPart", aimPartDropdown)
    cfg:RegisterElement("TeamCheck", teamCheckToggle)
    cfg:RegisterElement("AimKey", aimKeyBind)

    -- Trigger Bot
    cfg:RegisterElement("TriggerBot", triggerBotToggle)
    cfg:RegisterElement("TriggerFOV", triggerFovSlider)
    cfg:RegisterElement("TriggerDelay", triggerDelaySlider)
    cfg:RegisterElement("TriggerTeam", triggerTeamToggle)

    -- Hitbox
    cfg:RegisterElement("Hitbox", hitboxToggle)
    cfg:RegisterElement("HitboxSize", hitboxSizeSlider)
    cfg:RegisterElement("HitboxTransp", hitboxTranspSlider)

    -- ESP
    cfg:RegisterElement("ESP", espToggle)
    cfg:RegisterElement("ESPMode", espModeDropdown)
    cfg:RegisterElement("Box", boxToggle)
    cfg:RegisterElement("Name", nameToggle)
    cfg:RegisterElement("Health", healthToggle)
    cfg:RegisterElement("Distance", distToggle)
    cfg:RegisterElement("Line", lineToggle)
    cfg:RegisterElement("Skeleton", skeletonToggle)
    cfg:RegisterElement("Weapon", weaponToggle)
    cfg:RegisterElement("ESPDistance", espDistSlider)
    cfg:RegisterElement("ESPColor", espColorPicker)
    cfg:RegisterElement("TextColor", textColorPicker)
    cfg:RegisterElement("BoxColor", boxColorPicker)
    cfg:RegisterElement("LineColor", lineColorPicker)
    cfg:RegisterElement("SkelColor", skelColorPicker)

    -- Crosshair
    cfg:RegisterElement("Crosshair", crosshairToggle)
    cfg:RegisterElement("CrosshairColor", crosshairColorPicker)
    cfg:RegisterElement("CrosshairSize", crosshairSizeSlider)
    cfg:RegisterElement("CrosshairDistance", crosshairDistSlider)
    cfg:RegisterElement("CrosshairThick", crosshairThickSlider)
    cfg:RegisterElement("CrosshairTransp", crosshairTranspSlider)

    -- Player
    cfg:RegisterElement("FreeCam", freecamToggle)
    cfg:RegisterElement("NoRecoil", noRecoilToggle)
    cfg:RegisterElement("AutoRun", autoRunToggle)
    cfg:RegisterElement("Spider", spiderToggle)
    cfg:RegisterElement("SpiderSpeed", spiderSpeedSlider)

    -- Other
    cfg:RegisterElement("Fullbright", fullbrightToggle)
    cfg:RegisterElement("SkyColorEnabled", skyColorToggle)
    cfg:RegisterElement("SkyColorPicker", skyColorPicker)

    -- Settings
    cfg:RegisterElement("StatsHUD", statsHudToggle)

    return cfg
end

-- ===== [FIX] СВОЯ СИСТЕМА БИНДОВ =====
local function getBindsFile(cfgName)
    return "cloudclient_binds_" .. tostring(cfgName) .. ".txt"
end

local function saveBindsToFile(cfgName)
    if not writefile then return end
    local bindsTable = {
        Freecam = keybindFreecam, ESP = keybindESP, Fullbright = keybindFullbright,
        AutoRun = keybindAutoRun, Spider = keybindSpider, Trigger = keybindTrigger,
        Hitbox = keybindHitbox, NoRecoil = keybindNoRecoil, HideUI = keybindHideUI,
    }
    local data = {}
    for name, element in pairs(bindsTable) do
        local k = getBind(element)
        if k and k ~= Enum.KeyCode.Unknown then
            table.insert(data, name .. "=" .. tostring(k.Name))
        end
    end
    pcall(writefile, getBindsFile(cfgName), table.concat(data, "\n"))
end

local function loadBindsFromFile(cfgName)
    local bindsTable = {
        Freecam = keybindFreecam, ESP = keybindESP, Fullbright = keybindFullbright,
        AutoRun = keybindAutoRun, Spider = keybindSpider, Trigger = keybindTrigger,
        Hitbox = keybindHitbox, NoRecoil = keybindNoRecoil, HideUI = keybindHideUI,
    }
    -- Сначала стираем ВСЕ бинды
    for _, element in pairs(bindsTable) do
        syncBind(element, Enum.KeyCode.Unknown)
    end
    -- Читаем файл
    local file = getBindsFile(cfgName)
    if isfile and readfile and isfile(file) then
        local ok, content = pcall(readfile, file)
        if ok and content then
            for line in content:gmatch("[^\r\n]+") do
                local name, keyName = line:match("^(%w+)=(%w+)$")
                if name and keyName and bindsTable[name] then
                    local keyEnum = Enum.KeyCode[keyName]
                    if keyEnum then
                        syncBind(bindsTable[name], keyEnum)
                    end
                end
            end
        end
    end
end

-- ===== КНОПКИ SAVE / LOAD / DELETE =====

SettingsTab:AddButton({Title="Save Config", Text="Save", Callback=function()
    local ok, err = pcall(function()
        local name = configNameBox:Get()
        if not name or name == "" then error("empty name") end
        buildConfig(name):Save()
        saveBindsToFile(name) -- [FIX] Сохраняем бинды в свой файл
        savedConfigs:SetOptions(Window.ConfigManager:GetConfigs())
        Window:Notify({Title="Config", Text="Сохранён: "..name, Duration=2})
    end)
    if not ok then warn("[config] save:", err); Window:Notify({Title="Config", Text="Ошибка: "..tostring(err), Duration=4}) end
end})

SettingsTab:AddButton({Title="Load Config", Text="Load", Callback=function()
    local ok, err = pcall(function()
        local name = savedConfigs:Get()
        if not name or name == "" then error("no config") end
        configNameBox:Set(name)

        -- [FIX] 1. Сброс флагов функций
        Flags.HitboxEnabled      = false
        Flags.HitboxSize         = 2.0
        Flags.HitboxTransparency = 50
        Flags.TriggerBot         = false
        Flags.TriggerDelay       = 50
        Flags.TriggerFOV         = 15
        Flags.TriggerTeamCheck   = true
        Flags.NoRecoil           = false
        Flags.SkyColorEnabled    = false
        Flags.SkyColor           = Color3.fromRGB(100, 150, 255)

        buildConfig(name):Load()
        loadBindsFromFile(name) -- [FIX] Загружаем бинды из своего файла

        -- ESP
        for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
        syncUI(espToggle, Flags.ESP)

        -- Fullbright
        setFullbright(Flags.Fullbright)
        syncUI(fullbrightToggle, Flags.Fullbright)

        -- FreeCam
        if Flags.FreeCam then
            if not freecamConn then startFreeCam() end
        else
            if freecamConn then stopFreeCam() end
        end
        syncUI(freecamToggle, Flags.FreeCam)

        -- AutoRun
        syncUI(autoRunToggle, Flags.AutoRun)

        -- Spider
        syncUI(spiderToggle, Flags.Spider)
        if not Flags.Spider then clearSpiderVelocity() end

        -- No Recoil
        syncUI(noRecoilToggle, Flags.NoRecoil)
        if not Flags.NoRecoil then resetNoRecoilState() end

        -- Trigger Bot
        syncUI(triggerBotToggle, Flags.TriggerBot)

        -- Hitbox
        syncUI(hitboxToggle, Flags.HitboxEnabled)
        if Flags.HitboxEnabled then updateHitboxes() else restoreAllHitboxes() end

        -- Sky
        syncUI(skyColorToggle, Flags.SkyColorEnabled)
        setSkyColor(Flags.SkyColorEnabled, Flags.SkyColor)

        -- Stats HUD
        if not Flags.FPSPing and HudPanel then
            destroyHud()
        elseif Flags.FPSPing and not HudPanel then
            createHud()
        end

        Window:Notify({Title="Config", Text="Загружен: "..name, Duration=2})
    end)
    if not ok then warn("[config] load:", err); Window:Notify({Title="Config", Text="Ошибка: "..tostring(err), Duration=4}) end
end})

SettingsTab:AddButton({Title="Delete Config", Text="Delete", Risky=true, Callback=function()
    local ok, err = pcall(function()
        local name = savedConfigs:Get()
        if not name or name == "" then return end
        Window.ConfigManager:DeleteConfig(name)
        pcall(function() if delfile then delfile(getBindsFile(name)) end end) -- Удаляем и файл биндов
        savedConfigs:SetOptions(Window.ConfigManager:GetConfigs())
        Window:Notify({Title="Config", Text="Удалён: "..name, Duration=2})
    end)
    if not ok then warn("[config] delete:", err) end
end})

-- ===== 5. KEYBINDS =====
SettingsTab:AddSeparator()
SettingsTab:AddLabel("KEYBINDS", "keyboard")
SettingsTab:AddSeparator()

local keybindFreecam = SettingsTab:AddKeybind({
    Title = "FreeCam Keybind", Subtitle = "По умолчанию пусто", Icon = "camera",
    Callback = function()
        if freecamConn then stopFreeCam(); syncUI(freecamToggle, false)
        else startFreeCam(); syncUI(freecamToggle, true) end
    end
})

local keybindESP = SettingsTab:AddKeybind({
    Title = "ESP Keybind", Subtitle = "По умолчанию пусто", Icon = "eye",
    Callback = function()
        Flags.ESP = not Flags.ESP
        for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
        syncUI(espToggle, Flags.ESP)
    end
})

local keybindFullbright = SettingsTab:AddKeybind({
    Title = "Fullbright Keybind", Subtitle = "По умолчанию пусто", Icon = "sun",
    Callback = function()
        Flags.Fullbright = not Flags.Fullbright
        setFullbright(Flags.Fullbright)
        syncUI(fullbrightToggle, Flags.Fullbright)
    end
})

local keybindAutoRun = SettingsTab:AddKeybind({
    Title = "AutoRun Keybind", Subtitle = "По умолчанию пусто", Icon = "zap",
    Callback = function()
        Flags.AutoRun = not Flags.AutoRun
        syncUI(autoRunToggle, Flags.AutoRun)
    end
})

local keybindSpider = SettingsTab:AddKeybind({
    Title = "Spider Keybind", Subtitle = "По умолчанию пусто", Icon = "arrow-up",
    Callback = function()
        Flags.Spider = not Flags.Spider
        if not Flags.Spider then clearSpiderVelocity() end
        syncUI(spiderToggle, Flags.Spider)
    end
})

local keybindTrigger = SettingsTab:AddKeybind({
    Title = "Trigger Bot Keybind", Subtitle = "По умолчанию пусто", Icon = "crosshair",
    Callback = function()
        Flags.TriggerBot = not Flags.TriggerBot
        syncUI(triggerBotToggle, Flags.TriggerBot)
    end
})

local keybindHitbox = SettingsTab:AddKeybind({
    Title = "Hitbox Keybind", Subtitle = "По умолчанию пусто", Icon = "box",
    Callback = function()
        Flags.HitboxEnabled = not Flags.HitboxEnabled
        syncUI(hitboxToggle, Flags.HitboxEnabled)
        if not Flags.HitboxEnabled then restoreAllHitboxes() end
    end
})

local keybindNoRecoil = SettingsTab:AddKeybind({
    Title = "No Recoil Keybind", Subtitle = "По умолчанию пусто", Icon = "target",
    Callback = function()
        Flags.NoRecoil = not Flags.NoRecoil
        if not Flags.NoRecoil then resetNoRecoilState() end
        syncUI(noRecoilToggle, Flags.NoRecoil)
    end
})

local keybindHideUI = SettingsTab:AddKeybind({
    Title = "Hide UI Keybind", Icon = "keyboard", Default = Enum.KeyCode.Delete,
    Callback = function()
        local sg = Window.Gui
        if sg then sg.Enabled = not sg.Enabled end
    end
})

-- ===== 6. Периодическое обновление срока ключа =====
task.spawn(function()
    while true do
        task.wait(30)
        pcall(function()
            keyInfoLabel:Set(string.format("Ключ: %s | до: %s",
                _G.CloudKeyState.key or "—",
                keyRemainingText()))
        end)
    end
end)
