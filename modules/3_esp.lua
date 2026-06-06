-- MÓDULO: ESP
local ESP = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configurações
ESP.config = {
    enabled = false,
    boxEnabled = false,
    boxFilledEnabled = false,
    boxOutlineEnabled = false,
    nameEnabled = false,
    distanceEnabled = false,
    skeletonEnabled = false,
    boxColor = Color3.fromRGB(255, 255, 255),
    boxOutlineColor = Color3.fromRGB(0, 0, 0),
    nameColor = Color3.fromRGB(255, 255, 255),
    distanceColor = Color3.fromRGB(255, 255, 255),
    skeletonColor = Color3.fromRGB(255, 255, 255),
    maxESPDistance = 1000
}

ESP.gameObjects = {
    ESPs = {},
    entitiesfolder = nil,
    custommeshcharacter = nil,
    playerlist = nil
}

-- Funções auxiliares
local function worldToScreen(pos)
    local cam = workspace.CurrentCamera
    if not cam then return Vector2.new(0, 0), false end
    local pt, onScreen = cam:WorldToViewportPoint(pos)
    return Vector2.new(pt.X, pt.Y), onScreen
end

local function GetPlayerFromEntity(entity)
    if not entity or not ESP.gameObjects.custommeshcharacter or not ESP.gameObjects.playerlist then return nil end
    local char = ESP.gameObjects.custommeshcharacter:GetCharacterFromWorldCharacter(entity)
    if not char then return nil end
    local playerdata = ESP.gameObjects.playerlist:GetPlayerFromCharacter(char)
    if playerdata and playerdata.Name then return Players:FindFirstChild(playerdata.Name) end
    return nil
end

local function IsEntityAlive(entity)
    if not entity or not entity:IsA("Model") then return false end
    return entity:FindFirstChild("UpperTorso") ~= nil
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
    if not ESP.config.skeletonEnabled or not entity or not workspace.CurrentCamera then return end
    local cam = workspace.CurrentCamera
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
            local pos1, on1 = cam:WorldToViewportPoint(part1.Position)
            local pos2, on2 = cam:WorldToViewportPoint(part2.Position)
            if on1 and on2 then
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                line.Color = ESP.config.skeletonColor
                line.Visible = true
            else
                line.Visible = false
            end
        else
            if line then line.Visible = false end
        end
    end
end

local function updateESPBoxes(drawings, xPos, yPos, width, height)
    if ESP.config.boxEnabled then
        drawings.Box.Size = Vector2.new(width, height)
        drawings.Box.Position = Vector2.new(xPos, yPos)
        drawings.Box.Visible = true
        drawings.Box.Color = ESP.config.boxColor
        drawings.Box.Thickness = 1
        drawings.Box.Filled = ESP.config.boxFilledEnabled
        drawings.Box.Transparency = ESP.config.boxFilledEnabled and 0.5 or 0
    else
        drawings.Box.Visible = false
    end
    
    if ESP.config.boxOutlineEnabled then
        drawings.BoxOutline.Size = Vector2.new(width, height)
        drawings.BoxOutline.Position = Vector2.new(xPos, yPos)
        drawings.BoxOutline.Visible = true
        drawings.BoxOutline.Color = ESP.config.boxOutlineColor
        drawings.BoxOutline.Thickness = 2
    else
        drawings.BoxOutline.Visible = false
    end
end

local function updateESPTexts(drawings, player, distance, centerX, yPos, height)
    if ESP.config.nameEnabled then
        drawings.Name.Position = Vector2.new(centerX, yPos - 18)
        drawings.Name.Text = "[" .. player.Name .. "]"
        drawings.Name.Visible = true
        drawings.Name.Color = ESP.config.nameColor
    else
        drawings.Name.Visible = false
    end
    
    if ESP.config.distanceEnabled then
        local meters = math.floor(distance / 2.5714)
        drawings.Distance.Position = Vector2.new(centerX, yPos + height + 5)
        drawings.Distance.Text = string.format("[%d M]", meters)
        drawings.Distance.Visible = true
        drawings.Distance.Color = ESP.config.distanceColor
    else
        drawings.Distance.Visible = false
    end
end

local function updateESPCleanup(drawings, skeletonLines)
    for _, d in pairs(drawings) do if d then d.Visible = false end end
    for _, l in pairs(skeletonLines) do if l then l.Visible = false end end
end

