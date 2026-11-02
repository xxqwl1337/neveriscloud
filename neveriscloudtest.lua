-- ===== AUTORUN (REWORK) =====
local defaultWalkSpeed = 16
local autoRunActive = false
local autoRunKeyHeld = false
local autoRunVIM = game:GetService("VirtualInputManager")

local function captureDefaultWalkSpeed()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then defaultWalkSpeed = hum.WalkSpeed end
end
captureDefaultWalkSpeed()
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    captureDefaultWalkSpeed()
    if autoRunKeyHeld then
        autoRunKeyHeld = false
    end
end)

local function releaseAutoRunKey()
    if autoRunKeyHeld then
        pcall(function()
            autoRunVIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
        end)
        autoRunKeyHeld = false
    end
end

local function applyAutoRun()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then
        releaseAutoRunKey()
        return
    end

    if Flags.AutoRun then
        -- Пытаемся эмулировать зажатие Shift (для игр с встроенным спринтом)
        if not autoRunKeyHeld then
            local ok = pcall(function()
                autoRunVIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
            end)
            if ok then
                autoRunKeyHeld = true
            end
        end

        -- Fallback / гарантия: прямое управление скоростью и движением
        -- Даже если Shift не сработал, персонаж будет двигаться вперёд с ускорением
        autoRunActive = true
        if hum.WalkSpeed <= defaultWalkSpeed then
            hum.WalkSpeed = defaultWalkSpeed + 8
        end

        local look = Camera.CFrame.LookVector
        local dir = Vector3.new(look.X, 0, look.Z)
        if dir.Magnitude > 0.01 then
            hum:Move(dir.Unit, false)
        end
    else
        releaseAutoRunKey()
        if autoRunActive then
            hum.WalkSpeed = defaultWalkSpeed
            autoRunActive = false
        end
    end
end
