local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local speedEnabled = false
local speedConnection

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MiniSpeedGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,130,0,45)
frame.Position = UDim2.new(0.82,0,0.15,0)
frame.AnchorPoint = Vector2.new(0,0)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0,170,255)
stroke.Thickness = 1.5
stroke.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,0,1,0)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamBold
status.TextScaled = true
status.TextColor3 = Color3.new(1,1,1)
status.Text = "SPEED : OFF"
status.Parent = frame

-- SPEED FUNCTION
local function setSpeed(state)
    speedEnabled = state

    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end

    if not state then
        status.Text = "SPEED : OFF"
        frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
        return
    end

    status.Text = "SPEED : ON"
    frame.BackgroundColor3 = Color3.fromRGB(0,120,70)

    speedConnection = RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char then return end

        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if not hum or not hrp then return end

        local tool =
            char:FindFirstChild("Flying Carpet")
            or LP.Backpack:FindFirstChild("Flying Carpet")

        if tool then
            if tool.Parent ~= char then
                pcall(function()
                    hum:EquipTool(tool)
                end)
            end

            local moveDir = hum.MoveDirection

            if moveDir.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    moveDir.X * 150,  -- <--- CAMBIADO A 150
                    hrp.AssemblyLinearVelocity.Y,
                    moveDir.Z * 150   -- <--- CAMBIADO A 150
                )
            else
                hrp.AssemblyLinearVelocity = Vector3.new(
                    0,
                    hrp.AssemblyLinearVelocity.Y,
                    0
                )
            end
        end
    end)
end

-- CLICK
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        setSpeed(not speedEnabled)
    end
end)

-- AUTO ENABLE
setSpeed(true)