--[[
    CLOUDCLIENT — Silent Aim + ESP (Skeleton/Weapon/Chams) + FreeCam + AutoRun/Spider
    Aimbot: hookmetamethod (Silent) + CFrame.lookAt (Aimlock)
    Weapon ESP: фильтр Handle/служебных частей тулов
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
    -- ESP
    ESP = false, Glow = false, Box = false, Distance = false, Name = false, Health = false, Line = false,
    Skeleton = false, WeaponESP = false, Chams = false,
    MaxDistance = 1000,
    ESPColor = Color3.fromRGB(255,255,255), BoxColor = Color3.fromRGB(255,255,255), LineColor = Color3.fromRGB(255,255,255),
    SkeletonColor = Color3.fromRGB(0, 255, 0), ChamsColor = Color3.fromRGB(255, 0, 255),
    -- Player
    FreeCam = false, AutoRun = false, AutoRunSpeed = 16, Spider = false, SpiderSpeed = 30,
    -- Misc
    FPSPing = false, Fullbright = false,
    -- Aimbot
    Aimbot = false, AimPart = "Head", AimSmooth = 1, AimFOV = 120, AimTeamCheck = true,
    AimKey = Enum.UserInputType.MouseButton2, AimlockMode = false, AimPrediction = 0, HitChance = 100,
}

local CurrentTarget, CurrentTargetPart = nil, nil

-- ===== УТИЛИТЫ =====
-- Проверяет, что персонаж существует и жив (Humanoid.Health > 0)
local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- Возвращает часть для наведения: сначала указанная в Flags.AimPart, иначе Head
local function getAimPart(char)
    if not char then return nil end
    return char:FindFirstChild(Flags.AimPart) or char:FindFirstChild("Head")
end

-- ===== SILENT AIM (HOOK) =====
-- Подменяет Mouse.Hit / Mouse.Target через hookmetamethod.
-- Камера не двигается: пуля летит по координатам головы цели в момент выстрела.
-- Если хук не поддерживается экзекутором — в консоли warn, работает только Aimlock.
local silentHookOk = pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if self == Mouse and Flags.Aimbot and not Flags.AimlockMode and CurrentTargetPart then
            -- HitChance: с шансом (100 - HitChance)% возвращаем настоящий Mouse.Hit (промах)
            if math.random(1, 100) > Flags.HitChance then return oldIndex(self, key) end
            local targetPos = CurrentTargetPart.Position
            -- Prediction: компенсация скорости цели (Velocity * коэффициент)
            if Flags.AimPrediction > 0 and CurrentTargetPart.Velocity then
                targetPos = targetPos + (CurrentTargetPart.Velocity * Flags.AimPrediction)
            end
            if key == "Hit" then return CFrame.new(targetPos)
            elseif key == "Target" then return CurrentTargetPart end
        end
        return oldIndex(self, key)
    end)
end)
if not silentHookOk then warn("[cloudclient] hookmetamethod failed — Silent Aim недоступен, используй Aimlock") end

-- ===== ПОИСК ЦЕЛИ =====
-- Перебирает игроков, отбрасывает мёртвых/тиммейтов, считает расстояние в пикселях
-- от центра экрана до проекции AimPart. Возвращает ближайшую цель в радиусе AimFOV.
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
-- Альтернатива Silent Aim: плавно доворачивает камеру через CFrame.lookAt.
-- Lerp frame-rate independent: alpha = 1-(1-smooth)^(dt*60), чтобы скорость не зависела от FPS.
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
-- Каждый кадр пересчитывает текущую цель для Silent Aim / Aimlock / FOV-круга.
RunService.RenderStepped:Connect(function()
    if Flags.Aimbot then
        local _, part = getClosestTarget()
        CurrentTargetPart = part
    else
        CurrentTargetPart = nil
    end
end)

-- ===== FOV CIRCLE =====
-- Рисует круг радиуса AimFOV по центру экрана, пока аимбот включён.
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
-- Свободная камера: WASD + Space/Ctrl, мышь крутит угол. Блокирует движение персонажа.
local freecamConn, freecamMouseConn, savedCamType, savedMouseBehavior = nil, nil, nil, nil
local savedWS, savedJP = 16, 50
local freecamPos = Vector3.new(0,0,0); local freecamYaw, freecamPitch = 0, 0

