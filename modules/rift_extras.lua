-- ============================================
-- RIFT EXTRAS
-- Zombie Expander, Car Speed, Hitbox Expander, Scanner, Skybox, No Inventory Blur
-- ============================================
local Extras = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lighting = game:GetService("Lighting")
local Workspace = workspace
local CoreGui = game:GetService("CoreGui")

-- ========== VARIÁVEIS ==========
local gameObjects = {}
gameObjects.veiculosData = {}
gameObjects.originalZombieHeads = {}
gameObjects.carEspEnabled = false
gameObjects.zombieExpanderEnabled = false
gameObjects.zombieHitboxSize = 16
gameObjects.zombieHeadTransparency = 0.9
gameObjects.zombieEntitiesFolder = nil
gameObjects.zombieExpanderLoop = nil
gameObjects.carSpeedEnabled = false
gameObjects.carForwardMaxSpeed = 100
gameObjects.carReverseMaxSpeed = 40
gameObjects.carAcceleration = 60
gameObjects.carDeceleration = 100
gameObjects.carBraking = 35
gameObjects.carSteeringReduction = 0.35
gameObjects.carDensity = 1
gameObjects.carElasticity = 0
gameObjects.carStaticFriction = 5
gameObjects.carKineticFriction = 4
gameObjects.carSlipThreshold = 1
gameObjects.carModLoop = nil
gameObjects.hitboxExpanderEnabled = false
gameObjects.hitboxExpanderRadius = 5
gameObjects.custommeshcharacter = nil
gameObjects.playerlist = nil
gameObjects.noInventoryBlurEnabled = false
gameObjects.noInventoryBlurLoop = nil
gameObjects.speedhack = { enabled = false, speed = 20 }
gameObjects.movementPart = nil
gameObjects.climbSpeedEnabled = false
gameObjects.climbSpeedValue = 15
gameObjects.climbSpeedLoop = nil
gameObjects.autoJumpEnabled = false
gameObjects.autoJumpConnection = nil
gameObjects.noCarDamageLoop = nil
gameObjects.offsetEnabled = false
gameObjects.offsetX = 0
gameObjects.offsetY = 0
gameObjects.offsetZ = 0

-- Inicializa dependências
pcall(function()
    gameObjects.custommeshcharacter = require(game.ReplicatedFirst:WaitForChild("GunSystemPlugins"):WaitForChild("CustomMeshCharacter"))
end)
pcall(function()
    gameObjects.playerlist = require(game.ReplicatedStorage:WaitForChild("CustomCharacter"):WaitForChild("PlayerList"))
end)

-- ========== SKYBOX ==========
local skyboxes = {
    ["Standard"] = { "91458024", "91457980", "91458024", "91458024", "91458024", "91458002" },
    ["Blue Sky"] = { "591058823", "591059876", "591058104", "591057861", "591057625", "591059642" },
    ["Vaporwave"] = { "1417494030", "1417494146", "1417494253", "1417494402", "1417494499", "1417494643" },
    ["Redshift"] = { "401664839", "401664862", "401664960", "401664881", "401664901", "401664936" },
    ["Blaze"] = { "150939022", "150939038", "150939047", "150939056", "150939063", "150939082" },
    ["Among Us"] = { "5752463190", "5752463190", "5752463190", "5752463190", "5752463190", "5752463190" },
    ["Dark Night"] = { "6285719338", "6285721078", "6285722964", "6285724682", "6285726335", "6285730635" },
    ["Bright Pink"] = { "271042516", "271077243", "271042556", "271042310", "271042467", "271077958" },
    ["Purple Sky"] = { "570557514", "570557775", "570557559", "570557620", "570557672", "570557727" },
    ["Galaxy"] = { "15125283003", "15125281008", "15125277539", "15125279325", "15125274388", "15125275800" },
}
local originalSkybox = {}
local sky = lighting:FindFirstChild("Sky")
if sky then
    originalSkybox = {
        SkyboxBk = sky.SkyboxBk, SkyboxDn = sky.SkyboxDn, SkyboxFt = sky.SkyboxFt,
        SkyboxLf = sky.SkyboxLf, SkyboxRt = sky.SkyboxRt, SkyboxUp = sky.SkyboxUp
    }
