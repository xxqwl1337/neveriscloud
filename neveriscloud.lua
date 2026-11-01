--[[
    CLOUDCLIENT — Aimbot (Direct) + Visuals + Player + Other
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
    AimSmooth = 1.0,  -- 1.0 = моментально, 0.1 = плавно
    AimFOV = 120,
    -- Fullbright
    Fullbright = false,
}

-- ===== AIMBOT FOV CIRCLE =====
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false
fovCircle.Visible = false

-- ===== AIMBOT ЛОГИКА =====
local function getClosestTarget()
    local closest = nil
    local shortestDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local part = plr.Character:FindFirstChild(Flags.AimPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < Flags.AimFOV and dist < shortestDist then
                        shortestDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    return closest
end

-- ===== FREECAM =====
local freecamConn = nil
local savedCameraType = nil
local savedWalkSpeed, savedJumpPower = 16, 50
local freecamPos = Vector3.new(0,0,0)

local function stopFreeCam()
    if freecamConn then freecamConn:Disconnect(); freecamConn = nil end
    if savedCameraType then
        Camera.CameraType = savedCameraType
        savedCameraType = nil
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
    freecamPos = Camera.CFrame.Position

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        savedWalkSpeed = hum.WalkSpeed
        savedJumpPower = hum.JumpPower
        hum.WalkSpeed = 0
        hum.JumpPower = 0
    end

    freecamConn = RunService.RenderStepped:Connect(function(dt)
        local speed = 50 * dt
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then speed = 150 * dt end
        local moveDir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then
            freecamPos = freecamPos + moveDir.Unit * speed
        end
        Camera.CFrame = CFrame.new(freecamPos, freecamPos + Camera.CFrame.LookVector)
    end)
end

-- ===== FULLBRIGHT =====
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
}

local function setFullbright(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.Ambient = originalLighting.Ambient
    end
end

-- ===== ESP DRAWINGS =====
local Drawings = {}
local Highlights = {}

local function createDrawingsForPlayer(plr)
    if plr == LP or Drawings[plr] then return end
    local d = {}
    d.Box = Drawing.new("Square"); d.Box.Thickness = 1; d.Box.Filled = false; d.Box.Visible = false
    d.Name = Drawing.new("Text"); d.Name.Size = 14; d.Name.Center = true; d.Name.Outline = true; d.Name.Visible = false
    d.Health = Drawing.new("Text"); d.Health.Size = 12; d.Health.Center = true; d.Health.Outline = true; d.Health.Visible = false
    d.Line = Drawing.new("Line"); d.Line.Thickness = 1; d.Line.Visible = false
    d.Distance = Drawing.new("Text"); d.Distance.Size = 12; d.Distance.Center = true; d.Distance.Outline = true; d.Distance.Visible = false
    Drawings[plr] = d
end

local function removeDrawings(plr)
    if Drawings[plr] then
        for _, obj in pairs(Drawings[plr]) do if obj then obj:Remove() end end
        Drawings[plr] = nil
    end
    if Highlights[plr] then Highlights[plr]:Destroy(); Highlights[plr] = nil end
end

local function applyGlow(plr)
    if plr == LP then return end
    if not Flags.Glow then
        if Highlights[plr] then Highlights[plr]:Destroy(); Highlights[plr] = nil end
        return
    end
    local char = plr.Character
    if not char then return end
    if not Highlights[plr] or not Highlights[plr].Parent then
        local hl = Instance.new("Highlight")
        hl.FillColor = Flags.ESPColor; hl.FillTransparency = 0.5
        hl.OutlineColor = Flags.ESPColor; hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        Highlights[plr] = hl
    else
        Highlights[plr].FillColor = Flags.ESPColor
        Highlights[plr].OutlineColor = Flags.ESPColor
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
        if not onScreen then
            for _, obj in pairs(d) do obj.Visible = false end
            continue
        end
        local sx, sy = screenPos.X, screenPos.Y
        local headScreen, headOn = Camera:WorldToViewportPoint((char.Head and char.Head.Position or root.Position) + Vector3.new(0,1.5,0))
        local feetScreen, feetOn = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,2.5,0))

        if Flags.Box and headOn and feetOn then
            local h = math.abs(headScreen.Y - feetScreen.Y); local w = h*0.5
            d.Box.Size = Vector2.new(w,h); d.Box.Position = Vector2.new(sx-w/2, headScreen.Y)
            d.Box.Color = Flags.BoxColor; d.Box.Visible = true
        else d.Box.Visible = false end

        if Flags.Name then
            d.Name.Text = plr.Name; d.Name.Position = Vector2.new(sx, headScreen.Y-18)
            d.Name.Color = Flags.ESPColor; d.Name.Visible = true
        else d.Name.Visible = false end

        if Flags.Health then
            d.Health.Text = "HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
            d.Health.Position = Vector2.new(sx, feetScreen.Y+2)
            d.Health.Color = Flags.ESPColor; d.Health.Visible = true
        else d.Health.Visible = false end

        if Flags.Distance then
            d.Distance.Text = math.floor(dist).."m"; d.Distance.Position = Vector2.new(sx, feetScreen.Y+18)
            d.Distance.Color = Flags.ESPColor; d.Distance.Visible = true
        else d.Distance.Visible = false end

        if Flags.Line then
            d.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            d.Line.To = Vector2.new(sx, sy); d.Line.Color = Flags.LineColor; d.Line.Visible = true
        else d.Line.Visible = false end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do createDrawingsForPlayer(plr) end