-- Отключает FreeCam, восстанавливает CameraType, MouseBehavior и движение персонажа
local function stopFreeCam()
    if freecamConn then freecamConn:Disconnect(); freecamConn = nil end
    if freecamMouseConn then freecamMouseConn:Disconnect(); freecamMouseConn = nil end
    if savedCamType then Camera.CameraType = savedCamType; savedCamType = nil end
    if savedMouseBehavior then UIS.MouseBehavior = savedMouseBehavior; savedMouseBehavior = nil end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = savedWS; hum.JumpPower = savedJP end
end

-- Запускает FreeCam: запоминает камеру/движение, лочит мышь в центр, обрабатывает WASD
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
-- Автоматически ведёт персонажа вперёд в направлении камеры (Humanoid:Move).
-- Не двигает сам CFrame — сервер видит нормальное движение. Тоггл включает постоянный бег.
local function applyAutoRun()
    if not Flags.AutoRun then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    -- WalkSpeed принудительно ставим, чтобы обойти серверную установку 16
    hum.WalkSpeed = Flags.AutoRunSpeed
    -- Направление движения: горизонтальная проекция LookVector камеры
    local look = Camera.CFrame.LookVector
    local dir = Vector3.new(look.X, 0, look.Z)
    if dir.Magnitude > 0.01 then
        hum:Move(dir.Unit, false)
    end
end

-- ===== SPIDER =====
-- Лазание по стенам: если рядом стена (raycast) — задаём вертикальную скорость вверх
-- через BodyVelocity. Отключается при отпускании управления/в прыжке без стены.
local spiderBV = nil
local spiderRayParams = RaycastParams.new()
spiderRayParams.FilterType = Enum.RaycastFilterType.Exclude
spiderRayParams.FilterDescendantsInstances = {LP.Character}

-- Убирает BodyVelocity и обнуляет вертикальную скорость (чтобы персонаж нормально падал)
local function clearSpiderVelocity()
    if spiderBV then spiderBV:Destroy(); spiderBV = nil end
end