end

function Extras.applySkybox(skyboxName)
    local sky = lighting:FindFirstChild("Sky")
    if skyboxName == "Default" then
        if sky then sky:Destroy() end
        if originalSkybox then
            local newSky = Instance.new("Sky")
            newSky.Parent = lighting
            newSky.SkyboxBk = originalSkybox.SkyboxBk
            newSky.SkyboxDn = originalSkybox.SkyboxDn
            newSky.SkyboxFt = originalSkybox.SkyboxFt
            newSky.SkyboxLf = originalSkybox.SkyboxLf
            newSky.SkyboxRt = originalSkybox.SkyboxRt
            newSky.SkyboxUp = originalSkybox.SkyboxUp
        end
    elseif skyboxes[skyboxName] then
        if not sky then sky = Instance.new("Sky", lighting) end
        local data = skyboxes[skyboxName]
        sky.SkyboxBk = "rbxassetid://" .. data[1]
        sky.SkyboxDn = "rbxassetid://" .. data[2]
        sky.SkyboxFt = "rbxassetid://" .. data[3]
        sky.SkyboxLf = "rbxassetid://" .. data[4]
        sky.SkyboxRt = "rbxassetid://" .. data[5]
        sky.SkyboxUp = "rbxassetid://" .. data[6]
    end
end

-- ========== SCANNER ==========
local scannerRunning = false
function Extras.runScanner()
    if scannerRunning then return end
    scannerRunning = true
    task.spawn(function()
        local PlayersRef = cloneref(game:GetService("Players"))
        local HttpService = cloneref(game:GetService("HttpService"))

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

        local Found = {}
        local LocalPlayerRef = PlayersRef.LocalPlayer

        for _, Player in PlayersRef:GetPlayers() do
            if Player == LocalPlayerRef then continue end
            pcall(function()
                for _, Attribute in Attributes do
                    local Attr = Player:GetAttribute(Attribute)
                    if Attr then
                        local decoded = HttpService:JSONDecode(Attr)
                        if decoded and decoded.ClassName then
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
            scannerRunning = false
        end)
    end)
end

-- ========== CAR ESP ==========
local NOME_MODELO_CARRO = "WorldModel"
local RENDER_DIST = 4000
local COR_NOME = Color3.fromRGB(255, 0, 0)
local COR_DIST = Color3.fromRGB(255, 105, 180)
local TEXTO_VEIC = "Car"
local HEIGHT_OFFSET = 5

local function atualizarVeiculos()
    for _, info in ipairs(gameObjects.veiculosData) do
        if info.txt then pcall(function() info.txt:Remove() end) end
        if info.dist then pcall(function() info.dist:Remove() end) end
    end
    gameObjects.veiculosData = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == NOME_MODELO_CARRO then
            table.insert(gameObjects.veiculosData, { modelo = obj, txt = nil, dist = nil })
        end
    end
end
workspace.ChildAdded:Connect(function(c) if c:IsA("Model") and c.Name == NOME_MODELO_CARRO then atualizarVeiculos() end end)
workspace.ChildRemoved:Connect(function(c) if c:IsA("Model") and c.Name == NOME_MODELO_CARRO then atualizarVeiculos() end end)
atualizarVeiculos()

-- ========== ZOMBIE EXPANDER ==========
local function restoreZombieHead(model)
    if not model then return end
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        local originalSize = gameObjects.originalZombieHeads[model]
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
    if head and head:IsA("BasePart") and not gameObjects.originalZombieHeads[model] then
        gameObjects.originalZombieHeads[model] = head.Size
    end
end

local function shouldIgnoreZombie(model)
    if model:FindFirstChild("Scripts") and model:FindFirstChild("Scripts"):IsA("Folder") then return true end
    if model:FindFirstChild("ServerCollider") and model:FindFirstChild("ServerCollider"):IsA("BasePart") then return true end
    return false
end

