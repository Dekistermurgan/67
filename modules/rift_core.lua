-- ============================================
-- RIFT CORE (ESSENCIAL)
-- ESP, Aimbot, Silent Aim, Fly, Anti-Aim, Spinbot, Chams
-- ============================================
local Core = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lighting = game:GetService("Lighting")
local Workspace = workspace
local CoreGui = game:GetService("CoreGui")
local CurrentCamera = workspace.CurrentCamera

-- ========== VARIÁVEIS GLOBAIS ==========
local gameObjects = {}
gameObjects.ESPs = {}
gameObjects.targetVelocities = {}
gameObjects.flyKeys = { Forward = false, Backward = false, Left = false, Right = false, Up = false, Down = false }

-- Inicializa dependências
pcall(function()
    gameObjects.custommeshcharacter = require(game.ReplicatedFirst:WaitForChild("GunSystemPlugins"):WaitForChild("CustomMeshCharacter"))
end)
pcall(function()
    gameObjects.playerlist = require(game.ReplicatedStorage:WaitForChild("CustomCharacter"):WaitForChild("PlayerList"))
end)
gameObjects.gameassets = workspace:FindFirstChild("game_assets")
gameObjects.entitiesfolder = gameObjects.gameassets and gameObjects.gameassets:FindFirstChild("Entities") or workspace

-- ========== CONFIGURAÇÕES ESP ==========
gameObjects.ESPEnabled = false
gameObjects.boxEnabled = false
gameObjects.boxFilledEnabled = false
gameObjects.boxOutlineEnabled = false
gameObjects.nameEnabled = false
gameObjects.distanceEnabled = false
gameObjects.skeletonEnabled = false
gameObjects.boxColor = Color3.fromRGB(255, 255, 255)
gameObjects.boxOutlineColor = Color3.fromRGB(0, 0, 0)
gameObjects.nameColor = Color3.fromRGB(255, 255, 255)
gameObjects.distanceColor = Color3.fromRGB(255, 255, 255)
gameObjects.skeletonColor = Color3.fromRGB(255, 255, 255)
gameObjects.maxESPDistance = 1000

-- ========== ANTI-AIM ==========
gameObjects.antiAimEnabled = false
gameObjects.antiAimMode = "Up"
gameObjects.antiAimPitch = 0
gameObjects.antiAimYaw = 0
gameObjects.antiAimRandomSpeed = 0.5
gameObjects.antiAimRandomLast = "Up"
gameObjects.antiAimRandomTimer = 0

-- ========== SPINBOT ==========
gameObjects.spinbotEnabled = false
gameObjects.spinbotYawAngle = 0
gameObjects.spinbotYawSpeed = 5
gameObjects.spinbotConnection1 = nil
gameObjects.spinbotConnection2 = nil
gameObjects.spinbotController = nil

-- ========== FLY ==========
gameObjects.flyEnabled = false
gameObjects.flySpeed = 50
gameObjects.flyConnection = nil

-- ========== LIGHTING ==========
gameObjects.fullbrightEnabled = false
gameObjects.noFogEnabled = false
gameObjects.timeEnabled = false
gameObjects.timeValue = 12

-- ========== CHAMS ==========
gameObjects.selfChamsEnabled = false
gameObjects.selfChamsColor = Color3.fromRGB(128, 0, 128)
gameObjects.selfChamsMaterial = Enum.Material.ForceField
gameObjects.selfChamsTransparency = 0.2
gameObjects.selfChamsHeadTransparency = 1
gameObjects.selfChamsUpdater = nil
gameObjects.selfChamsCharacter = nil

gameObjects.armChamsEnabled = false
gameObjects.armChamsColor = Color3.fromRGB(255, 255, 255)
gameObjects.armChamsMaterial = Enum.Material.ForceField
gameObjects.armChamsConnections = {}
gameObjects.armChamsUpdater = nil

gameObjects.weaponChamsEnabled = false
gameObjects.weaponChamsColor = Color3.fromRGB(244, 224, 155)
gameObjects.weaponChamsMaterial = Enum.Material.ForceField

gameObjects.longNeckEnabled = false
gameObjects.longNeckHeight = 5
gameObjects.gunplugin = nil

