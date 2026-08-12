-- =====================================================================
-- BEST PET ESP + SPEED BYPASS + FPS BOOST + AUTO STEAL - ALL IN ONE
-- =====================================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

-- =====================================================================
-- PART 1: BEST PET ESP - Always Active with Machine Block
-- =====================================================================

getgenv().BestPetESP = getgenv().BestPetESP or {
    active = false,
    connection = nil,
    espInstance = nil
}

local ESP_CONFIG = {
    ScanInterval = 0.5,
    TargetFolder = "Debris",
    TemplateName = "FastOverheadTemplate"
}

local _BLOCKING_MACHINE_TYPES = {
    Fuse = true,
    Duel = true,
    Trade = true,
    Crafting = true,
}

local function _VanishIsFusing(animalData)
    if type(animalData) ~= "table" then return false end
    local m = animalData.Machine
    if type(m) ~= "table" then return false end
    return _BLOCKING_MACHINE_TYPES[m.Type] == true
end

local function parseValue(text)
    if not text then return 0 end
    text = tostring(text):gsub("%s", ""):gsub("/s", "")
    local numStr, suffix = text:match("([%d%.]+)([KkMmBbTtQq]?)")
    if not numStr then return 0 end
    local num = tonumber(numStr) or 0
    local multipliers = { K = 1e3, M = 1e6, B = 1e9 }
    local mult = multipliers[(suffix or ""):upper()] or 1
    return num * mult
end

local function getESPInstance()
    if getgenv().BestPetESP.espInstance and getgenv().BestPetESP.espInstance.Parent then
        return getgenv().BestPetESP.espInstance
    end

    local bb = Instance.new("BillboardGui")
    bb.Name = "OptimizedBestPetESP"
    bb.Size = UDim2.new(0, 200, 0, 60)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, -8, 0)
    bb.Parent = CoreGui

    local container = Instance.new("Frame", bb)
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1

    local nameLabel = Instance.new("TextLabel", container)
    nameLabel.Name = "PetName"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold/Yellow
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    local valueLabel = Instance.new("TextLabel", container)
    valueLabel.Name = "PetValue"
    valueLabel.Size = UDim2.new(1, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0, 0, 0.5, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextColor3 = Color3.fromRGB(0, 255, 200) -- Cyan/Teal
    valueLabel.TextStrokeTransparency = 0
    valueLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    getgenv().BestPetESP.espInstance = bb
    return bb
end

local function updateESP(targetPart, displayName, valueText)
    local esp = getESPInstance()
    if targetPart then
        esp.Adornee = targetPart
        esp.Enabled = true
        local container = esp:FindFirstChild("Frame")
        if container then
            container.PetName.Text = displayName
            container.PetValue.Text = valueText
        end
    else
        esp.Enabled = false
        esp.Adornee = nil
    end
end

local function scanForBestPet()
    local debris = Workspace:FindFirstChild(ESP_CONFIG.TargetFolder)
    if not debris then return end

    local bestPet = { value = -1, part = nil, displayText = "None", rawText = "" }
    local items = debris:GetChildren()
    
    for _, item in ipairs(items) do
        if item.Name == ESP_CONFIG.TemplateName then
            local surfaceGui = item:FindFirstChildOfClass("SurfaceGui")
            if surfaceGui and surfaceGui.Adornee then
                local animalData = item:FindFirstChild("AnimalData")
                if animalData then
                    local data = animalData:GetAttributes()
                    if _VanishIsFusing(data) then continue end
                end
                
                local genLabel = surfaceGui:FindFirstChild("Generation", true)
                if genLabel and genLabel:IsA("TextLabel") then
                    local text = genLabel.Text
                    local val = parseValue(text)
                    if val > bestPet.value then
                        local nameLabel = surfaceGui:FindFirstChild("DisplayName", true)
                        bestPet.value = val
                        bestPet.part = surfaceGui.Adornee
                        bestPet.displayText = nameLabel and nameLabel.Text or "Unknown"
                        bestPet.rawText = text
                    end
                end
            end
        end
    end

    if bestPet.part then
        updateESP(bestPet.part, bestPet.displayText, bestPet.rawText)
    else
        updateESP(nil, nil, nil)
    end
end

local function startESPLoop()
    if getgenv().BestPetESP.active then return end
    getgenv().BestPetESP.active = true
    task.spawn(function()
        while getgenv().BestPetESP.active do
            local success, err = pcall(scanForBestPet)
            if not success then warn("[ESP Error]:", err) end
            task.wait(ESP_CONFIG.ScanInterval)
        end
    end)
end

startESPLoop()

-- =====================================================================
-- PART 2: SPEED BYPASS (con GUI táctil) - APAGADO POR DEFECTO
-- =====================================================================

local speedEnabled = false
local speedConnection = nil

local speedGui = Instance.new("ScreenGui")
speedGui.Name = "MiniSpeedGUI"
speedGui.ResetOnSpawn = false
speedGui.IgnoreGuiInset = true
speedGui.Parent = Player:WaitForChild("PlayerGui")

local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0, 130, 0, 45)
speedFrame.Position = UDim2.new(0.82, 0, 0.15, 0)
speedFrame.AnchorPoint = Vector2.new(0, 0)
speedFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
speedFrame.BorderSizePixel = 0
speedFrame.Active = true
speedFrame.Parent = speedGui

