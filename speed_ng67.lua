local ESP_ENABLED = true
local ESP_PLAYERS_ENABLED = false
local MIN_GEN_FOR_ESP = 50000000

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Datas = ReplicatedStorage:WaitForChild("Datas")
local Utils = ReplicatedStorage:WaitForChild("Utils")

local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
local AnimalsData = require(Datas:WaitForChild("Animals"))
local RaritiesData = require(Datas:WaitForChild("Rarities"))
local NumberUtils = require(Utils:WaitForChild("NumberUtils"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ESP_INSTANCES = {}
local PLAYER_ESP = {}
local ESP_BEST_UID = nil
local allAnimalsCache = {}
local screenGui = nil

-- =====================================================================
-- BLOQUEO LOCAL: máquinas que bloquean el ESP
-- =====================================================================
local BLOCKING_MACHINE_TYPES = {
    Fuse     = true,
    Duel     = true,
    Trade    = true,
    Crafting = true,
}

local function isInBlockingMachine(animalData)
    if type(animalData) ~= "table" then return false end
    local machine = animalData.Machine
    if type(machine) ~= "table" then return false end
    return BLOCKING_MACHINE_TYPES[machine.Type] == true
end

-- =====================================================================
-- Funciones principales del ESP
-- =====================================================================

local function isMyBaseAnimal(animalData)
    if not animalData or not animalData.plot then return false end
    
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    
    local plot = plots:FindFirstChild(animalData.plot)
    if not plot then return false end
    
    local channel = Synchronizer:Get(plot.Name)
    if channel then
        local owner = channel:Get("Owner")
        if owner then
            if typeof(owner) == "Instance" and owner:IsA("Player") then
                return owner.UserId == LocalPlayer.UserId
            elseif typeof(owner) == "table" and owner.UserId then
                return owner.UserId == LocalPlayer.UserId
            end
        end
    end
    
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") then
            return yourBase.Enabled == true
        end
    end
    
    return false
end

local function getPodiumWorldPart(animal)
    if not animal.plot or not animal.slot then return nil end
    
    local plot = workspace.Plots:FindFirstChild(animal.plot)
    if not plot then return nil end
    
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    
    local podium = podiums:FindFirstChild(animal.slot)
    if not podium then return nil end
    
    local base = podium:FindFirstChild("Base")
    if not base then return podium end
    
    local spawn = base:FindFirstChild("Spawn")
    return spawn or base or podium
end

local function clearESPForUID(uid)
    local rec = ESP_INSTANCES[uid]
    if not rec then return end
    if rec.highlight then pcall(function() rec.highlight:Destroy() end) end
    if rec.billboard then pcall(function() rec.billboard:Destroy() end) end
    ESP_INSTANCES[uid] = nil
end

local function clearAllESP()
    for uid in pairs(ESP_INSTANCES) do
        clearESPForUID(uid)
    end
    ESP_BEST_UID = nil
end

local function refreshAllESP()
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BrainrotESP"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = PlayerGui
    end
    
    if not ESP_ENABLED then
        clearAllESP()
        return
    end
    
    local activeUIDs = {}
    local bestAnimal = nil
    
    for _, animalData in ipairs(allAnimalsCache) do
        if not isMyBaseAnimal(animalData) then
            bestAnimal = animalData
            break
        end
    end
    
    ESP_BEST_UID = bestAnimal and bestAnimal.uid or nil
    
    for _, animalData in ipairs(allAnimalsCache) do
        if isMyBaseAnimal(animalData) then
            continue
        end
        
        -- BLOQUEO: saltar animales que están en máquinas bloqueadas
        if isInBlockingMachine(animalData) then
            -- Limpiar ESP si existe y continuar
            if ESP_INSTANCES[animalData.uid] then
                clearESPForUID(animalData.uid)
            end
            continue
        end
        
        if (animalData.uid == ESP_BEST_UID) or (animalData.genValue >= MIN_GEN_FOR_ESP) then
            local uid = animalData.uid
            activeUIDs[uid] = true
            
            local rec = ESP_INSTANCES[uid]
            local model = getPodiumWorldPart(animalData)
            
            if not model then
                if rec then clearESPForUID(uid) end
                ESP_INSTANCES[uid] = nil
            else
                if not rec or rec.part ~= model then
                    if rec then clearESPForUID(uid) end
                    
                    rec = { part = model }
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = model
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillTransparency = 0.7
                    highlight.FillColor = Color3.fromRGB(255, 20, 147) -- ROSA FUERTE
                    highlight.OutlineTransparency = 0.3
                    highlight.OutlineColor = Color3.fromRGB(255, 105, 180) -- ROSA CLARO
                    highlight.Parent = screenGui
                    rec.highlight = highlight
                    
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "BrainrotESP"
                    bb.Adornee = model
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0, 220, 0, 80)
                    bb.SizeOffset = Vector2.new(0, 0)
                    bb.StudsOffset = Vector3.new(0, 3.5, 0)
                    bb.Parent = screenGui
                    
                    local bgFrame = Instance.new("Frame")
                    bgFrame.Size = UDim2.new(1, 0, 1, 0)
                    bgFrame.BackgroundTransparency = 1
                    bgFrame.Parent = bb
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, -10, 0.5, 0)
                    nameLabel.Position = UDim2.new(0, 5, 0, 5)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.TextScaled = true
                    nameLabel.Font = Enum.Font.GothamBlack
                    nameLabel.TextStrokeTransparency = 0
                    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    nameLabel.Parent = bgFrame
                    rec.labelName = nameLabel
                    
                    local genLabel = Instance.new("TextLabel")
                    genLabel.Size = UDim2.new(1, -10, 0.5, -5)
                    genLabel.Position = UDim2.new(0, 5, 0.5, 0)
                    genLabel.BackgroundTransparency = 1
                    genLabel.TextColor3 = Color3.fromRGB(255, 20, 147) -- ROSA
                    genLabel.TextScaled = true
                    genLabel.Font = Enum.Font.GothamBold
                    genLabel.TextStrokeTransparency = 0
                    genLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    genLabel.Parent = bgFrame
                    rec.labelGen = genLabel
                    
                    rec.billboard = bb
                    ESP_INSTANCES[uid] = rec
                end
                
                rec.labelName.Text = animalData.name
                rec.labelGen.Text = animalData.genText
                
                -- Mantener color rosa o usar rarity
                if animalData.rarity == "Legendary" then
                    rec.highlight.FillColor = Color3.fromRGB(255, 20, 147)
                elseif animalData.rarity == "Mythical" then
                    rec.highlight.FillColor = Color3.fromRGB(255, 20, 147)
                else
                    rec.highlight.FillColor = Color3.fromRGB(255, 20, 147)
                end
            end
        end
    end
    
    for uid in pairs(ESP_INSTANCES) do
        if not activeUIDs[uid] then
            clearESPForUID(uid)
        end
    end
