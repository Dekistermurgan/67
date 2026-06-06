-- MÓDULO: MOUSE AIMBOT
local MouseAimbot = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configurações
MouseAimbot.config = {
    enabled = false,
    showFOV = false,
    fovRadius = 200,
    fovThickness = 2,
    smoothing = 0.5,
    fovColor = Color3.fromRGB(255, 255, 255),
    fovRainbow = false,
    fovShape = "Circle",
    fovSpin = false,
    fovSpinSpeed = 45,
    keybind = Enum.UserInputType.MouseButton2,
    aiming = false,
    predictionX = 0.2,
    bulletDropFactor = 1.0,
    verticalOffset = 0,
    hitPart = "Head"
}

MouseAimbot.fovSpinAngle = 0
MouseAimbot.lastSpinUpdate = tick()
MouseAimbot.currentWeaponCache = nil
MouseAimbot.lastWeaponCheck = 0

-- Variáveis do jogo
local gameObjects = {
    entitiesfolder = nil,
    targetVelocities = {}
}

-- Funções auxiliares
local function getCurrentWeapon()
    local cam = workspace.Camera
    if not cam then return nil end
    local currentWeaponObj = cam:FindFirstChild("CurrentWeapon")
    if not currentWeaponObj then return nil end
    local pointer = currentWeaponObj:FindFirstChild("Pointer")
    if pointer and pointer:IsA("ObjectValue") and pointer.Value then
        return pointer.Value
    end
    return nil
end

local function getNumberValue(instance)
    if not instance then return nil end
    if instance:IsA("NumberValue") or instance:IsA("IntValue") then
        return instance.Value
    end
    return tonumber(instance.Value)
end

local function getWeaponBulletSettings(weaponName)
    local gunSystem = ReplicatedStorage:FindFirstChild("GunSystemAssets")
    if not gunSystem then return nil end
    local gunData = gunSystem:FindFirstChild("GunData")
    if not gunData then return nil end

    local weaponFolder = gunData:FindFirstChild(weaponName)
    if not weaponFolder then return nil end

    local stats = weaponFolder:FindFirstChild("Stats")
    if not stats then return nil end
    local bulletSettings = stats:FindFirstChild("BulletSettings")
    if not bulletSettings then return nil end

    local speedObj = bulletSettings:FindFirstChild("BulletSpeed")
    local gravityObj = bulletSettings:FindFirstChild("BulletGravity")

    local bulletSpeed = getNumberValue(speedObj) or 2500
    local bulletGravity = getNumberValue(gravityObj) or 196.2

    return { BulletSpeed = bulletSpeed, BulletGravity = bulletGravity }
end

function MouseAimbot.getCurrentWeaponConfig()
    local now = tick()
    if now - MouseAimbot.lastWeaponCheck > 0.3 then
        local weapon = getCurrentWeapon()
        if weapon then
            MouseAimbot.currentWeaponCache = getWeaponBulletSettings(weapon.Name)
        else
            MouseAimbot.currentWeaponCache = nil
        end
        MouseAimbot.lastWeaponCheck = now
    end
    return MouseAimbot.currentWeaponCache
end

local function getTargetVelocity(part)
    if not part then return Vector3.zero end
    local now = tick()
    local data = gameObjects.targetVelocities[part]
    if data then
        local delta = now - data.time
        if delta > 0 and delta < 0.2 then
            local vel = (part.Position - data.pos) / delta
            if vel.Magnitude > 80 then vel = vel.Unit * 80 end
            data.pos = part.Position
            data.time = now
            data.vel = vel
            return vel
        end
    end
    gameObjects.targetVelocities[part] = { pos = part.Position, time = now, vel = Vector3.zero }
    return Vector3.zero
end

local function calculateBulletDrop(distance, bulletSpeed, gravity)
    local travelTime = distance / bulletSpeed
    local drop = 0.5 * gravity * travelTime * travelTime
    return drop
end

function MouseAimbot.predictPosition(targetPart, weaponConfig, distance)
    if not targetPart then return targetPart and targetPart.Position end

    local bulletSpeed = (weaponConfig and weaponConfig.BulletSpeed) or 2500
    local gravity = (weaponConfig and weaponConfig.BulletGravity) or 196.2

    local travelTime = distance / bulletSpeed
    local predTime = travelTime + MouseAimbot.config.predictionX
    local targetVel = getTargetVelocity(targetPart)
    local predictedPos = targetPart.Position + (targetVel * predTime)

    local drop = calculateBulletDrop(distance, bulletSpeed, gravity)
    drop = drop * MouseAimbot.config.bulletDropFactor
    predictedPos = predictedPos + Vector3.new(0, drop, 0)
    predictedPos = predictedPos + Vector3.new(0, MouseAimbot.config.verticalOffset, 0)

    return predictedPos
end

function MouseAimbot.setEntitiesFolder(folder)
    gameObjects.entitiesfolder = folder
end

-- Callbacks
function MouseAimbot.setEnabled(v) MouseAimbot.config.enabled = v end
function MouseAimbot.setFOVVisible(v) MouseAimbot.config.showFOV = v end
function MouseAimbot.setFOVRadius(v) MouseAimbot.config.fovRadius = v end
function MouseAimbot.setFOVThickness(v) MouseAimbot.config.fovThickness = v end
function MouseAimbot.setSmoothing(v) MouseAimbot.config.smoothing = v / 100 end
function MouseAimbot.setPredictionX(v) MouseAimbot.config.predictionX = v / 100 end
function MouseAimbot.setBulletDropFactor(v) MouseAimbot.config.bulletDropFactor = v / 100 end
function MouseAimbot.setVerticalOffset(v) MouseAimbot.config.verticalOffset = v end
function MouseAimbot.setHitPart(v) MouseAimbot.config.hitPart = v end
function MouseAimbot.setKeybind(key) MouseAimbot.config.keybind = key end
function MouseAimbot.setAiming(v) MouseAimbot.config.aiming = v end

return MouseAimbot
