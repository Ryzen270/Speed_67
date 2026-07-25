local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
if not LP then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LP = Players.LocalPlayer
end

-- ============================================================
--  PARTE 1: SPEED BYPASS (con GUI táctil) - APAGADO POR DEFECTO
-- ============================================================
local speedEnabled = false  -- 🔴 CAMBIADO A FALSE (apagado por defecto)
local speedConnection = nil

-- GUI Speed
local gui = Instance.new("ScreenGui")
gui.Name = "MiniSpeedGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 130, 0, 45)
frame.Position = UDim2.new(0.82, 0, 0.15, 0)
frame.AnchorPoint = Vector2.new(0, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 1.5
stroke.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 1, 0)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamBold
status.TextScaled = true
status.TextColor3 = Color3.new(1, 1, 1)
status.Text = "SPEED : OFF"  -- 🔴 Apagado por defecto
status.Parent = frame

-- Función Speed
local function setSpeed(state)
    speedEnabled = state

    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end

    if not state then
        status.Text = "SPEED : OFF"
        frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        return
    end

    status.Text = "SPEED : ON"
    frame.BackgroundColor3 = Color3.fromRGB(0, 120, 70)

    speedConnection = RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char then return end

        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local tool = char:FindFirstChild("Flying Carpet") or LP.Backpack:FindFirstChild("Flying Carpet")

        if tool then
            if tool.Parent ~= char then
                pcall(function() hum:EquipTool(tool) end)
            end

            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    moveDir.X * 150,
                    hrp.AssemblyLinearVelocity.Y,
                    moveDir.Z * 150
                )
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end
    end)
end

-- Click para toggle (enciende/apaga)
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        setSpeed(not speedEnabled)
    end
end)

-- 🔴 ELIMINADO: setSpeed(true)  <- Esto ya no enciende automáticamente

-- ============================================================
--  PARTE 2: FPS BOOST (integrado del segundo script)
-- ============================================================

-- Variables globales compatibles
_G._FH_CarpetTP_Speed = _G._FH_CarpetTP_Speed or 214
_G._FH_AlwaysOnFPS = true

-- ===== FUNCIONES DE OPTIMIZACIÓN =====

local function stripToolPhysics(tool)
    if not tool or not tool:IsA("Tool") then return end
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("BasePart") then
            pcall(function()
                d.Massless = true
                d.CanCollide = false
            end)
        elseif d:IsA("BodyVelocity") or d:IsA("BodyPosition") or d:IsA("BodyGyro")
            or d:IsA("AlignPosition") or d:IsA("AlignOrientation") or d:IsA("VectorForce")
            or d:IsA("LinearVelocity") or d:IsA("AngularVelocity") then
            pcall(function() d.Enabled = false end)
        end
    end
    tool.DescendantAdded:Connect(function(d)
        if d:IsA("BasePart") then
            pcall(function()
                d.Massless = true
                d.CanCollide = false
            end)
        end
    end)
end

local function wireChar(c)
    for _, t in ipairs(c:GetChildren()) do stripToolPhysics(t) end
    c.ChildAdded:Connect(stripToolPhysics)
end

-- Aplicar a personaje
if LP.Character then wireChar(LP.Character) end
LP.CharacterAdded:Connect(wireChar)

-- ===== CARPET TP =====
local _fhCarpetActiveTween = nil

function _G._FH_CarpetTP(targetCF, speedOverride)
    local chr = LP.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetCF then return end
    if typeof(targetCF) == "Vector3" then targetCF = CFrame.new(targetCF) end

    local dist = (hrp.Position - targetCF.Position).Magnitude
    local dur = math.max(0.05, dist / (speedOverride or _G._FH_CarpetTP_Speed or 214))

    local bp = LP:FindFirstChildOfClass("Backpack")
    local carpet = (bp and bp:FindFirstChild("Flying Carpet")) or chr:FindFirstChild("Flying Carpet")
    local hum = chr:FindFirstChildOfClass("Humanoid")

    if carpet and hum and carpet.Parent ~= chr then
        pcall(function() hum:EquipTool(carpet) end)
    end

    if _fhCarpetActiveTween then
        pcall(function() _fhCarpetActiveTween:Cancel() end)
    end

    local tw = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = targetCF})
    _fhCarpetActiveTween = tw
    tw:Play()
    return tw
