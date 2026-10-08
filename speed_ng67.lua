-- =====================================================================
-- XENHUB - SPEED + FPS BOOST + AUTO STEAL + INF JUMP + AKA X-RAY + ANTI-RAGDOLL
-- by KWP | INF JUMP by @rznnq | AKA X-RAY + ANTI-RAGDOLL integrados
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

print("========================================")
print("XENHUB - LOADED")
print("by KWP")
print("========================================")

-- =====================================================================
-- PART 1: SPEED BYPASS
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
-- PART 2: FPS BOOST PRO (sin tocar cámara)
-- =====================================================================

_G._FH_CarpetTP_Speed = _G._FH_CarpetTP_Speed or 214
_G._FH_AlwaysOnFPS = true

pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    Lighting.ClockTime = 14
    Lighting.GeographicLatitude = 0
    Lighting.ExposureCompensation = 0
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect") 
           or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") 
           or v:IsA("DepthOfFieldEffect") then
            pcall(function() v.Enabled = false end)
        end
    end
end)

Lighting.DescendantAdded:Connect(function(obj)
    if obj:IsA("PostEffect") or obj:IsA("BlurEffect") or obj:IsA("BloomEffect")
       or obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
        pcall(function() obj.Enabled = false end)
    end
end)

pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

local function stripMeshTextures(inst)
    if inst:IsA("MeshPart") then
        pcall(function() inst.TextureID = "" end)
    elseif inst:IsA("SpecialMesh") then
        pcall(function() inst.TextureId = "" end)
    elseif inst:IsA("SurfaceAppearance") then
        pcall(function() inst:Destroy() end)
    end
end

local function stripHeavyVisuals(inst)
    pcall(function()
        if inst:IsA("Highlight") or inst:IsA("Beam") or inst:IsA("SelectionBox") 
           or inst:IsA("SelectionSphere") then
            inst.Enabled = false
        end
        if inst:IsA("BillboardGui") then
            if inst.Parent and not Players:GetPlayerFromCharacter(inst.Parent) then
                inst.Enabled = false
            end
        end
        if inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
            inst.Enabled = false
        end
    end)
end

local function killParticles(inst)
    if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke") 
       or inst:IsA("Fire") or inst:IsA("Sparkles") then
        pcall(function() inst.Enabled = false end)
    end
end

local function applyPartPerf(inst)
    if inst:IsA("BasePart") then
        pcall(function()
            inst.CastShadow = false
            inst.Material = Enum.Material.Plastic
            inst.Reflectance = 0
        end)
    end
end

-- =====================================================================
-- PART 3: BRAINROT / HAUNTED FUSE OPTIMIZATION
-- =====================================================================

