-- MÓDULO: SILENT AIM (BASEADO NO SEU BACKUP FUNCIONAL)
local SilentAim = {}

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuração
SilentAim.flags = {
    SilentEnabled = true,
    TeamCheck = true,
    FovSize = 100,
    AimPart = "Head",
    NoSpread = false,
    ResolveX = false,
    ResolveY = false,
    InstantBullet = false,
    ScoutPred = false
}

SilentAim.prediction_mode = "axal"

-- Gun data references
local gundata = ReplicatedStorage:FindFirstChild("GunSystemAssets") and ReplicatedStorage.GunSystemAssets:FindFirstChild("GunData")
local sv_config = ReplicatedStorage:FindFirstChild("CustomCharacterConfigs") and ReplicatedStorage.CustomCharacterConfigs:FindFirstChild("Configuration") and ReplicatedStorage.CustomCharacterConfigs.Configuration:FindFirstChild("Server")

-- FOV Circle
local fovcircle = Drawing.new("Circle")
fovcircle.Visible = true
fovcircle.Color = Color3.fromRGB(255, 0, 0)
fovcircle.Thickness = 2
fovcircle.NumSides = 30
fovcircle.Radius = SilentAim.flags.FovSize
fovcircle.Transparency = 1
fovcircle.Filled = false

-- Atualizar posição do FOV
RunService.Heartbeat:Connect(function()
    local cam = Workspace.CurrentCamera
    if cam then
        fovcircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    end
end)

-- Get current gun
local function get_current_gun(plr)
    if not plr then return "Fists" end
    local c = plr:FindFirstChild("CurrentSelectedObject")
    c = c and c.Value
    c = c and c.Value
    return c and c.Name or "Fists"
end

-- Get entity list
local entitylist = nil
for _, gc in ipairs(getgc(true)) do
    if type(gc) == "table" then
        local gpfwc = rawget(gc, "GetPlayerFromWorldCharacter")
        if gpfwc and type(gpfwc) == "function" then
            local upvs = getupvalues(gpfwc)
            local GetCharacters = upvs[2] and upvs[2].GetCharacters
            if GetCharacters and type(GetCharacters) == "function" then
                entitylist = getupvalues(GetCharacters)[1]
                break
            end
        end
    end
end

-- Prediction functions
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

-- Get closest target
local function get_closest_target(fov_size, aimpart, team_check)
    local best_part, best_player, best_root
    local max_distance = fov_size
    local mousepos = UserInputService:GetMouseLocation()
    
    if not entitylist then return nil, nil, nil end
    
    for userid, v in pairs(entitylist) do
        local player = v.Player
        if not (player and player ~= LocalPlayer) then continue end
        
        local root = v.RootPart
        local worldmodel = v.WorldModel
        local character = v.Character
        
        if not (root and worldmodel and character) then continue end
        
        local part = worldmodel:FindFirstChild(aimpart)
        if not part then continue end
        
        local position, onscreen = Camera:WorldToViewportPoint(part.Position)
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

-- Full prediction
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
    
    local campos = Camera.CFrame.Position
    local velocity = (target_collider and target_collider.AssemblyLinearVelocity) or Vector3.zero
    
    if SilentAim.flags.ResolveY then velocity = Vector3.new(velocity.X, 0, velocity.Z) end
    if SilentAim.flags.InstantBullet then velocity = Vector3.zero end
    
    if SilentAim.prediction_mode == "axal" then
        return predict_axal(campos, target_position, velocity, proj_speed, proj_drop)
    elseif SilentAim.prediction_mode == "priv9" then
        return predict_priv9(campos, target_position, velocity, proj_speed, proj_drop)
    end
    
    return predict_axal(campos, target_position, velocity, proj_speed, proj_drop)
end

-- Silent aim hook (COMPLETAMENTE ORIGINAL DO SEU BACKUP)
local old = nil
old = hookfunction(buffer.create, function(size, ...)
    if size ~= 300 then
        return old(size, ...)
    end
    
    local args = {...}
    local Route = args[1]
    local Payload = args[2]
    
    if not debug.traceback():find("GunController") then
        return old(size, ...)
    end
    
    local stack = debug.getstack(3, 1)
    if type(stack) ~= "table" then
        return old(size, ...)
    end
    
    if type(stack[3]) == "table" and stack[3].Resimulation ~= nil then
        return old(size, ...)
    end
    
    local cam = Workspace.CurrentCamera
    local pitch, yaw, roll = cam.CFrame:ToEulerAnglesYXZ()
    
    local pred
    local part, player, collider = get_closest_target(SilentAim.flags.FovSize, SilentAim.flags.AimPart, SilentAim.flags.TeamCheck)
    
    if part then
        pred = full_prediction_silent(part.Position, collider)
    end
    
    local ld
    
    if pred and SilentAim.flags.SilentEnabled then
        ld = CFrame.lookAt(cam.CFrame.Position, pred)
    else
        ld = cam.CFrame.LookVector
    end
    
    local spread = Vector3.zero
    
    if SilentAim.flags.NoSpread then
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
    local pitch2, yaw2, roll2 = cf:ToEulerAnglesYXZ()
    local dir = cf.LookVector
    local r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    
    stack[32] = cf
    stack[33] = dir
    stack[34] = dir
    stack[36] = pitch2
    stack[37] = yaw2
    stack[38] = CFrame.new(0, 0, 0, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    stack[39] = CFrame.new(0, 0, 0, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    stack[44] = CFrame.new(0, 0, 0, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    stack[45] = dir
    stack[46] = dir
    
    return old(size, ...)
end)

-- Public methods
function SilentAim.setEnabled(v) SilentAim.flags.SilentEnabled = v end
function SilentAim.setTeamCheck(v) SilentAim.flags.TeamCheck = v end
function SilentAim.setFOVRadius(v) SilentAim.flags.FovSize = v; fovcircle.Radius = v end
function SilentAim.setFOVVisible(v) fovcircle.Visible = v end
function SilentAim.setAimPart(v) SilentAim.flags.AimPart = v end
function SilentAim.setPredictionMode(v) SilentAim.prediction_mode = v == "Axal" and "axal" or "priv9" end
function SilentAim.setNoSpread(v) SilentAim.flags.NoSpread = v end
function SilentAim.setResolveY(v) SilentAim.flags.ResolveY = v end
function SilentAim.setInstantBullet(v) SilentAim.flags.InstantBullet = v end

return SilentAim
