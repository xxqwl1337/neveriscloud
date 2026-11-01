--[[
    CLOUDCLIENT — Silent Aim + ESP (Mode: Chams/Glow) + FreeCam + AutoRun/Spider
    ESP: один Highlight, режим Chams (заливка) / Glow (обводка), ОДИН цвет ESPColor
    TextColor: отдельный цвет для Name/Distance/Health/Weapon
    ESP Distance: 100-1000
    Stats HUD: отдельная панель VantixUI с FPS/Ping/HP/Position
    Weapon ESP: только реальное оружие/предмет, части тела и Handle отфильтрованы
]]
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
Window:CreateTag("Beta", Color3.fromRGB(255, 105, 180), nil, "flask-conical")
Window:CreateTag("v1.0", Color3.fromRGB(150, 150, 150), nil, "git-branch")
Window:CreateTag("Premium", Color3.fromRGB(255, 215, 0), nil, "crown")
Window:Notify({ Title = "Welcome", Text = "cloudclient loaded", Icon = "check", Duration = 4 })

-- ===== СОСТОЯНИЕ =====
local Flags = {
    ESP = false, ESPMode = "Chams",
    Box = false, Distance = false, Name = false, Health = false, Line = false,
    Skeleton = false, WeaponESP = false,
    MaxDistance = 1000,
    ESPColor = Color3.fromRGB(255, 0, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    BoxColor = Color3.fromRGB(255,255,255), LineColor = Color3.fromRGB(255,255,255),
    SkeletonColor = Color3.fromRGB(0, 255, 0),
    FreeCam = false, AutoRun = false, Spider = false, SpiderSpeed = 20,
    FPSPing = false, Fullbright = false,
    Aimbot = false, AimPart = "Head", AimSmooth = 1, AimFOV = 120, AimTeamCheck = true,
    AimKey = Enum.UserInputType.MouseButton2, AimlockMode = false, AimPrediction = 0, HitChance = 100,
}

local CurrentTarget, CurrentTargetPart = nil, nil

-- ===== УТИЛИТЫ =====
local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getAimPart(char)
    if not char then return nil end
    return char:FindFirstChild(Flags.AimPart) or char:FindFirstChild("Head")
end

-- ===== SILENT AIM =====
local silentHookOk = pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if self == Mouse and Flags.Aimbot and not Flags.AimlockMode and CurrentTargetPart then
            if math.random(1, 100) > Flags.HitChance then return oldIndex(self, key) end
            local targetPos = CurrentTargetPart.Position
            if Flags.AimPrediction > 0 and CurrentTargetPart.Velocity then
                targetPos = targetPos + (CurrentTargetPart.Velocity * Flags.AimPrediction)
            end
            if key == "Hit" then return CFrame.new(targetPos)
            elseif key == "Target" then return CurrentTargetPart end
        end
        return oldIndex(self, key)
    end)
end)
if not silentHookOk then warn("[cloudclient] hookmetamethod failed — Silent Aim недоступен") end

