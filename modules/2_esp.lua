-- MÓDULO 2: ESP
local ESP = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

-- Configurações
_G.gameObjects.ESPEnabled = false
_G.gameObjects.boxEnabled = false
_G.gameObjects.boxFilledEnabled = false
_G.gameObjects.boxOutlineEnabled = false
_G.gameObjects.nameEnabled = false
_G.gameObjects.distanceEnabled = false
_G.gameObjects.skeletonEnabled = false
_G.gameObjects.boxColor = Color3.fromRGB(255, 255, 255)
_G.gameObjects.boxOutlineColor = Color3.fromRGB(0, 0, 0)
_G.gameObjects.nameColor = Color3.fromRGB(255, 255, 255)
_G.gameObjects.distanceColor = Color3.fromRGB(255, 255, 255)
_G.gameObjects.skeletonColor = Color3.fromRGB(255, 255, 255)
_G.gameObjects.maxESPDistance = 1000

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

local function RemoveESP(entity)
    local esp = _G.gameObjects.ESPs[entity]
    if esp then
        if esp.Connection then esp.Connection:Disconnect() end
        for _, drawing in pairs(esp.Drawings or {}) do
            if drawing then pcall(function() drawing:Remove() end) end
        end
        for _, line in pairs(esp.SkeletonLines or {}) do
            if line then pcall(function() line:Remove() end) end
        end
        _G.gameObjects.ESPs[entity] = nil
    end
end

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
    if not _G.gameObjects.skeletonEnabled or not entity then return end
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
                line.Color = _G.gameObjects.skeletonColor
                line.Visible = true
            else
                line.Visible = false
            end
        else
            if line then line.Visible = false end
        end
    end
end

function ESP.AddEntity(entity)
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
    Drawings.Name.Color = _G.gameObjects.nameColor
    Drawings.Name.Center = true
    Drawings.Name.Outline = true
    Drawings.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    Drawings.Name.Size = 14
    Drawings.Name.Visible = false

    Drawings.Distance.Color = _G.gameObjects.distanceColor
    Drawings.Distance.Center = true
    Drawings.Distance.Outline = true
    Drawings.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    Drawings.Distance.Size = 13
    Drawings.Distance.Visible = false

    local connection = RunService.RenderStepped:Connect(function()
        if not _G.gameObjects.ESPEnabled then
            for _, d in pairs(Drawings) do if d then d.Visible = false end end
            for _, l in pairs(skeletonLines) do if l then l.Visible = false end end
            return
        end
        if not entity or not entity.Parent or not IsEntityAlive(entity) then RemoveESP(entity) return end

        UpdateSkeleton(entity, skeletonLines)

        local Head = entity:FindFirstChild('Head')
        local UpperTorso = entity:FindFirstChild('UpperTorso')
        local LowerTorso = entity:FindFirstChild('LowerTorso')
        local HumanoidRootPart = entity:FindFirstChild('HumanoidRootPart')
        local rootPart = HumanoidRootPart or UpperTorso or LowerTorso
        local headPart = Head or UpperTorso
        if not rootPart or not headPart then
            for _, d in pairs(Drawings) do if d then d.Visible = false end end
            return
        end

        local distance = (rootPart.Position - CurrentCamera.CFrame.Position).Magnitude
        if distance > _G.gameObjects.maxESPDistance then
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
            Drawings.Box.Size = Vector2.new(width, height)
            Drawings.Box.Position = Vector2.new(xPos, yPos)
            Drawings.Box.Visible = _G.gameObjects.boxEnabled
            Drawings.Box.Color = _G.gameObjects.boxColor
            Drawings.Box.Thickness = 1
            Drawings.Box.Filled = _G.gameObjects.boxFilledEnabled
            Drawings.Box.Transparency = _G.gameObjects.boxFilledEnabled and 0.5 or 0

            Drawings.BoxOutline.Size = Vector2.new(width, height)
            Drawings.BoxOutline.Position = Vector2.new(xPos, yPos)
            Drawings.BoxOutline.Visible = _G.gameObjects.boxOutlineEnabled
            Drawings.BoxOutline.Color = _G.gameObjects.boxOutlineColor
            Drawings.BoxOutline.Thickness = 2
            Drawings.BoxOutline.ZIndex = 1
            Drawings.Box.ZIndex = 2

            Drawings.Name.Position = Vector2.new(centerX, yPos - 18)
            Drawings.Name.Text = "[" .. player.Name .. "]"
            Drawings.Name.Visible = _G.gameObjects.nameEnabled
            Drawings.Name.Color = _G.gameObjects.nameColor
            Drawings.Name.ZIndex = 3

            local meters = math.floor(distance / 2.5714)
            Drawings.Distance.Position = Vector2.new(centerX, yPos + height + 5)
            Drawings.Distance.Text = string.format("[%d M]", meters)
            Drawings.Distance.Visible = _G.gameObjects.distanceEnabled
            Drawings.Distance.Color = _G.gameObjects.distanceColor
            Drawings.Distance.ZIndex = 3
        else
            for _, d in pairs(Drawings) do if d then d.Visible = false end end
        end
    end)
    
    _G.gameObjects.ESPs[entity] = { Connection = connection, Drawings = Drawings, SkeletonLines = skeletonLines, Player = player }
end

function ESP.Refresh()
    for _, entity in pairs(_G.gameObjects.entitiesfolder:GetChildren()) do
        if entity:IsA("Model") and IsEntityAlive(entity) then
            local player = GetPlayerFromEntity(entity)
            if player and player ~= LocalPlayer then ESP.AddEntity(entity) end
        end
    end
end

-- Inicializa ESP
for _, entity in pairs(_G.gameObjects.entitiesfolder:GetChildren()) do
    if entity:IsA("Model") then
        local player = GetPlayerFromEntity(entity)
        if player and player ~= LocalPlayer then task.wait(0.1); ESP.AddEntity(entity) end
    end
end
_G.gameObjects.entitiesfolder.ChildAdded:Connect(function(entity)
    task.wait(0.1)
    if entity:IsA("Model") and IsEntityAlive(entity) then
        local player = GetPlayerFromEntity(entity)
        if player and player ~= LocalPlayer then ESP.AddEntity(entity) end
    end
end)
_G.gameObjects.entitiesfolder.ChildRemoved:Connect(RemoveESP)
ESP.Refresh()

return ESP
