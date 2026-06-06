-- MÓDULO: WORLD (COMPLETO)
local World = {}

local RunService = game:GetService("RunService")
local Workspace = workspace
local lighting = game:GetService("Lighting")

World.config = {
    carSpeedEnabled = false,
    carForwardMaxSpeed = 100,
    carReverseMaxSpeed = 40,
    carAcceleration = 60,
    carDeceleration = 100,
    carBraking = 35,
    carSteeringReduction = 0.35,
    carDensity = 1,
    carElasticity = 0,
    carStaticFriction = 5,
    carKineticFriction = 4,
    carSlipThreshold = 1,
    zombieExpanderEnabled = false,
    zombieHitboxSize = 16,
    zombieHeadTransparency = 0.9,
    noInventoryBlurEnabled = false,
    removeGrassEnabled = false,
    noTreeEnabled = false
}

World.originalZombieHeads = {}
World.zombieEntitiesFolder = nil
World.zombieExpanderLoop = nil
World.carModLoop = nil
World.noInventoryBlurLoop = nil
World.noCarDamageLoop = nil
World.noTreeConnection = nil

-- ========== CAR SPEED ==========
local function applyCarModifications()
    if not World.config.carSpeedEnabled then return end
    local carros = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Controller" and obj.Parent and obj.Parent.Name == "Scripts" then
            table.insert(carros, obj.Parent.Parent)
        end
    end
    for _, car in ipairs(carros) do
        local engine = car:FindFirstChild("Engine")
        local steering = car:FindFirstChild("Steering")
        local wheels = car:FindFirstChild("Wheels")
        if engine then
            pcall(function()
                engine:SetAttribute("forwardMaxSpeed", World.config.carForwardMaxSpeed)
                engine:SetAttribute("reverseMaxSpeed", World.config.carReverseMaxSpeed)
                engine:SetAttribute("acceleration", World.config.carAcceleration)
                engine:SetAttribute("deceleration", World.config.carDeceleration)
                engine:SetAttribute("braking", World.config.carBraking)
            end)
        end
        if steering then 
            pcall(function() steering:SetAttribute("steeringReduction", World.config.carSteeringReduction) end) 
        end
        if wheels then
            pcall(function()
                wheels:SetAttribute("density", World.config.carDensity)
                wheels:SetAttribute("elasticity", World.config.carElasticity)
                wheels:SetAttribute("staticFriction", World.config.carStaticFriction)
                wheels:SetAttribute("kineticFriction", World.config.carKineticFriction)
                wheels:SetAttribute("slipThreshold", World.config.carSlipThreshold)
            end)
        end
    end
end

local function startCarModLoop()
    if World.carModLoop then task.cancel(World.carModLoop); World.carModLoop = nil end
    if World.config.carSpeedEnabled then
        World.carModLoop = task.spawn(function()
            while World.config.carSpeedEnabled do
                applyCarModifications()
                task.wait(0.5)
            end
        end)
    end
end

function World.setCarSpeedEnabled(v)
    World.config.carSpeedEnabled = v
    startCarModLoop()
    if v then applyCarModifications() elseif World.carModLoop then task.cancel(World.carModLoop); World.carModLoop = nil end
end

function World.setCarForwardMaxSpeed(v) World.config.carForwardMaxSpeed = v; if World.config.carSpeedEnabled then applyCarModifications() end end
function World.setCarReverseMaxSpeed(v) World.config.carReverseMaxSpeed = v; if World.config.carSpeedEnabled then applyCarModifications() end end
function World.setCarAcceleration(v) World.config.carAcceleration = v; if World.config.carSpeedEnabled then applyCarModifications() end end
function World.setCarDeceleration(v) World.config.carDeceleration = v; if World.config.carSpeedEnabled then applyCarModifications() end end
function World.setCarBraking(v) World.config.carBraking = v; if World.config.carSpeedEnabled then applyCarModifications() end end
function World.setCarSteeringReduction(v) World.config.carSteeringReduction = v / 100; if World.config.carSpeedEnabled then applyCarModifications() end end
function World.setCarStaticFriction(v) World.config.carStaticFriction = v; if World.config.carSpeedEnabled then applyCarModifications() end end
function World.setCarKineticFriction(v) World.config.carKineticFriction = v; if World.config.carSpeedEnabled then applyCarModifications() end end
function World.setCarSlipThreshold(v) World.config.carSlipThreshold = v; if World.config.carSpeedEnabled then applyCarModifications() end end

-- ========== ZOMBIE EXPANDER ==========
local function restoreZombieHead(model)
    if not model then return end
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        local originalSize = World.originalZombieHeads[model]
        if originalSize then
            head.Size = originalSize
        else
            head.Size = Vector3.new(2, 2, 2)
        end
        head.Transparency = 0
        head.CanCollide = true
    end
end

local function saveOriginalZombieSize(model)
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") and not World.originalZombieHeads[model] then
        World.originalZombieHeads[model] = head.Size
    end
end

local function shouldIgnoreZombie(model)
    if model:FindFirstChild("Scripts") and model:FindFirstChild("Scripts"):IsA("Folder") then return true end
    if model:FindFirstChild("ServerCollider") and model:FindFirstChild("ServerCollider"):IsA("BasePart") then return true end
    return false
end