-- Основной тик Spider: raycast по 4 направлениям (вперёд/назад/влево/вправо)
-- от HumanoidRootPart. Если стена близко и игрок жмёт W — тянем вверх.
local function updateSpider()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then clearSpiderVelocity(); return end

    if not Flags.Spider then clearSpiderVelocity(); return end

    -- Ищем стену: 4 рейкаста вокруг персонажа на 2.5 стада
    spiderRayParams.FilterDescendantsInstances = {char}
    local origin = hrp.Position
    local dirs = {
        Camera.CFrame.LookVector,
        -Camera.CFrame.LookVector,
        Camera.CFrame.RightVector,
        -Camera.CFrame.RightVector,
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

    -- На стене: если держим W (или Space) — тянем вверх, если S — вниз
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
-- Сохраняет исходные параметры Lighting и подменяет их при включении.
-- Восстанавливает ровно то, что было, при выключении.
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
-- Хранилища: Drawings — тексты/боксы/линии на игрока, Highlights — Highlight-объекты (glow/chams),
-- Skeletons — линии скелета, WeaponLabels — зарезервировано под расширения.
local Drawings, Highlights, Skeletons, WeaponLabels = {}, {}, {}, {}

-- Создаёт набор Drawing-объектов для игрока (один раз при подключении)
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

-- Полностью удаляет все Drawing/Highlight/скелет для игрока (при PlayerRemoving)
local function removeDrawings(plr)
    if Drawings[plr] then
        for _,o in pairs(Drawings[plr]) do if o then pcall(function() o:Remove() end) end end
        Drawings[plr]=nil
    end
    if Highlights[plr] then pcall(function() Highlights[plr]:Destroy() end); Highlights[plr]=nil end
    if Skeletons[plr] then
        for _,l in pairs(Skeletons[plr].lines) do pcall(function() l:Remove() end) end
        Skeletons[plr]=nil
    end
    if WeaponLabels[plr] then pcall(function() WeaponLabels[plr]:Remove() end); WeaponLabels[plr]=nil end
end

-- Уничтожает Highlight игрока (используется и для Glow, и для Chams)
local function clearHighlight(plr)
    if Highlights[plr] then pcall(function() Highlights[plr]:Destroy() end); Highlights[plr]=nil end
end

-- Glow: полупрозрачный Highlight вокруг модели (FillTransparency=0.5)
local function applyGlow(plr)
    if plr == LP or not Flags.Glow then clearHighlight(plr); return end
    local char = plr.Character
    if not char or not isAlive(char) then clearHighlight(plr); return end
    local hl = Highlights[plr]
    if not hl or not hl.Parent then
        clearHighlight(plr)
        hl = Instance.new("Highlight")
        hl.FillColor = Flags.ESPColor; hl.FillTransparency = 0.5
        hl.OutlineColor = Flags.ESPColor; hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char; Highlights[plr] = hl
    else hl.FillColor = Flags.ESPColor; hl.OutlineColor = Flags.ESPColor end
end

-- Chams: непрозрачный Highlight (FillTransparency=0) — модель заливается цветом сквозь стены
local function applyChams(plr)
    if plr == LP or not Flags.Chams then
        if Highlights[plr] and Highlights[plr].Name == "ChamsHL" then clearHighlight(plr) end
        return
    end
    local char = plr.Character
    if not char or not isAlive(char) then return end
    local hl = Highlights[plr]
    if not hl or not hl.Parent or hl.Name ~= "ChamsHL" then
        clearHighlight(plr)
        hl = Instance.new("Highlight")
        hl.Name = "ChamsHL"
        hl.FillColor = Flags.ChamsColor; hl.FillTransparency = 0
        hl.OutlineColor = Flags.ChamsColor; hl.OutlineTransparency = 1
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char; Highlights[plr] = hl
    else hl.FillColor = Flags.ChamsColor end
end

-- ===== SKELETON =====
-- Соединения костей для R15 и R6. Используются как пары для линий Drawing.
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

-- Лениво создаёт массив линий для игрока (кол-во под текущий скелет)
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

-- Обновляет линии скелета: проецирует кости в экран, скрывает невидимые/за камерой
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
-- Служебные имена частей Tool, которые не считаем «оружием» в руках.
local WEAPON_IGNORE = {
    Handle = true, Grip = true, Attachment = true, Attachment1 = true,
    ["LeftGrip"] = true, ["RightGrip"] = true, ["Tool"] = true,
}

-- Возвращает имя реального оружия у персонажа или nil.
-- Проверяет Tool и его потомков: если Tool имеет оружие-подобную часть/имя — вернёт имя.
-- Пропускает Handle и служебные объекты, чтобы не показывать «Handle» когда берут предмет.
local function getWeaponName(char)
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    -- Если имя тула не служебное — берём его (это и есть «оружие»)
    if not WEAPON_IGNORE[tool.Name] and tool.Name ~= "" then
        return tool.Name
    end
    -- Иначе ищем внутри Tool осмысленное имя (не Handle и не Attachment)
    for _, child in ipairs(tool:GetChildren()) do
        if child:IsA("BasePart") and not WEAPON_IGNORE[child.Name] then
            return child.Name
        end
    end
    -- Всё служебное — не показываем вовсе
    return nil
end

-- ===== ОСНОВНОЙ ESP ЦИКЛ =====
-- Обновляет все включённые элементы ESP для каждого игрока:
-- бокс/имя/HP/дистанция/линия/weapon/skeleton. Скрывает всё при выключенном ESP.
local function updateESP()
    local localChar = LP.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then
        for _,d in pairs(Drawings) do for _,o in pairs(d) do o.Visible=false end end
        for _,sk in pairs(Skeletons) do for _,l in pairs(sk.lines) do l.Visible=false end end
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
            continue
        end
        local dist = (root.Position - localPos).Magnitude
        if dist > Flags.MaxDistance then
            for _,o in pairs(d) do o.Visible=false end
            if Skeletons[plr] then for _,l in pairs(Skeletons[plr].lines) do l.Visible=false end end
            continue
        end
        local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen or sp.Z <= 0 then
            for _,o in pairs(d) do o.Visible=false end
            if Skeletons[plr] then for _,l in pairs(Skeletons[plr].lines) do l.Visible=false end end
            continue
        end
        local sx, sy = sp.X, sp.Y
        local headPos = (char:FindFirstChild("Head") and char.Head.Position or root.Position) + Vector3.new(0,1.5,0)
        local feetPos = root.Position - Vector3.new(0,2.5,0)
        local hS, hO = Camera:WorldToViewportPoint(headPos)
        local fS, fO = Camera:WorldToViewportPoint(feetPos)

        -- Box: рамка вокруг модели
        if Flags.Box and hO and fO then
            local h = math.abs(hS.Y - fS.Y); local w = h * 0.5
            d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(sx - w/2, hS.Y)
            d.Box.Color = Flags.BoxColor; d.Box.Visible = true
        else d.Box.Visible = false end

        -- Name / Health / Distance / Line — стандартные тексты
        if Flags.Name then d.Name.Text = plr.Name; d.Name.Position = Vector2.new(sx, hS.Y-18); d.Name.Color = Flags.ESPColor; d.Name.Visible = true else d.Name.Visible = false end
        if Flags.Health then d.Health.Text = "HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth); d.Health.Position = Vector2.new(sx, fS.Y+2); d.Health.Color = Flags.ESPColor; d.Health.Visible = true else d.Health.Visible = false end
        if Flags.Distance then d.Distance.Text = math.floor(dist).."m"; d.Distance.Position = Vector2.new(sx, fS.Y+18); d.Distance.Color = Flags.ESPColor; d.Distance.Visible = true else d.Distance.Visible = false end
        if Flags.Line then d.Line.From = Vector2.new(vs.X/2, vs.Y); d.Line.To = Vector2.new(sx, sy); d.Line.Color = Flags.LineColor; d.Line.Visible = true else d.Line.Visible = false end

        -- Weapon ESP: показываем только реальное оружие, игнорируя Handle и служебные части
        if Flags.WeaponESP then
            local weaponName = getWeaponName(char)
            if weaponName then
                d.Weapon.Text = "["..weaponName.."]"
                d.Weapon.Position = Vector2.new(sx, fS.Y + 34)
                d.Weapon.Color = Flags.ESPColor
                d.Weapon.Visible = true
            else d.Weapon.Visible = false end
        else d.Weapon.Visible = false end

        -- Skeleton: линии между костями
        if Flags.Skeleton then updateSkeleton(plr, char) else
            if Skeletons[plr] then for _,l in pairs(Skeletons[plr].lines) do l.Visible=false end end
        end
    end
end

-- ===== ХУКИ ИГРОКОВ =====
-- Навешивает на игрока создание Drawing + переприменение Glow/Chams на респавн/смерть.
local function hookPlayer(plr)
    if plr == LP then return end
    createDrawings(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.2)
        if Flags.Glow then applyGlow(plr) end
        if Flags.Chams then applyChams(plr) end
    end)
    plr.CharacterRemoving:Connect(function() clearHighlight(plr) end)
    if Flags.Glow then task.wait(1); applyGlow(plr) end
    if Flags.Chams then task.wait(1); applyChams(plr) end