end

-- ===== FPS BOOST - LIGHTING =====
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

-- ===== LIMPIEZA DE TEXTURAS =====
local function cleanSingleTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    pcall(function()
        local handle = tool:FindFirstChild("Handle")
        if handle then
            for _, obj in pairs(handle:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    obj:Destroy()
                elseif obj:IsA("SpecialMesh") or obj:IsA("MeshPart") then
                    pcall(function() obj.TextureId = "" end)
                end
            end
        end
        for _, obj in pairs(tool:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj:Destroy()
            elseif obj:IsA("SpecialMesh") or obj:IsA("MeshPart") then
                pcall(function() obj.TextureId = "" end)
            elseif obj:IsA("ParticleEmitter") then
                obj:Destroy()
            end
        end
    end)
end

local function cleanAllPlayerTools()
    if not LP then return end
    pcall(function()
        if LP.Character then
            for _, tool in pairs(LP.Character:GetChildren()) do
                if tool:IsA("Tool") then cleanSingleTool(tool) end
            end
        end
        local backpack = LP:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then cleanSingleTool(tool) end
            end
        end
    end)
end

-- ===== MONITOREO DE HERRAMIENTAS =====
local function startToolMonitoring()
    LP.CharacterAdded:Connect(function(character)
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

    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        backpack.ChildAdded:Connect(function(tool)
            if tool:IsA("Tool") then task.defer(function() cleanSingleTool(tool) end) end
        end)
    end

    task.spawn(function()
        while task.wait(3) do
            cleanAllPlayerTools()
        end
    end)
end

-- ===== OPTIMIZACIONES DE WORKSPACE =====
local function disableAnimationsOnModel(model)
    if Players:GetPlayerFromCharacter(model) then return end
    pcall(function()
        for _, v in pairs(model:GetDescendants()) do
            if v:IsA("AnimationController") or v:IsA("Animator") then
                v:Destroy()
            elseif v:IsA("Humanoid") then
                v:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end
    end)
end

local function optimizeBrainrot(model)
    if model.Name and string.lower(model.Name):find("brainrot") then
        pcall(function()
            for _, v in pairs(model:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                end
                if v:IsA("AnimationController") or v:IsA("Animator") then
                    v:Destroy()
                end
                if v:IsA("Texture") or v:IsA("Decal") then
                    v:Destroy()
                end
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then
                    v.Enabled = false
                end
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
                if v:IsA("BasePart") then
                    v.Transparency = 1
                end
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
                if v:IsA("Texture") or v:IsA("Decal") then
                    v:Destroy()
                end
                if v:IsA("AnimationController") or v:IsA("Animator") then
                    v:Destroy()
                end
            end
        end)
    end
end

-- ===== APLICAR OPTIMIZACIONES A WORKSPACE =====
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
        if obj:IsA("Texture") or obj:IsA("Decal") then
            pcall(function() obj:Destroy() end)
        end
    end
end)

-- ===== EVENTOS PARA OBJETOS NUEVOS =====
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        disableAnimationsOnModel(obj)
        optimizeBrainrot(obj)
        hideSpecialEvents(obj)
    end
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        pcall(function() obj.Enabled = false end)
    end
    if obj:IsA("BasePart") then
        pcall(function() obj.Material = Enum.Material.Plastic end)
    end
    if obj:IsA("Texture") or obj:IsA("Decal") then
        pcall(function() obj:Destroy() end)
    end
end)

-- ===== INICIAR MONITOREOS =====
startToolMonitoring()
cleanAllPlayerTools()

-- ===== CALIDAD DE RENDER =====
task.spawn(function()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e9
        Lighting.Brightness = 1
    end)
end)

-- ============================================================
--  ESTADO FINAL
-- ============================================================
print("✅ SPEED BYPASS + FPS BOOST UNIFICADOS")
print("   🚀 Speed: OFF (toca la GUI para encender)")  -- 🔴 Cambiado
print("   🔧 FPS Boost: ACTIVADO")
print("   🧹 Limpieza de texturas: ACTIVADA")
print("   🎨 Materiales a PLÁSTICO: ACTIVADO")
print("   🌑 Sombras desactivadas")