-- ========== AIMBOT ==========
gameObjects.aimbot = {
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
gameObjects.fovSpinAngle = 0
gameObjects.lastSpinUpdate = tick()
gameObjects.currentWeaponCache = nil
gameObjects.lastWeaponCheck = 0

-- ========== SILENT AIM ==========
local silentAimFlags = {
    SilentEnabled = false,
    TeamCheck = true,
    FovSize = 200,
    AimPart = "Head",
    NoSpread = false,
    ResolveY = false,
    InstantBullet = false
}
local prediction_mode = "axal"

local gundata = ReplicatedStorage:FindFirstChild("GunSystemAssets") and ReplicatedStorage.GunSystemAssets:FindFirstChild("GunData")
local sv_config = ReplicatedStorage:FindFirstChild("CustomCharacterConfigs") and ReplicatedStorage.CustomCharacterConfigs:FindFirstChild("Configuration") and ReplicatedStorage.CustomCharacterConfigs.Configuration:FindFirstChild("Server")

local silentFovCircle = Drawing.new("Circle")
silentFovCircle.Visible = false
silentFovCircle.Color = Color3.fromRGB(255, 0, 0)
silentFovCircle.Thickness = 2
silentFovCircle.NumSides = 30
silentFovCircle.Radius = silentAimFlags.FovSize
silentFovCircle.Transparency = 1
silentFovCircle.Filled = false

RunService.Heartbeat:Connect(function()
    local cam = workspace.CurrentCamera
    if cam and silentFovCircle.Visible then
        silentFovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    end
end)

local function get_current_gun(plr)
    if not plr then return "Fists" end
    local c = plr:FindFirstChild("CurrentSelectedObject")
    c = c and c.Value
    c = c and c.Value
    return c and c.Name or "Fists"
end

local silentEntitylist = nil
for _, gc in ipairs(getgc(true)) do
    if type(gc) == "table" then
        local gpfwc = rawget(gc, "GetPlayerFromWorldCharacter")
        if gpfwc and type(gpfwc) == "function" then
            local upvs = getupvalues(gpfwc)
            local GetCharacters = upvs[2] and upvs[2].GetCharacters
            if GetCharacters and type(GetCharacters) == "function" then
                silentEntitylist = getupvalues(GetCharacters)[1]
                break
            end
        end
    end
end

local function predict_axal(origin, pos, vel, speed, drop)
    local dist = (origin - pos).Magnitude
    local t = dist / speed
    local p = pos + vel * t
    t = t + (p - pos).Magnitude / speed
    return p + Vector3.new(0, drop * t * t, 0)
end

local function predict_priv9(origin, pos, vel, speed, drop)
    local dist = (origin - pos).Magnitude
    local t = dist / speed
    return pos + (vel * t) + Vector3.new(0, drop * t * t, 0)
end

local function get_closest_target_silent(fov_size, aimpart, team_check)
    local best_part, best_player, best_root
    local max_distance = fov_size
    local mousepos = UserInputService:GetMouseLocation()
    
    if not silentEntitylist then return nil, nil, nil end
    
    for userid, v in pairs(silentEntitylist) do
        local player = v.Player
        if not player then continue end
        if team_check and player.Team == LocalPlayer.Team then continue end
        if player == LocalPlayer then continue end
        
        local root = v.RootPart
        local worldmodel = v.WorldModel
        local character = v.Character
        
        if not (root and worldmodel and character) then continue end
        
        local part = worldmodel:FindFirstChild(aimpart)
        if not part then continue end
        
        local position, onscreen = CurrentCamera:WorldToViewportPoint(part.Position)
        if not onscreen then continue end
        
        local distance = (Vector2.new(position.X, position.Y) - mousepos).Magnitude
        
        if distance <= max_distance then
            best_player = player
            best_part = part
            best_root = root
            max_distance = distance
        end
    end
    
    return best_part, best_player, best_root
end

local function full_prediction_silent(target_position, target_collider)
    if not target_position then return nil end
    
    local currentgun = get_current_gun(LocalPlayer)
    local gun = gundata and gundata:FindFirstChild(currentgun)
    local stats = gun and gun:FindFirstChild("Stats")
    local bullet_settings = stats and stats:FindFirstChild("BulletSettings")
    
    local proj_speed, proj_drop
    
    if bullet_settings then
        local bullet_speed = bullet_settings:FindFirstChild("BulletSpeed")
        local bullet_gravity = bullet_settings:FindFirstChild("BulletGravity")
        proj_speed = tonumber(bullet_speed and bullet_speed.Value) or (sv_config and tonumber(sv_config.sv_default_bullet_speed.Value) or 1500)
        proj_drop = tonumber(bullet_gravity and bullet_gravity.Value) or (sv_config and tonumber(sv_config.sv_default_bullet_gravity.Value) or 0)
    else
        proj_speed = sv_config and tonumber(sv_config.sv_default_bullet_speed.Value) or 1500
        proj_drop = sv_config and tonumber(sv_config.sv_default_bullet_gravity.Value) or 0
    end
    
    local campos = CurrentCamera.CFrame.Position
    local velocity = (target_collider and target_collider.AssemblyLinearVelocity) or Vector3.zero
    
    if silentAimFlags.ResolveY then velocity = Vector3.new(velocity.X, 0, velocity.Z) end
    if silentAimFlags.InstantBullet then velocity = Vector3.zero end
    
    if prediction_mode == "axal" then
        return predict_axal(campos, target_position, velocity, proj_speed, proj_drop)
    elseif prediction_mode == "priv9" then
        return predict_priv9(campos, target_position, velocity, proj_speed, proj_drop)
    end
    
    return predict_axal(campos, target_position, velocity, proj_speed, proj_drop)
end

-- HOOK DO SILENT AIM
local oldBufferHook = nil
oldBufferHook = hookfunction(buffer.create, function(size, ...)
    if size ~= 300 then
        return oldBufferHook(size, ...)
    end
    
    if not debug.traceback():find("GunController") then
        return oldBufferHook(size, ...)
    end
    
    local stack = debug.getstack(3, 1)
    if type(stack) ~= "table" then
        return oldBufferHook(size, ...)
    end
    
    if type(stack[3]) == "table" and stack[3].Resimulation ~= nil then
        return oldBufferHook(size, ...)
    end
    
    local cam = workspace.CurrentCamera
    local pred
    local part, player, collider = get_closest_target_silent(silentAimFlags.FovSize, silentAimFlags.AimPart, silentAimFlags.TeamCheck)
    
    if part then
        pred = full_prediction_silent(part.Position, collider)
    end
    
    local ld
    if pred and silentAimFlags.SilentEnabled then
        ld = CFrame.lookAt(cam.CFrame.Position, pred)
    else
        ld = cam.CFrame.LookVector
    end
    
    local spread = Vector3.zero
    if silentAimFlags.NoSpread then
        local rng = Random.new(stack[48] + 1)
        spread = Vector3.new(
            rng:NextNumber() - rng:NextNumber(),
            rng:NextNumber() - rng:NextNumber(),
            rng:NextNumber() - rng:NextNumber()
        ) / stack[22]
    end
    
    if typeof(ld) == "Vector3" then
        ld = (ld - spread).Unit
    else
        ld = (ld.LookVector - spread).Unit
    end
    
    local cf = CFrame.lookAt(Vector3.zero, ld)
    local pitch2, yaw2 = cf:ToEulerAnglesYXZ()
    local dir = cf.LookVector
    local r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    local zeroCF = CFrame.new(0, 0, 0, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    
    stack[32] = cf
    stack[33] = dir
    stack[34] = dir
    stack[36] = pitch2
    stack[37] = yaw2
    stack[38] = zeroCF
    stack[39] = zeroCF
    stack[44] = zeroCF
    stack[45] = dir
    stack[46] = dir
    
    return oldBufferHook(size, ...)
end)

-- ========== FUNÇÕES AUXILIARES ==========
local function worldToScreen(pos)
    if not CurrentCamera then return Vector2.new(0, 0), false end
    local pt, onScreen = CurrentCamera:WorldToViewportPoint(pos)
    return Vector2.new(pt.X, pt.Y), onScreen
end

local function GetPlayerFromEntity(entity)
    if not entity or not gameObjects.custommeshcharacter or not gameObjects.playerlist then return nil end
    local char = gameObjects.custommeshcharacter:GetCharacterFromWorldCharacter(entity)
    if not char then return nil end
    local playerdata = gameObjects.playerlist:GetPlayerFromCharacter(char)
    if playerdata and playerdata.Name then return Players:FindFirstChild(playerdata.Name) end
    return nil
end

local function IsEntityAlive(entity)
    if not entity or not entity:IsA("Model") then return false end
    return entity:FindFirstChild("UpperTorso") ~= nil
end

local function RemoveESP(entity)
    local esp = gameObjects.ESPs[entity]
    if esp then
        if esp.Connection then pcall(function() esp.Connection:Disconnect() end) end
        for _, drawing in pairs(esp.Drawings or {}) do
            if drawing then pcall(function() drawing:Remove() end) end
        end
        for _, line in pairs(esp.SkeletonLines or {}) do
            if line then pcall(function() line:Remove() end) end
        end
        gameObjects.ESPs[entity] = nil
    end
end

-- ========== ESP ==========
local function CreateSkeletonLines()
    local lines = {}
    for i = 1, 14 do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Transparency = 1
        line.Visible = false
        table.insert(lines, line)
    end
    return lines
end

local function UpdateSkeleton(entity, lines)
    if not gameObjects.skeletonEnabled or not entity or not CurrentCamera then return end
    local connections = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    }
    for i, conn in ipairs(connections) do
        local part1 = entity:FindFirstChild(conn[1])
        local part2 = entity:FindFirstChild(conn[2])
        local line = lines[i]
        if part1 and part2 and line then
            local pos1, on1 = CurrentCamera:WorldToViewportPoint(part1.Position)
            local pos2, on2 = CurrentCamera:WorldToViewportPoint(part2.Position)
            if on1 and on2 then
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                line.Color = gameObjects.skeletonColor
                line.Visible = true
            else
                line.Visible = false
            end
        else
            if line then line.Visible = false end
        end
    end
end

local function ESPOnEntity(entity)
    RemoveESP(entity)
    local player = GetPlayerFromEntity(entity)
    if not player or player == LocalPlayer then return end

    local skeletonLines = CreateSkeletonLines()
    local Drawings = {
        Box = Drawing.new('Square'),
        BoxOutline = Drawing.new('Square'),
        Name = Drawing.new('Text'),
        Distance = Drawing.new('Text'),
    }
    Drawings.Name.Color = gameObjects.nameColor
    Drawings.Name.Center = true
    Drawings.Name.Outline = true
    Drawings.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    Drawings.Name.Size = 14

    Drawings.Distance.Color = gameObjects.distanceColor
    Drawings.Distance.Center = true
    Drawings.Distance.Outline = true
    Drawings.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    Drawings.Distance.Size = 13

    local connection = RunService.RenderStepped:Connect(function()
        if not gameObjects.ESPEnabled then
            for _, d in pairs(Drawings) do if d then d.Visible = false end end
            for _, l in pairs(skeletonLines) do if l then l.Visible = false end end
            return
        end
        if not entity or not entity.Parent or not IsEntityAlive(entity) then 
            RemoveESP(entity) 
            return 
        end

        UpdateSkeleton(entity, skeletonLines)

        local Head = entity:FindFirstChild('Head')
        local UpperTorso = entity:FindFirstChild('UpperTorso')
        local LowerTorso = entity:FindFirstChild('LowerTorso')
        local HumanoidRootPart = entity:FindFirstChild('HumanoidRootPart')
        local rootPart = HumanoidRootPart or UpperTorso or LowerTorso
        local headPart = Head or UpperTorso
        if not rootPart or not headPart or not CurrentCamera then
            for _, d in pairs(Drawings) do if d then d.Visible = false end end
            return
        end

        local distance = (rootPart.Position - CurrentCamera.CFrame.Position).Magnitude
        if not distance then
            for _, d in pairs(Drawings) do if d then d.Visible = false end end
            return
        end
        
        if distance > gameObjects.maxESPDistance then
            for _, d in pairs(Drawings) do if d then d.Visible = false end end
            return
        end

        local headPos = headPart.Position + Vector3.new(0, 1.5, 0)
        local feetPos = rootPart.Position - Vector3.new(0, 3, 0)
        local topPos, topOn = CurrentCamera:WorldToViewportPoint(headPos)
        local bottomPos, bottomOn = CurrentCamera:WorldToViewportPoint(feetPos)
        
        if not topOn and not bottomOn then
            for _, d in pairs(Drawings) do if d then d.Visible = false end end
            return
        end

        local height = bottomPos.Y - topPos.Y
        local width = height * 0.65
        local centerX = (topPos.X + bottomPos.X) / 2
        
        if width > 0 and height > 0 then
            local yPos = topPos.Y
            local xPos = centerX - width / 2
            
            -- Box
            if gameObjects.boxEnabled then
                Drawings.Box.Size = Vector2.new(width, height)
                Drawings.Box.Position = Vector2.new(xPos, yPos)
                Drawings.Box.Visible = true
                Drawings.Box.Color = gameObjects.boxColor
                Drawings.Box.Thickness = 1
                Drawings.Box.Filled = gameObjects.boxFilledEnabled
                Drawings.Box.Transparency = gameObjects.boxFilledEnabled and 0.5 or 0
            else
                Drawings.Box.Visible = false
            end
            
            -- Box Outline
            if gameObjects.boxOutlineEnabled then
                Drawings.BoxOutline.Size = Vector2.new(width, height)
                Drawings.BoxOutline.Position = Vector2.new(xPos, yPos)
                Drawings.BoxOutline.Visible = true
                Drawings.BoxOutline.Color = gameObjects.boxOutlineColor
                Drawings.BoxOutline.Thickness = 2
            else
                Drawings.BoxOutline.Visible = false
            end
            
            -- Name
            if gameObjects.nameEnabled and player and player.Name then
                Drawings.Name.Position = Vector2.new(centerX, yPos - 18)
                Drawings.Name.Text = "[" .. player.Name .. "]"
                Drawings.Name.Visible = true
                Drawings.Name.Color = gameObjects.nameColor
            else
                Drawings.Name.Visible = false
            end
            
            -- Distance
            if gameObjects.distanceEnabled and distance then
                local meters = math.floor(distance / 2.5714)
                Drawings.Distance.Position = Vector2.new(centerX, yPos + height + 5)
                Drawings.Distance.Text = string.format("[%d M]", meters or 0)
                Drawings.Distance.Visible = true
                Drawings.Distance.Color = gameObjects.distanceColor
            else
                Drawings.Distance.Visible = false
            end
        else
            for _, d in pairs(Drawings) do if d then d.Visible = false end end
        end
    end)
    
    gameObjects.ESPs[entity] = { Connection = connection, Drawings = Drawings, SkeletonLines = skeletonLines, Player = player }
end

-- ========== AIMBOT (WEAPON E PREDIÇÃO) ==========
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

local function getCurrentWeaponConfig()
    local now = tick()
    if now - gameObjects.lastWeaponCheck > 0.3 then
        local weapon = getCurrentWeapon()
        if weapon then
            gameObjects.currentWeaponCache = getWeaponBulletSettings(weapon.Name)
        else
            gameObjects.currentWeaponCache = nil
        end
        gameObjects.lastWeaponCheck = now
    end
    return gameObjects.currentWeaponCache
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

local function predictPosition(targetPart, weaponConfig, distance)
    if not targetPart then return targetPart and targetPart.Position end

    local bulletSpeed = (weaponConfig and weaponConfig.BulletSpeed) or 2500
    local gravity = (weaponConfig and weaponConfig.BulletGravity) or 196.2

    local travelTime = distance / bulletSpeed
    local predTime = travelTime + gameObjects.aimbot.predictionX
    local targetVel = getTargetVelocity(targetPart)
    local predictedPos = targetPart.Position + (targetVel * predTime)

    local drop = calculateBulletDrop(distance, bulletSpeed, gravity)
    drop = drop * gameObjects.aimbot.bulletDropFactor
    predictedPos = predictedPos + Vector3.new(0, drop, 0)
    predictedPos = predictedPos + Vector3.new(0, gameObjects.aimbot.verticalOffset, 0)

    return predictedPos
end

-- ========== FOV SHAPES ==========
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
    if angle ~= 0 then
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
    if angle ~= 0 then
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
    if not gameObjects.aimbot.showFOV or not CurrentCamera then return end

    local center = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    local color = gameObjects.aimbot.fovRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or gameObjects.aimbot.fovColor
    local radius = gameObjects.aimbot.fovRadius
    local thickness = gameObjects.aimbot.fovThickness

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

-- ========== FLY ==========
local function findMovementPart()
    for _, child in ipairs(workspace.CurrentCamera:GetDescendants()) do
        if child:IsA("BasePart") and child.Size == Vector3.new(2.5, 5, 2.5) then return child end
    end
end

local function updateFly()
    if not gameObjects.flyEnabled then return end
    local part = findMovementPart()
    if not part then return end
    local cam = workspace.CurrentCamera
    local dir = Vector3.zero
    local keys = gameObjects.flyKeys
    if keys.Forward then dir = dir + cam.CFrame.LookVector end
    if keys.Backward then dir = dir - cam.CFrame.LookVector end
    if keys.Left then dir = dir - cam.CFrame.RightVector end
    if keys.Right then dir = dir + cam.CFrame.RightVector end
    if keys.Up then dir = dir + Vector3.yAxis end
    if keys.Down then dir = dir - Vector3.yAxis end
    part.AssemblyLinearVelocity = (dir.Magnitude > 0 and dir.Unit or Vector3.zero) * gameObjects.flySpeed
end

-- ========== NO RECOIL ==========
getgenv().norecoilenabled = true
local function setupNoRecoil()
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "_positionVelocity") then
                if not getgenv().oldPositionVelocity then getgenv().oldPositionVelocity = v._positionVelocity end
                v._positionVelocity = function(self, ...)
                    if getgenv().norecoilenabled then return Vector3.zero, Vector3.zero end
                    return getgenv().oldPositionVelocity(self, ...)
                end
            end
        end
    end)