local function expandZombieHitbox(model)
    if not gameObjects.zombieExpanderEnabled then 
        restoreZombieHead(model)
        return 
    end
    if shouldIgnoreZombie(model) then return end
    
    saveOriginalZombieSize(model)
    
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        head.Size = Vector3.new(gameObjects.zombieHitboxSize, gameObjects.zombieHitboxSize, gameObjects.zombieHitboxSize)
        head.Transparency = gameObjects.zombieHeadTransparency
        head.CanCollide = false
        head.Massless = true
    end
end

local function setupZombieExpander()
    if not gameObjects.zombieEntitiesFolder then
        local success, result = pcall(function() return workspace:WaitForChild("game_assets"):WaitForChild("Entities") end)
        if success then gameObjects.zombieEntitiesFolder = result else return end
    end
    
    for _, v in pairs(gameObjects.zombieEntitiesFolder:GetChildren()) do
        if v:IsA("Model") then
            saveOriginalZombieSize(v)
            if gameObjects.zombieExpanderEnabled then
                expandZombieHitbox(v)
            end
        end
    end
    
    gameObjects.zombieEntitiesFolder.ChildAdded:Connect(function(v)
        if v:IsA("Model") then
            task.wait(0.2)
            saveOriginalZombieSize(v)
            if gameObjects.zombieExpanderEnabled then
                expandZombieHitbox(v)
            end
        end
    end)
end

local function startZombieExpanderLoop()
    if gameObjects.zombieExpanderLoop then task.cancel(gameObjects.zombieExpanderLoop); gameObjects.zombieExpanderLoop = nil end
    
    gameObjects.zombieExpanderLoop = task.spawn(function()
        while true do
            if gameObjects.zombieEntitiesFolder then
                for _, v in pairs(gameObjects.zombieEntitiesFolder:GetChildren()) do
                    if v:IsA("Model") and not shouldIgnoreZombie(v) then
                        if gameObjects.zombieExpanderEnabled then
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

-- ========== CAR SPEED ==========
local function applyCarModifications()
    if not gameObjects.carSpeedEnabled then return end
    local carros = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
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
                engine:SetAttribute("forwardMaxSpeed", gameObjects.carForwardMaxSpeed)
                engine:SetAttribute("reverseMaxSpeed", gameObjects.carReverseMaxSpeed)
                engine:SetAttribute("acceleration", gameObjects.carAcceleration)
                engine:SetAttribute("deceleration", gameObjects.carDeceleration)
                engine:SetAttribute("braking", gameObjects.carBraking)
            end)
        end
        if steering then pcall(function() steering:SetAttribute("steeringReduction", gameObjects.carSteeringReduction) end) end
        if wheels then
            pcall(function()
                wheels:SetAttribute("density", gameObjects.carDensity)
                wheels:SetAttribute("elasticity", gameObjects.carElasticity)
                wheels:SetAttribute("staticFriction", gameObjects.carStaticFriction)
                wheels:SetAttribute("kineticFriction", gameObjects.carKineticFriction)
                wheels:SetAttribute("slipThreshold", gameObjects.carSlipThreshold)
            end)
        end
    end
end

local function startCarModLoop()
    if gameObjects.carModLoop then task.cancel(gameObjects.carModLoop); gameObjects.carModLoop = nil end
    if gameObjects.carSpeedEnabled then
        gameObjects.carModLoop = task.spawn(function()
            while gameObjects.carSpeedEnabled do
                applyCarModifications()
                task.wait(0.5)
            end
        end)
    end
end

-- ========== HITBOX EXPANDER ==========
local function removeFakeHeadsHitbox(Character)
    if not Character then return end
    for _, Head in Character:QueryDescendants("[$FakeHead]") do
        pcall(function() Head:Destroy() end)
    end
end

