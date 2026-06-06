-- MÓDULO: FUNCIONALIDADES FALTANTES
local Missing = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lighting = game:GetService("Lighting")
local Workspace = workspace

-- ========== VARIÁVEIS GLOBAIS ==========
Missing.gameObjects = {
    veiculosData = {},
    targetVelocities = {},
    flyKeys = { Forward = false, Backward = false, Left = false, Right = false, Up = false, Down = false },
    HITSOUND_OPTIONS = {
        ["Rust"] = 5043539486, ["Minecraft"] = 140322880337590, ["Pop"] = 6586979979,
        ["CS"] = 5764885315, ["Neverlose"] = 97643101798871, ["Gamesense"] = 4817809188, ["nn dog"] = 5902468562
    },
    carEspEnabled = false,
    previewSound = nil,
    originalLightingSettings = {
        Brightness = lighting.Brightness,
        ClockTime = lighting.ClockTime,
        GlobalShadows = lighting.GlobalShadows,
        OutdoorAmbient = lighting.OutdoorAmbient
    }
}

-- Inicializa o som de preview
Missing.gameObjects.previewSound = Instance.new("Sound", game:GetService("SoundService"))
Missing.gameObjects.previewSound.Volume = 2.0

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

local function updateFOVShape(shape, spinAngle, center, radius, thickness, color)
    if fovShapeObjects.current then
        if type(fovShapeObjects.current) == "table" then
            for _, obj in pairs(fovShapeObjects.current) do pcall(function() obj:Remove() end) end
        else
            pcall(function() fovShapeObjects.current:Remove() end)
        end
        fovShapeObjects.current = nil
    end

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

-- ========== CAR ESP ==========
local NOME_MODELO_CARRO = "WorldModel"
local RENDER_DIST = 4000
local COR_NOME = Color3.fromRGB(255, 0, 0)
local COR_DIST = Color3.fromRGB(255, 105, 180)
local TEXTO_VEIC = "Car"
local HEIGHT_OFFSET = 5

local function atualizarVeiculos()
    for _, info in ipairs(Missing.gameObjects.veiculosData) do
        if info.txt then pcall(function() info.txt:Remove() end) end
        if info.dist then pcall(function() info.dist:Remove() end) end
    end
    Missing.gameObjects.veiculosData = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == NOME_MODELO_CARRO then
            table.insert(Missing.gameObjects.veiculosData, { modelo = obj, txt = nil, dist = nil })
        end
    end
end

workspace.ChildAdded:Connect(function(c) 
    if c:IsA("Model") and c.Name == NOME_MODELO_CARRO then atualizarVeiculos() end 
end)
workspace.ChildRemoved:Connect(function(c) 
    if c:IsA("Model") and c.Name == NOME_MODELO_CARRO then atualizarVeiculos() end 
end)
atualizarVeiculos()

local function updateCarESP()
    if not Missing.gameObjects.carEspEnabled then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    
    for _, info in pairs(Missing.gameObjects.veiculosData) do
        if info.modelo and info.modelo.Parent then
            local ok, pivot = pcall(function() return info.modelo:GetPivot() end)
            if ok and pivot then
                local pos = pivot.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
                local dist = (cam.CFrame.Position - pivot.Position).Magnitude
                local pos2D, onScreen = cam:WorldToViewportPoint(pos)
                
                if dist <= RENDER_DIST and onScreen and pos2D.Z > 0 then
                    if not info.txt then
                        info.txt = Drawing.new("Text")
                        info.txt.Font = 2
                        info.txt.Size = 19
                        info.txt.Color = COR_NOME
                        info.txt.Center = true
                        info.txt.Outline = true
                    end
                    info.txt.Text = TEXTO_VEIC
                    info.txt.Position = Vector2.new(pos2D.X, pos2D.Y)
                    info.txt.Visible = true
                    
                    if not info.dist then
                        info.dist = Drawing.new("Text")
                        info.dist.Font = 1
                        info.dist.Size = 15
                        info.dist.Color = COR_DIST
                        info.dist.Center = true
                        info.dist.Outline = true
                    end
                    info.dist.Text = string.format("(%dm)", math.floor(dist / 3.6))
                    info.dist.Position = Vector2.new(pos2D.X, pos2D.Y + 15)
                    info.dist.Visible = true
                else
                    if info.txt then info.txt.Visible = false end
                    if info.dist then info.dist.Visible = false end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(updateCarESP)

