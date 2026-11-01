--[[
    CLOUDCLIENT — Aimbot (Delta-based) + Visuals + Player + Other
    fixed: aimbot via mouse deltas, glow respawn, fov circle, freecam mouse, fullbright restore
]]
local VantixUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/refs/heads/main/neverisUI2.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Window = VantixUI:CreateWindow({
    Title       = "cloudclient",
    Theme       = "Vantix",
    AccentColor = Color3.fromRGB(255, 255, 255),
    LogoID      = 110034487018208,
    Size        = {820, 480},
})

Window:CreateTag("Beta",    Color3.fromRGB(255, 105, 180), nil, "flask-conical")
Window:CreateTag("v1.0",    Color3.fromRGB(150, 150, 150), nil, "git-branch")
Window:CreateTag("Premium", Color3.fromRGB(255, 215, 0),   nil, "crown")

Window:Notify({ Title = "Welcome", Text = "cloudclient loaded", Icon = "check", Duration = 4 })

-- ===== СОСТОЯНИЕ =====
local Flags = {
    ESP = false, Glow = false, Box = false, Distance = false, Name = false, Health = false, Line = false,
    MaxDistance = 1000,
    ESPColor = Color3.fromRGB(255,255,255), BoxColor = Color3.fromRGB(255,255,255), LineColor = Color3.fromRGB(255,255,255),
    FreeCam = false,
    FPSPing = false,
    -- Aimbot
    Aimbot = false,
    AimPart = "Head",
    AimSmooth = 1,         -- 1 = snap, 100 = max smooth
    AimFOV = 120,
    AimTeamCheck = true,
    AimKey = Enum.UserInputType.MouseButton2,
    -- Fullbright
    Fullbright = false,
}

-- ===== AIMBOT FOV CIRCLE =====
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.NumSides = 64

-- ===== AIMBOT ЛОГИКА =====
local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getAimPart(char)
    if not char then return nil end
    local p = char:FindFirstChild(Flags.AimPart)
    if p then return p end
    -- фоллбек для R6
    return char:FindFirstChild("Head")
end