end
setupNoRecoil()

-- ========== ANTI-AIM ==========
local function getAntiAimAngles()
    if gameObjects.antiAimMode == "Up" then
        return -0.35, -0.32
    elseif gameObjects.antiAimMode == "Down" then
        return 3.14, -0.32
    elseif gameObjects.antiAimMode == "Random" then
        local now = tick()
        if now - gameObjects.antiAimRandomTimer >= gameObjects.antiAimRandomSpeed then
            gameObjects.antiAimRandomTimer = now
            if gameObjects.antiAimRandomLast == "Up" then
                gameObjects.antiAimRandomLast = "Down"
                return 3.14, -0.32
            else
                gameObjects.antiAimRandomLast = "Up"
                return -0.35, -0.32
            end
        end
        if gameObjects.antiAimRandomLast == "Up" then
            return -0.35, -0.32
        else
            return 3.14, -0.32
        end
    else
        return gameObjects.antiAimPitch, gameObjects.antiAimYaw
    end
end

-- ========== SPINBOT ==========
local function setupSpinbot()
    if gameObjects.spinbotConnection1 then
        pcall(function() gameObjects.spinbotConnection1:Disconnect() end)
        gameObjects.spinbotConnection1 = nil
    end
    if gameObjects.spinbotConnection2 then
        pcall(function() gameObjects.spinbotConnection2:Disconnect() end)
        gameObjects.spinbotConnection2 = nil
    end
    
    if not gameObjects.spinbotEnabled then return end
    
    gameObjects.spinbotConnection1 = RunService.Heartbeat:Connect(function(dt)
        if not gameObjects.spinbotEnabled then return end
        gameObjects.spinbotYawAngle = (gameObjects.spinbotYawAngle + gameObjects.spinbotYawSpeed * dt) % (2 * math.pi)
    end)
    
    gameObjects.spinbotConnection2 = RunService.RenderStepped:Connect(function()
        if not gameObjects.spinbotEnabled then return end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            pcall(function()
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, gameObjects.spinbotYawAngle, 0)
            end)
        end
    end)