-- ========== HITSOUNDS ==========
local hitsoundsConnection = nil

function Missing.playSoundPreview(soundId)
    if Missing.gameObjects.previewSound then
        Missing.gameObjects.previewSound.SoundId = "rbxassetid://" .. tostring(soundId)
        Missing.gameObjects.previewSound:Play()
    end
end

function Missing.setupHitsounds(enabled, hitmarkerSound, headshotSound, library)
    if enabled then
        local SOUNDS_FOLDER_PATH = { "GunSystemAssets", "Sounds", "DefaultHitmarker" }
        local SOUND_REPLACEMENTS = {
            Hitmarker = "rbxassetid://" .. tostring(Missing.gameObjects.HITSOUND_OPTIONS[hitmarkerSound]),
            Headshot = "rbxassetid://" .. tostring(Missing.gameObjects.HITSOUND_OPTIONS[headshotSound])
        }
        
        local function findSoundsFolder()
            local current = ReplicatedStorage
            for _, folderName in ipairs(SOUNDS_FOLDER_PATH) do
                current = current:FindFirstChild(folderName)
                if not current then return nil end
            end
            return current
        end
        
        local function replaceSounds()
            local soundsFolder
            while true do
                soundsFolder = findSoundsFolder()
                if soundsFolder then break end
                task.wait(1)
            end
            for soundName, newId in pairs(SOUND_REPLACEMENTS) do
                local sound = soundsFolder:FindFirstChild(soundName)
                if sound and sound:IsA("Sound") then
                    if not sound:FindFirstChild("__backup") then
                        local backup = sound:Clone()
                        backup.Name = "__backup"
                        backup.Parent = sound
                    end
                    sound.SoundId = newId
                    sound.Volume = 2.0
                end
            end
        end
        
        local function interceptNewSounds()
            workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Sound") then
                    task.wait(0.05)
                    for soundName, newId in pairs(SOUND_REPLACEMENTS) do
                        if descendant.Name == soundName then
                            descendant.SoundId = newId
                            descendant.Volume = 2.0
                        end
                    end
                end
            end)
        end
        
        hitsoundsConnection = {
            replace = task.spawn(replaceSounds),
            intercept = task.spawn(interceptNewSounds)
        }
        
        if library then
            library:Notify("Hitsounds On", 3)
        end
    else
        if hitsoundsConnection then
            if hitsoundsConnection.replace then pcall(function() task.cancel(hitsoundsConnection.replace) end) end
            if hitsoundsConnection.intercept then pcall(function() hitsoundsConnection.intercept:Disconnect() end) end
            hitsoundsConnection = nil
        end
        if library then
            library:Notify("Hitsounds Off", 3)
        end
    end
end

-- ========== NO GUN SWAY/BOB ==========
local swayBackup = {}
local bobBackup = {}

function Missing.setNoGunSway(enabled)
    for _, obj in getgc(true) do
        if typeof(obj) == "table" and rawget(obj, "_positionVelocity") and type(rawget(obj, "_positionVelocity")) == "function" then
            if not swayBackup[obj] then
                swayBackup[obj] = rawget(obj, "_positionVelocity")
            end
            if enabled then
                rawset(obj, "_positionVelocity", function(self, now)
                    return Vector3.zero, Vector3.zero
                end)
            else
                if swayBackup[obj] then
                    rawset(obj, "_positionVelocity", swayBackup[obj])
                end
            end
        end
    end
end