local function setHitboxHeads(Character, Remove)
    if not Character then return end
    
    removeFakeHeadsHitbox(Character)
    
    if Remove or not gameObjects.hitboxExpanderEnabled then
        return
    end
    
    local RealHead = Character:FindFirstChild("Head")
    if not RealHead then return end
    
    local RealNeck = RealHead:FindFirstChild("Neck")
    local BaseC0 = RealNeck and RealNeck.C0 or CFrame.identity
    
    local VisualHead = RealHead:Clone()
    if VisualHead:FindFirstChild("face") then
        VisualHead.face:Destroy()
    end
    VisualHead.Shape = Enum.PartType.Ball
    VisualHead.Size = Vector3.one * gameObjects.hitboxExpanderRadius * 2
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
    
    local SizeRadius = gameObjects.hitboxExpanderRadius - 0.5
    if SizeRadius <= 0 then return end
    
    for X = -SizeRadius, SizeRadius do
        for Y = -SizeRadius, SizeRadius do
            for Z = -SizeRadius, SizeRadius do
                local Distance = math.sqrt(X * X + Y * Y + Z * Z) - SizeRadius
                
                if Distance <= 0.5 and Distance >= -0.5 then
                    local NewHead = RealHead:Clone()
                    if NewHead:FindFirstChild("face") then
                        NewHead.face:Destroy()
                    end
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

local function refreshHitboxCharacters()
    if not gameObjects.custommeshcharacter then return end
    for i, v in gameObjects.custommeshcharacter:GetCharacters() do
        if v.Player ~= LocalPlayer then
            task.spawn(setHitboxHeads, v.WorldModel)
        end
    end
end

local function setupHitboxExpanderConnections()
    if not gameObjects.custommeshcharacter then return end
    
    gameObjects.custommeshcharacter.CharacterAdded:Connect(function(Player, Character, WorldModel)
        if Player ~= LocalPlayer then
            task.spawn(setHitboxHeads, WorldModel)
        end
    end)
    
    gameObjects.custommeshcharacter.CharacterRemoved:Connect(function(Player, Character, WorldModel)
        task.wait(1)
        if WorldModel then
            setHitboxHeads(WorldModel, true)
        end
    end)
    
    if gameObjects.playerlist then
        gameObjects.playerlist.PlayerAdded:Connect(function(Player)
            if Player == LocalPlayer then return end
            local Character = gameObjects.custommeshcharacter:GetWorldCharacterFromPlayer(Player)
            if Character then
                task.spawn(setHitboxHeads, Character)
            end
        end)
        
        gameObjects.playerlist.PlayerRemoving:Connect(function(Player)
            local Character = gameObjects.custommeshcharacter:GetWorldCharacterFromPlayer(Player)
            if Character then
                setHitboxHeads(Character, true)
            end
        end)
    end
    
    refreshHitboxCharacters()
end

-- ========== NO INVENTORY BLUR ==========
local function startNoInventoryBlurLoop()
    if gameObjects.noInventoryBlurLoop then task.cancel(gameObjects.noInventoryBlurLoop); gameObjects.noInventoryBlurLoop = nil end
    if gameObjects.noInventoryBlurEnabled then
        gameObjects.noInventoryBlurLoop = task.spawn(function()
            while gameObjects.noInventoryBlurEnabled do
                local cam = workspace.CurrentCamera
                local blur = cam and cam:FindFirstChild("Blur")
                if blur then blur.Enabled = false end
                task.wait(0.5)
            end
        end)
    end
end

-- ========== NO CAR DAMAGE ==========
local function startNoCarDamageLoop()
    if gameObjects.noCarDamageLoop then task.cancel(gameObjects.noCarDamageLoop); gameObjects.noCarDamageLoop = nil end
    gameObjects.noCarDamageLoop = task.spawn(function()
        while true do
            for _, child in ipairs(workspace:GetDescendants()) do 
                if child.Name == "Impact" then pcall(function() child:Destroy() end) end
            end
            task.wait(1)
        end
    end)
end

-- ========== SPEEDHACK ==========
local function findMovementPartForSpeed()
    if not workspace.CurrentCamera then return nil end
    for _, child in workspace.CurrentCamera:GetDescendants() do
        if child:IsA("MeshPart") and child.Size == Vector3.new(2.5, 5, 2.5) then return child end
    end
    return nil
end
gameObjects.movementPart = findMovementPartForSpeed()

