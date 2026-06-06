-- MÓDULO 1: CORE (Inicialização, Bypass, Variáveis Globais, Scanner)
local Core = {}

-- BYPASS DO SERVICE MANAGER
do
    local ServiceManagerEnv

    for i, v in getgc(true) do
        if type(v) == "table" then
            if rawget(v, "newcclosure") and rawget(v, "vx") and type(getrawmetatable(v).__index) == "table" then
                ServiceManagerEnv = v
                break
            end
        end
    end

    if ServiceManagerEnv then
        local prime = 16777619
        local max32bitunsigned = 4294967295
        local max16bitunsigned = 65535

        local CalculateHeartbeat = function(num)
            num = tostring(num)
            local hash = 2166136261
            for i = 1, #num do
                local byte = string.byte(num, i)
                local t1 = bit32.bxor(hash, byte)
                local t2 = t1 * prime
                local t3 = bit32.band(t2, max32bitunsigned)
                hash = t3
            end
            local finalhb = bit32.band(hash, max16bitunsigned)
            return "\n>" .. num .. "--" .. finalhb
        end

        local OldIndex = getrawmetatable(ServiceManagerEnv).__index
        local Heartbeat = ServiceManagerEnv.s
        ServiceManagerEnv.s = nil

        getrawmetatable(ServiceManagerEnv).__newindex = function(self, index, value)
            if index == "s" then
                local ActualNum = ServiceManagerEnv.c
                value = CalculateHeartbeat(ActualNum)
                Heartbeat = value
                return
            end
            rawset(self, index, value)
        end

        getrawmetatable(ServiceManagerEnv).__index = function(self, index)
            if index == "s" then return Heartbeat end
            return rawget(OldIndex, index)
        end

        print("THE RIFT - Bypass ativado")
    else
        print("THE RIFT - Falha no bypass")
    end
end

-- Variáveis globais compartilhadas
_G.gameObjects = {}
_G.gameObjects.ESPs = {}
_G.gameObjects.veiculosData = {}
_G.gameObjects.targetVelocities = {}
_G.gameObjects.flyKeys = { Forward = false, Backward = false, Left = false, Right = false, Up = false, Down = false }
_G.gameObjects.originalZombieHeads = {}

-- Scanner
_G.scannerRunning = false
_G.runScanner = function()
    if _G.scannerRunning then return end
    _G.scannerRunning = true
    task.spawn(function()
        local Players = cloneref(game:GetService("Players"))
        local HttpService = cloneref(game:GetService("HttpService"))
        local CoreGui = game:GetService("CoreGui")

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
        local LocalPlayer = Players.LocalPlayer

        for _, Player in Players:GetPlayers() do
            if Player == LocalPlayer then continue end
            for _, Attribute in Attributes do
                local Attr = Player:GetAttribute(Attribute)
                Attr = Attr and HttpService:JSONDecode(Attr) or {}
                if Attr.ClassName then
                    local Text = Attr.ClassName:gsub("%.item", "")
                    if Map[Text:lower()] then
                        table.insert(Found, { Player = Player, Gun = Text })
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
                                Gun:FindFirstChild("DisplayName").Value, Gun.Name,
                                (Mag and Mag.Value or 0) + (Reserve and Reserve.Value or 0))
                        })
                    end
                end
            end
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
                header.BackgroundTransparency = 0.25 + alpha
                header.TextLabel.TextTransparency = alpha
                for _, bar in ipairs(bars) do
                    bar.BackgroundTransparency = 0.25 + alpha
                    bar.TextLabel.TextTransparency = alpha
                end
                task.wait(0.05)
            end
            ScreenGui:Destroy()
            _G.scannerRunning = false
        end)
    end)
end

-- Inicializa dependências do jogo
pcall(function()
    _G.gameObjects.custommeshcharacter = require(game.ReplicatedFirst:WaitForChild("GunSystemPlugins"):WaitForChild("CustomMeshCharacter"))
end)
pcall(function()
    _G.gameObjects.playerlist = require(game.ReplicatedStorage:WaitForChild("CustomCharacter"):WaitForChild("PlayerList"))
end)
_G.gameObjects.gameassets = workspace:FindFirstChild("game_assets")
_G.gameObjects.entitiesfolder = _G.gameObjects.gameassets and _G.gameObjects.gameassets:FindFirstChild("Entities") or workspace

return Core