Instance.new("UICorner", speedFrame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 1.5
stroke.Parent = speedFrame

local speedStatus = Instance.new("TextLabel")
speedStatus.Size = UDim2.new(1, 0, 1, 0)
speedStatus.BackgroundTransparency = 1
speedStatus.Font = Enum.Font.GothamBold
speedStatus.TextScaled = true
speedStatus.TextColor3 = Color3.new(1, 1, 1)
speedStatus.Text = "SPEED : OFF"
speedStatus.Parent = speedFrame

local function getFlightItem(char, backpack)
    local wings = char:FindFirstChild("Cupid's Wings") or (backpack and backpack:FindFirstChild("Cupid's Wings"))
    if wings then return wings end
    local carpet = char:FindFirstChild("Flying Carpet") or (backpack and backpack:FindFirstChild("Flying Carpet"))
    if carpet then return carpet end
    return nil
end

local function setSpeed(state)
    speedEnabled = state
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    if not state then
        speedStatus.Text = "SPEED : OFF"
        speedFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        return
    end
    speedStatus.Text = "SPEED : ON"
    speedFrame.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
    speedConnection = RunService.Heartbeat:Connect(function()
        local char = Player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        local backpack = Player:FindFirstChild("Backpack")
        local flightItem = getFlightItem(char, backpack)
        if flightItem then
            if flightItem.Parent ~= char then pcall(function() hum:EquipTool(flightItem) end) end
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * 150, hrp.AssemblyLinearVelocity.Y, moveDir.Z * 150)
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end
    end)
end

speedFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        setSpeed(not speedEnabled)
    end
end)

-- =====================================================================
-- PART 3: FPS BOOST
-- =====================================================================

_G._FH_CarpetTP_Speed = _G._FH_CarpetTP_Speed or 214
_G._FH_AlwaysOnFPS = true

local function stripToolPhysics(tool)
    if not tool or not tool:IsA("Tool") then return end
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("BasePart") then
            pcall(function()
                d.Massless = true
                d.CanCollide = false
            end)
        elseif d:IsA("BodyVelocity") or d:IsA("BodyPosition") or d:IsA("BodyGyro") or d:IsA("AlignPosition") 
            or d:IsA("AlignOrientation") or d:IsA("VectorForce") or d:IsA("LinearVelocity") or d:IsA("AngularVelocity") then
            pcall(function() d.Enabled = false end)
        end
    end
    tool.DescendantAdded:Connect(function(d)
        if d:IsA("BasePart") then
            pcall(function() d.Massless = true; d.CanCollide = false end)
        end
    end)
end

local function wireChar(c)
    for _, t in ipairs(c:GetChildren()) do stripToolPhysics(t) end
    c.ChildAdded:Connect(stripToolPhysics)
end

if Player.Character then wireChar(Player.Character) end
Player.CharacterAdded:Connect(wireChar)

local _fhCarpetActiveTween = nil

function _G._FH_CarpetTP(targetCF, speedOverride)
    local chr = Player.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetCF then return end
    if typeof(targetCF) == "Vector3" then targetCF = CFrame.new(targetCF) end
    local dist = (hrp.Position - targetCF.Position).Magnitude
    local dur = math.max(0.05, dist / (speedOverride or _G._FH_CarpetTP_Speed or 214))
    local bp = Player:FindFirstChildOfClass("Backpack")
    local flightItem = getFlightItem(chr, bp)
    local hum = chr:FindFirstChildOfClass("Humanoid")
    if flightItem and hum and flightItem.Parent ~= chr then pcall(function() hum:EquipTool(flightItem) end) end
    if _fhCarpetActiveTween then pcall(function() _fhCarpetActiveTween:Cancel() end) end
    local tw = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = targetCF})
    _fhCarpetActiveTween = tw
    tw:Play()
    return tw