end
for _,plr in ipairs(Players:GetPlayers()) do hookPlayer(plr) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(removeDrawings)

-- ===== FPS/PING =====
-- Счётчик кадров раз в секунду + пинг сервера (Stat.Network.ServerStatsItem)
local fpsText, pingText, fpsCounter, lastFpsTime = nil, nil, 0, os.clock()
RunService.RenderStepped:Connect(function()
    if Flags.FPSPing then
        if not fpsText then
            fpsText = Drawing.new("Text"); fpsText.Size=14; fpsText.Color=Color3.fromRGB(255,255,255); fpsText.Outline=true; fpsText.Position=Vector2.new(10,10)
            pingText = Drawing.new("Text"); pingText.Size=14; pingText.Color=Color3.fromRGB(255,255,255); pingText.Outline=true; pingText.Position=Vector2.new(10,28)
        end
        fpsCounter = fpsCounter + 1
        local now = os.clock()
        if now - lastFpsTime >= 1 then
            fpsText.Text = "FPS: "..fpsCounter; fpsText.Visible=true
            fpsCounter=0; lastFpsTime=now
            local ok, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
            pingText.Text = ok and ping and ("Ping: "..math.floor(ping).."ms") or "Ping: n/a"
            pingText.Visible=true
        end
    else
        if fpsText then fpsText.Visible=false end
        if pingText then pingText.Visible=false end
    end
end)

-- ===== AUTORUN / SPIDER TIMER =====
-- Единый тик Stepped: применяет AutoRun и Spider (вызовы игнорируют флаги внутри).
RunService.Stepped:Connect(function()
    applyAutoRun()
    updateSpider()
end)

