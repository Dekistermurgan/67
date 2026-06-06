-- MÓDULO: MOUSE AIMBOT (COMPLETO)
local MouseAimbot = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace

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

local gameObjects = {
    entitiesfolder = nil,
    targetVelocities = {}
}

-- FOV Shapes
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
    if not MouseAimbot.config.showFOV or not Workspace.CurrentCamera then return end

    local cam = Workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local color = MouseAimbot.config.fovRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or MouseAimbot.config.fovColor
    local radius = MouseAimbot.config.fovRadius
    local thickness = MouseAimbot.config.fovThickness

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

function MouseAimbot.setFOVShape(v) 
    currentFOVShape = v
    if MouseAimbot.config.showFOV then 
        updateFOVShape(v, MouseAimbot.fovSpinAngle)
    end
end

function MouseAimbot.setFOVSpin(v)
    MouseAimbot.config.fovSpin = v
    if MouseAimbot.config.showFOV then
        updateFOVShape(currentFOVShape, MouseAimbot.fovSpinAngle)
    end
end

function MouseAimbot.setFOVSpinSpeed(v) MouseAimbot.config.fovSpinSpeed = v end
function MouseAimbot.setFOVColor(v) MouseAimbot.config.fovColor = v; if MouseAimbot.config.showFOV then updateFOVShape(currentFOVShape, MouseAimbot.fovSpinAngle) end end
function MouseAimbot.setFOVRainbow(v) MouseAimbot.config.fovRainbow = v end

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

local function worldToScreen(pos)
    local cam = Workspace.CurrentCamera
    if not cam then return Vector2.new(0, 0), false end
    local pt, onScreen = cam:WorldToViewportPoint(pos)
    return Vector2.new(pt.X, pt.Y), onScreen
end

local function IsEntityAlive(entity)
    if not entity or not entity:IsA("Model") then return false end
    return entity:FindFirstChild("UpperTorso") ~= nil
end

local function GetPlayerFromEntity(entity)
    local custommeshcharacter = gameObjects.custommeshcharacter
    local playerlist = gameObjects.playerlist
    if not custommeshcharacter or not playerlist then return nil end
    local char = custommeshcharacter:GetCharacterFromWorldCharacter(entity)
    if not char then return nil end
    local playerdata = playerlist:GetPlayerFromCharacter(char)
    if playerdata and playerdata.Name then return Players:FindFirstChild(playerdata.Name) end
    return nil
end

function MouseAimbot.updateAimbot(center)
    if not MouseAimbot.config.enabled or not MouseAimbot.config.aiming then return end
    
    local weaponConfig = MouseAimbot.getCurrentWeaponConfig()
    if not weaponConfig then return end
    
    local bestPos = nil
    local bestDist = math.huge
    local cam = Workspace.CurrentCamera
    local entities = gameObjects.entitiesfolder
    
    if not entities then return end
    
    for _, entity in pairs(entities:GetChildren()) do
        if not entity:IsA("Model") or not IsEntityAlive(entity) then continue end
        
        local player = GetPlayerFromEntity(entity)
        if not player or player == LocalPlayer then continue end
        
        local hitPart = entity:FindFirstChild(MouseAimbot.config.hitPart) or 
                       entity:FindFirstChild("Head") or 
                       entity:FindFirstChild("UpperTorso")
        if not hitPart then continue end
        
        local distance = (hitPart.Position - cam.CFrame.Position).Magnitude
        local predicted = MouseAimbot.predictPosition(hitPart, weaponConfig, distance)
        local screenPos, onScreen = worldToScreen(predicted)
        
        if onScreen then
            local distToCenter = (screenPos - center).Magnitude
            if distToCenter <= MouseAimbot.config.fovRadius and distToCenter < bestDist then
                bestDist = distToCenter
                bestPos = predicted
            end
        end
    end
    
    if bestPos then
        local screenPos, onScreen = worldToScreen(bestPos)
        if onScreen then
            local delta = screenPos - center
            if delta.Magnitude > 0.5 then
                mousemoverel(delta.X * MouseAimbot.config.smoothing, delta.Y * MouseAimbot.config.smoothing)
            end
        end
    end
end