end

-- ========== CHAMS ==========
local function isArmPart(part)
    local armParts = { "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand" }
    return table.find(armParts, part.Name) ~= nil
end

local function applyChamToPart(part)
    if part:IsA('BasePart') then
        for _, child in ipairs(part:GetChildren()) do
            if child:IsA('SurfaceAppearance') then child:Destroy() end
        end
        part.Material = gameObjects.armChamsMaterial
        part.Color = gameObjects.armChamsColor
    end
end

local function applyArmChamsToCharacter(character)
    if not character or not gameObjects.armChamsEnabled then return end
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA('BasePart') and isArmPart(descendant) then
            applyChamToPart(descendant)
        end
    end
end

local function updateSkinColor()
    if not gameObjects.armChamsEnabled then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    for _, obj in pairs(camera:GetDescendants()) do
        if obj.Name == "Skin" and obj:IsA("BasePart") then
            obj.Material = gameObjects.armChamsMaterial
            obj.Color = gameObjects.armChamsColor
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("SurfaceAppearance") then child:Destroy() end
            end
        elseif obj:IsA("BasePart") and isArmPart(obj) then
            applyChamToPart(obj)
        end
    end
end

local function applyArmChams()
    if not gameObjects.armChamsEnabled then return end
    local character = LocalPlayer.Character
    if character then applyArmChamsToCharacter(character) end
    updateSkinColor()
end

