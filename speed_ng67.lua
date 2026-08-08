-- =====================================================================
-- Best Pet ESP - Always Active with Machine Block
-- =====================================================================

local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

getgenv().BestPetESP = getgenv().BestPetESP or {
    active = false,
    connection = nil,
    espInstance = nil
}

local CONFIG = {
    ScanInterval = 0.5,
    TargetFolder = "Debris",
    TemplateName = "FastOverheadTemplate"
}

-- =====================================================================
-- Fusing / machine-block helper (used by scanAllPets)
-- =====================================================================
local _BLOCKING_MACHINE_TYPES = {
    Fuse     = true,
    Duel     = true,
    Trade    = true,
    Crafting = true,
}

local function _VanishIsFusing(animalData)
    if type(animalData) ~= "table" then return false end
    local m = animalData.Machine
    if type(m) ~= "table" then return false end
    return _BLOCKING_MACHINE_TYPES[m.Type] == true
end

local function isMyBase(plotName)
    local plot = workspace.Plots:FindFirstChild(plotName)
    if not plot then return false end
    
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") then
            return yourBase.Enabled == true
        end
    end
    return false
end

local function parseValue(text)
    if not text then return 0 end
    text = tostring(text):gsub("%s", ""):gsub("/s", "")
    
    local numStr, suffix = text:match("([%d%.]+)([KkMmBbTtQq]?)")
    if not numStr then return 0 end
    
    local num = tonumber(numStr) or 0
    local multipliers = {
        K = 1e3,
        M = 1e6,
        B = 1e9
    }
    
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
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    local valueLabel = Instance.new("TextLabel", container)
    valueLabel.Name = "PetValue"
    valueLabel.Size = UDim2.new(1, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0, 0, 0.5, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
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
    local debris = Workspace:FindFirstChild(CONFIG.TargetFolder)
    if not debris then return end

    local bestPet = {
        value = -1,
        part = nil,
        displayText = "None",
        rawText = ""
    }

    local items = debris:GetChildren()
    
    for _, item in ipairs(items) do
        if item.Name == CONFIG.TemplateName then
            local surfaceGui = item:FindFirstChildOfClass("SurfaceGui")
            
            if surfaceGui and surfaceGui.Adornee then
                -- Check for machine block
                local animalData = item:FindFirstChild("AnimalData")
                if animalData then
                    local data = animalData:GetAttributes()
                    if _VanishIsFusing(data) then
                        -- Skip this pet if it's in a blocking machine
                        continue
                    end
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

local function startLoop()
    if getgenv().BestPetESP.active then return end
    getgenv().BestPetESP.active = true
    
    print("[ESP] Started Optimized Loop (Always Active)")

    task.spawn(function()
        while getgenv().BestPetESP.active do
            local success, err = pcall(scanForBestPet)
            if not success then
                warn("[ESP Error]:", err)
            end
            task.wait(CONFIG.ScanInterval)
        end
    end)
end

local function stopLoop()
    getgenv().BestPetESP.active = false
    updateESP(nil, nil, nil)
end

-- Initialize ESP as always active
startLoop()

print("[ESP] Best Pet ESP Loaded - Always Active")
print("[ESP] Blocked machine types: Fuse, Duel, Trade, Crafting")