Players.PlayerAdded:Connect(function(plr) createDrawingsForPlayer(plr); if Flags.Glow then task.wait(1); applyGlow(plr) end end)
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
        end
        local ok, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if ok and ping then
            pingText.Text = "Ping: " .. math.floor(ping) .. "ms"
            pingText.Visible = true
        else
            pingText.Text = "Ping: n/a"
            pingText.Visible = true
        end
    else
        if fpsText then fpsText.Visible = false end
        if pingText then pingText.Visible = false end
    end
end)

-- ===== ОСНОВНОЙ ЦИКЛ (ESP + Aimbot FOV Circle) =====
RunService:BindToRenderStep("CloudClientMain", Enum.RenderPriority.Camera.Value + 1, function()
    -- ESP
    if Flags.ESP then updateESP()
    else
        for _, d in pairs(Drawings) do
            for _, obj in pairs(d) do obj.Visible = false end
        end
    end
    
    -- Aimbot FOV Circle
    if Flags.Aimbot then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = Flags.AimFOV
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)

-- ===== AIMBOT CYCLE (Прямая наводка) =====
RunService:BindToRenderStep("CloudClientAimbot", Enum.RenderPriority.Camera.Value + 2, function()
    if Flags.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestTarget()
        if target then
            local cameraPos = Camera.CFrame.Position
            local targetPos = target.Position
            
            -- Считаем, куда должна смотреть камера
            local lookCF = CFrame.new(cameraPos, targetPos)
            
            if Flags.AimSmooth >= 1.0 then
                -- Мгновенная наводка (1.0)
                Camera.CFrame = lookCF
            else
                -- Плавная наводка
                Camera.CFrame = Camera.CFrame:Lerp(lookCF, Flags.AimSmooth)
            end
        end
    end
end)

-- ===== AIMBOT TAB (сверху) =====
local AimbotTab = Window:AddTab("Aimbot", "crosshair")

AimbotTab:AddToggle({ Title = "Aimbot", Subtitle = "Hold Right Mouse Button to aim", Icon = "crosshair", Default = false,
    Callback = function(s) Flags.Aimbot = s end })

AimbotTab:AddSlider({ Title = "Smoothness", Icon = "activity", Min = 0.1, Max = 1.0, Default = 1.0,
    Callback = function(v) Flags.AimSmooth = v end })

AimbotTab:AddSlider({ Title = "Aim FOV", Icon = "circle", Min = 20, Max = 400, Default = 120,
    Callback = function(v) Flags.AimFOV = v end })

AimbotTab:AddDropdown({ Title = "Target Part", Icon = "user", Options = {"Head", "HumanoidRootPart", "UpperTorso"}, Default = "Head",
    Callback = function(s) Flags.AimPart = s end })

-- ===== VISUALS =====
local VisualsTab = Window:AddTab("Visuals", "eye")

VisualsTab:AddColorPicker({ Title = "ESP Color", Icon = "palette", Default = Flags.ESPColor,
    Callback = function(c)
        Flags.ESPColor = c
        if Flags.Glow then for plr, hl in pairs(Highlights) do if hl and hl.Parent then hl.FillColor = c; hl.OutlineColor = c end end end
    end })
VisualsTab:AddColorPicker({ Title = "Box Color", Icon = "square", Default = Flags.BoxColor, Callback = function(c) Flags.BoxColor = c end })
VisualsTab:AddColorPicker({ Title = "Line Color", Icon = "move", Default = Flags.LineColor, Callback = function(c) Flags.LineColor = c end })

VisualsTab:AddSeparator()
VisualsTab:AddLabel("ESP SYSTEM", "eye")
VisualsTab:AddSeparator()

VisualsTab:AddToggle({ Title = "ESP", Icon = "eye", Default = false, Callback = function(s)
    Flags.ESP = s
    if not s and Flags.Glow then
        for plr, hl in pairs(Highlights) do if hl then hl:Destroy() end; Highlights[plr] = nil end
    end
end })
VisualsTab:AddToggle({ Title = "Glow", Icon = "sparkles", Default = false, Callback = function(s)
    Flags.Glow = s
    if s then refreshAllGlows()
    else for plr, hl in pairs(Highlights) do if hl then hl:Destroy() end; Highlights[plr] = nil end end
end })
VisualsTab:AddToggle({ Title = "Box", Icon = "box", Default = false, Callback = function(s) Flags.Box = s end })
VisualsTab:AddToggle({ Title = "Distance", Icon = "ruler", Default = false, Callback = function(s) Flags.Distance = s end })
VisualsTab:AddSlider({ Title = "ESP Distance", Icon = "ruler", Min = 0, Max = 2000, Default = 1000, Callback = function(v) Flags.MaxDistance = v end })
VisualsTab:AddToggle({ Title = "Name", Icon = "user", Default = false, Callback = function(s) Flags.Name = s end })
VisualsTab:AddToggle({ Title = "Health", Icon = "heart", Default = false, Callback = function(s) Flags.Health = s end })
VisualsTab:AddToggle({ Title = "Line", Icon = "move", Default = false, Callback = function(s) Flags.Line = s end })

-- ===== PLAYER =====
local PlayerTab = Window:AddTab("Player", "user")

PlayerTab:AddToggle({ Title = "FreeCam", Subtitle = "WASD + Space/Ctrl to fly camera", Icon = "camera", Default = false,
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