local function changeWeaponLook(gun)
    if not gameObjects.weaponChamsEnabled or not gun then return end
    local parts = gun:FindFirstChild("Weapon")
    if not parts then return end
    for _, v in pairs(parts:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 1 then
            v.Material = gameObjects.weaponChamsMaterial
            v.Color = gameObjects.weaponChamsColor
        end
        if v:IsA("SurfaceAppearance") then v:Destroy() end
    end
end

local function setupWeaponChanger()
    local cam = workspace.Camera
    if not cam then return end
    local currentGun = cam:FindFirstChild("CurrentWeapon")
    if currentGun then changeWeaponLook(currentGun) end
    cam.ChildAdded:Connect(function(obj)
        if obj.Name == "CurrentWeapon" then
            task.delay(0.1, function() changeWeaponLook(obj) end)
        end
    end)
end

local function findCharacterByCamera()
    if not gameObjects.entitiesfolder or not CurrentCamera then return nil end
    local cameraPos = CurrentCamera.CFrame.Position
    local closest, closestDist = nil, 15
    for _, model in pairs(gameObjects.entitiesfolder:GetChildren()) do
        if model:IsA("Model") then
            local head = model:FindFirstChild("Head")
            if head then
                local dist = (cameraPos - head.Position).Magnitude
                if dist < closestDist then closestDist, closest = dist, model end
            end
        end
    end
    return closest
end

local function applySelfChams()
    if not gameObjects.selfChamsEnabled then return end
    local char = (gameObjects.selfChamsCharacter and gameObjects.selfChamsCharacter.Parent) and gameObjects.selfChamsCharacter or findCharacterByCamera()
    if not char then return end
    gameObjects.selfChamsCharacter = char
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("SurfaceAppearance") then child:Destroy() end
            end
            part.Material = gameObjects.selfChamsMaterial
            part.Color = gameObjects.selfChamsColor
            if part.Name == "Head" then
                part.Transparency = gameObjects.selfChamsHeadTransparency
            else
                part.Transparency = gameObjects.selfChamsTransparency
            end
        end
    end
end

-- ========== GUN PLUGIN (LONG NECK) ==========
local function setupGunPlugin()
    local success, result = pcall(function()
        return require(game:GetService("ReplicatedFirst").GunSystem.GunController.Events.GunPlugin)
    end)
    if success then gameObjects.gunplugin = result end
end
setupGunPlugin()

local function updateLongNeck()
    if gameObjects.gunplugin then
        pcall(function()
            if gameObjects.longNeckEnabled then gameObjects.gunplugin:SetOverrideCameraHeight(gameObjects.longNeckHeight)
            else gameObjects.gunplugin:SetOverrideCameraHeight(0) end
        end)
    end
end

-- ========== UI ==========
function Core.InitializeUI(Library, ThemeManager, SaveManager)
    local Window = Library:CreateWindow({
        Title = 'THE RIFT',
        Center = true,
        AutoShow = true,
        TabPadding = 8,
        MenuFadeTime = 0.2
    })

    local Tabs = {
        Combat = Window:AddTab('Combat'),
        Visuals = Window:AddTab('Visuals'),
        World = Window:AddTab('World'),
        Character = Window:AddTab('Character'),
        Exploit = Window:AddTab('Exploit'),
        ['UI Settings'] = Window:AddTab('UI Settings')
    }

    -- Silent Aim Section
    local SilentAimSection = Tabs.Combat:AddLeftGroupbox('Silent Aim')
    SilentAimSection:AddToggle('SilentAimToggle', { Text = 'Enable Silent Aim', Default = false, Callback = function(v) silentAimFlags.SilentEnabled = v end })
    SilentAimSection:AddToggle('SilentTeamCheck', { Text = 'Team Check', Default = true, Callback = function(v) silentAimFlags.TeamCheck = v end })
    SilentAimSection:AddDivider()
    SilentAimSection:AddDropdown('SilentAimPart', { Values = { 'Head', 'UpperTorso', 'HumanoidRootPart' }, Default = 1, Text = 'Target Part', Callback = function(v) silentAimFlags.AimPart = v end })
    SilentAimSection:AddSlider('SilentFOVRadius', { Text = 'FOV Radius', Default = 200, Min = 0, Max = 500, Rounding = 1, Callback = function(v) silentAimFlags.FovSize = v; silentFovCircle.Radius = v end })
    SilentAimSection:AddToggle('SilentFOVVisible', { Text = 'Show FOV Circle', Default = false, Callback = function(v) silentFovCircle.Visible = v end })
    SilentAimSection:AddDivider()
    SilentAimSection:AddDropdown('SilentPredictionMode', { Text = 'Prediction Mode', Default = 'Axal', Values = { 'Axal', 'Priv9' }, Callback = function(v) prediction_mode = v == "Axal" and "axal" or "priv9" end })
    SilentAimSection:AddToggle('SilentResolveY', { Text = 'Resolve Y', Default = false, Callback = function(v) silentAimFlags.ResolveY = v end })
    SilentAimSection:AddToggle('SilentInstantBullet', { Text = 'Instant Bullet', Default = false, Callback = function(v) silentAimFlags.InstantBullet = v end })
    SilentAimSection:AddToggle('SilentNoSpread', { Text = 'No Spread', Default = false, Callback = function(v) silentAimFlags.NoSpread = v end })

    -- Mouse Aimbot Section
    local MouseAimbotSection = Tabs.Combat:AddLeftGroupbox('Mouse Aimbot')
    local aimbotToggle = MouseAimbotSection:AddToggle('AimbotToggle', { Text = 'Enable Mouse Aimbot', Default = false, Callback = function(v) gameObjects.aimbot.enabled = v end })
    MouseAimbotSection:AddLabel('Toggle Aimbot Key'):AddKeyPicker('AimbotToggleKey', { Default = 'X', SyncToggleState = true, Mode = 'Toggle', Callback = function(value) aimbotToggle:SetValue(value) end })
    MouseAimbotSection:AddLabel('Aim Key (Hold)'):AddKeyPicker('AimbotHoldKey', { Default = 'MB2', SyncToggleState = false, Mode = 'Hold', Text = 'Aim Key', ChangedCallback = function(New)
        if New == "MB2" then gameObjects.aimbot.keybind = Enum.UserInputType.MouseButton2
        elseif New == "MB1" then gameObjects.aimbot.keybind = Enum.UserInputType.MouseButton1
        else gameObjects.aimbot.keybind = Enum.KeyCode[New] end
    end })
    MouseAimbotSection:AddDivider()
    MouseAimbotSection:AddDropdown('HitPart', { Values = { 'Head', 'UpperTorso', 'HumanoidRootPart' }, Default = 1, Text = 'Hit Part', Callback = function(v) gameObjects.aimbot.hitPart = v end })
    MouseAimbotSection:AddSlider('Smoothing', { Text = 'Smoothing', Default = 50, Min = 0, Max = 100, Rounding = 1, Callback = function(v) gameObjects.aimbot.smoothing = v / 100 end })

    -- Predictions
    local PredictionsSection = Tabs.Combat:AddLeftGroupbox('Predictions')
    PredictionsSection:AddSlider('PredictionX', { Text = 'Lateral Prediction (s)', Default = 20, Min = 0, Max = 50, Rounding = 1, Callback = function(v) gameObjects.aimbot.predictionX = v / 100 end })
    PredictionsSection:AddSlider('BulletDropFactor', { Text = 'Bullet Drop Factor (%)', Default = 100, Min = 0, Max = 200, Rounding = 1, Callback = function(v) gameObjects.aimbot.bulletDropFactor = v / 100 end })
    PredictionsSection:AddSlider('VerticalOffset', { Text = 'Vertical Offset', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) gameObjects.aimbot.verticalOffset = v end })

    -- FOV Settings
    local FOVSection = Tabs.Combat:AddRightGroupbox('FOV Settings')
    FOVSection:AddToggle('ShowFOV', { Text = 'Show FOV', Default = false, Callback = function(v) gameObjects.aimbot.showFOV = v; if v then updateFOVShape(currentFOVShape, gameObjects.fovSpinAngle) end end })
    FOVSection:AddSlider('FOVRadius', { Text = 'FOV Radius', Default = 200, Min = 0, Max = 500, Rounding = 1, Callback = function(v) gameObjects.aimbot.fovRadius = v; if gameObjects.aimbot.showFOV then updateFOVShape(currentFOVShape, gameObjects.fovSpinAngle) end end })
    FOVSection:AddSlider('FOVThickness', { Text = 'FOV Thickness', Default = 2, Min = 1, Max = 10, Rounding = 1, Callback = function(v) gameObjects.aimbot.fovThickness = v; if gameObjects.aimbot.showFOV then updateFOVShape(currentFOVShape, gameObjects.fovSpinAngle) end end })
    FOVSection:AddDropdown('FOVShape', { Text = 'FOV Shape', Default = 'Circle', Values = { 'Circle', 'Triangle', 'Star of David', 'Pentagon', 'Hexagon' }, Callback = function(v) currentFOVShape = v; if gameObjects.aimbot.showFOV then updateFOVShape(v, gameObjects.fovSpinAngle) end end })
    FOVSection:AddToggle('FOVSpin', { Text = 'Spin FOV', Default = false, Callback = function(v) gameObjects.aimbot.fovSpin = v; if gameObjects.aimbot.showFOV then updateFOVShape(currentFOVShape, gameObjects.fovSpinAngle) end end })
    FOVSection:AddSlider('FOVSpinSpeed', { Text = 'Spin Speed', Default = 45, Min = 0, Max = 360, Rounding = 1, Callback = function(v) gameObjects.aimbot.fovSpinSpeed = v end })
    FOVSection:AddLabel('FOV Color'):AddColorPicker('FOVColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) gameObjects.aimbot.fovColor = c; if gameObjects.aimbot.showFOV then updateFOVShape(currentFOVShape, gameObjects.fovSpinAngle) end end })
    FOVSection:AddToggle('FOVRainbow', { Text = 'Rainbow FOV', Default = false, Callback = function(v) gameObjects.aimbot.fovRainbow = v end })

    -- Gun Mods
    local GunSection = Tabs.Combat:AddRightGroupbox('Gun Modifications')
    GunSection:AddToggle('NoRecoil', { Text = 'No Recoil', Default = true, Callback = function(v) getgenv().norecoilenabled = v end })
    local function enableInstantAim()
        for _, v in next, getgc(true) do
            if type(v) == 'table' then
                for i, val in next, v do
                    if type(i) == 'string' and i:find('GunAim') then
                        if type(val) == 'number' then v[i] = 100000000
                        elseif type(val) == 'function' then hookfunction(val, function() return 100000000 end) end
                    end
                end
            end
        end
    end
    GunSection:AddToggle('InstantAim', { Text = 'Instant Aim', Default = false, Callback = function(state) if state then enableInstantAim() end end })

    -- ESP Section
    local ESPGroup = Tabs.Visuals:AddLeftGroupbox('Player ESP')
    ESPGroup:AddToggle('ESPEnabled', { Text = 'Enable ESP', Default = false, Callback = function(v) gameObjects.ESPEnabled = v end })
    ESPGroup:AddToggle('ShowBoxes', { Text = 'Show Boxes', Default = false, Callback = function(v) gameObjects.boxEnabled = v end })
    ESPGroup:AddToggle('FilledBoxes', { Text = 'Filled Boxes', Default = false, Callback = function(v) gameObjects.boxFilledEnabled = v end })
    ESPGroup:AddToggle('OutlineBoxes', { Text = 'Outline Boxes', Default = false, Callback = function(v) gameObjects.boxOutlineEnabled = v end })
    ESPGroup:AddToggle('Skeleton', { Text = 'Skeleton', Default = false, Callback = function(v) gameObjects.skeletonEnabled = v end })
    ESPGroup:AddToggle('ShowNames', { Text = 'Show Names', Default = false, Callback = function(v) gameObjects.nameEnabled = v end })
    ESPGroup:AddToggle('ShowDistances', { Text = 'Show Distances', Default = false, Callback = function(v) gameObjects.distanceEnabled = v end })
    ESPGroup:AddLabel('Box Color'):AddColorPicker('BoxColor', { Default = gameObjects.boxColor, Callback = function(c) gameObjects.boxColor = c end })
    ESPGroup:AddLabel('Name Color'):AddColorPicker('NameColor', { Default = gameObjects.nameColor, Callback = function(c) gameObjects.nameColor = c end })
    ESPGroup:AddSlider('MaxDistance', { Text = 'Max ESP Distance', Default = 1000, Min = 0, Max = 5000, Rounding = 1, Callback = function(v) gameObjects.maxESPDistance = v end })

    -- Character Chams
    local ArmGroup = Tabs.Character:AddLeftGroupbox('Arm Chams')
    ArmGroup:AddToggle('ArmChams', { Text = 'Enable Arm Chams', Default = false, Callback = function(v) gameObjects.armChamsEnabled = v; if v then applyArmChams() end end })
    ArmGroup:AddLabel('Arm Color'):AddColorPicker('ArmColor', { Default = gameObjects.armChamsColor, Callback = function(c) gameObjects.armChamsColor = c; if gameObjects.armChamsEnabled then applyArmChams() end end })
    ArmGroup:AddDropdown('ArmMaterial', { Values = { "ForceField", "Plastic", "SmoothPlastic", "Neon", "Glass", "Metal", "Wood", "Concrete" }, Default = "ForceField", Text = "Material", Callback = function(v) gameObjects.armChamsMaterial = Enum.Material[v]; if gameObjects.armChamsEnabled then applyArmChams() end end })

    local WeaponGroup = Tabs.Character:AddLeftGroupbox('Weapon Chams')
    WeaponGroup:AddToggle('WeaponChams', { Text = 'Enable Weapon Chams', Default = false, Callback = function(v) gameObjects.weaponChamsEnabled = v; if v then local gun = workspace.Camera:FindFirstChild("CurrentWeapon"); if gun then changeWeaponLook(gun) end end end })
    WeaponGroup:AddLabel('Weapon Color'):AddColorPicker('WeaponColor', { Default = gameObjects.weaponChamsColor, Callback = function(c) gameObjects.weaponChamsColor = c; if gameObjects.weaponChamsEnabled then local gun = workspace.Camera:FindFirstChild("CurrentWeapon"); if gun then changeWeaponLook(gun) end end end })
    WeaponGroup:AddDropdown('WeaponMaterial', { Values = { "ForceField", "Plastic", "SmoothPlastic", "Neon", "Glass", "Metal", "Wood", "Concrete" }, Default = "ForceField", Text = "Material", Callback = function(v) gameObjects.weaponChamsMaterial = Enum.Material[v]; if gameObjects.weaponChamsEnabled then local gun = workspace.Camera:FindFirstChild("CurrentWeapon"); if gun then changeWeaponLook(gun) end end end })

    local SelfGroup = Tabs.Character:AddRightGroupbox('Self Chams')
    SelfGroup:AddToggle('SelfChams', { Text = 'Enable Self Chams', Default = false, Callback = function(v) gameObjects.selfChamsEnabled = v; if v then applySelfChams(); if gameObjects.selfChamsUpdater then gameObjects.selfChamsUpdater:Disconnect() end; gameObjects.selfChamsUpdater = RunService.RenderStepped:Connect(applySelfChams) end end })
    SelfGroup:AddLabel('Self Color'):AddColorPicker('SelfColor', { Default = gameObjects.selfChamsColor, Callback = function(c) gameObjects.selfChamsColor = c; if gameObjects.selfChamsEnabled then applySelfChams() end end })
    SelfGroup:AddDropdown('SelfMaterial', { Values = { "ForceField", "Neon", "Plastic", "SmoothPlastic", "Metal", "Glass", "Wood", "Concrete" }, Default = "ForceField", Text = "Material", Callback = function(v) gameObjects.selfChamsMaterial = Enum.Material[v]; if gameObjects.selfChamsEnabled then applySelfChams() end end })

    -- Long Neck
    local NeckGroup = Tabs.Exploit:AddRightGroupbox('Long Neck')
    NeckGroup:AddToggle('LongNeck', { Text = 'Long Neck', Default = false, Callback = function(v) gameObjects.longNeckEnabled = v; updateLongNeck() end })
    NeckGroup:AddSlider('NeckHeight', { Text = 'Height', Default = 5, Min = 1, Max = 7, Rounding = 1, Callback = function(v) gameObjects.longNeckHeight = v; if gameObjects.longNeckEnabled then updateLongNeck() end end })

    -- Movement Exploits
    local MoveGroup = Tabs.Exploit:AddLeftGroupbox('Movement')
    MoveGroup:AddToggle('Fly', { Text = 'Fly (Press P)', Default = false, Callback = function(v) gameObjects.flyEnabled = v; if v then if gameObjects.flyConnection then gameObjects.flyConnection:Disconnect() end; gameObjects.flyConnection = RunService.Heartbeat:Connect(updateFly); local part = findMovementPart(); if part then part.CanCollide = false end else local part = findMovementPart(); if part then part.AssemblyLinearVelocity = Vector3.zero; part.CanCollide = true end end end })
    MoveGroup:AddSlider('FlySpeed', { Text = 'Fly Speed', Default = 50, Min = 10, Max = 300, Rounding = 1, Callback = function(v) gameObjects.flySpeed = v end })
    MoveGroup:AddDivider()
    MoveGroup:AddToggle('AntiAim', { Text = 'Anti-Aim', Default = false, Callback = function(v) gameObjects.antiAimEnabled = v end })
    MoveGroup:AddDropdown('AntiAimMode', { Text = 'Mode', Default = 'Up', Values = { 'Up', 'Down', 'Random', 'Custom' }, Callback = function(v) gameObjects.antiAimMode = v end })
    MoveGroup:AddDivider()
    MoveGroup:AddToggle('Spinbot', { Text = 'Spinbot', Default = false, Callback = function(v) gameObjects.spinbotEnabled = v; if v then setupSpinbot() else if gameObjects.spinbotConnection1 then gameObjects.spinbotConnection1:Disconnect() end; if gameObjects.spinbotConnection2 then gameObjects.spinbotConnection2:Disconnect() end end end })
    MoveGroup:AddSlider('SpinbotSpeed', { Text = 'Spin Speed', Default = 5, Min = 1, Max = 100, Rounding = 1, Callback = function(v) gameObjects.spinbotYawSpeed = v end })

    -- UI Settings
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu Settings')
    MenuGroup:AddButton('Unload', function() Library:Unload() end)
    MenuGroup:AddLabel('Menu Bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

    Library.ToggleKeybind = 'End'
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder('TheRift')
    ThemeManager:ApplyToTab(Tabs['UI Settings'])
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
    SaveManager:SetFolder('TheRift')
    SaveManager:BuildConfigSection(Tabs['UI Settings'])
    SaveManager:LoadAutoloadConfig()

        -- ========== EXTRAS (Zombie, Car, Hitbox, etc) ==========
    
    -- Extra Groupbox (para funcionalidades extras)
    local ExtrasGroup = Tabs.World:AddLeftGroupbox('Extras')
    
    -- Scanner
    ExtrasGroup:AddButton("Run Scanner", function() 
        if _G.Extras and _G.Extras.runScanner then _G.Extras.runScanner() end
    end)
    
    -- Vehicle ESP
    ExtrasGroup:AddToggle('CarESP', { Text = 'Vehicle ESP', Default = false, Callback = function(v) 
        if _G.Extras then _G.Extras.setCarEspEnabled(v) end 
    end })
    
    -- No Inventory Blur
    ExtrasGroup:AddToggle('NoInventoryBlur', { Text = 'No Inventory Blur', Default = false, Callback = function(v) 
        if _G.Extras then _G.Extras.setNoInventoryBlur(v) end 
    end })
    
    -- No Car Damage
    ExtrasGroup:AddButton('Toggle No Car Damage', function() 
        if _G.Extras then _G.Extras.toggleNoCarDamage() end 
    end)
    
    -- Remove Clouds
    local originalCloudsEnabled = workspace.Terrain:FindFirstChild("Clouds") and workspace.Terrain.Clouds.Enabled or true
    ExtrasGroup:AddToggle('RemoveClouds', { Text = 'Remove Clouds', Default = false, Callback = function(v)
        if workspace.Terrain:FindFirstChild("Clouds") then
            workspace.Terrain.Clouds.Enabled = not v
        end
    end })
    
    -- Skybox
    local SkyboxSection = Tabs.World:AddRightGroupbox('Skybox Changer')
    SkyboxSection:AddDropdown('Skybox', { Text = 'Skybox', Default = 'Default', Values = { 'Default', 'Standard', 'Blue Sky', 'Vaporwave', 'Redshift', 'Blaze', 'Among Us', 'Dark Night', 'Bright Pink', 'Purple Sky', 'Galaxy' }, Callback = function(v) 
        if _G.Extras then _G.Extras.applySkybox(v) end 
    end })
    
    -- Zombie Expander
    local ZombieSection = Tabs.Exploit:AddRightGroupbox('Zombie Expander')
    ZombieSection:AddToggle('ZombieExpanderToggle', { Text = 'Zombie Expander', Default = false, Callback = function(v) 
        if _G.Extras then _G.Extras.setZombieExpander(v) end 
    end })
    ZombieSection:AddSlider('ZombieHitboxSize', { Text = 'Hitbox Size', Default = 16, Min = 1, Max = 50, Rounding = 1, Callback = function(v) 
        if _G.Extras then _G.Extras.setZombieHitboxSize(v) end 
    end })
    ZombieSection:AddSlider('ZombieHeadTransparency', { Text = 'Head Transparency', Default = 0.9, Min = 0, Max = 1, Rounding = 2, Callback = function(v) 
        if _G.Extras then _G.Extras.setZombieHeadTransparency(v) end 
    end })
    
    -- Car Speed
    local CarSpeedSection = Tabs.Exploit:AddRightGroupbox('Car Speed')
    CarSpeedSection:AddToggle('CarSpeedToggle', { Text = 'Car Speed', Default = false, Callback = function(v) 
        if _G.Extras then _G.Extras.setCarSpeedEnabled(v) end 
    end })
    CarSpeedSection:AddSlider('CarForwardMaxSpeed', { Text = 'Forward Max Speed', Default = 100, Min = 50, Max = 300, Rounding = 1, Callback = function(v) 
        if _G.Extras then _G.Extras.setCarForwardMaxSpeed(v) end 
    end })
    CarSpeedSection:AddSlider('CarReverseMaxSpeed', { Text = 'Reverse Max Speed', Default = 40, Min = 20, Max = 150, Rounding = 1, Callback = function(v) 
        if _G.Extras then _G.Extras.setCarReverseMaxSpeed(v) end 
    end })
    CarSpeedSection:AddSlider('CarAcceleration', { Text = 'Acceleration', Default = 60, Min = 10, Max = 200, Rounding = 1, Callback = function(v) 
        if _G.Extras then _G.Extras.setCarAcceleration(v) end 
    end })
    
    -- Hitbox Expander
    local HitboxSection = Tabs.Exploit:AddRightGroupbox('Hitbox Expander')
    HitboxSection:AddToggle('HitboxExpanderToggle', { Text = 'Enable Hitbox Expander', Default = false, Callback = function(v) 
        if _G.Extras then _G.Extras.setHitboxExpanderEnabled(v) end 
    end })
    HitboxSection:AddSlider('HitboxExpanderRadius', { Text = 'Hitbox Radius', Default = 5, Min = 1, Max = 10, Rounding = 1, Callback = function(v) 
        if _G.Extras then _G.Extras.setHitboxExpanderRadius(v) end 
    end })
    
    -- Speedhack
    local SpeedhackSection = Tabs.Exploit:AddLeftGroupbox('Speedhack')
    SpeedhackSection:AddToggle('SpeedhackToggle', { Text = 'Speedhack', Default = false, Callback = function(v) 
        if _G.Extras then _G.Extras.setSpeedhackEnabled(v) end 
    end })
    SpeedhackSection:AddSlider('SpeedhackSlider', { Text = 'Speedhack Speed', Default = 20, Min = 5, Max = 100, Rounding = 1, Callback = function(v) 
        if _G.Extras then _G.Extras.setSpeedhackSpeed(v) end 
    end })
    
    -- Auto Jump
    SpeedhackSection:AddDivider()
    SpeedhackSection:AddToggle('AutoJump', { Text = 'Auto Jump (Bunny Hop)', Default = false, Callback = function(v) 
        if _G.Extras then _G.Extras.setAutoJumpEnabled(v) end 
    end })
    
    -- Climb Speed
    SpeedhackSection:AddToggle('ClimbSpeedToggle', { Text = 'Climb Speed', Default = false, Callback = function(v) 
        if _G.Extras then _G.Extras.setClimbSpeedEnabled(v) end 
    end })
    SpeedhackSection:AddSlider('ClimbSpeedValue', { Text = 'Climb Speed', Default = 15, Min = 0, Max = 50, Rounding = 1, Callback = function(v) 
        if _G.Extras then _G.Extras.setClimbSpeedValue(v) end 
    end })
    
    -- Offset Changer
    local OffsetSection = Tabs.Combat:AddRightGroupbox('Offset Changer')
    OffsetSection:AddToggle('OffsetToggle', { Text = 'Enable Offset Changer', Default = false, Callback = function(v) 
        if _G.Extras then _G.Extras.setOffsetEnabled(v) end 
    end })
    OffsetSection:AddSlider('OffsetX', { Text = 'Offset X', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) 
        if _G.Extras then _G.Extras.setOffsetX(v) end 
    end })
    OffsetSection:AddSlider('OffsetY', { Text = 'Offset Y', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) 
        if _G.Extras then _G.Extras.setOffsetY(v) end 
    end })
    OffsetSection:AddSlider('OffsetZ', { Text = 'Offset Z', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) 
        if _G.Extras then _G.Extras.setOffsetZ(v) end 
    end })
    
    -- No Gun Sway / Bob (já estavam no Gun Mods)
    GunSection:AddDivider()
    GunSection:AddToggle('NoGunSway', { Text = 'No Gun Sway', Default = false, Callback = function(v)
        for _, obj in getgc(true) do
            if typeof(obj) == "table" and rawget(obj, "_positionVelocity") then
                if v then
                    rawset(obj, "_positionVelocity", function() return Vector3.zero, Vector3.zero end)
                else
                    rawset(obj, "_positionVelocity", nil)
                end
            end
        end
    end })
    
    GunSection:AddToggle('NoGunBob', { Text = 'No Gun Bob', Default = false, Callback = function(v)
        for _, tbl in getgc(true) do
            if type(tbl) == 'table' and rawget(tbl, 'BobSpeed') then
                if v then
                    tbl.BobSpeed = 0
                    tbl.BobAmplitudeHorizontal = 0
                    tbl.BobAmplitudeVertical = 0
                else
                    tbl.BobSpeed = 1
                    tbl.BobAmplitudeHorizontal = 0.5
                    tbl.BobAmplitudeVertical = 0.3
                end
            end
        end
    end })
    
    print("✅ UI Carregada!")
