-- MÓDULO 4: MOUSE AIMBOT
local Aimbot = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace
local CurrentCamera = workspace.CurrentCamera

_G.gameObjects.aimbot = {
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
_G.gameObjects.fovSpinAngle = 0
_G.gameObjects.lastSpinUpdate = tick()
_G.gameObjects.currentWeaponCache = nil
_G.gameObjects.lastWeaponCheck = 0

local fovShapeObjects = {}
local currentFOVShape = "Circle"

local function rotatePoint(center, point, angle)
    local dx = point.X - center.X
    local dy = point.Y - center.Y
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    return Vector2.new(center.X + dx * cos - dy * sin, center.Y + dx * sin + dy * cos)
end

local function drawRotatedRegularPolygon(center, radius, thickness, color, numPoints, angle)
    local points = {}
    for i = 1, numPoints do
        local theta = -math.pi / 2 + (i - 1) * 2 * math.pi / numPoints
        local x = center.X + math.cos(theta) * radius
        local y = center.Y + math.sin(theta) * radius
        table.insert(points, Vector2.new(x, y))
    end
    if angle and angle ~= 0 then
        for i = 1, numPoints do
            points[i] = rotatePoint(center, points[i], angle)
        end
    end
    local lines = {}
    for i = 1, numPoints do
        local line = Drawing.new("Line")
        line.From = points[i]
        line.To = points[i % numPoints + 1]
        line.Thickness = thickness
        line.Color = color
        line.Transparency = 1
        line.Visible = true
        table.insert(lines, line)
    end
    return lines
end

local function drawRotatedStarOfDavid(center, radius, thickness, color, angle)
    local tri1Points = {}
    local tri2Points = {}
    for i = 1, 3 do
        local theta = -math.pi / 2 + (i - 1) * 2 * math.pi / 3
        local x = center.X + math.cos(theta) * radius
        local y = center.Y + math.sin(theta) * radius
        table.insert(tri1Points, Vector2.new(x, y))
    end
    for i = 1, 3 do
        local theta = -math.pi / 2 + math.pi / 3 + (i - 1) * 2 * math.pi / 3
        local x = center.X + math.cos(theta) * radius
        local y = center.Y + math.sin(theta) * radius
        table.insert(tri2Points, Vector2.new(x, y))
    end
    if angle and angle ~= 0 then
        for i = 1, 3 do
            tri1Points[i] = rotatePoint(center, tri1Points[i], angle)
            tri2Points[i] = rotatePoint(center, tri2Points[i], angle)
        end
    end
    local lines = {}
    for i = 1, 3 do
        local line1 = Drawing.new("Line")
        line1.From = tri1Points[i]
        line1.To = tri1Points[i % 3 + 1]
        line1.Thickness = thickness
        line1.Color = color
        line1.Transparency = 1
        line1.Visible = true
        table.insert(lines, line1)
        local line2 = Drawing.new("Line")
        line2.From = tri2Points[i]
        line2.To = tri2Points[i % 3 + 1]
        line2.Thickness = thickness
        line2.Color = color
        line2.Transparency = 1
        line2.Visible = true
        table.insert(lines, line2)
    end
    return lines
end

local function updateFOVShape(shape, spinAngle)
    if fovShapeObjects.current then
        if type(fovShapeObjects.current) == "table" then
            for _, obj in pairs(fovShapeObjects.current) do pcall(function() obj:Remove() end) end
        else
            pcall(function() fovShapeObjects.current:Remove() end)
        end
        fovShapeObjects.current = nil
    end
    if not _G.gameObjects.aimbot.showFOV then return end

    local center = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    local color = _G.gameObjects.aimbot.fovRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or _G.gameObjects.aimbot.fovColor
    local radius = _G.gameObjects.aimbot.fovRadius
    local thickness = _G.gameObjects.aimbot.fovThickness

    if shape == "Circle" then
        local circle = Drawing.new("Circle")
        circle.Radius = radius
        circle.Thickness = thickness
        circle.NumSides = 64
        circle.Color = color
        circle.Transparency = 1
        circle.Filled = false
        circle.Position = center
        circle.Visible = true
        fovShapeObjects.current = circle
    elseif shape == "Triangle" then
        fovShapeObjects.current = drawRotatedRegularPolygon(center, radius, thickness, color, 3, spinAngle or 0)
    elseif shape == "Star of David" then
        fovShapeObjects.current = drawRotatedStarOfDavid(center, radius, thickness, color, spinAngle or 0)
    elseif shape == "Pentagon" then
        fovShapeObjects.current = drawRotatedRegularPolygon(center, radius, thickness, color, 5, spinAngle or 0)
    elseif shape == "Hexagon" then
        fovShapeObjects.current = drawRotatedRegularPolygon(center, radius, thickness, color, 6, spinAngle or 0)
    end
end

function Aimbot.setFOVShape(v)
    currentFOVShape = v
    if _G.gameObjects.aimbot.showFOV then updateFOVShape(v, _G.gameObjects.fovSpinAngle) end
end
function Aimbot.setFOVSpin(v) _G.gameObjects.aimbot.fovSpin = v; if _G.gameObjects.aimbot.showFOV then updateFOVShape(currentFOVShape, _G.gameObjects.fovSpinAngle) end end
function Aimbot.setFOVSpinSpeed(v) _G.gameObjects.aimbot.fovSpinSpeed = v end
function Aimbot.setFOVColor(v) _G.gameObjects.aimbot.fovColor = v; if _G.gameObjects.aimbot.showFOV then updateFOVShape(currentFOVShape, _G.gameObjects.fovSpinAngle) end end
function Aimbot.setFOVRainbow(v) _G.gameObjects.aimbot.fovRainbow = v end
function Aimbot.setFOVVisible(v) _G.gameObjects.aimbot.showFOV = v; if v then updateFOVShape(currentFOVShape, _G.gameObjects.fovSpinAngle) end end
function Aimbot.setFOVRadius(v) _G.gameObjects.aimbot.fovRadius = v; if _G.gameObjects.aimbot.showFOV then updateFOVShape(currentFOVShape, _G.gameObjects.fovSpinAngle) end end
function Aimbot.setFOVThickness(v) _G.gameObjects.aimbot.fovThickness = v; if _G.gameObjects.aimbot.showFOV then updateFOVShape(currentFOVShape, _G.gameObjects.fovSpinAngle) end end

local function getCurrentWeapon()
    local cam = Workspace.Camera
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

function Aimbot.getCurrentWeaponConfig()
    local now = tick()
    if now - _G.gameObjects.lastWeaponCheck > 0.3 then
        local weapon = getCurrentWeapon()
        if weapon then
            _G.gameObjects.currentWeaponCache = getWeaponBulletSettings(weapon.Name)
        else
            _G.gameObjects.currentWeaponCache = nil
        end
        _G.gameObjects.lastWeaponCheck = now
    end
    return _G.gameObjects.currentWeaponCache
end

local function getTargetVelocity(part)
    if not part then return Vector3.zero end
    local now = tick()
    local data = _G.gameObjects.targetVelocities[part]
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
    _G.gameObjects.targetVelocities[part] = { pos = part.Position, time = now, vel = Vector3.zero }
    return Vector3.zero
end

local function calculateBulletDrop(distance, bulletSpeed, gravity)
    local travelTime = distance / bulletSpeed
    local drop = 0.5 * gravity * travelTime * travelTime
    return drop
end

function Aimbot.predictPosition(targetPart, weaponConfig, distance)
    if not targetPart then return targetPart and targetPart.Position end

    local bulletSpeed = (weaponConfig and weaponConfig.BulletSpeed) or 2500
    local gravity = (weaponConfig and weaponConfig.BulletGravity) or 196.2

    local travelTime = distance / bulletSpeed
    local predTime = travelTime + _G.gameObjects.aimbot.predictionX
    local targetVel = getTargetVelocity(targetPart)
    local predictedPos = targetPart.Position + (targetVel * predTime)

    local drop = calculateBulletDrop(distance, bulletSpeed, gravity)
    drop = drop * _G.gameObjects.aimbot.bulletDropFactor
    predictedPos = predictedPos + Vector3.new(0, drop, 0)
    predictedPos = predictedPos + Vector3.new(0, _G.gameObjects.aimbot.verticalOffset, 0)

    return predictedPos
end

local function GetPlayerFromEntity(entity)
    if not entity then return nil end
    local char = _G.gameObjects.custommeshcharacter:GetCharacterFromWorldCharacter(entity)
    if not char then return nil end
    local playerdata = _G.gameObjects.playerlist:GetPlayerFromCharacter(char)
    if playerdata and playerdata.Name then return Players:FindFirstChild(playerdata.Name) end
    return nil
end

local function IsEntityAlive(entity)
    if not entity or not entity:IsA("Model") then return false end
    return entity:FindFirstChild("UpperTorso") ~= nil
end

local function worldToScreen(pos)
    local pt, onScreen = CurrentCamera:WorldToViewportPoint(pos)
    return Vector2.new(pt.X, pt.Y), onScreen
end

function Aimbot.update()
    if not _G.gameObjects.aimbot.enabled or not _G.gameObjects.aimbot.aiming then return end
    
    local weaponConfig = Aimbot.getCurrentWeaponConfig()
    if not weaponConfig then return end
    
    local bestTargetPos = nil
    local bestDistance = math.huge
    local center = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    local entitiesFolder = _G.gameObjects.entitiesfolder

    for _, entity in pairs(entitiesFolder:GetChildren()) do
        if entity:IsA("Model") and IsEntityAlive(entity) then
            local player = GetPlayerFromEntity(entity)
            if player and player ~= LocalPlayer then
                local hitPart = entity:FindFirstChild(_G.gameObjects.aimbot.hitPart) or entity:FindFirstChild("Head") or entity:FindFirstChild("UpperTorso")
                if hitPart then
                    local distance = (hitPart.Position - CurrentCamera.CFrame.Position).Magnitude
                    local predicted = Aimbot.predictPosition(hitPart, weaponConfig, distance)
                    local screenPos, onScreen = worldToScreen(predicted)
                    if onScreen then
                        local distToCenter = (screenPos - center).Magnitude
                        if distToCenter <= _G.gameObjects.aimbot.fovRadius and distToCenter < bestDistance then
                            bestDistance = distToCenter
                            bestTargetPos = predicted
                        end
                    end
                end
            end
        end
    end

    if bestTargetPos then
        local screenPos, onScreen = worldToScreen(bestTargetPos)
        if onScreen then
            local delta = screenPos - center
            if delta.Magnitude > 0.5 then
                mousemoverel(delta.X * _G.gameObjects.aimbot.smoothing, delta.Y * _G.gameObjects.aimbot.smoothing)
            end
        end
    end
end

function Aimbot.setEnabled(v) _G.gameObjects.aimbot.enabled = v end
function Aimbot.setSmoothing(v) _G.gameObjects.aimbot.smoothing = v / 100 end
function Aimbot.setPredictionX(v) _G.gameObjects.aimbot.predictionX = v / 100 end
function Aimbot.setBulletDropFactor(v) _G.gameObjects.aimbot.bulletDropFactor = v / 100 end
function Aimbot.setVerticalOffset(v) _G.gameObjects.aimbot.verticalOffset = v end
function Aimbot.setHitPart(v) _G.gameObjects.aimbot.hitPart = v end
function Aimbot.setKeybind(key) _G.gameObjects.aimbot.keybind = key end
function Aimbot.setAiming(v) _G.gameObjects.aimbot.aiming = v end

return Aimbot