-- ===== MAIN LOOP =====
-- Основной ESP-рендер: если ESP выключен — гасим все Drawing, не тратя CPU.
RunService:BindToRenderStep("CloudClientMain", Enum.RenderPriority.Camera.Value + 1, function()
    if Flags.ESP then updateESP() else
        for _,d in pairs(Drawings) do for _,o in pairs(d) do o.Visible=false end end
        for _,sk in pairs(Skeletons) do for _,l in pairs(sk.lines) do l.Visible=false end end
    end
end)

-- ===== UI: AIMBOT =====
local AimbotTab = Window:AddTab("Aimbot", "crosshair")
AimbotTab:AddToggle({Title="Aimbot", Subtitle="Silent Aim (камера не двигается)", Icon="crosshair", Default=false, Callback=function(s) Flags.Aimbot=s end})
AimbotTab:AddToggle({Title="Aimlock Mode", Subtitle="CFrame.lookAt вместо Silent — камера доворачивается", Icon="eye", Default=false, Callback=function(s) Flags.AimlockMode=s end})
AimbotTab:AddSlider({Title="Smoothness (1=snap)", Icon="activity", Min=1, Max=100, Default=1, Callback=function(v) Flags.AimSmooth=v end})
AimbotTab:AddSlider({Title="Aim FOV", Icon="circle", Min=20, Max=400, Default=120, Callback=function(v) Flags.AimFOV=v end})
AimbotTab:AddSlider({Title="Prediction", Icon="trending-up", Min=0, Max=0.5, Default=0, Callback=function(v) Flags.AimPrediction=v end})
AimbotTab:AddSlider({Title="Hit Chance %", Icon="percent", Min=0, Max=100, Default=100, Callback=function(v) Flags.HitChance=v end})
AimbotTab:AddDropdown({Title="Target Part", Icon="user", Options={"Head","HumanoidRootPart","UpperTorso"}, Default="Head", Callback=function(s) Flags.AimPart=s end})
AimbotTab:AddToggle({Title="Team Check", Icon="users", Default=true, Callback=function(s) Flags.AimTeamCheck=s end})
AimbotTab:AddKeybind({Title="Aim Key", Icon="mouse-pointer", Default=Enum.UserInputType.MouseButton2, Callback=function(k) if k and k.UserInputType then Flags.AimKey=k.UserInputType end end})

-- ===== UI: VISUALS =====
local VisualsTab = Window:AddTab("Visuals", "eye")

-- Цвета
VisualsTab:AddColorPicker({Title="ESP Color", Icon="palette", Default=Flags.ESPColor, Callback=function(c)
    Flags.ESPColor=c
    -- Применяем сразу к существующим Glow (не Chams)
    if Flags.Glow then
        for _,hl in pairs(Highlights) do
            if hl and hl.Parent and hl.Name~="ChamsHL" then hl.FillColor=c; hl.OutlineColor=c end
        end
    end
end})
VisualsTab:AddColorPicker({Title="Box Color", Icon="square", Default=Flags.BoxColor, Callback=function(c) Flags.BoxColor=c end})
VisualsTab:AddColorPicker({Title="Line Color", Icon="move", Default=Flags.LineColor, Callback=function(c) Flags.LineColor=c end})
VisualsTab:AddColorPicker({Title="Skeleton Color", Icon="bone", Default=Flags.SkeletonColor, Callback=function(c) Flags.SkeletonColor=c end})
VisualsTab:AddColorPicker({Title="Chams Color", Icon="shirt", Default=Flags.ChamsColor, Callback=function(c)
    Flags.ChamsColor=c
    -- Применяем сразу к существующим Chams
    for _,hl in pairs(Highlights) do if hl and hl.Name=="ChamsHL" then hl.FillColor=c end end
end})

VisualsTab:AddSeparator(); VisualsTab:AddLabel("ESP SYSTEM", "eye"); VisualsTab:AddSeparator()