local function optimizeBrainrot(model)
    if not model.Name then return end
    local lname = string.lower(model.Name)
    if lname:find("brainrot") or lname:find("brainrots") then
        pcall(function()
            for _, v in pairs(model:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                end
                if v:IsA("MeshPart") then
                    pcall(function() v.TextureID = "" end)
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                end
                if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
                    v:Destroy()
                end
                if v:IsA("AnimationController") or v:IsA("Animator") then
                    v:Destroy()
                end
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") 
                   or v:IsA("Sparkles") or v:IsA("Fire") then
                    v.Enabled = false
                end
                if v:IsA("Highlight") or v:IsA("SelectionBox") or v:IsA("Beam") then
                    v.Enabled = false
                end
                if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                    v.Enabled = false
                end
            end
        end)
    end
end

local function removeHauntedFuse(model)
    if not model.Name then return end
    local lname = string.lower(model.Name)
    if lname:find("haunted") or lname:find("fuse") then
        pcall(function()
            for _, v in pairs(model:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    v.Transparency = 1
                    v.CanCollide = false
                    v.CanTouch = false
                    v.CanQuery = false
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                end
                if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
                    v:Destroy()
                end
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") 
                   or v:IsA("Sparkles") or v:IsA("Fire") then
                    v.Enabled = false
                end
                if v:IsA("Highlight") or v:IsA("SelectionBox") or v:IsA("Beam") then
                    v.Enabled = false
                end
                if v:IsA("AnimationController") or v:IsA("Animator") then
                    v:Destroy()
                end
                if v:IsA("Sound") or v:IsA("SoundGroup") then
                    pcall(function() v.Volume = 0; v:Stop() end)
                end
                if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                    v.Enabled = false
                end
            end
        end)
    end
end

local function hideSpecialEvents(model)
    if not model.Name then return end
    local name = string.lower(model.Name)
    if name:find("fire") or name:find("taco") or name:find("nyan") or name:find("event") 
        or name:find("haunted") or name:find("fuse") then
        pcall(function()
            for _, v in pairs(model:GetDescendants()) do
                if v:IsA("BasePart") then 
                    v.Transparency = 1
                    v.Reflectance = 0
                    v.Material = Enum.Material.Plastic
                    v.CanCollide = false
                end
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") 
                   or v:IsA("Sparkles") or v:IsA("Fire") then v.Enabled = false end
                if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then v:Destroy() end
                if v:IsA("AnimationController") or v:IsA("Animator") then v:Destroy() end
                if v:IsA("Highlight") or v:IsA("Beam") or v:IsA("SelectionBox") then v.Enabled = false end
                if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v.Enabled = false end
            end
        end)
    end
end

-- =====================================================================
-- PART 4: TOOL / CHARACTER CLEANUP
-- =====================================================================

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

local function cleanSingleTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    pcall(function()
        local handle = tool:FindFirstChild("Handle")
        if handle then
            for _, obj in pairs(handle:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then 
                    obj:Destroy()
                elseif obj:IsA("SpecialMesh") or obj:IsA("MeshPart") then 
                    pcall(function() obj.TextureId = ""; obj.TextureID = "" end) 
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") 
                    or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj.Enabled = false
                end
            end
        end
        for _, obj in pairs(tool:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then 
                obj:Destroy()
            elseif obj:IsA("SpecialMesh") or obj:IsA("MeshPart") then 
                pcall(function() obj.TextureId = ""; obj.TextureID = "" end)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") 
                or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = false
            end
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

-- =====================================================================
-- PART 5: HIDE PLAYER ANIMATIONS (visualmente)
-- =====================================================================

local function hidePlayerAnimations(character)
    if not character or character == Player.Character then return end
    if not Players:GetPlayerFromCharacter(character) then return end
    
    task.spawn(function()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                pcall(function()
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        track:Stop(0)
                    end
                end)
                animator.AnimationPlayed:Connect(function(track)
                    pcall(function() track:Stop(0) end)
                end)
            end
        end
        
        for _, v in ipairs(character:GetDescendants()) do
            if v:IsA("AnimationController") then
                for _, anim in ipairs(v:GetPlayingAnimationTracks()) do
                    pcall(function() anim:Stop(0) end)
                end
            end
        end
    end)
end

local function hookPlayerAnimations(plr)
    if plr == Player then return end
    if plr.Character then hidePlayerAnimations(plr.Character) end
    plr.CharacterAdded:Connect(hidePlayerAnimations)
end

for _, plr in ipairs(Players:GetPlayers()) do
    hookPlayerAnimations(plr)
end
Players.PlayerAdded:Connect(hookPlayerAnimations)

local function disableAnimationsOnModel(model)
    if Players:GetPlayerFromCharacter(model) then return end
    pcall(function()
        for _, v in pairs(model:GetDescendants()) do
            if v:IsA("AnimationController") or v:IsA("Animator") then v:Destroy()
            elseif v:IsA("Humanoid") then v:ChangeState(Enum.HumanoidStateType.Physics) end
        end
    end)
end

-- =====================================================================
-- PART 5.5: AKA X-RAY (otros jugadores semi-transparentes)
-- =====================================================================

local akaXrayEnabled = false
local akaXrayConnections = {}
local akaXrayOriginal = {}

local function applyAKAXrayToCharacter(character)
    if not character or character == Player.Character then return end
    if not Players:GetPlayerFromCharacter(character) then return end
    task.spawn(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if not akaXrayOriginal[part] then
                    akaXrayOriginal[part] = part.LocalTransparencyModifier
                end
                pcall(function()
                    part.LocalTransparencyModifier = 0.85
                end)
            end
        end
        local conn = character.DescendantAdded:Connect(function(d)
            if not akaXrayEnabled then return end
            if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                if not akaXrayOriginal[d] then
                    akaXrayOriginal[d] = d.LocalTransparencyModifier
                end
                pcall(function()
                    d.LocalTransparencyModifier = 0.85
                end)
            end
        end)
        table.insert(akaXrayConnections, conn)
    end)
end

local function removeAKAXrayFromCharacter(character)
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.LocalTransparencyModifier = akaXrayOriginal[part] or 0
            end)
            akaXrayOriginal[part] = nil
        end
    end
end

local function enableAKAXray()
    akaXrayEnabled = true
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            applyAKAXrayToCharacter(plr.Character)
        end
    end
    local conn1 = Players.PlayerAdded:Connect(function(plr)
        if not akaXrayEnabled then return end
        plr.CharacterAdded:Connect(function(c)
            if akaXrayEnabled then
                task.wait(0.3)
                applyAKAXrayToCharacter(c)
            end
        end)
    end)
    table.insert(akaXrayConnections, conn1)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local conn2 = plr.CharacterAdded:Connect(function(c)
                if akaXrayEnabled then
                    task.wait(0.3)
                    applyAKAXrayToCharacter(c)
                end
            end)
            table.insert(akaXrayConnections, conn2)
        end
    end
end

local function disableAKAXray()
    akaXrayEnabled = false
    for _, conn in ipairs(akaXrayConnections) do
        pcall(function() conn:Disconnect() end)
    end
    akaXrayConnections = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            removeAKAXrayFromCharacter(plr.Character)
        end
    end
    akaXrayOriginal = {}
end

-- =====================================================================
-- PART 5.6: ANTI-RAGDOLL ESTILO REP (auto-recuperación + limpieza)
-- =====================================================================

local antiRagdollEnabled = true
local antiRagdollConnections = {}
local antiRagdollLoopConn = nil

local function isRagdolled(hum)
    if not hum then return false end
    local state = hum:GetState()
    return state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown
end

-- Limpia constraints y BallSockets que causan ragdoll
local function cleanRagdollConstraints(char)
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BallSocketConstraint") 
           or d:IsA("NoCollisionConstraint")
           or d:IsA("HingeConstraint") then
            pcall(function() d:Destroy() end)
        elseif d:IsA("Attachment") and (d.Name == "A" or d.Name == "B") then
            pcall(function() d:Destroy() end)
        end
    end
    -- Reactivar Motor6D
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Motor6D") and not d.Enabled then
            pcall(function() d.Enabled = true end)
        end
    end
end

-- Fuerza el Humanoid a Running y rehabilita controles
local function recoverFromRagdoll(char, hum, hrp)
    if not char or not hum or not hrp then return end
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end)
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    pcall(function()
        if Workspace.CurrentCamera and Workspace.CurrentCamera.CameraSubject ~= hum then
            Workspace.CurrentCamera.CameraSubject = hum
        end
    end)
    -- Reactivar controles del PlayerModule
    task.defer(function()
        pcall(function()
            local ps = Player:FindFirstChild("PlayerScripts")
            local pm = ps and ps:FindFirstChild("PlayerModule")
            if pm then
                local controls = require(pm):GetControls()
                if controls then controls:Enable() end
            end
        end)
    end)
    cleanRagdollConstraints(char)
end

-- Hook de CharacterAdded para monitorear el nuevo personaje
local function hookAntiRagdoll(char)
    if not char then return end
    -- Desconectar los anteriores
    for _, c in ipairs(antiRagdollConnections) do
        pcall(function() c:Disconnect() end)
    end
    antiRagdollConnections = {}

    local hum = char:WaitForChild("Humanoid", 10)
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hum or not hrp then return end

    -- 1. Escuchar cambios de estado del Humanoid (V1)
    local c1 = hum.StateChanged:Connect(function()
        if not antiRagdollEnabled then return end
        if isRagdolled(hum) then
            recoverFromRagdoll(char, hum, hrp)
        end
    end)
    table.insert(antiRagdollConnections, c1)

    -- 2. Detectar cuando entran constraints nuevos (V2)
    local c2 = char.DescendantAdded:Connect(function(desc)
        if not antiRagdollEnabled then return end
        if desc:IsA("BallSocketConstraint") 
           or desc:IsA("NoCollisionConstraint")
           or desc:IsA("HingeConstraint")
           or (desc:IsA("Attachment") and (desc.Name == "A" or desc.Name == "B")) then
            task.defer(function()
                if char and char.Parent then
                    cleanRagdollConstraints(char)
                    if isRagdolled(hum) then
                        recoverFromRagdoll(char, hum, hrp)
                    end
                end
            end)
        end
    end)
    table.insert(antiRagdollConnections, c2)

    -- 3. Hook del RemoteEvent ApplyImpulse (empujones)
    pcall(function()
        local pkg = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
        if not pkg then return end
        local net = pkg:FindFirstChild("Net")
        if not net then return end
        local applyImp = net:FindFirstChild("RE/CombatService/ApplyImpulse")
        if applyImp and applyImp:IsA("RemoteEvent") then
            local c3 = applyImp.OnClientEvent:Connect(function()
                if not antiRagdollEnabled then return end
                task.defer(function()
                    if hrp and hrp.Parent then
                        pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
                    end
                    if isRagdolled(hum) then
                        recoverFromRagdoll(char, hum, hrp)
                    end
                end)
            end)
            table.insert(antiRagdollConnections, c3)
        end
    end)

    -- Limpieza inicial por si ya está ragdollea'o
    task.wait(0.2)
    if isRagdolled(hum) then
        recoverFromRagdoll(char, hum, hrp)
    end
end

-- Loop de seguridad por si algo se escapa
antiRagdollLoopConn = RunService.Heartbeat:Connect(function()
    if not antiRagdollEnabled then return end
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    if isRagdolled(hum) then
        -- Solo actuar si el personaje no tiene el carpet equipado
        -- (para no interferir con vuelo por Flying Carpet)
        local hasCarpet = false
        local tool = char:FindFirstChild("Flying Carpet") 
                  or char:FindFirstChild("Cupid's Wings")
        if tool then
            for _, o in ipairs(hrp:GetChildren()) do
                if o:IsA("BodyVelocity") or o:IsA("BodyPosition") or o:IsA("BodyGyro") then
                    hasCarpet = true
                    break
                end
            end
        end
        if not hasCarpet then
            recoverFromRagdoll(char, hum, hrp)
        end
    end
end)

-- Aplicar al personaje actual y a los siguientes
if Player.Character then
    task.spawn(function() hookAntiRagdoll(Player.Character) end)
end
Player.CharacterAdded:Connect(function(c)
    task.wait(0.3)
    if antiRagdollEnabled then hookAntiRagdoll(c) end
end)

local function enableAntiRagdoll()
    antiRagdollEnabled = true
    if Player.Character then hookAntiRagdoll(Player.Character) end
end

local function disableAntiRagdoll()
    antiRagdollEnabled = false
    for _, c in ipairs(antiRagdollConnections) do
        pcall(function() c:Disconnect() end)
    end
    antiRagdollConnections = {}
end

-- =====================================================================
-- PART 6: WORKSPACE SWEEP + MONITORING
-- =====================================================================

task.spawn(function()
    task.wait(0.5)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            disableAnimationsOnModel(obj)
            optimizeBrainrot(obj)
            removeHauntedFuse(obj)
            hideSpecialEvents(obj)
        end
        stripMeshTextures(obj)
        stripHeavyVisuals(obj)
        killParticles(obj)
        applyPartPerf(obj)
        if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then 
            pcall(function() obj:Destroy() end) 
        end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        disableAnimationsOnModel(obj)
        optimizeBrainrot(obj)
        removeHauntedFuse(obj)
        hideSpecialEvents(obj)
    end
    stripMeshTextures(obj)
    stripHeavyVisuals(obj)
    killParticles(obj)
    applyPartPerf(obj)
    if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then 
        pcall(function() obj:Destroy() end) 
    end
end)

startToolMonitoring()
cleanAllPlayerTools()

-- =====================================================================
-- PART 7: INF JUMP (by @rznnq)
-- =====================================================================

local infinityJumpEnabled = true
local jumpForce = 50
local clampFallSpeed = 80

RunService.Heartbeat:Connect(function()
    if not infinityJumpEnabled then return end
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Velocity.Y < -clampFallSpeed then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, -clampFallSpeed, hrp.Velocity.Z)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not infinityJumpEnabled then return end
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, jumpForce, hrp.Velocity.Z)
    end
end)

-- =====================================================================
-- PART 8: AUTO STEAL
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

local function getDiscordProgress(percent)
    local totalChars = 9
    local adjustedPercent = math.min(percent * 1.5, 100)
    local charsToShow = math.floor((adjustedPercent / 100) * totalChars)
    if charsToShow == 0 and percent > 0 then charsToShow = 1 end
    return string.rep("-", charsToShow)
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
-- PART 9: GUI - Red/Black Style
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
sg.Name = "XenHub"
sg.ResetOnSpawn = false
sg.Parent = Player.PlayerGui
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 280 * guiScale, 0, 251 * guiScale)
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
titleLabel.Text = "XENHUB"
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
closeBtn.Text = "X"
closeBtn.TextColor3 = Colors.textDim
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14 * guiScale
closeBtn.MouseButton1Click:Connect(function() 
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

local function createToggleRow(parent, yPos, labelText, defaultOn, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -20 * guiScale, 0, 38 * guiScale)
    row.Position = UDim2.new(0, 10 * guiScale, 0, yPos)
    row.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8 * guiScale, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Colors.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14 * guiScale
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local bg = Instance.new("Frame", row)
    bg.Size = UDim2.new(0, 48 * guiScale, 0, 24 * guiScale)
    bg.Position = UDim2.new(1, -56 * guiScale, 0.5, -12 * guiScale)
    bg.BackgroundColor3 = defaultOn and Colors.red or Color3.fromRGB(30, 20, 35)
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame", bg)
    circle.Size = UDim2.new(0, 19 * guiScale, 0, 19 * guiScale)
    circle.Position = defaultOn and UDim2.new(1, -21 * guiScale, 0.5, -9.5 * guiScale) or UDim2.new(0, 3 * guiScale, 0.5, -9.5 * guiScale)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local state = defaultOn
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(bg, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Colors.red or Color3.fromRGB(30, 20, 35)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Position = state and UDim2.new(1, -21 * guiScale, 0.5, -9.5 * guiScale) or UDim2.new(0, 3 * guiScale, 0.5, -9.5 * guiScale)
        }):Play()
        callback(state)
    end)
    
    return row