local function updateSpeedhack()
    if not gameObjects.speedhack.enabled then return end
    if not gameObjects.movementPart or not gameObjects.movementPart.Parent then
        gameObjects.movementPart = findMovementPartForSpeed()
        if not gameObjects.movementPart then return end
    end
    if not workspace.CurrentCamera then return end
    local cam = workspace.CurrentCamera
    local camLook = cam.CFrame.LookVector
    camLook = Vector3.new(camLook.X, 0, camLook.Z)
    if camLook.Magnitude > 0 then camLook = camLook.Unit end
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camLook end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camLook end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Vector3.new(-camLook.Z, 0, camLook.X) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir + Vector3.new(camLook.Z, 0, -camLook.X) end
    if dir.Magnitude > 0 then
        dir = dir.Unit
        gameObjects.movementPart.AssemblyLinearVelocity = dir * gameObjects.speedhack.speed + Vector3.new(0, gameObjects.movementPart.AssemblyLinearVelocity.Y, 0)
    end
end

RunService.RenderStepped:Connect(updateSpeedhack)

-- ========== CLIMB SPEED ==========
local function startClimbSpeedLoop()
    if gameObjects.climbSpeedLoop then task.cancel(gameObjects.climbSpeedLoop); gameObjects.climbSpeedLoop = nil end
    if gameObjects.climbSpeedEnabled then
        gameObjects.climbSpeedLoop = task.spawn(function()
            while gameObjects.climbSpeedEnabled do
                for _, v in pairs(getgc(true)) do
                    if type(v) == "table" and rawget(v, "ClimbSpeed") then
                        v.ClimbSpeed = gameObjects.climbSpeedValue
                    end
                end
                task.wait(1)
            end
        end)
    end
end

-- ========== AUTO JUMP ==========
local function setupAutoJump()
    if gameObjects.autoJumpConnection then
        if type(gameObjects.autoJumpConnection) == "thread" then task.cancel(gameObjects.autoJumpConnection)
        elseif gameObjects.autoJumpConnection.Disconnect then gameObjects.autoJumpConnection:Disconnect() end
        gameObjects.autoJumpConnection = nil
    end
    if not gameObjects.autoJumpEnabled then return end
    local controller = game:GetService("ReplicatedFirst"):WaitForChild("CustomCharacter"):WaitForChild("CharacterController")
    local plugin = require(controller.CharacterPlugin)
    local holdingSpace = false
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Space then holdingSpace = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then holdingSpace = false end
    end)
    gameObjects.autoJumpConnection = task.spawn(function()
        while gameObjects.autoJumpEnabled do
            task.wait()
            pcall(function()
                plugin._InternalSetJumpFatigueEvent:Fire(1)
                if holdingSpace then plugin._InternalJump:Fire() end
            end)
        end
    end)
end

-- ========== OFFSET CHANGER ==========
local function applyOffsetChanger()
    local gunSystemAssets = ReplicatedStorage:FindFirstChild("GunSystemAssets")
    if not gunSystemAssets then return end
    local gunData = gunSystemAssets:FindFirstChild("GunData")
    if not gunData then return end

    for _, armaFolder in ipairs(gunData:GetChildren()) do
        local stats = armaFolder:FindFirstChild("Stats")
        if stats then
            local offset = stats:FindFirstChild("Offset")
            if offset and offset:IsA("Vector3Value") then
                offset.Value = Vector3.new(gameObjects.offsetX, gameObjects.offsetY, gameObjects.offsetZ)
            end
        end
    end
end

local function restoreOffsetChanger()
    local gunSystemAssets = ReplicatedStorage:FindFirstChild("GunSystemAssets")
    if not gunSystemAssets then return end
    local gunData = gunSystemAssets:FindFirstChild("GunData")
    if not gunData then return end

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