local function getClosestTarget()
    local closest, closestPart
    local shortestDist = math.huge
    local vs = Camera.ViewportSize
    local center = Vector2.new(vs.X / 2, vs.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isAlive(plr.Character) then
            local skip = false
            if Flags.AimTeamCheck and LP.Team and plr.Team and plr.Team == LP.Team then
                skip = true
            end
            if not skip then
                local part = getAimPart(plr.Character)
                if part then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                    -- onScreen не надёжен, для аима важнее Z > 0
                    if screenPos.Z > 0 then
                        local sp = Vector2.new(screenPos.X, screenPos.Y)
                        local dist = (center - sp).Magnitude
                        if dist < Flags.AimFOV and dist < shortestDist then
                            shortestDist = dist
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

-- ===== DELTA AIMBOT =====
-- Aimbot работает через инъекцию дельт мыши в контроллер камеры.
-- В Rust Decoy прямая запись Camera.CFrame перезаписывается weapon controller'ом,
-- а движение мыши проходит через него естественно.

local function getMouseDeltaSensitivity()
    local ok, v = pcall(function() return UIS.MouseDeltaSensitivity end)
    return ok and v or 1
end

local function aimAtDelta(targetPos)
    local camPos = Camera.CFrame.Position
    local dir = (targetPos - camPos)
    if dir.Magnitude < 0.01 then return end

    -- угол между направлением камеры и целью в screen space
    local vs = Camera.ViewportSize
    local sp, _ = Camera:WorldToScreenPoint(targetPos)
    if sp.Z <= 0 then return end

    local dx = (sp.X - vs.X / 2)
    local dy = (sp.Y - vs.Y / 2)

    -- smooth: alpha = 1/smooth, smooth = 1 даёт полный снап
    local alpha = 1 / math.max(1, Flags.AimSmooth)

    dx = dx * alpha
    dy = dy * alpha

    -- инжектим через mousemoverel (если экзекутор поддерживает)
    local ok = pcall(function()
        if mousemoverel then
            mousemoverel(dx, dy)
        end
    end)

    -- fallback через Camera.CFrame lerp (если mousemoverel нет — оружие может перебить,
    -- но хотя бы что-то)
    if not ok or not mousemoverel then
        local lookCF = CFrame.new(camPos, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(lookCF, alpha)
    end
end

-- ===== FREECAM =====
local freecamConn = nil
local freecamMouseConn = nil
local savedCameraType = nil
local savedMouseBehavior = nil
local savedWalkSpeed, savedJumpPower = 16, 50
local freecamPos = Vector3.new(0,0,0)
local freecamYaw, freecamPitch = 0, 0

local function stopFreeCam()
    if freecamConn then freecamConn:Disconnect(); freecamConn = nil end
    if freecamMouseConn then freecamMouseConn:Disconnect(); freecamMouseConn = nil end
    if savedCameraType then
        Camera.CameraType = savedCameraType
        savedCameraType = nil
    end
    if savedMouseBehavior then
        UIS.MouseBehavior = savedMouseBehavior
        savedMouseBehavior = nil
    end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = savedWalkSpeed
        hum.JumpPower = savedJumpPower
    end
end

local function startFreeCam()
    if freecamConn then return end
    savedCameraType = Camera.CameraType
    Camera.CameraType = Enum.CameraType.Scriptable
    savedMouseBehavior = UIS.MouseBehavior
    UIS.MouseBehavior = Enum.MouseBehavior.LockCenter

    freecamPos = Camera.CFrame.Position
    local look = Camera.CFrame.LookVector
    freecamYaw = math.atan2(-look.X, -look.Z)
    freecamPitch = math.asin(math.clamp(look.Y, -1, 1))

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        savedWalkSpeed = hum.WalkSpeed
        savedJumpPower = hum.JumpPower
        hum.WalkSpeed = 0
        hum.JumpPower = 0
    end

    freecamMouseConn = UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local sens = 0.005
            freecamYaw   = freecamYaw   - input.Delta.X * sens
            freecamPitch = freecamPitch - input.Delta.Y * sens
            freecamPitch = math.clamp(freecamPitch, -math.rad(89), math.rad(89))
        end
    end)

    freecamConn = RunService.RenderStepped:Connect(function(dt)
        local speed = 50
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then speed = 150 end
        local moveDir = Vector3.new(0,0,0)
        local cf = CFrame.fromEulerAnglesYXZ(freecamPitch, freecamYaw, 0)
        local look = cf.LookVector
        local right = cf.RightVector
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + look end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - look end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then
            freecamPos = freecamPos + moveDir.Unit * speed * dt
        end
        Camera.CFrame = CFrame.new(freecamPos) * cf
    end)
end

-- ===== FULLBRIGHT =====
local originalLighting = {
    Brightness     = Lighting.Brightness,
    ClockTime      = Lighting.ClockTime,
    FogEnd         = Lighting.FogEnd,
    FogStart       = Lighting.FogStart,
    GlobalShadows  = Lighting.GlobalShadows,
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local function setFullbright(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
end

-- ===== ESP DRAWINGS =====
local Drawings = {}
local Highlights = {}

local function createDrawingsForPlayer(plr)
    if plr == LP or Drawings[plr] then return end
    local d = {}
    d.Box      = Drawing.new("Square"); d.Box.Thickness = 1; d.Box.Filled = false; d.Box.Visible = false
    d.Name     = Drawing.new("Text"); d.Name.Size = 14; d.Name.Center = true; d.Name.Outline = true; d.Name.Visible = false
    d.Health   = Drawing.new("Text"); d.Health.Size = 12; d.Health.Center = true; d.Health.Outline = true; d.Health.Visible = false
    d.Line     = Drawing.new("Line"); d.Line.Thickness = 1; d.Line.Visible = false
    d.Distance = Drawing.new("Text"); d.Distance.Size = 12; d.Distance.Center = true; d.Distance.Outline = true; d.Distance.Visible = false
    Drawings[plr] = d
end

local function removeDrawings(plr)
    if Drawings[plr] then
        for _, obj in pairs(Drawings[plr]) do
            if obj then pcall(function() obj:Remove() end) end
        end
        Drawings[plr] = nil
    end
    if Highlights[plr] then
        pcall(function() Highlights[plr]:Destroy() end)
        Highlights[plr] = nil
    end
end

local function clearHighlight(plr)
    if Highlights[plr] then
        pcall(function() Highlights[plr]:Destroy() end)
        Highlights[plr] = nil
    end
end

local function applyGlow(plr)
    if plr == LP then return end
    if not Flags.Glow then clearHighlight(plr); return end
    local char = plr.Character
    if not char or not isAlive(char) then clearHighlight(plr); return end
    local hl = Highlights[plr]
    if not hl or not hl.Parent then
        clearHighlight(plr)
        hl = Instance.new("Highlight")
        hl.FillColor = Flags.ESPColor
        hl.FillTransparency = 0.5
        hl.OutlineColor = Flags.ESPColor
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        Highlights[plr] = hl
    else
        hl.FillColor = Flags.ESPColor
        hl.OutlineColor = Flags.ESPColor
    end
end

local function refreshAllGlows()
    for _, plr in ipairs(Players:GetPlayers()) do applyGlow(plr) end
end

local function updateESP()
    local localChar = LP.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then
        for _, d in pairs(Drawings) do for _, obj in pairs(d) do obj.Visible = false end end
        return
    end
    local localPos = localRoot.Position
    local vs = Camera.ViewportSize
    for plr, d in pairs(Drawings) do
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then
            for _, obj in pairs(d) do obj.Visible = false end
            continue
        end
        local dist = (root.Position - localPos).Magnitude
        if dist > Flags.MaxDistance then
            for _, obj in pairs(d) do obj.Visible = false end
            continue
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen or screenPos.Z <= 0 then
            for _, obj in pairs(d) do obj.Visible = false end
            continue
        end
        local sx, sy = screenPos.X, screenPos.Y
        local headPos = (char:FindFirstChild("Head") and char.Head.Position or root.Position) + Vector3.new(0,1.5,0)
        local feetPos = root.Position - Vector3.new(0,2.5,0)
        local headScreen, headOn = Camera:WorldToViewportPoint(headPos)
        local feetScreen, feetOn = Camera:WorldToViewportPoint(feetPos)

        if Flags.Box and headOn and feetOn then
            local h = math.abs(headScreen.Y - feetScreen.Y)
            local w = h * 0.5
            d.Box.Size = Vector2.new(w, h)
            d.Box.Position = Vector2.new(sx - w/2, headScreen.Y)
            d.Box.Color = Flags.BoxColor
            d.Box.Visible = true
        else
            d.Box.Visible = false
        end

        if Flags.Name then
            d.Name.Text = plr.Name
            d.Name.Position = Vector2.new(sx, headScreen.Y - 18)
            d.Name.Color = Flags.ESPColor
            d.Name.Visible = true
        else d.Name.Visible = false end

        if Flags.Health then
            d.Health.Text = "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
            d.Health.Position = Vector2.new(sx, feetScreen.Y + 2)
            d.Health.Color = Flags.ESPColor
            d.Health.Visible = true
        else d.Health.Visible = false end

        if Flags.Distance then
            d.Distance.Text = math.floor(dist) .. "m"
            d.Distance.Position = Vector2.new(sx, feetScreen.Y + 18)
            d.Distance.Color = Flags.ESPColor
            d.Distance.Visible = true
        else d.Distance.Visible = false end

        if Flags.Line then
            d.Line.From = Vector2.new(vs.X/2, vs.Y)
            d.Line.To = Vector2.new(sx, sy)
            d.Line.Color = Flags.LineColor
            d.Line.Visible = true
        else d.Line.Visible = false end
    end
end

-- ===== ХУКИ ИГРОКОВ =====
local function hookPlayer(plr)
    if plr == LP then return end
    createDrawingsForPlayer(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.2)
        if Flags.Glow then applyGlow(plr) end
    end)
    plr.CharacterRemoving:Connect(function()
        clearHighlight(plr)
    end)
    if Flags.Glow then
        task.wait(1)
        applyGlow(plr)
    end
end

for _, plr in ipairs(Players:GetPlayers()) do hookPlayer(plr) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(removeDrawings)

-- ===== FPS/PING COUNTER =====
local fpsText, pingText
local fpsCounter = 0
local lastFpsTime = os.clock()

local function ensureCounter()
    if not fpsText then
        fpsText = Drawing.new("Text")
        fpsText.Size = 14; fpsText.Color = Color3.fromRGB(255,255,255)
        fpsText.Outline = true; fpsText.Position = Vector2.new(10, 10); fpsText.Visible = false
    end
    if not pingText then
        pingText = Drawing.new("Text")
        pingText.Size = 14; pingText.Color = Color3.fromRGB(255,255,255)
        pingText.Outline = true; pingText.Position = Vector2.new(10, 28); pingText.Visible = false
    end
end

local function readPing()
    local ok, val = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and val then return math.floor(val) end
    return nil
end

RunService.RenderStepped:Connect(function()
    if Flags.FPSPing then
        ensureCounter()
        fpsCounter = fpsCounter + 1
        local now = os.clock()
        if now - lastFpsTime >= 1 then
            fpsText.Text = "FPS: " .. fpsCounter
            fpsText.Visible = true
            fpsCounter = 0
            lastFpsTime = now
            local p = readPing()
            pingText.Text = p and ("Ping: " .. p .. "ms") or "Ping: n/a"
            pingText.Visible = true
        end
    else
        if fpsText then fpsText.Visible = false end
        if pingText then pingText.Visible = false end
    end
end)

-- ===== ОСНОВНОЙ ЦИКЛ =====
RunService:BindToRenderStep("CloudClientMain", Enum.RenderPriority.Camera.Value + 1, function()
    if Flags.ESP then updateESP()
    else
        for _, d in pairs(Drawings) do
            for _, obj in pairs(d) do obj.Visible = false end
        end
    end

    if Flags.Aimbot then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = Flags.AimFOV
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)

-- ===== AIMBOT CYCLE =====
RunService:BindToRenderStep("CloudClientAimbot", Enum.RenderPriority.Camera.Value + 2, function()
    if not Flags.Aimbot then return end
    if not UIS:IsMouseButtonPressed(Flags.AimKey) then return end
    local _, part = getClosestTarget()
    if part then
        aimAtDelta(part.Position)
    end
end)

-- ===== AIMBOT TAB =====
local AimbotTab = Window:AddTab("Aimbot", "crosshair")

AimbotTab:AddToggle({ Title = "Aimbot", Subtitle = "Hold aim key to lock", Icon = "crosshair", Default = false,
    Callback = function(s) Flags.Aimbot = s end })

AimbotTab:AddSlider({ Title = "Smoothness (1=snap, 100=smooth)", Icon = "activity", Min = 1, Max = 100, Default = 1,
    Callback = function(v) Flags.AimSmooth = v end })

AimbotTab:AddSlider({ Title = "Aim FOV", Icon = "circle", Min = 20, Max = 400, Default = 120,
    Callback = function(v) Flags.AimFOV = v end })

AimbotTab:AddDropdown({ Title = "Target Part", Icon = "user", Options = {"Head", "HumanoidRootPart", "UpperTorso"}, Default = "Head",
    Callback = function(s) Flags.AimPart = s end })

AimbotTab:AddToggle({ Title = "Team Check", Icon = "users", Default = true,
    Callback = function(s) Flags.AimTeamCheck = s end })

AimbotTab:AddKeybind({ Title = "Aim Key", Icon = "mouse-pointer", Default = Enum.UserInputType.MouseButton2,
    Callback = function(k) if k and k.UserInputType then Flags.AimKey = k.UserInputType end end })

-- ===== VISUALS =====
local VisualsTab = Window:AddTab("Visuals", "eye")

VisualsTab:AddColorPicker({ Title = "ESP Color", Icon = "palette", Default = Flags.ESPColor,
    Callback = function(c)
        Flags.ESPColor = c
        if Flags.Glow then
            for _, hl in pairs(Highlights) do
                if hl and hl.Parent then hl.FillColor = c; hl.OutlineColor = c end
            end
        end
    end })
VisualsTab:AddColorPicker({ Title = "Box Color", Icon = "square", Default = Flags.BoxColor, Callback = function(c) Flags.BoxColor = c end })
VisualsTab:AddColorPicker({ Title = "Line Color", Icon = "move", Default = Flags.LineColor, Callback = function(c) Flags.LineColor = c end })

VisualsTab:AddSeparator()
VisualsTab:AddLabel("ESP SYSTEM", "eye")
VisualsTab:AddSeparator()

VisualsTab:AddToggle({ Title = "ESP", Icon = "eye", Default = false, Callback = function(s) Flags.ESP = s end })
VisualsTab:AddToggle({ Title = "Glow", Icon = "sparkles", Default = false, Callback = function(s)
    Flags.Glow = s
    if s then refreshAllGlows()
    else
        for plr in pairs(Highlights) do clearHighlight(plr) end
    end
end })
VisualsTab:AddToggle({ Title = "Box", Icon = "box", Default = false, Callback = function(s) Flags.Box = s end })
VisualsTab:AddToggle({ Title = "Distance", Icon = "ruler", Default = false, Callback = function(s) Flags.Distance = s end })
VisualsTab:AddSlider({ Title = "ESP Distance", Icon = "ruler", Min = 0, Max = 2000, Default = 1000, Callback = function(v) Flags.MaxDistance = v end })
VisualsTab:AddToggle({ Title = "Name", Icon = "user", Default = false, Callback = function(s) Flags.Name = s end })
VisualsTab:AddToggle({ Title = "Health", Icon = "heart", Default = false, Callback = function(s) Flags.Health = s end })
VisualsTab:AddToggle({ Title = "Line", Icon = "move", Default = false, Callback = function(s) Flags.Line = s end })

-- ===== PLAYER =====
local PlayerTab = Window:AddTab("Player", "user")

PlayerTab:AddToggle({ Title = "FreeCam", Subtitle = "WASD + Space/Ctrl to fly, mouse to look", Icon = "camera", Default = false,
    Callback = function(s)
        Flags.FreeCam = s
        if s then startFreeCam() else stopFreeCam() end
    end })

-- ===== OTHER =====
local OtherTab = Window:AddTab("Other", "box")

OtherTab:AddToggle({ Title = "Fullbright", Subtitle = "Makes the world bright", Icon = "sun", Default = false,
    Callback = function(s)
        Flags.Fullbright = s
        setFullbright(s)
    end })

-- ===== SETTINGS =====
local SettingsTab = Window:AddTab("Settings", "settings")

local themeNames = {}
for name in pairs(VantixUI.Themes) do table.insert(themeNames, name) end
table.sort(themeNames)

SettingsTab:AddDropdown({ Title = "Theme", Icon = "swatch-book", Options = themeNames, Default = Window:GetTheme(),
    Callback = function(s) Window:SetTheme(s) end })
SettingsTab:AddDropdown({ Title = "Accent Color", Icon = "droplet", Options = {"White","Blue","Red","Green","Purple"}, Default = "White",
    Callback = function(s)
        local colors = {White=Color3.fromRGB(255,255,255),Blue=Color3.fromRGB(64,156,255),Red=Color3.fromRGB(230,70,70),Green=Color3.fromRGB(80,210,120),Purple=Color3.fromRGB(170,110,240)}
        VantixUI:SetAccentColor(colors[s])
    end })

SettingsTab:AddSeparator()

SettingsTab:AddToggle({ Title = "FPS / Ping Counter", Icon = "activity", Default = false,
    Callback = function(s) Flags.FPSPing = s end })

SettingsTab:AddSeparator()

SettingsTab:AddKeybind({ Title = "Hide UI Keybind", Icon = "keyboard", Default = Enum.KeyCode.Delete,
    Callback = function()
        local sg = Window.Gui
        if sg then sg.Enabled = not sg.Enabled end
    end })