end

pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.Ambient = Color3.fromRGB(160, 160, 160)
    Lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 160)
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") then
            pcall(function() v.Enabled = false end)
        end
    end
end)

local function cleanSingleTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    pcall(function()
        local handle = tool:FindFirstChild("Handle")
        if handle then
            for _, obj in pairs(handle:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy()
                elseif obj:IsA("SpecialMesh") or obj:IsA("MeshPart") then pcall(function() obj.TextureId = "" end) end
            end
        end
        for _, obj in pairs(tool:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy()
            elseif obj:IsA("SpecialMesh") or obj:IsA("MeshPart") then pcall(function() obj.TextureId = "" end)
            elseif obj:IsA("ParticleEmitter") then obj:Destroy() end
        end
    end)
end

local function cleanAllPlayerTools()
    if not Player then return end
    pcall(function()
        if Player.Character then
            for _, tool in pairs(Player.Character:GetChildren()) do
                if tool:IsA("Tool") then cleanSingleTool(tool) end
            end
        end
        local backpack = Player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then cleanSingleTool(tool) end
            end
        end
    end)
end

local function startToolMonitoring()
    Player.CharacterAdded:Connect(function(character)
        task.wait(0.3)
        cleanAllPlayerTools()
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then task.defer(function() cleanSingleTool(child) end) end
        end)
        character.DescendantAdded:Connect(function(desc)
            if desc:IsA("Tool") or (desc:IsA("BasePart") and desc.Parent and desc.Parent:IsA("Tool")) then
                local tool = desc:IsA("Tool") and desc or desc.Parent
                task.defer(function() cleanSingleTool(tool) end)
            end
        end)
    end)
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        backpack.ChildAdded:Connect(function(tool)
            if tool:IsA("Tool") then task.defer(function() cleanSingleTool(tool) end) end
        end)
    end
    task.spawn(function()
        while task.wait(3) do cleanAllPlayerTools() end
    end)
end

local function disableAnimationsOnModel(model)
    if Players:GetPlayerFromCharacter(model) then return end
    pcall(function()
        for _, v in pairs(model:GetDescendants()) do
            if v:IsA("AnimationController") or v:IsA("Animator") then v:Destroy()
            elseif v:IsA("Humanoid") then v:ChangeState(Enum.HumanoidStateType.Physics) end
        end
    end)
end

local function optimizeBrainrot(model)
    if model.Name and string.lower(model.Name):find("brainrot") then
        pcall(function()
            for _, v in pairs(model:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.Plastic; v.Reflectance = 0 end
                if v:IsA("AnimationController") or v:IsA("Animator") then v:Destroy() end
                if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then v.Enabled = false end
            end
        end)
    end
end

local function hideSpecialEvents(model)
    if not model.Name then return end
    local name = string.lower(model.Name)
    if name:find("fire") or name:find("taco") or name:find("nyan") or name:find("event") then
        pcall(function()
            for _, v in pairs(model:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 1 end
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = false end
                if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
                if v:IsA("AnimationController") or v:IsA("Animator") then v:Destroy() end
            end
        end)
    end
end

task.spawn(function()
    task.wait(0.5)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            disableAnimationsOnModel(obj)
            optimizeBrainrot(obj)
            hideSpecialEvents(obj)
        end
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            pcall(function() obj.Enabled = false end)
        end
        if obj:IsA("BasePart") and obj.Material ~= Enum.Material.Plastic then
            pcall(function() obj.Material = Enum.Material.Plastic end)
        end
        if obj:IsA("Texture") or obj:IsA("Decal") then pcall(function() obj:Destroy() end) end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        disableAnimationsOnModel(obj)
        optimizeBrainrot(obj)
        hideSpecialEvents(obj)
    end
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        pcall(function() obj.Enabled = false end)
    end
    if obj:IsA("BasePart") then pcall(function() obj.Material = Enum.Material.Plastic end) end
    if obj:IsA("Texture") or obj:IsA("Decal") then pcall(function() obj:Destroy() end) end
end)

startToolMonitoring()
cleanAllPlayerTools()

task.spawn(function()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e9
        Lighting.Brightness = 1
    end)
end)

-- =====================================================================
-- PART 4: AUTO STEAL
-- =====================================================================

local Config = {
    AutoSteal = true,
    STEAL_RADIUS = 59,
    STEAL_DURATION = 1.3
}

local isStealing = false
local stealStartTime = nil
local progressConnection = nil
local StealData = {}
local Connections = {}
local ProgressBarFill, ProgressLabel, ProgressPercentLabel
local fpsLabel = nil
local fpsUpdateConnection = nil

local DISCORD_TEXT = "Zeuss"

local function getDiscordProgress(percent)
    local totalChars = #DISCORD_TEXT
    local adjustedPercent = math.min(percent * 1.5, 100)
    local charsToShow = math.floor((adjustedPercent / 100) * totalChars)
    if charsToShow == 0 and percent > 0 then charsToShow = 1 end
    return string.sub(DISCORD_TEXT, 1, charsToShow)
end

local function isMyPlotByName(pn)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(pn)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            return yb.Enabled == true
        end
    end
    return false
end

local function findNearestPrompt()
    local char = Player.Character
    local h = char and char:FindFirstChild("HumanoidRootPart")
    if not h then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local nearestPrompt, nearestDist, nearestName = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then continue end
        for _, pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - h.Position).Magnitude
                    if dist < nearestDist and dist <= Config.STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then
                                    nearestPrompt, nearestDist, nearestName = ch, dist, pod.Name
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    return nearestPrompt, nearestDist, nearestName
end

local function ResetProgressBar()
    if ProgressLabel then ProgressLabel.Text = "READY" end
    if ProgressPercentLabel then ProgressPercentLabel.Text = "" end
    if ProgressBarFill then ProgressBarFill.Size = UDim2.new(0, 0, 1, 0) end
end

local function executeSteal(prompt, name)
    if isStealing then return end
    if not StealData[prompt] then
        StealData[prompt] = {hold = {}, trigger = {}, ready = true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(StealData[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(StealData[prompt].trigger, c.Function) end
                end
            end
        end)
    end
    local data = StealData[prompt]
    if not data.ready then return end
    data.ready = false
    isStealing = true
    stealStartTime = tick()
    if ProgressLabel then ProgressLabel.Text = name or "STEALING..." end
    if progressConnection then progressConnection:Disconnect() end
    progressConnection = RunService.Heartbeat:Connect(function()
        if not isStealing then progressConnection:Disconnect() return end
        local prog = math.clamp((tick() - stealStartTime) / Config.STEAL_DURATION, 0, 1)
        if ProgressBarFill then ProgressBarFill.Size = UDim2.new(prog, 0, 1, 0) end
        if ProgressPercentLabel then 
            local percent = math.floor(prog * 100)
            ProgressPercentLabel.Text = getDiscordProgress(percent)
        end
    end)
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        task.wait(Config.STEAL_DURATION)
        for _, f in ipairs(data.trigger) do task.spawn(f) end
        if progressConnection then progressConnection:Disconnect() end
        ResetProgressBar()
        data.ready = true
        isStealing = false
    end)
end

local function startAutoSteal()
    if Connections.autoSteal then return end
    Connections.autoSteal = RunService.Heartbeat:Connect(function()
        if not Config.AutoSteal or isStealing then return end
        local prompt, _, name = findNearestPrompt()
        if prompt then executeSteal(prompt, name) end
    end)
end

local function stopAutoSteal()
    if Connections.autoSteal then
        Connections.autoSteal:Disconnect()
        Connections.autoSteal = nil
    end
    isStealing = false
    ResetProgressBar()
end

local function startFPS()
    local frameCount = 0
    local lastTime = tick()
    fpsUpdateConnection = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        local delta = currentTime - lastTime
        if delta >= 0.5 then
            local fps = math.floor(frameCount / delta)
            frameCount = 0
            lastTime = currentTime
            if fpsLabel then
                local color = fps >= 60 and Color3.fromRGB(0, 255, 100) or (fps >= 30 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 50, 50))
                fpsLabel.Text = "FPS: " .. fps
                fpsLabel.TextColor3 = color
            end
        end
    end)