function Missing.setNoGunBob(enabled)
    for _, tbl in getgc(true) do
        if type(tbl) == 'table' and rawget(tbl, 'BobSpeed') then
            if not bobBackup[tbl] then
                bobBackup[tbl] = {
                    BobSpeed = tbl.BobSpeed,
                    BobAmplitudeHorizontal = tbl.BobAmplitudeHorizontal,
                    BobAmplitudeVertical = tbl.BobAmplitudeVertical,
                    MovementOffset = tbl.MovementOffset,
                    CrouchOffset = tbl.CrouchOffset,
                    TransitionRate = tbl.TransitionRate,
                    TransitionRateCrouch = tbl.TransitionRateCrouch,
                    BobPower = tbl.BobPower
                }
            end
            if enabled then
                tbl.BobSpeed = 0
                tbl.BobAmplitudeHorizontal = 0
                tbl.BobAmplitudeVertical = 0
                tbl.MovementOffset = Vector3.new()
                tbl.CrouchOffset = Vector3.new()
                tbl.TransitionRate = 0
                tbl.TransitionRateCrouch = 0
                tbl.BobPower = 0
            else
                local saved = bobBackup[tbl]
                if saved then
                    tbl.BobSpeed = saved.BobSpeed
                    tbl.BobAmplitudeHorizontal = saved.BobAmplitudeHorizontal
                    tbl.BobAmplitudeVertical = saved.BobAmplitudeVertical
                    tbl.MovementOffset = saved.MovementOffset
                    tbl.CrouchOffset = saved.CrouchOffset
                    tbl.TransitionRate = saved.TransitionRate
                    tbl.TransitionRateCrouch = saved.TransitionRateCrouch
                    tbl.BobPower = saved.BobPower
                end
            end
        end
    end
end

-- ========== OFFSET CHANGER ==========
local offsetX, offsetY, offsetZ = 0, 0, 0
local offsetEnabled = false

function Missing.applyOffsetChanger()
    if not offsetEnabled then return end
    local gunSystemAssets = ReplicatedStorage:FindFirstChild("GunSystemAssets")
    if not gunSystemAssets then return end
    local gunData = gunSystemAssets:FindFirstChild("GunData")
    if not gunData then return end

    for _, armaFolder in ipairs(gunData:GetChildren()) do
        local stats = armaFolder:FindFirstChild("Stats")
        if stats then
            local offset = stats:FindFirstChild("Offset")
            if offset and offset:IsA("Vector3Value") then
                offset.Value = Vector3.new(offsetX, offsetY, offsetZ)
            end
        end
    end
end

function Missing.setOffsetEnabled(enabled)
    offsetEnabled = enabled
    if enabled then
        Missing.applyOffsetChanger()
    else
        -- Restaurar offsets originais
        local gunSystemAssets = ReplicatedStorage:FindFirstChild("GunSystemAssets")
        if gunSystemAssets then
            local gunData = gunSystemAssets:FindFirstChild("GunData")
            if gunData then
                for _, armaFolder in ipairs(gunData:GetChildren()) do
                    local stats = armaFolder:FindFirstChild("Stats")
                    if stats then
                        local offset = stats:FindFirstChild("Offset")
                        if offset and offset:IsA("Vector3Value") then
                            offset.Value = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end
        end
    end
end

function Missing.setOffsetX(v) offsetX = v; if offsetEnabled then Missing.applyOffsetChanger() end end
function Missing.setOffsetY(v) offsetY = v; if offsetEnabled then Missing.applyOffsetChanger() end end
function Missing.setOffsetZ(v) offsetZ = v; if offsetEnabled then Missing.applyOffsetChanger() end end

-- ========== HITBOX EXPANDER ==========
local hitboxExpanderEnabled = false
local hitboxExpanderRadius = 5

function Missing.removeFakeHeadsHitbox(Character)
    if not Character then return end
    for _, Head in Character:QueryDescendants("[$FakeHead]") do
        pcall(function() Head:Destroy() end)
    end
end