-- ===== ПОИСК ЦЕЛИ =====
local function getClosestTarget()
    local closest, closestPart
    local shortest = math.huge
    local vs = Camera.ViewportSize
    local center = Vector2.new(vs.X/2, vs.Y/2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isAlive(plr.Character) then
            if Flags.AimTeamCheck and LP.Team and plr.Team and plr.Team == LP.Team then continue end
            local part = getAimPart(plr.Character)
            if part then
                local sp = Camera:WorldToScreenPoint(part.Position)
                if sp.Z > 0 then
                    local dist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                    if dist < Flags.AimFOV and dist < shortest then
                        shortest = dist; closest = plr; closestPart = part
                    end
                end
            end
        end
    end
    return closest, closestPart
end

-- ===== AIMLOCK =====
RunService:BindToRenderStep("CloudClientAimlock", Enum.RenderPriority.Camera.Value + 2, function(dt)
    if not Flags.Aimbot or not Flags.AimlockMode then return end
    if not UIS:IsMouseButtonPressed(Flags.AimKey) or not CurrentTargetPart then return end
    local camPos = Camera.CFrame.Position
    local targetPos = CurrentTargetPart.Position
    if Flags.AimPrediction > 0 and CurrentTargetPart.Velocity then
        targetPos = targetPos + (CurrentTargetPart.Velocity * Flags.AimPrediction)
    end
    local lookCF = CFrame.lookAt(camPos, targetPos)
    local alpha = 1 - (1 - (1/math.max(1, Flags.AimSmooth))) ^ (dt * 60)
    Camera.CFrame = Camera.CFrame:Lerp(lookCF, alpha)
end)

-- ===== ОБНОВЛЕНИЕ ЦЕЛИ =====
RunService.RenderStepped:Connect(function()
    if Flags.Aimbot then
        local _, part = getClosestTarget()
        CurrentTargetPart = part
    else
        CurrentTargetPart = nil
    end
end)

-- ===== FOV CIRCLE =====
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1; fovCircle.Color = Color3.fromRGB(255,255,255)
fovCircle.Filled = false; fovCircle.Visible = false; fovCircle.NumSides = 64

RunService.RenderStepped:Connect(function()
    if Flags.Aimbot then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Radius = Flags.AimFOV; fovCircle.Visible = true
    else fovCircle.Visible = false end
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
end

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

-- ===== FULLBRIGHT =====
local origLight = {Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime, FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart, GlobalShadows=Lighting.GlobalShadows, Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient}
local function setFullbright(state)
    if state then
        Lighting.Brightness=2; Lighting.ClockTime=12; Lighting.FogEnd=1e5; Lighting.FogStart=0
        Lighting.GlobalShadows=false; Lighting.Ambient=Color3.fromRGB(178,178,178); Lighting.OutdoorAmbient=Color3.fromRGB(178,178,178)
    else
        for k,v in pairs(origLight) do Lighting[k] = v end
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

    if not want or not char or not isAlive(char) then
        clearHighlight(plr)
        return
    end

    local hl = Highlights[plr]
    if not hl or not hl.Parent then
        if hl then pcall(function() hl:Destroy() end) end
        hl = Instance.new("Highlight")
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        Highlights[plr] = hl
    end

    if Flags.ESPMode == "Chams" then
        hl.FillColor = Flags.ESPColor
        hl.FillTransparency = 0
        hl.OutlineColor = Flags.ESPColor
        hl.OutlineTransparency = 1
    else -- Glow
        hl.FillColor = Flags.ESPColor
        hl.FillTransparency = 1
        hl.OutlineColor = Flags.ESPColor
        hl.OutlineTransparency = 0
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

local function ensureSkeleton(plr)
    if Skeletons[plr] then return end
    local lines = {}
    local connections = (LP.Character and LP.Character:FindFirstChild("UpperTorso")) and SKELETON_CONNECTIONS or R6_CONNECTIONS
    for i = 1, #connections do
        local l = Drawing.new("Line"); l.Thickness=1; l.Visible=false
        lines[i] = l
    end
    Skeletons[plr] = {lines = lines, conns = connections}
end

local function updateSkeleton(plr, char)
    ensureSkeleton(plr)
    local sk = Skeletons[plr]
    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    local conns = isR15 and SKELETON_CONNECTIONS or R6_CONNECTIONS
    if #sk.conns ~= #conns then sk.conns = conns end
    for i, conn in ipairs(conns) do
        local p1 = char:FindFirstChild(conn[1])
        local p2 = char:FindFirstChild(conn[2])
        local line = sk.lines[i]
        if p1 and p2 then
            local s1, o1 = Camera:WorldToViewportPoint(p1.Position)
            local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
            if o1 and o2 and s1.Z > 0 and s2.Z > 0 then
                line.From = Vector2.new(s1.X, s1.Y); line.To = Vector2.new(s2.X, s2.Y)
                line.Color = Flags.SkeletonColor; line.Visible = true
            else line.Visible = false end
        else line.Visible = false end
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
    for _, child in ipairs(tool:GetChildren()) do
        if (child:IsA("Model") or child:IsA("MeshPart")) and isMeaningfulName(child.Name) then return child.Name end
    end
    return nil
end

-- ===== HIGHLIGHT ПО ДИСТАНЦИИ =====
local function updateHighlightDistance(plr, dist, visible)
    local hl = Highlights[plr]
    if not hl or not hl.Parent then return end
    local inRange = Flags.ESP and Flags.MaxDistance > 0 and visible and dist <= Flags.MaxDistance
    hl.Enabled = inRange or false
end

-- ===== ОСНОВНОЙ ESP ЦИКЛ =====
local function updateESP()
    if not Flags.ESP or Flags.MaxDistance <= 0 then
        for _,d in pairs(Drawings) do for _,o in pairs(d) do o.Visible=false end end
        for _,sk in pairs(Skeletons) do for _,l in pairs(sk.lines) do l.Visible=false end end
        for _,hl in pairs(Highlights) do if hl and hl.Parent then hl.Enabled = false end end
        return
    end

    local localChar = LP.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then
        for _,d in pairs(Drawings) do for _,o in pairs(d) do o.Visible=false end end
        for _,sk in pairs(Skeletons) do for _,l in pairs(sk.lines) do l.Visible=false end end
        for _,hl in pairs(Highlights) do if hl and hl.Parent then hl.Enabled = false end end
        return
    end
    local localPos = localRoot.Position
    local vs = Camera.ViewportSize

    for plr, d in pairs(Drawings) do
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then
            for _,o in pairs(d) do o.Visible=false end
            if Skeletons[plr] then for _,l in pairs(Skeletons[plr].lines) do l.Visible=false end end
            updateHighlightDistance(plr, math.huge, false)
            continue
        end
        local dist = (root.Position - localPos).Magnitude
        if dist > Flags.MaxDistance then
            for _,o in pairs(d) do o.Visible=false end
            if Skeletons[plr] then for _,l in pairs(Skeletons[plr].lines) do l.Visible=false end end
            updateHighlightDistance(plr, dist, false)
            continue
        end
        local sp = Camera:WorldToViewportPoint(root.Position)
        if sp.Z <= 0 then
            for _,o in pairs(d) do o.Visible=false end
            if Skeletons[plr] then for _,l in pairs(Skeletons[plr].lines) do l.Visible=false end end
            updateHighlightDistance(plr, dist, false)
            continue
        end

        local sx, sy = sp.X, sp.Y
        local headPos = (char:FindFirstChild("Head") and char.Head.Position or root.Position) + Vector3.new(0,1.5,0)
        local feetPos = root.Position - Vector3.new(0,2.5,0)
        local hS = Camera:WorldToViewportPoint(headPos)
        local fS = Camera:WorldToViewportPoint(feetPos)

        if Flags.Box and hS.Z > 0 and fS.Z > 0 then
            local h = math.abs(hS.Y - fS.Y); local w = h * 0.5
            d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(sx - w/2, hS.Y)
            d.Box.Color = Flags.BoxColor; d.Box.Visible = true
        else d.Box.Visible = false end

        if Flags.Name then d.Name.Text = plr.Name; d.Name.Position = Vector2.new(sx, hS.Y-18); d.Name.Color = Flags.TextColor; d.Name.Visible = true else d.Name.Visible = false end
        if Flags.Health then d.Health.Text = "HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth); d.Health.Position = Vector2.new(sx, fS.Y+2); d.Health.Color = Flags.TextColor; d.Health.Visible = true else d.Health.Visible = false end
        if Flags.Distance then d.Distance.Text = math.floor(dist).."m"; d.Distance.Position = Vector2.new(sx, fS.Y+18); d.Distance.Color = Flags.TextColor; d.Distance.Visible = true else d.Distance.Visible = false end
        if Flags.Line then d.Line.From = Vector2.new(vs.X/2, vs.Y); d.Line.To = Vector2.new(sx, sy); d.Line.Color = Flags.LineColor; d.Line.Visible = true else d.Line.Visible = false end

        if Flags.WeaponESP then
            local weaponName = getWeaponName(char)
            if weaponName then
                d.Weapon.Text = "["..weaponName.."]"
                d.Weapon.Position = Vector2.new(sx, fS.Y + 34)
                d.Weapon.Color = Flags.TextColor
                d.Weapon.Visible = true
            else d.Weapon.Visible = false end
        else d.Weapon.Visible = false end

        if Flags.Skeleton then updateSkeleton(plr, char) else
            if Skeletons[plr] then for _,l in pairs(Skeletons[plr].lines) do l.Visible=false end end
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
        Title = "Stats",
        Name = "CloudClientStats",
        Size = {220},
        Minimizable = true,
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
                if pingRow then
                    pingRow:Set(ok and ping and (math.floor(ping).." ms") or "n/a")
                end
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
            if statusRow then
                statusRow:Set(Flags.ESP and "ESP on" or "ESP off")
            end
        else
            if HudPanel then destroyHud() end
        end
        RunService.Heartbeat:Wait()
    end
end)

-- ===== AUTORUN / SPIDER TIMER =====
RunService.Stepped:Connect(function()
    applyAutoRun()
    updateSpider()
end)

-- ===== MAIN LOOP =====
RunService:BindToRenderStep("CloudClientMain", Enum.RenderPriority.Camera.Value + 1, function()
    if Flags.ESP and Flags.MaxDistance > 0 then
        updateESP()
    else
        for _,d in pairs(Drawings) do for _,o in pairs(d) do o.Visible=false end end
        for _,sk in pairs(Skeletons) do for _,l in pairs(sk.lines) do l.Visible=false end end
        for _,hl in pairs(Highlights) do if hl and hl.Parent then hl.Enabled = false end end
    end
end)

-- ===== UI: AIMBOT =====
local AimbotTab = Window:AddTab("Aimbot", "crosshair")
AimbotTab:AddToggle({Title="Aimbot", Subtitle="Silent Aim через хук Mouse.Hit, камера не двигается", Icon="crosshair", Default=false, Callback=function(s) Flags.Aimbot=s end})
AimbotTab:AddToggle({Title="Aimlock Mode", Subtitle="CFrame.lookAt вместо Silent — камера доворачивается", Icon="eye", Default=false, Callback=function(s) Flags.AimlockMode=s end})
AimbotTab:AddSlider({Title="Smoothness (1=snap)", Icon="activity", Min=1, Max=100, Default=1, Callback=function(v) Flags.AimSmooth=v end})
AimbotTab:AddSlider({Title="Aim FOV", Icon="circle", Min=20, Max=400, Default=120, Callback=function(v) Flags.AimFOV=v end})
AimbotTab:AddSlider({Title="Prediction", Icon="trending-up", Min=0, Max=0.5, Default=0, Callback=function(v) Flags.AimPrediction=v end})
AimbotTab:AddSlider({Title="Hit Chance %", Icon="percent", Min=0, Max=100, Default=100, Callback=function(v) Flags.HitChance=v end})
AimbotTab:AddDropdown({Title="Target Part", Subtitle="Куда целится аимбот", Icon="user", Options={"Head","HumanoidRootPart","UpperTorso"}, Default="Head", Callback=function(s) Flags.AimPart=s end})
AimbotTab:AddToggle({Title="Team Check", Subtitle="Не наводится на союзников", Icon="users", Default=true, Callback=function(s) Flags.AimTeamCheck=s end})
AimbotTab:AddKeybind({Title="Aim Key", Icon="mouse-pointer", Default=Enum.UserInputType.MouseButton2, Callback=function(k) if k and k.UserInputType then Flags.AimKey=k.UserInputType end end})

-- ===== UI: VISUALS =====
local VisualsTab = Window:AddTab("Visuals", "eye")

VisualsTab:AddSeparator(); VisualsTab:AddLabel("ESP COLOR", "palette"); VisualsTab:AddSeparator()

VisualsTab:AddColorPicker({Title="ESP Color", Subtitle="Общий цвет для Chams (заливка) и Glow (обводка)", Icon="palette", Default=Flags.ESPColor, Callback=function(c)
    Flags.ESPColor=c
    for _,hl in pairs(Highlights) do
        if hl and hl.Parent then hl.FillColor = c; hl.OutlineColor = c end
    end
end})

VisualsTab:AddColorPicker({Title="ESP Color", Subtitle="Общий цвет для Chams (заливка) и Glow (обводка)", Icon="palette", Default=Flags.ESPColor, Callback=function(c)
    Flags.ESPColor=c
    for _,hl in pairs(Highlights) do
        if hl and hl.Parent then hl.FillColor = c; hl.OutlineColor = c end
    end
end})

VisualsTab:AddColorPicker({Title="Text Color", Subtitle="Цвет текста: Name / Distance / Health / Weapon", Icon="type", Default=Flags.TextColor, Callback=function(c) Flags.TextColor=c end})
VisualsTab:AddColorPicker({Title="Box Color", Subtitle="Цвет рамки вокруг игрока", Icon="square", Default=Flags.BoxColor, Callback=function(c) Flags.BoxColor=c end})
VisualsTab:AddColorPicker({Title="Line Color", Subtitle="Цвет линии от низа экрана к игроку", Icon="move", Default=Flags.LineColor, Callback=function(c) Flags.LineColor=c end})
VisualsTab:AddColorPicker({Title="Skeleton Color", Subtitle="Цвет линий скелета (кость к кости)", Icon="bone", Default=Flags.SkeletonColor, Callback=function(c) Flags.SkeletonColor=c end})

VisualsTab:AddSeparator(); VisualsTab:AddLabel("ESP SYSTEM", "eye"); VisualsTab:AddSeparator()

VisualsTab:AddToggle({Title="ESP", Subtitle="Главный тоггл: без него ничего не рисуется", Icon="eye", Default=false, Callback=function(s)
    Flags.ESP=s
    for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
end})

VisualsTab:AddDropdown({Title="ESP Mode", Subtitle="Chams = заливка модели, Glow = обводка контура", Icon="layers", Options={"Chams","Glow"}, Default="Chams", Callback=function(v)
    Flags.ESPMode = v
    for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
end})

VisualsTab:AddToggle({Title="Box", Subtitle="Рамка вокруг модели игрока", Icon="box", Default=false, Callback=function(s) Flags.Box=s end})
VisualsTab:AddToggle({Title="Name", Subtitle="Ник игрока над головой", Icon="user", Default=false, Callback=function(s) Flags.Name=s end})
VisualsTab:AddToggle({Title="Health", Subtitle="HP и MaxHP под ногами", Icon="heart", Default=false, Callback=function(s) Flags.Health=s end})
VisualsTab:AddToggle({Title="Distance", Subtitle="Расстояние до игрока в метрах", Icon="ruler", Default=false, Callback=function(s) Flags.Distance=s end})
VisualsTab:AddToggle({Title="Line", Subtitle="Линия от низа экрана к игроку (snaplines)", Icon="move", Default=false, Callback=function(s) Flags.Line=s end})
VisualsTab:AddToggle({Title="Skeleton", Subtitle="Линии между костями (R6 и R15)", Icon="bone", Default=false, Callback=function(s) Flags.Skeleton=s end})
VisualsTab:AddToggle({Title="Weapon ESP", Subtitle="Имя оружия в руках (без Handle и частей тела)", Icon="sword", Default=false, Callback=function(s) Flags.WeaponESP=s end})
VisualsTab:AddSlider({Title="ESP Distance", Subtitle="Максимальная дистанция отрисовки, метров", Icon="ruler", Min=100, Max=1000, Default=1000, Callback=function(v)
    Flags.MaxDistance=v
    for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
end})

-- ===== UI: PLAYER =====
local PlayerTab = Window:AddTab("Player", "user")

PlayerTab:AddToggle({Title="FreeCam", Subtitle="Свободная камера: WASD + Space/Ctrl, мышь крутит угол", Icon="camera", Default=false, Callback=function(s)
    Flags.FreeCam=s
    if s then startFreeCam() else stopFreeCam() end
end})

PlayerTab:AddSeparator(); PlayerTab:AddLabel("MOVEMENT", "move"); PlayerTab:AddSeparator()

PlayerTab:AddToggle({Title="AutoRun", Subtitle="Автоматический бег вперёд (speed 20)", Icon="zap", Default=false, Callback=function(s) Flags.AutoRun=s end})
PlayerTab:AddToggle({Title="Spider", Subtitle="Лазать по стенам: W/Space вверх, S/Ctrl вниз", Icon="arrow-up", Default=false, Callback=function(s) Flags.Spider=s end})
PlayerTab:AddSlider({Title="Spider Speed", Subtitle="Скорость лазания по стенам", Icon="gauge", Min=15, Max=30, Default=20, Callback=function(v) Flags.SpiderSpeed=v end})

-- ===== UI: OTHER =====
local OtherTab = Window:AddTab("Other", "box")
OtherTab:AddToggle({Title="Fullbright", Subtitle="Яркий мир: убирает туман и тени", Icon="sun", Default=false, Callback=function(s)
    Flags.Fullbright=s
    setFullbright(s)
end})

-- ===== UI: SETTINGS =====
local SettingsTab = Window:AddTab("Settings", "settings")

local themeNames = {}
for name in pairs(VantixUI.Themes) do table.insert(themeNames, name) end
table.sort(themeNames)

SettingsTab:AddDropdown({Title="Theme", Subtitle="Тема оформления меню", Icon="swatch-book", Options=themeNames, Default=Window:GetTheme(), Callback=function(s) Window:SetTheme(s) end})
SettingsTab:AddDropdown({Title="Accent Color", Subtitle="Акцентный цвет элементов меню", Icon="droplet", Options={"White","Blue","Red","Green","Purple"}, Default="White", Callback=function(s)
    local colors = {
        White=Color3.fromRGB(255,255,255), Blue=Color3.fromRGB(64,156,255),
        Red=Color3.fromRGB(230,70,70),     Green=Color3.fromRGB(80,210,120),
        Purple=Color3.fromRGB(170,110,240),
    }
    VantixUI:SetAccentColor(colors[s])
end})

SettingsTab:AddSeparator()

SettingsTab:AddToggle({Title="Stats HUD", Subtitle="FPS / Ping / HP / Position в отдельной панели", Icon="gauge", Default=false, Callback=function(s) Flags.FPSPing=s end})

SettingsTab:AddSeparator()

SettingsTab:AddKeybind({Title="Hide UI Keybind", Subtitle="Кнопка скрытия/показа меню", Icon="keyboard", Default=Enum.KeyCode.Delete, Callback=function()
    local sg = Window.Gui
    if sg then sg.Enabled = not sg.Enabled end
end})