end

-- ========== LOOP PRINCIPAL ==========
RunService.RenderStepped:Connect(function()
    if not CurrentCamera then return end
    local center = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    local t = tick()
    
    -- FOV Spin
    if gameObjects.aimbot.fovSpin then
        local delta = t - gameObjects.lastSpinUpdate
        gameObjects.lastSpinUpdate = t
        gameObjects.fovSpinAngle = gameObjects.fovSpinAngle + math.rad(gameObjects.aimbot.fovSpinSpeed * delta)
        if gameObjects.fovSpinAngle > 2 * math.pi then gameObjects.fovSpinAngle = gameObjects.fovSpinAngle - 2 * math.pi end
    end

    -- Update FOV visual
    if gameObjects.aimbot.showFOV and fovShapeObjects.current then
        local color = gameObjects.aimbot.fovRainbow and Color3.fromHSV(t % 5 / 5, 1, 1) or gameObjects.aimbot.fovColor
        if type(fovShapeObjects.current) == "table" then
            if gameObjects.aimbot.fovSpin and currentFOVShape ~= "Circle" then
                updateFOVShape(currentFOVShape, gameObjects.fovSpinAngle)
            else
                for _, obj in pairs(fovShapeObjects.current) do
                    if obj then obj.Color = color; obj.Thickness = gameObjects.aimbot.fovThickness end
                end
                if currentFOVShape ~= "Circle" then
                    updateFOVShape(currentFOVShape, gameObjects.aimbot.fovSpin and gameObjects.fovSpinAngle or 0)
                end
            end
        else
            fovShapeObjects.current.Color = color
            fovShapeObjects.current.Thickness = gameObjects.aimbot.fovThickness
            if currentFOVShape == "Circle" then
                fovShapeObjects.current.Position = center
                fovShapeObjects.current.Radius = gameObjects.aimbot.fovRadius
            end
        end
    end

    -- Mouse Aimbot
    if gameObjects.aimbot.enabled and gameObjects.aimbot.aiming then
        local weaponConfig = getCurrentWeaponConfig()
        if weaponConfig then
            local bestPos = nil
            local bestDist = math.huge
            for _, entity in pairs(gameObjects.entitiesfolder:GetChildren()) do
                if entity:IsA("Model") and IsEntityAlive(entity) then
                    local player = GetPlayerFromEntity(entity)
                    if player and player ~= LocalPlayer then
                        local hitPart = entity:FindFirstChild(gameObjects.aimbot.hitPart) or entity:FindFirstChild("Head") or entity:FindFirstChild("UpperTorso")
                        if hitPart then
                            local distance = (hitPart.Position - CurrentCamera.CFrame.Position).Magnitude
                            local predicted = predictPosition(hitPart, weaponConfig, distance)
                            local screenPos, onScreen = worldToScreen(predicted)
                            if onScreen then
                                local distToCenter = (screenPos - center).Magnitude
                                if distToCenter <= gameObjects.aimbot.fovRadius and distToCenter < bestDist then
                                    bestDist = distToCenter
                                    bestPos = predicted
                                end
                            end
                        end
                    end
                end
            end
            if bestPos then
                local screenPos, onScreen = worldToScreen(bestPos)
                if onScreen then
                    local delta = screenPos - center
                    if delta.Magnitude > 0.5 then
                        mousemoverel(delta.X * gameObjects.aimbot.smoothing, delta.Y * gameObjects.aimbot.smoothing)
                    end
                end
            end
        end
    end

    -- Cleanup
    for part in pairs(gameObjects.targetVelocities) do
        if not part or not part.Parent then
            gameObjects.targetVelocities[part] = nil
        end
    end

    -- Lighting
    if gameObjects.fullbrightEnabled then
        lighting.Brightness = 10
        lighting.ClockTime = 12
        lighting.GlobalShadows = false
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end
    if gameObjects.noFogEnabled and lighting:FindFirstChild("Atmosphere") then
        lighting.Atmosphere.Density = 0
    end
    if gameObjects.timeEnabled then
        lighting.ClockTime = gameObjects.timeValue
    end
end)