function Missing.setHitboxHeads(Character, Remove)
    if not Character then return end
    Missing.removeFakeHeadsHitbox(Character)
    
    if Remove or not hitboxExpanderEnabled then return end
    
    local RealHead = Character:FindFirstChild("Head")
    if not RealHead then return end
    
    local RealNeck = RealHead:FindFirstChild("Neck")
    local BaseC0 = RealNeck and RealNeck.C0 or CFrame.identity
    
    local VisualHead = RealHead:Clone()
    if VisualHead:FindFirstChild("face") then VisualHead.face:Destroy() end
    VisualHead.Shape = Enum.PartType.Ball
    VisualHead.Size = Vector3.one * hitboxExpanderRadius * 2
    VisualHead.Color = Color3.fromRGB(138, 50, 255)
    VisualHead.Material = Enum.Material.ForceField
    VisualHead.CanCollide = false
    VisualHead.CanQuery = false
    VisualHead.CanTouch = false
    VisualHead.Massless = true
    VisualHead.CastShadow = false
    VisualHead:SetAttribute("FakeHead", true)
    VisualHead.Parent = Character
    VisualHead.Transparency = 0.8
    
    local SizeRadius = hitboxExpanderRadius - 0.5
    if SizeRadius <= 0 then return end
    
    for X = -SizeRadius, SizeRadius do
        for Y = -SizeRadius, SizeRadius do
            for Z = -SizeRadius, SizeRadius do
                local Distance = math.sqrt(X * X + Y * Y + Z * Z) - SizeRadius
                if Distance <= 0.5 and Distance >= -0.5 then
                    local NewHead = RealHead:Clone()
                    if NewHead:FindFirstChild("face") then NewHead.face:Destroy() end
                    NewHead.CanCollide = true
                    NewHead.CanQuery = true
                    NewHead.CanTouch = false
                    NewHead.Massless = true
                    NewHead.CastShadow = false
                    NewHead.Transparency = 1
                    NewHead:SetAttribute("FakeHead", true)
                    NewHead.Parent = Character
                    
                    local Neck = NewHead:FindFirstChild("Neck")
                    if Neck then
                        Neck.C0 = BaseC0 * CFrame.new(X, Y, Z)
                    end
                end
            end
        end
    end
end

function Missing.setHitboxExpanderEnabled(enabled)
    hitboxExpanderEnabled = enabled
end

function Missing.setHitboxExpanderRadius(radius)
    hitboxExpanderRadius = radius
end

-- ========== INSTANT AIM ==========
function Missing.enableInstantAim()
    for _, v in next, getgc(true) do
        if type(v) == 'table' then
            for i, val in next, v do
                if type(i) == 'string' and i:find('GunAim') then
                    if type(val) == 'number' then 
                        v[i] = 100000000
                    elseif type(val) == 'function' then 
                        hookfunction(val, function() return 100000000 end)
                    end
                end
            end
        end
    end
end

-- ========== REMOVE CLOUDS ==========
function Missing.setRemoveClouds(remove)
    if workspace.Terrain:FindFirstChild("Clouds") then
        workspace.Terrain.Clouds.Enabled = not remove
    end
end

-- ========== NO INVENTORY BLUR ==========
local noInventoryBlurLoop = nil
local noInventoryBlurEnabled = false

function Missing.setNoInventoryBlur(enabled)
    noInventoryBlurEnabled = enabled
    if noInventoryBlurLoop then task.cancel(noInventoryBlurLoop); noInventoryBlurLoop = nil end
    if enabled then
        noInventoryBlurLoop = task.spawn(function()
            while noInventoryBlurEnabled do
                local cam = workspace.CurrentCamera
                local blur = cam and cam:FindFirstChild("Blur")
                if blur then blur.Enabled = false end
                task.wait(0.5)
            end
        end)
    else
        local cam = workspace.CurrentCamera
        local blur = cam and cam:FindFirstChild("Blur")
        if blur then blur.Enabled = true end
    end
end

-- ========== SCANNER ==========
Missing.scannerRunning = false