-- Основные тогглы
VisualsTab:AddToggle({Title="ESP", Icon="eye", Default=false, Callback=function(s) Flags.ESP=s end})
VisualsTab:AddToggle({Title="Glow", Icon="sparkles", Default=false, Callback=function(s)
    Flags.Glow=s
    if s then
        for _,p in ipairs(Players:GetPlayers()) do applyGlow(p) end
    else
        -- Убираем только Glow, не трогаем Chams
        for p in pairs(Highlights) do
            if Highlights[p] and Highlights[p].Name~="ChamsHL" then clearHighlight(p) end
        end
    end
end})
VisualsTab:AddToggle({Title="Chams", Subtitle="Заливка модели цветом", Icon="shirt", Default=false, Callback=function(s)
    Flags.Chams=s
    if s then
        for _,p in ipairs(Players:GetPlayers()) do applyChams(p) end
    else
        -- Убираем только Chams, не трогаем Glow
        for p in pairs(Highlights) do
            if Highlights[p] and Highlights[p].Name=="ChamsHL" then clearHighlight(p) end
        end
    end
end})
VisualsTab:AddToggle({Title="Box", Icon="box", Default=false, Callback=function(s) Flags.Box=s end})
VisualsTab:AddToggle({Title="Name", Icon="user", Default=false, Callback=function(s) Flags.Name=s end})
VisualsTab:AddToggle({Title="Health", Icon="heart", Default=false, Callback=function(s) Flags.Health=s end})
VisualsTab:AddToggle({Title="Distance", Icon="ruler", Default=false, Callback=function(s) Flags.Distance=s end})
VisualsTab:AddToggle({Title="Line", Icon="move", Default=false, Callback=function(s) Flags.Line=s end})
VisualsTab:AddToggle({Title="Skeleton", Subtitle="R6 + R15", Icon="bone", Default=false, Callback=function(s) Flags.Skeleton=s end})
VisualsTab:AddToggle({Title="Weapon ESP", Subtitle="Только реальное оружие, без Handle", Icon="sword", Default=false, Callback=function(s) Flags.WeaponESP=s end})
VisualsTab:AddSlider({Title="ESP Distance", Icon="ruler", Min=0, Max=2000, Default=1000, Callback=function(v) Flags.MaxDistance=v end})

-- ===== UI: PLAYER =====
local PlayerTab = Window:AddTab("Player", "user")

PlayerTab:AddToggle({Title="FreeCam", Icon="camera", Default=false, Callback=function(s)
    Flags.FreeCam=s
    if s then startFreeCam() else stopFreeCam() end
end})

PlayerTab:AddSeparator(); PlayerTab:AddLabel("MOVEMENT", "move"); PlayerTab:AddSeparator()

-- AutoRun: постоянно ведёт персонажа вперёд в направлении камеры
PlayerTab:AddToggle({Title="AutoRun", Subtitle="Автоматический бег вперёд", Icon="zap", Default=false, Callback=function(s) Flags.AutoRun=s end})
PlayerTab:AddSlider({Title="AutoRun Speed", Icon="footprints", Min=1, Max=200, Default=16, Callback=function(v) Flags.AutoRunSpeed=v end})

-- Spider: лазание по стенам через BodyVelocity
PlayerTab:AddToggle({Title="Spider", Subtitle="Лазать по стенам (W/Space вверх, S/Ctrl вниз)", Icon="arrow-up", Default=false, Callback=function(s) Flags.Spider=s end})
PlayerTab:AddSlider({Title="Spider Speed", Icon="gauge", Min=5, Max=200, Default=30, Callback=function(v) Flags.SpiderSpeed=v end})

-- ===== UI: OTHER =====
local OtherTab = Window:AddTab("Other", "box")
OtherTab:AddToggle({Title="Fullbright", Icon="sun", Default=false, Callback=function(s)
    Flags.Fullbright=s
    setFullbright(s)
end})

-- ===== UI: SETTINGS =====
local SettingsTab = Window:AddTab("Settings", "settings")

-- Тема
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

SettingsTab:AddSeparator()

-- Счётчик FPS/Ping
SettingsTab:AddToggle({Title="FPS / Ping Counter", Icon="activity", Default=false, Callback=function(s) Flags.FPSPing=s end})

SettingsTab:AddSeparator()

-- Кейбинд скрытия UI
SettingsTab:AddKeybind({Title="Hide UI Keybind", Icon="keyboard", Default=Enum.KeyCode.Delete, Callback=function()
    local sg = Window.Gui
    if sg then sg.Enabled = not sg.Enabled end
end})