-- Anti-Aim Hook
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and key == "CFrame" and self == CurrentCamera then
        local cf = oldIndex(self, key)
        if gameObjects.antiAimEnabled and cf then
            local pitch, yaw = getAntiAimAngles()
            return CFrame.new(cf.Position, cf.Position + Vector3.new(math.sin(pitch), math.cos(pitch), math.sin(yaw)))
        end
        return cf
    end
    return oldIndex(self, key)
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.P then
        gameObjects.flyEnabled = not gameObjects.flyEnabled
        if gameObjects.flyEnabled then
            if gameObjects.flyConnection then gameObjects.flyConnection:Disconnect() end
            gameObjects.flyConnection = RunService.Heartbeat:Connect(updateFly)
            local part = findMovementPart()
            if part then part.CanCollide = false end
        else
            local part = findMovementPart()
            if part then part.AssemblyLinearVelocity = Vector3.zero; part.CanCollide = true end
        end
    elseif k == Enum.KeyCode.W then gameObjects.flyKeys.Forward = true
    elseif k == Enum.KeyCode.S then gameObjects.flyKeys.Backward = true
    elseif k == Enum.KeyCode.A then gameObjects.flyKeys.Left = true
    elseif k == Enum.KeyCode.D then gameObjects.flyKeys.Right = true
    elseif k == Enum.KeyCode.Space then gameObjects.flyKeys.Up = true
    elseif k == Enum.KeyCode.LeftShift or k == Enum.KeyCode.RightShift then gameObjects.flyKeys.Down = true
    end
    if input.UserInputType == gameObjects.aimbot.keybind then 
        gameObjects.aimbot.aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local k = input.KeyCode
    if k == Enum.KeyCode.W then gameObjects.flyKeys.Forward = false
    elseif k == Enum.KeyCode.S then gameObjects.flyKeys.Backward = false
    elseif k == Enum.KeyCode.A then gameObjects.flyKeys.Left = false
    elseif k == Enum.KeyCode.D then gameObjects.flyKeys.Right = false
    elseif k == Enum.KeyCode.Space then gameObjects.flyKeys.Up = false
    elseif k == Enum.KeyCode.LeftShift or k == Enum.KeyCode.RightShift then gameObjects.flyKeys.Down = false
    end
    if input.UserInputType == gameObjects.aimbot.keybind then 
        gameObjects.aimbot.aiming = false
    end
end)

setupWeaponChanger()
print("✅ Core carregado!")

return Core