end

createToggleRow(main, 46 * guiScale, "AUTO STEAL", true, function(state)
    Config.AutoSteal = state
    if state then startAutoSteal() else stopAutoSteal() end
end)

createToggleRow(main, 84 * guiScale, "INF JUMP", true, function(state)
    infinityJumpEnabled = state
end)

createToggleRow(main, 122 * guiScale, "AKA X-RAY", false, function(state)
    if state then
        enableAKAXray()
    else
        disableAKAXray()
    end
end)

createToggleRow(main, 160 * guiScale, "ANTI-RAGDOLL", true, function(state)
    if state then
        enableAntiRagdoll()
    else
        disableAntiRagdoll()
    end
end)

local infoRow = Instance.new("Frame", main)
infoRow.Size = UDim2.new(1, -20 * guiScale, 0, 28 * guiScale)
infoRow.Position = UDim2.new(0, 10 * guiScale, 0, 214 * guiScale)
infoRow.BackgroundTransparency = 1

local infoLabel = Instance.new("TextLabel", infoRow)
infoLabel.Size = UDim2.new(1, 0, 1, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "INF JUMP @rznnq | ANTI-RAGDOLL REP-STYLE"
infoLabel.TextColor3 = Colors.redLight
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 10 * guiScale
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
progClose.Text = "X"
progClose.TextColor3 = Colors.textDim
progClose.Font = Enum.Font.GothamBold
progClose.TextSize = 12 * guiScale
progClose.MouseButton1Click:Connect(function() 
    sg:Destroy()
    if fpsUpdateConnection then fpsUpdateConnection:Disconnect() end
end)

-- =====================================================================
-- PART 10: MAINTENANCE LOOP (FPS sin tocar cámara)
-- =====================================================================

task.spawn(function()
    while task.wait(5) do
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.CastShadow then
                    obj.CastShadow = false
                end
                if (obj:IsA("Highlight") or obj:IsA("Beam")) and obj.Enabled then
                    obj.Enabled = false
                end
                if (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke")) and obj.Enabled then
                    obj.Enabled = false
                end
                if (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) and obj.Enabled then
                    obj.Enabled = false
                end
            end
        end)
    end
end)

-- =====================================================================
-- INITIALIZE
-- =====================================================================

startFPS()
startAutoSteal()

print("========================================")
print("XENHUB - LOADED SUCCESSFULLY")
print("by KWP | INF JUMP @rznnq | AKA X-RAY + ANTI-RAGDOLL REP integrados")
print("========================================")