function Missing.runScanner()
    if Missing.scannerRunning then return end
    Missing.scannerRunning = true
    task.spawn(function()
        local success, PlayersRef = pcall(function() return cloneref(game:GetService("Players")) end)
        if not success then Missing.scannerRunning = false; return end
        local success2, HttpService = pcall(function() return cloneref(game:GetService("HttpService")) end)
        if not success2 then Missing.scannerRunning = false; return end

        local Map = {
            ["Barret50"] = true, ["RenelliM4"] = true, ["M79"] = true,
            ["SVD"] = true, ["AKM"] = true, ["Saiga"] = true, ["AWM"] = true,
            ["MRAD"] = true, ["m110k"] = true, ["P90"] = true, ["M4A1"] = true,
            ["MCX"] = true, ["HoneyBadger"] = true, ["MK47"] = true, ["MK18"] = true,
            ["FN-FAL"] = true, ["Famas"] = true, ["SCAR-H"] = true, ["SPAS-12"] = true,
            ["AsVal"] = true, ["M249"] = true, ["PKM"] = true,
            ["AltynHelmet"] = true, ["RatnikVest"] = true, ["VestTier3"] = true,
            ["Mulepack"] = true, ["DuffleBag"] = true, ["BackpackTier4"] = true, ["BackpackTier3"] = true,
        }

        local Attributes = {
            ["Pants"] = "EquipmentPants", ["Shirt"] = "EquipmentShirt", ["Hat"] = "EquipmentHat",
            ["Vest"] = "EquipmentVest", ["Mask"] = "EquipmentMask", ["Backpack"] = "EquipmentBackpack",
            ["Shoes"] = "EquipmentShoes",
        }

        for Index, Val in Map do Map[Index] = nil; Map[Index:lower()] = Val end

        local Found = {}
        local LocalPlayerRef = PlayersRef.LocalPlayer
        if not LocalPlayerRef then Missing.scannerRunning = false; return end

        for _, Player in PlayersRef:GetPlayers() do
            if Player == LocalPlayerRef then continue end
            pcall(function()
                for _, Attribute in Attributes do
                    local Attr = Player:GetAttribute(Attribute)
                    if Attr then
                        local success3, decoded = pcall(function() return HttpService:JSONDecode(Attr) end)
                        if success3 and decoded and decoded.ClassName then
                            local Text = decoded.ClassName:gsub("%.item", "")
                            if Map[Text:lower()] then
                                table.insert(Found, { Player = Player, Gun = Text })
                            end
                        end
                    end
                end
                local GunInventory = Player:FindFirstChild("GunInventory")
                if GunInventory then
                    for _, Slot in GunInventory:GetChildren() do
                        local Gun = Slot.Value
                        if Gun and Map[Gun.Name:lower()] then
                            local Mag = Slot:FindFirstChild("BulletsInMagazine")
                            local Reserve = Slot:FindFirstChild("BulletsInReserve")
                            table.insert(Found, {
                                Player = Player,
                                Gun = string.format("%s (%s) with %d ammo",
                                    Gun:FindFirstChild("DisplayName") and Gun.DisplayName.Value or Gun.Name,
                                    Gun.Name,
                                    (Mag and Mag.Value or 0) + (Reserve and Reserve.Value or 0))
                            })
                        end
                    end
                end
            end)
        end

        local CoreGui = game:GetService("CoreGui")
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.IgnoreGuiInset = true
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = CoreGui

        local function CreateBar(text, order)
            local Frame = Instance.new("Frame")
            Frame.Parent = ScreenGui
            Frame.Size = UDim2.new(0, 380, 0, 26)
            Frame.Position = UDim2.new(1, -20, 0, 40 + (order * 30))
            Frame.AnchorPoint = Vector2.new(1, 0)
            Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
            Frame.BackgroundTransparency = 0.25
            Frame.BorderSizePixel = 2
            Frame.BorderColor3 = Color3.fromRGB(0, 0, 120)
            local Label = Instance.new("TextLabel")
            Label.Parent = Frame
            Label.Size = UDim2.new(1, -8, 1, 0)
            Label.Position = UDim2.new(0, 4, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(220, 220, 255)
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Text = text
            return Frame
        end

        local header = CreateBar("Found " .. #Found .. " things that match", 0)
        local bars = {}
        for i, Data in ipairs(Found) do
            table.insert(bars, CreateBar(Data.Player.Name .. " — " .. Data.Gun, i))
        end

        task.delay(4, function()
            for t = 1, 20 do
                local alpha = t / 20
                pcall(function()
                    header.BackgroundTransparency = 0.25 + alpha
                    header.TextLabel.TextTransparency = alpha
                    for _, bar in ipairs(bars) do
                        bar.BackgroundTransparency = 0.25 + alpha
                        bar.TextLabel.TextTransparency = alpha
                    end
                end)
                task.wait(0.05)
            end
            pcall(function() ScreenGui:Destroy() end)
            Missing.scannerRunning = false
        end)
    end)
end

-- Exporta tudo
Missing.fovShapeObjects = fovShapeObjects
Missing.updateFOVShape = updateFOVShape
Missing.setCarEspEnabled = function(v) Missing.gameObjects.carEspEnabled = v end
Missing.setNoInventoryBlur = Missing.setNoInventoryBlur
Missing.setRemoveClouds = Missing.setRemoveClouds
Missing.enableInstantAim = Missing.enableInstantAim

return Missing