local function processESPFrame(entity, player, drawings, skeletonLines)
    local cam = workspace.CurrentCamera
    if not ESP.config.enabled then
        updateESPCleanup(drawings, skeletonLines)
        return
    end
    if not entity or not entity.Parent or not IsEntityAlive(entity) then 
        ESP.RemoveEntity(entity)
        return 
    end

    UpdateSkeleton(entity, skeletonLines)

    local Head = entity:FindFirstChild('Head')
    local UpperTorso = entity:FindFirstChild('UpperTorso')
    local LowerTorso = entity:FindFirstChild('LowerTorso')
    local HumanoidRootPart = entity:FindFirstChild('HumanoidRootPart')
    local rootPart = HumanoidRootPart or UpperTorso or LowerTorso
    local headPart = Head or UpperTorso
    
    if not rootPart or not headPart or not cam then
        updateESPCleanup(drawings, skeletonLines)
        return
    end

    local distance = (rootPart.Position - cam.CFrame.Position).Magnitude
    if distance > ESP.config.maxESPDistance then
        updateESPCleanup(drawings, skeletonLines)
        return
    end

    local headPos = headPart.Position + Vector3.new(0, 1.5, 0)
    local feetPos = rootPart.Position - Vector3.new(0, 3, 0)
    local topPos, topOn = cam:WorldToViewportPoint(headPos)
    local bottomPos, bottomOn = cam:WorldToViewportPoint(feetPos)
    
    if not topOn and not bottomOn then
        updateESPCleanup(drawings, skeletonLines)
        return
    end

    local height = bottomPos.Y - topPos.Y
    local width = height * 0.65
    local centerX = (topPos.X + bottomPos.X) / 2
    
    if width > 0 and height > 0 then
        local yPos = topPos.Y
        local xPos = centerX - width / 2
        
        updateESPBoxes(drawings, xPos, yPos, width, height)
        updateESPTexts(drawings, player, distance, centerX, yPos, height)
    else
        updateESPCleanup(drawings, skeletonLines)
    end
end

function ESP.AddEntity(entity)
    ESP.RemoveEntity(entity)
    local player = GetPlayerFromEntity(entity)
    if not player or player == LocalPlayer then return end

    local skeletonLines = CreateSkeletonLines()
    local Drawings = {
        Box = Drawing.new('Square'),
        BoxOutline = Drawing.new('Square'),
        Name = Drawing.new('Text'),
        Distance = Drawing.new('Text'),
    }
    Drawings.Name.Color = ESP.config.nameColor
    Drawings.Name.Center = true
    Drawings.Name.Outline = true
    Drawings.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    Drawings.Name.Size = 14
    Drawings.Name.Visible = false

    Drawings.Distance.Color = ESP.config.distanceColor
    Drawings.Distance.Center = true
    Drawings.Distance.Outline = true
    Drawings.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    Drawings.Distance.Size = 13
    Drawings.Distance.Visible = false

    local connection = RunService.RenderStepped:Connect(function()
        processESPFrame(entity, player, Drawings, skeletonLines)
    end)
    
    ESP.gameObjects.ESPs[entity] = { 
        Connection = connection, 
        Drawings = Drawings, 
        SkeletonLines = skeletonLines, 
        Player = player 
    }
end

function ESP.RemoveEntity(entity)
    local esp = ESP.gameObjects.ESPs[entity]
    if esp then
        if esp.Connection then pcall(function() esp.Connection:Disconnect() end) end
        for _, drawing in pairs(esp.Drawings or {}) do
            if drawing then pcall(function() drawing:Remove() end) end
        end
        for _, line in pairs(esp.SkeletonLines or {}) do
            if line then pcall(function() line:Remove() end) end
        end
        ESP.gameObjects.ESPs[entity] = nil
    end
end

function ESP.Refresh()
    if not ESP.gameObjects.entitiesfolder then return end
    for _, entity in pairs(ESP.gameObjects.entitiesfolder:GetChildren()) do
        if entity:IsA("Model") and IsEntityAlive(entity) then
            local player = GetPlayerFromEntity(entity)
            if player and player ~= LocalPlayer then ESP.AddEntity(entity) end
        end
    end
end

function ESP.SetEntitiesFolder(folder)
    ESP.gameObjects.entitiesfolder = folder
end

function ESP.SetCustomMeshCharacter(obj)
    ESP.gameObjects.custommeshcharacter = obj
end

function ESP.SetPlayerList(obj)
    ESP.gameObjects.playerlist = obj
end

-- Callbacks
function ESP.setEnabled(v) ESP.config.enabled = v end
function ESP.setBoxEnabled(v) ESP.config.boxEnabled = v end
function ESP.setBoxFilled(v) ESP.config.boxFilledEnabled = v end
function ESP.setBoxOutline(v) ESP.config.boxOutlineEnabled = v end
function ESP.setSkeleton(v) ESP.config.skeletonEnabled = v end
function ESP.setNames(v) ESP.config.nameEnabled = v end
function ESP.setDistances(v) ESP.config.distanceEnabled = v end
function ESP.setBoxColor(c) ESP.config.boxColor = c end
function ESP.setBoxOutlineColor(c) ESP.config.boxOutlineColor = c end
function ESP.setSkeletonColor(c) ESP.config.skeletonColor = c end
function ESP.setNameColor(c) ESP.config.nameColor = c end
function ESP.setDistanceColor(c) ESP.config.distanceColor = c end
function ESP.setMaxDistance(v) ESP.config.maxESPDistance = v end

return ESP