local function updateFOVSpin()
    if MouseAimbot.config.fovSpin then
        local now = tick()
        local delta = now - MouseAimbot.lastSpinUpdate
        MouseAimbot.lastSpinUpdate = now
        MouseAimbot.fovSpinAngle = MouseAimbot.fovSpinAngle + math.rad(MouseAimbot.config.fovSpinSpeed * delta)
        if MouseAimbot.fovSpinAngle > 2 * math.pi then
            MouseAimbot.fovSpinAngle = MouseAimbot.fovSpinAngle - 2 * math.pi
        end
    else
        MouseAimbot.fovSpinAngle = 0
    end
end

local function updateFOVVisual()
    if not MouseAimbot.config.showFOV or not fovShapeObjects.current then return end
    
    local cam = Workspace.CurrentCamera
    if not cam then return end
    
    local t = tick()
    local color = MouseAimbot.config.fovRainbow and Color3.fromHSV(t % 5 / 5, 1, 1) or MouseAimbot.config.fovColor
    
    if type(fovShapeObjects.current) == "table" then
        if MouseAimbot.config.fovSpin and currentFOVShape ~= "Circle" then
            updateFOVShape(currentFOVShape, MouseAimbot.fovSpinAngle)
        else
            for _, obj in pairs(fovShapeObjects.current) do
                if obj then 
                    obj.Color = color
                    obj.Thickness = MouseAimbot.config.fovThickness
                end
            end
            if currentFOVShape ~= "Circle" and fovShapeObjects.current[1] then
                local angle = MouseAimbot.config.fovSpin and MouseAimbot.fovSpinAngle or 0
                updateFOVShape(currentFOVShape, angle)
            end
        end
    else
        if fovShapeObjects.current then
            fovShapeObjects.current.Color = color
            fovShapeObjects.current.Thickness = MouseAimbot.config.fovThickness
        end
        if currentFOVShape == "Circle" and fovShapeObjects.current then
            local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            fovShapeObjects.current.Position = center
            fovShapeObjects.current.Radius = MouseAimbot.config.fovRadius
        end
    end
end

function MouseAimbot.setupRenderLoop()
    RunService.RenderStepped:Connect(function()
        updateFOVSpin()
        updateFOVVisual()
        
        local cam = Workspace.CurrentCamera
        if cam then
            local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            MouseAimbot.updateAimbot(center)
        end
    end)
end

function MouseAimbot.setEnabled(v) MouseAimbot.config.enabled = v end
function MouseAimbot.setFOVVisible(v) 
    MouseAimbot.config.showFOV = v
    if v then updateFOVShape(currentFOVShape, MouseAimbot.fovSpinAngle)
    elseif fovShapeObjects.current then 
        pcall(function() 
            if type(fovShapeObjects.current) == "table" then
                for _, obj in pairs(fovShapeObjects.current) do obj.Visible = false end
            else fovShapeObjects.current.Visible = false end
        end) 
    end 
end
function MouseAimbot.setFOVRadius(v) MouseAimbot.config.fovRadius = v; if MouseAimbot.config.showFOV then updateFOVShape(currentFOVShape, MouseAimbot.fovSpinAngle) end end
function MouseAimbot.setFOVThickness(v) MouseAimbot.config.fovThickness = v; if MouseAimbot.config.showFOV then updateFOVShape(currentFOVShape, MouseAimbot.fovSpinAngle) end end
function MouseAimbot.setSmoothing(v) MouseAimbot.config.smoothing = v / 100 end
function MouseAimbot.setPredictionX(v) MouseAimbot.config.predictionX = v / 100 end
function MouseAimbot.setBulletDropFactor(v) MouseAimbot.config.bulletDropFactor = v / 100 end
function MouseAimbot.setVerticalOffset(v) MouseAimbot.config.verticalOffset = v end
function MouseAimbot.setHitPart(v) MouseAimbot.config.hitPart = v end
function MouseAimbot.setKeybind(key) MouseAimbot.config.keybind = key end
function MouseAimbot.setAiming(v) MouseAimbot.config.aiming = v end

function MouseAimbot.setCustomMeshCharacter(obj) gameObjects.custommeshcharacter = obj end
function MouseAimbot.setPlayerList(obj) gameObjects.playerlist = obj end

MouseAimbot.setupRenderLoop()

return MouseAimbot