end

-- =====================================================================
-- PART 5: GUI - Red/Black Style
-- =====================================================================

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiScale = isMobile and 0.55 or 0.85

local Colors = {
    bg = Color3.fromRGB(4, 2, 2),
    red = Color3.fromRGB(255, 40, 40),
    redLight = Color3.fromRGB(255, 80, 80),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(200, 100, 100)
}

local sg = Instance.new("ScreenGui")
sg.Name = "ZeussHub"
sg.ResetOnSpawn = false
sg.Parent = Player.PlayerGui
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function playClickSound()
    pcall(function()
        local s = Instance.new("Sound", SoundService)
        s.SoundId = "rbxassetid://6895079813"
        s.Volume = 0.25
        s:Play()
        game:GetService("Debris"):AddItem(s, 1)
    end)
end

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 280 * guiScale, 0, 130 * guiScale)
main.Position = UDim2.new(1, -295 * guiScale, 0, 10 * guiScale)
main.BackgroundColor3 = Colors.bg
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12 * guiScale)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Thickness = 2
local strokeGrad = Instance.new("UIGradient", mainStroke)
strokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.red),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 0, 0)),
    ColorSequenceKeypoint.new(1, Colors.red)
})

task.spawn(function()
    local r = 0
    while main.Parent do
        r = (r + 1.5) % 360
        strokeGrad.Rotation = r
        task.wait(0.03)
    end
end)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 38 * guiScale)
header.BackgroundTransparency = 1