local function expandZombieHitbox(model)
    if not World.config.zombieExpanderEnabled then 
        restoreZombieHead(model)
        return 
    end
    if shouldIgnoreZombie(model) then return end
    
    saveOriginalZombieSize(model)
    
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        head.Size = Vector3.new(World.config.zombieHitboxSize, World.config.zombieHitboxSize, World.config.zombieHitboxSize)
        head.Transparency = World.config.zombieHeadTransparency
        head.CanCollide = false
        head.Massless = true
    end
end

local function setupZombieExpander()
    if not World.zombieEntitiesFolder then
        local success, result = pcall(function() return Workspace:WaitForChild("game_assets"):WaitForChild("Entities") end)
        if success then World.zombieEntitiesFolder = result else return end
    end
    
    for _, v in pairs(World.zombieEntitiesFolder:GetChildren()) do
        if v:IsA("Model") then
            saveOriginalZombieSize(v)
            if World.config.zombieExpanderEnabled then
                expandZombieHitbox(v)
            end
        end
    end
    
    World.zombieEntitiesFolder.ChildAdded:Connect(function(v)
        if v:IsA("Model") then
            task.wait(0.2)
            saveOriginalZombieSize(v)
            if World.config.zombieExpanderEnabled then
                expandZombieHitbox(v)
            end
        end
    end)
end

local function startZombieExpanderLoop()
    if World.zombieExpanderLoop then task.cancel(World.zombieExpanderLoop); World.zombieExpanderLoop = nil end
    
    World.zombieExpanderLoop = task.spawn(function()
        while true do
            if World.zombieEntitiesFolder then
                for _, v in pairs(World.zombieEntitiesFolder:GetChildren()) do
                    if v:IsA("Model") and not shouldIgnoreZombie(v) then
                        if World.config.zombieExpanderEnabled then
                            expandZombieHitbox(v)
                        else
                            restoreZombieHead(v)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

function World.setZombieExpander(v)
    World.config.zombieExpanderEnabled = v
    if v then 
        pcall(setupZombieExpander)
        startZombieExpanderLoop()
    elseif World.zombieEntitiesFolder then
        for _, v in pairs(World.zombieEntitiesFolder:GetChildren()) do
            if v:IsA("Model") then restoreZombieHead(v) end
        end
    end
end

function World.setZombieHitboxSize(v) 
    World.config.zombieHitboxSize = v
    if World.config.zombieExpanderEnabled then startZombieExpanderLoop() end
end

function World.setZombieHeadTransparency(v)
    World.config.zombieHeadTransparency = v
    if World.config.zombieExpanderEnabled then startZombieExpanderLoop() end
end

-- ========== NO INVENTORY BLUR ==========
local function startNoInventoryBlurLoop()
    if World.noInventoryBlurLoop then task.cancel(World.noInventoryBlurLoop); World.noInventoryBlurLoop = nil end
    if World.config.noInventoryBlurEnabled then
        World.noInventoryBlurLoop = task.spawn(function()
            while World.config.noInventoryBlurEnabled do
                local cam = workspace.CurrentCamera
                local blur = cam and cam:FindFirstChild("Blur")
                if blur then blur.Enabled = false end
                task.wait(0.5)
            end
        end)
    end
end

function World.setNoInventoryBlur(v)
    World.config.noInventoryBlurEnabled = v
    if v then 
        startNoInventoryBlurLoop()
    else
        if World.noInventoryBlurLoop then task.cancel(World.noInventoryBlurLoop); World.noInventoryBlurLoop = nil end
        local cam = workspace.CurrentCamera
        local blur = cam and cam:FindFirstChild("Blur")
        if blur then blur.Enabled = true end
    end
end

-- ========== NO CAR DAMAGE ==========
local function startNoCarDamageLoop()
    if World.noCarDamageLoop then task.cancel(World.noCarDamageLoop); World.noCarDamageLoop = nil end
    World.noCarDamageLoop = task.spawn(function()
        while true do
            for _, child in ipairs(Workspace:GetDescendants()) do 
                if child.Name == "Impact" then pcall(function() child:Destroy() end) end
            end
            task.wait(1)
        end
    end)
end

function World.toggleNoCarDamage()
    if World.noCarDamageLoop then 
        task.cancel(World.noCarDamageLoop)
        World.noCarDamageLoop = nil
    else 
        startNoCarDamageLoop()
    end
end

-- ========== REMOVE GRASS ==========
function World.setRemoveGrass(v)
    World.config.removeGrassEnabled = v
    pcall(function() 
        sethiddenproperty(Workspace.Terrain, "Decoration", not v)
    end)
end

-- ========== NO TREE ==========
function World.setNoTree(v)
    World.config.noTreeEnabled = v
    if v then
        local lastCheck = 0
        local cache = {}
        World.noTreeConnection = RunService.Heartbeat:Connect(function()
            local now = tick()
            if now - lastCheck > 5 or #cache == 0 then
                lastCheck = now
                cache = {}
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") and (part.Name == "Leaves" or part.Name == "Tree") then 
                        table.insert(cache, part) 
                    end
                end
                for _, part in ipairs(cache) do 
                    part.Transparency = 1
                    part.CanCollide = false
                    part.Anchored = true
                end
            end
        end)
    else
        if World.noTreeConnection then 
            World.noTreeConnection:Disconnect()
            World.noTreeConnection = nil 
        end
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name == "Leaves" or part.Name == "Tree") then 
                part.Transparency = 0
                part.CanCollide = true 
            end
        end
    end
end

return World