-- ========== EXPORTA FUNÇÕES ==========
Extras.setCarEspEnabled = function(v) gameObjects.carEspEnabled = v end
Extras.setZombieExpander = function(v) gameObjects.zombieExpanderEnabled = v; if v then pcall(setupZombieExpander); startZombieExpanderLoop() elseif gameObjects.zombieEntitiesFolder then for _, v in pairs(gameObjects.zombieEntitiesFolder:GetChildren()) do if v:IsA("Model") then restoreZombieHead(v) end end end end
Extras.setZombieHitboxSize = function(v) gameObjects.zombieHitboxSize = v; if gameObjects.zombieExpanderEnabled then startZombieExpanderLoop() end end
Extras.setZombieHeadTransparency = function(v) gameObjects.zombieHeadTransparency = v; if gameObjects.zombieExpanderEnabled then startZombieExpanderLoop() end end
Extras.setCarSpeedEnabled = function(v) gameObjects.carSpeedEnabled = v; startCarModLoop(); if v then applyCarModifications() elseif gameObjects.carModLoop then task.cancel(gameObjects.carModLoop); gameObjects.carModLoop = nil end end
Extras.setCarForwardMaxSpeed = function(v) gameObjects.carForwardMaxSpeed = v; if gameObjects.carSpeedEnabled then applyCarModifications() end end
Extras.setCarReverseMaxSpeed = function(v) gameObjects.carReverseMaxSpeed = v; if gameObjects.carSpeedEnabled then applyCarModifications() end end
Extras.setCarAcceleration = function(v) gameObjects.carAcceleration = v; if gameObjects.carSpeedEnabled then applyCarModifications() end end
Extras.setCarDeceleration = function(v) gameObjects.carDeceleration = v; if gameObjects.carSpeedEnabled then applyCarModifications() end end
Extras.setCarBraking = function(v) gameObjects.carBraking = v; if gameObjects.carSpeedEnabled then applyCarModifications() end end
Extras.setCarSteeringReduction = function(v) gameObjects.carSteeringReduction = v / 100; if gameObjects.carSpeedEnabled then applyCarModifications() end end
Extras.setHitboxExpanderEnabled = function(v) gameObjects.hitboxExpanderEnabled = v; refreshHitboxCharacters() end
Extras.setHitboxExpanderRadius = function(v) gameObjects.hitboxExpanderRadius = v; if gameObjects.hitboxExpanderEnabled then refreshHitboxCharacters() end end
Extras.setNoInventoryBlur = function(v) gameObjects.noInventoryBlurEnabled = v; if v then startNoInventoryBlurLoop() else if gameObjects.noInventoryBlurLoop then task.cancel(gameObjects.noInventoryBlurLoop); gameObjects.noInventoryBlurLoop = nil end; local cam = workspace.CurrentCamera; local blur = cam and cam:FindFirstChild("Blur"); if blur then blur.Enabled = true end end end
Extras.toggleNoCarDamage = function() if gameObjects.noCarDamageLoop then task.cancel(gameObjects.noCarDamageLoop); gameObjects.noCarDamageLoop = nil else startNoCarDamageLoop() end end
Extras.setSpeedhackEnabled = function(v) gameObjects.speedhack.enabled = v end
Extras.setSpeedhackSpeed = function(v) gameObjects.speedhack.speed = v end
Extras.setClimbSpeedEnabled = function(v) gameObjects.climbSpeedEnabled = v; startClimbSpeedLoop() end
Extras.setClimbSpeedValue = function(v) gameObjects.climbSpeedValue = v; if gameObjects.climbSpeedEnabled then startClimbSpeedLoop() end end
Extras.setAutoJumpEnabled = function(v) gameObjects.autoJumpEnabled = v; setupAutoJump() end
Extras.setOffsetEnabled = function(v) gameObjects.offsetEnabled = v; if v then applyOffsetChanger() else restoreOffsetChanger() end end
Extras.setOffsetX = function(v) gameObjects.offsetX = v; if gameObjects.offsetEnabled then applyOffsetChanger() end end
Extras.setOffsetY = function(v) gameObjects.offsetY = v; if gameObjects.offsetEnabled then applyOffsetChanger() end end
Extras.setOffsetZ = function(v) gameObjects.offsetZ = v; if gameObjects.offsetEnabled then applyOffsetChanger() end end

setupHitboxExpanderConnections()
print("✅ Extras carregado!")

return Extras