local titleLabel = Instance.new("TextLabel", header)
titleLabel.Size = UDim2.new(0.65, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 12 * guiScale, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Zeuss HUB"
titleLabel.TextColor3 = Colors.text
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 14 * guiScale
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

fpsLabel = Instance.new("TextLabel", header)
fpsLabel.Size = UDim2.new(0, 60 * guiScale, 1, 0)
fpsLabel.Position = UDim2.new(0.65, 0, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Colors.textDim
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 11 * guiScale
fpsLabel.TextXAlignment = Enum.TextXAlignment.Right

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 26 * guiScale, 0, 26 * guiScale)
closeBtn.Position = UDim2.new(1, -30 * guiScale, 0.5, -13 * guiScale)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Colors.textDim
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14 * guiScale
closeBtn.MouseButton1Click:Connect(function() 
    playClickSound()
    sg:Destroy() 
    if fpsUpdateConnection then fpsUpdateConnection:Disconnect() end
end)
closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = Colors.red end)
closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = Colors.textDim end)

local separator = Instance.new("Frame", main)
separator.Size = UDim2.new(0.9, 0, 0, 1)
separator.Position = UDim2.new(0.05, 0, 0, 38 * guiScale)
separator.BackgroundColor3 = Colors.red
separator.BackgroundTransparency = 0.7
separator.BorderSizePixel = 0

local toggleRow = Instance.new("Frame", main)
toggleRow.Size = UDim2.new(1, -20 * guiScale, 0, 42 * guiScale)
toggleRow.Position = UDim2.new(0, 10 * guiScale, 0, 46 * guiScale)
toggleRow.BackgroundTransparency = 1

local toggleLabel = Instance.new("TextLabel", toggleRow)
toggleLabel.Size = UDim2.new(0.55, 0, 1, 0)
toggleLabel.Position = UDim2.new(0, 8 * guiScale, 0, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "AUTO STEAL"
toggleLabel.TextColor3 = Colors.text
toggleLabel.Font = Enum.Font.GothamBold
toggleLabel.TextSize = 14 * guiScale
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

local toggleBg = Instance.new("Frame", toggleRow)
toggleBg.Size = UDim2.new(0, 48 * guiScale, 0, 24 * guiScale)
toggleBg.Position = UDim2.new(1, -56 * guiScale, 0.5, -12 * guiScale)
toggleBg.BackgroundColor3 = Colors.red
Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

local toggleCircle = Instance.new("Frame", toggleBg)
toggleCircle.Size = UDim2.new(0, 19 * guiScale, 0, 19 * guiScale)
toggleCircle.Position = UDim2.new(1, -21 * guiScale, 0.5, -9.5 * guiScale)
toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

local toggleBtn = Instance.new("TextButton", toggleRow)
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""

local autoStealOn = true

toggleBtn.MouseButton1Click:Connect(function()
    playClickSound()
    autoStealOn = not autoStealOn
    Config.AutoSteal = autoStealOn
    TweenService:Create(toggleBg, TweenInfo.new(0.2), {
        BackgroundColor3 = autoStealOn and Colors.red or Color3.fromRGB(30, 20, 35)
    }):Play()
    TweenService:Create(toggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        Position = autoStealOn and UDim2.new(1, -21 * guiScale, 0.5, -9.5 * guiScale) or UDim2.new(0, 3 * guiScale, 0.5, -9.5 * guiScale)
    }):Play()
    if autoStealOn then startAutoSteal() else stopAutoSteal() end
end)