end

local lastAnimalData = {}
local plotChannels = {}

local function getAnimalHash(animalList)
    if not animalList then return "" end
    local hash = ""
    for slot, data in pairs(animalList) do
        if type(data) == "table" then
            hash = hash .. tostring(slot) .. tostring(data.Index) .. tostring(data.Mutation)
        end
    end
    return hash
end

local function scanSinglePlot(plot)
    pcall(function()
        local plotUID = plot.Name
        local channel = Synchronizer:Get(plotUID)
        if not channel then return end
        
        local animalList = channel:Get("AnimalList")
        local currentHash = getAnimalHash(animalList)
        if lastAnimalData[plotUID] == currentHash then
            return
        end
        lastAnimalData[plotUID] = currentHash
        
        for i = #allAnimalsCache, 1, -1 do
            if allAnimalsCache[i].plot == plot.Name then
                table.remove(allAnimalsCache, i)
            end
        end
        
        local owner = channel:Get("Owner")
        if not owner or not Players:FindFirstChild(owner.Name) then
            return
        end
        
        local ownerName = owner and owner.Name or "Unknown"
        if not animalList then return end
        
        for slot, animalData in pairs(animalList) do
            if type(animalData) == "table" then
                local animalName = animalData.Index
                local animalInfo = AnimalsData[animalName]
                if not animalInfo then continue end
                
                local rarity = animalInfo.Rarity
                local rarityColor = (RaritiesData[rarity] and RaritiesData[rarity].Color) or Color3.fromRGB(255, 255, 255)
                
                local mutation = animalData.Mutation or "None"
                local traits = (animalData.Traits and #animalData.Traits > 0) and table.concat(animalData.Traits, ", ") or "None"
                
                local genValue = require(ReplicatedStorage.Shared.Animals):GetGeneration(animalName, animalData.Mutation, animalData.Traits, nil)
                local genText = "$" .. NumberUtils:ToString(genValue) .. "/s"
                
                table.insert(allAnimalsCache, {
                    name = animalInfo.DisplayName or animalName,
                    genText = genText,
                    genValue = genValue,
                    rarity = rarity,
                    rarityColor = rarityColor,
                    mutation = mutation,
                    traits = traits,
                    owner = ownerName,
                    plot = plot.Name,
                    slot = tostring(slot),
                    uid = plot.Name .. "_" .. tostring(slot),
                    Machine = animalData.Machine -- Guardar info de máquina
                })
            end
        end
        
        table.sort(allAnimalsCache, function(a, b)
            return a.genValue > b.genValue
        end)
        
        refreshAllESP()
    end)
end

local function setupPlotListener(plot)
    if plotChannels[plot.Name] then return end
    
    local channel
    local retries = 0
    local maxRetries = 10
    
    while not channel and retries < maxRetries do
        local success, result = pcall(function()
            return Synchronizer:Get(plot.Name)
        end)
        if success and result then
            channel = result
            break
        else
            retries = retries + 1
            if retries < maxRetries then
                task.wait(0.5)
            end
        end
    end
    
    if not channel then return end
    plotChannels[plot.Name] = true
    
    scanSinglePlot(plot)
    
    plot.DescendantAdded:Connect(function()
        task.wait(0.1)
        scanSinglePlot(plot)
    end)
    
    plot.DescendantRemoving:Connect(function()
        task.wait(0.1)
        scanSinglePlot(plot)
    end)
    
    task.spawn(function()
        while plot.Parent and plotChannels[plot.Name] do
            task.wait(1)
            scanSinglePlot(plot)
        end
    end)
end

local function initializePlotScanner()
    local plots = workspace:WaitForChild("Plots", 8)
    if not plots then
        return
    end
    
    for _, plot in ipairs(plots:GetChildren()) do
        setupPlotListener(plot)
    end
    
    plots.ChildAdded:Connect(function(plot)
        task.wait(0.5)
        setupPlotListener(plot)
    end)
    
    plots.ChildRemoved:Connect(function(plot)
        plotChannels[plot.Name] = nil
        lastAnimalData[plot.Name] = nil
        
        for i = #allAnimalsCache, 1, -1 do
            if allAnimalsCache[i].plot == plot.Name then
                table.remove(allAnimalsCache, i)
            end
        end
        
        refreshAllESP()
    end)
end

local function clearPlayerESP(plr)
    local rec = PLAYER_ESP[plr]
    if not rec then return end
    
    if rec.highlight then pcall(function() rec.highlight:Destroy() end) end
    if rec.billboard then pcall(function() rec.billboard:Destroy() end) end
    PLAYER_ESP[plr] = nil
end

local function clearAllPlayerESP()
    for plr in pairs(PLAYER_ESP) do
        clearPlayerESP(plr)
    end
end

local function createPlayerESP(plr)
    local char = plr.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char.PrimaryPart
    if not hrp then return end
    
    local rec = {}
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 20, 147) -- ROSA
    highlight.Parent = screenGui
    rec.highlight = highlight
    
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 160, 0, 32)
    bb.Adornee = hrp
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.Parent = screenGui
    rec.billboard = bb
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 20, 147) -- ROSA
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = plr.Name
    nameLabel.Parent = bb
    
    PLAYER_ESP[plr] = rec
end

local function refreshPlayerESP()
    if not ESP_PLAYERS_ENABLED then
        clearAllPlayerESP()
        return
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not PLAYER_ESP[plr] then
                createPlayerESP(plr)
            end
        end
    end
    
    local myChar = LocalPlayer.Character
    local myHRP = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("UpperTorso") or myChar.PrimaryPart)
    
    for plr, rec in pairs(PLAYER_ESP) do
        local char = plr.Character
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char.PrimaryPart)
        
        if not char or not hrp or not myHRP then
            clearPlayerESP(plr)
        else
            local dist = (myHRP.Position - hrp.Position).Magnitude
            local distInt = math.floor(dist + 0.5)
            
            if rec.billboard then
                local nameLabel = rec.billboard:FindFirstChild("TextLabel")
                if nameLabel then
                    nameLabel.Text = string.format("%s [%dm]", plr.Name, distInt)
                end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    for i = #allAnimalsCache, 1, -1 do
        if allAnimalsCache[i].owner == player.Name then
            table.remove(allAnimalsCache, i)
        end
    end
    refreshAllESP()
end)

RunService.Heartbeat:Connect(function()
    if ESP_PLAYERS_ENABLED then
        refreshPlayerESP()
    end
end)

initializePlotScanner()