local infoRow = Instance.new("Frame", main)
infoRow.Size = UDim2.new(1, -20 * guiScale, 0, 28 * guiScale)
infoRow.Position = UDim2.new(0, 10 * guiScale, 0, 94 * guiScale)
infoRow.BackgroundTransparency = 1

local infoLabel = Instance.new("TextLabel", infoRow)
infoLabel.Size = UDim2.new(1, 0, 1, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "STEAL RADIUS: 59  |  DURATION: 1.3s"
infoLabel.TextColor3 = Colors.redLight
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 11 * guiScale
infoLabel.TextXAlignment = Enum.TextXAlignment.Center

-- =====================================================================
-- PROGRESS BAR
-- =====================================================================

local progressContainer = Instance.new("Frame", sg)
progressContainer.Size = UDim2.new(0, 380 * guiScale, 0, 52 * guiScale)
progressContainer.Position = UDim2.new(0.5, -190 * guiScale, 1, -65 * guiScale)
progressContainer.BackgroundColor3 = Color3.fromRGB(2, 2, 4)
progressContainer.ClipsDescendants = true
Instance.new("UICorner", progressContainer).CornerRadius = UDim.new(0, 10 * guiScale)

local progStroke = Instance.new("UIStroke", progressContainer)
progStroke.Thickness = 1.5
progStroke.Color = Colors.red

ProgressLabel = Instance.new("TextLabel", progressContainer)
ProgressLabel.Size = UDim2.new(0.35, 0, 0.5, 0)
ProgressLabel.Position = UDim2.new(0, 12 * guiScale, 0, 0)
ProgressLabel.BackgroundTransparency = 1
ProgressLabel.Text = "READY"
ProgressLabel.TextColor3 = Colors.text
ProgressLabel.Font = Enum.Font.GothamBold
ProgressLabel.TextSize = 12 * guiScale
ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left

ProgressPercentLabel = Instance.new("TextLabel", progressContainer)
ProgressPercentLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
ProgressPercentLabel.Position = UDim2.new(0.35, 0, 0, 0)
ProgressPercentLabel.BackgroundTransparency = 1
ProgressPercentLabel.Text = ""
ProgressPercentLabel.TextColor3 = Colors.redLight
ProgressPercentLabel.Font = Enum.Font.GothamBlack
ProgressPercentLabel.TextSize = 14 * guiScale
ProgressPercentLabel.TextXAlignment = Enum.TextXAlignment.Center

local progTrack = Instance.new("Frame", progressContainer)
progTrack.Size = UDim2.new(0.96, 0, 0, 6 * guiScale)
progTrack.Position = UDim2.new(0.02, 0, 1, -12 * guiScale)
progTrack.BackgroundColor3 = Color3.fromRGB(8, 5, 10)
Instance.new("UICorner", progTrack).CornerRadius = UDim.new(1, 0)

ProgressBarFill = Instance.new("Frame", progTrack)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Colors.red
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1, 0)

local progClose = Instance.new("TextButton", progressContainer)
progClose.Size = UDim2.new(0, 22 * guiScale, 0, 22 * guiScale)
progClose.Position = UDim2.new(1, -28 * guiScale, 0.5, -11 * guiScale)
progClose.BackgroundTransparency = 1
progClose.Text = "✕"
progClose.TextColor3 = Colors.textDim
progClose.Font = Enum.Font.GothamBold
progClose.TextSize = 12 * guiScale
progClose.MouseButton1Click:Connect(function() 
    playClickSound()
    sg:Destroy()
    if fpsUpdateConnection then fpsUpdateConnection:Disconnect() end
end)

-- =====================================================================
-- INITIALIZE
-- =====================================================================

startFPS()
startAutoSteal()

print("If there is a bug, report it on discord ")
print("Dev KWP")
print("Best Scripts")