-- MÓDULO 5: VISUAIS (Chams, Lighting, Skybox, Car ESP, Long Neck)
local Visuals = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local lighting = game:GetService("Lighting")
local Workspace = workspace

_G.gameObjects.armChamsEnabled = false
_G.gameObjects.armChamsColor = Color3.fromRGB(255, 255, 255)
_G.gameObjects.armChamsMaterial = Enum.Material.ForceField
_G.gameObjects.armChamsConnections = {}
_G.gameObjects.armChamsUpdater = nil

_G.gameObjects.weaponChamsEnabled = false
_G.gameObjects.weaponChamsColor = Color3.fromRGB(244, 224, 155)
_G.gameObjects.weaponChamsMaterial = Enum.Material.ForceField

_G.gameObjects.selfChamsEnabled = false
_G.gameObjects.selfChamsColor = Color3.fromRGB(128, 0, 128)
_G.gameObjects.selfChamsMaterial = Enum.Material.ForceField
_G.gameObjects.selfChamsTransparency = 0.2
_G.gameObjects.selfChamsHeadTransparency = 1
_G.gameObjects.selfChamsUpdater = nil
_G.gameObjects.selfChamsCharacter = nil

_G.gameObjects.longNeckEnabled = false
_G.gameObjects.longNeckHeight = 5
_G.gameObjects.gunplugin = nil

_G.gameObjects.fullbrightEnabled = false
_G.gameObjects.noFogEnabled = false
_G.gameObjects.timeEnabled = false
_G.gameObjects.timeValue = 12

_G.gameObjects.carEspEnabled = false
_G.gameObjects.veiculosData = {}

local originalLightingSettings = {
    Brightness = lighting.Brightness,
    ClockTime = lighting.ClockTime,
    GlobalShadows = lighting.GlobalShadows,
    OutdoorAmbient = lighting.OutdoorAmbient
}
local originalAtmosphereDensity = lighting:FindFirstChild("Atmosphere") and lighting.Atmosphere.Density or 0.5

-- CAR ESP
local NOME_MODELO_CARRO = "WorldModel"
local RENDER_DIST = 4000
local COR_NOME = Color3.fromRGB(255, 0, 0)
local COR_DIST = Color3.fromRGB(255, 105, 180)
local TEXTO_VEIC = "Car"
local HEIGHT_OFFSET = 5

local function atualizarVeiculos()
    for _, info in ipairs(_G.gameObjects.veiculosData) do
        if info.txt then pcall(function() info.txt:Remove() end) end
        if info.dist then pcall(function() info.dist:Remove() end) end
    end
    _G.gameObjects.veiculosData = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == NOME_MODELO_CARRO then
            table.insert(_G.gameObjects.veiculosData, { modelo = obj, txt = nil, dist = nil })
        end
    end
end
workspace.ChildAdded:Connect(function(c) if c:IsA("Model") and c.Name == NOME_MODELO_CARRO then atualizarVeiculos() end end)
workspace.ChildRemoved:Connect(function(c) if c:IsA("Model") and c.Name == NOME_MODELO_CARRO then atualizarVeiculos() end end)
atualizarVeiculos()

-- ARM CHAMS
local function isArmPart(part)
    local armParts = {
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand"
    }
    return table.find(armParts, part.Name) ~= nil
end

local function applyChamToPart(part)
    if part:IsA('BasePart') then
        for _, child in ipairs(part:GetChildren()) do
            if child:IsA('SurfaceAppearance') then
                child:Destroy()
            end
        end
        part.Material = _G.gameObjects.armChamsMaterial
        part.Color = _G.gameObjects.armChamsColor
    end
end

local function restorePartOriginal(part)
    if part:IsA('BasePart') then
        part.Material = Enum.Material.Plastic
        part.Color = Color3.fromRGB(255, 255, 255)
    end
end

local function applyArmChamsToCharacter(character)
    if not character or not _G.gameObjects.armChamsEnabled then return end
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA('BasePart') and isArmPart(descendant) then
            applyChamToPart(descendant)
        end
    end
end

local function restoreArmChamsFromCharacter(character)
    if not character then return end
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA('BasePart') and isArmPart(descendant) then
            restorePartOriginal(descendant)
        end
    end
end

local function updateSkinColor()
    if not _G.gameObjects.armChamsEnabled then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    for _, obj in pairs(camera:GetDescendants()) do
        if obj.Name == "Skin" and obj:IsA("BasePart") then
            obj.Material = _G.gameObjects.armChamsMaterial
            obj.Color = _G.gameObjects.armChamsColor
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("SurfaceAppearance") then
                    child:Destroy()
                end
            end
        elseif obj:IsA("BasePart") and isArmPart(obj) then
            applyChamToPart(obj)
        end
    end
end

local function applyArmChams()
    if not _G.gameObjects.armChamsEnabled then return end
    local character = LocalPlayer.Character
    if character then applyArmChamsToCharacter(character) end
    updateSkinColor()
end

function Visuals.setArmChamsEnabled(v)
    _G.gameObjects.armChamsEnabled = v
    if v then
        applyArmChams()
        if _G.gameObjects.armChamsUpdater then _G.gameObjects.armChamsUpdater:Disconnect() end
        _G.gameObjects.armChamsUpdater = RunService.RenderStepped:Connect(applyArmChams)
    else
        if _G.gameObjects.armChamsUpdater then _G.gameObjects.armChamsUpdater:Disconnect() end
        local character = LocalPlayer.Character
        if character then restoreArmChamsFromCharacter(character) end
        local camera = workspace.CurrentCamera
        if camera then
            for _, obj in pairs(camera:GetDescendants()) do
                if obj.Name == "Skin" and obj:IsA("BasePart") then
                    obj.Material = Enum.Material.Plastic
                    obj.Color = Color3.fromRGB(255, 255, 255)
                elseif obj:IsA("BasePart") and isArmPart(obj) then
                    restorePartOriginal(obj)
                end
            end
        end
    end
end

function Visuals.setArmChamsColor(c) _G.gameObjects.armChamsColor = c; if _G.gameObjects.armChamsEnabled then applyArmChams() end end
function Visuals.setArmChamsMaterial(v) _G.gameObjects.armChamsMaterial = Enum.Material[v]; if _G.gameObjects.armChamsEnabled then applyArmChams() end end

-- WEAPON CHAMS
local function changeWeaponLook(gun)
    if not _G.gameObjects.weaponChamsEnabled or not gun then return end
    local parts = gun:FindFirstChild("Weapon")
    if not parts then return end
    for _, v in pairs(parts:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 1 then
            v.Material = _G.gameObjects.weaponChamsMaterial
            v.Color = _G.gameObjects.weaponChamsColor
        end
        if v:IsA("SurfaceAppearance") then v:Destroy() end
    end
end

function Visuals.setWeaponChamsEnabled(v)
    _G.gameObjects.weaponChamsEnabled = v
    if v and workspace.Camera then
        local currentGun = workspace.Camera:FindFirstChild("CurrentWeapon")
        if currentGun then changeWeaponLook(currentGun) end
    end
end
function Visuals.setWeaponChamsColor(c) _G.gameObjects.weaponChamsColor = c; if _G.gameObjects.weaponChamsEnabled and workspace.Camera then local currentGun = workspace.Camera:FindFirstChild("CurrentWeapon"); if currentGun then changeWeaponLook(currentGun) end end end
function Visuals.setWeaponMaterial(v) _G.gameObjects.weaponChamsMaterial = Enum.Material[v]; if _G.gameObjects.weaponChamsEnabled and workspace.Camera then local currentGun = workspace.Camera:FindFirstChild("CurrentWeapon"); if currentGun then changeWeaponLook(currentGun) end end end

-- SELF CHAMS
local function findCharacterByCamera()
    if not _G.gameObjects.entitiesfolder then return nil end
    local cameraPos = workspace.CurrentCamera.CFrame.Position
    local closest, closestDist = nil, 15
    for _, model in pairs(_G.gameObjects.entitiesfolder:GetChildren()) do
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
    if not _G.gameObjects.selfChamsEnabled then return end
    local char = (_G.gameObjects.selfChamsCharacter and _G.gameObjects.selfChamsCharacter.Parent) and _G.gameObjects.selfChamsCharacter or findCharacterByCamera()
    if not char then return end
    _G.gameObjects.selfChamsCharacter = char
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("SurfaceAppearance") then child:Destroy() end
            end
            part.Material = _G.gameObjects.selfChamsMaterial
            part.Color = _G.gameObjects.selfChamsColor
            if part.Name == "Head" then
                part.Transparency = _G.gameObjects.selfChamsHeadTransparency
                for _, child in pairs(part:GetChildren()) do
                    if child:IsA("Decal") and child.Name == "Face" then child:Destroy() end
                end
            else
                part.Transparency = _G.gameObjects.selfChamsTransparency
            end
        end
    end
end

function Visuals.setSelfChamsEnabled(v)
    _G.gameObjects.selfChamsEnabled = v
    if v then
        if _G.gameObjects.selfChamsUpdater then _G.gameObjects.selfChamsUpdater:Disconnect() end
        _G.gameObjects.selfChamsUpdater = RunService.RenderStepped:Connect(applySelfChams)
        applySelfChams()
    elseif _G.gameObjects.selfChamsUpdater then
        _G.gameObjects.selfChamsUpdater:Disconnect()
        _G.gameObjects.selfChamsUpdater = nil
    end
end
function Visuals.setSelfChamsColor(c) _G.gameObjects.selfChamsColor = c; if _G.gameObjects.selfChamsEnabled then applySelfChams() end end
function Visuals.setSelfChamsMaterial(v) _G.gameObjects.selfChamsMaterial = Enum.Material[v]; if _G.gameObjects.selfChamsEnabled then applySelfChams() end end
function Visuals.setSelfChamsTransparency(v) _G.gameObjects.selfChamsTransparency = v; if _G.gameObjects.selfChamsEnabled then applySelfChams() end end
function Visuals.setSelfChamsHeadTransparency(v) _G.gameObjects.selfChamsHeadTransparency = v; if _G.gameObjects.selfChamsEnabled then applySelfChams() end end

-- LONG NECK
local function setupGunPlugin()
    local success, result = pcall(function()
        return require(game:GetService("ReplicatedFirst").GunSystem.GunController.Events.GunPlugin)
    end)
    if success then _G.gameObjects.gunplugin = result end
end
setupGunPlugin()

function Visuals.setLongNeckEnabled(v)
    _G.gameObjects.longNeckEnabled = v
    if _G.gameObjects.gunplugin then
        pcall(function()
            if v then _G.gameObjects.gunplugin:SetOverrideCameraHeight(_G.gameObjects.longNeckHeight)
            else _G.gameObjects.gunplugin:SetOverrideCameraHeight(0) end
        end)
    end
end
function Visuals.setLongNeckHeight(v)
    _G.gameObjects.longNeckHeight = v
    if _G.gameObjects.longNeckEnabled and _G.gameObjects.gunplugin then
        pcall(function() _G.gameObjects.gunplugin:SetOverrideCameraHeight(v) end)
    end
end

-- SKYBOX
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

function Visuals.applySkybox(skyboxName)
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
        sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = "rbxassetid://" .. data[1], "rbxassetid://" .. data[2], "rbxassetid://" .. data[3]
        sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = "rbxassetid://" .. data[4], "rbxassetid://" .. data[5], "rbxassetid://" .. data[6]
    end
end

-- LIGHTING
function Visuals.setFullbright(v) _G.gameObjects.fullbrightEnabled = v end
function Visuals.setNoFog(v) _G.gameObjects.noFogEnabled = v end
function Visuals.setTimeEnabled(v) _G.gameObjects.timeEnabled = v; if not v then lighting.ClockTime = originalLightingSettings.ClockTime end end
function Visuals.setTimeValue(v) _G.gameObjects.timeValue = v; if _G.gameObjects.timeEnabled then lighting.ClockTime = v end end
function Visuals.setCarEspEnabled(v) _G.gameObjects.carEspEnabled = v end

-- WEAPON CHANGER SETUP
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
setupWeaponChanger()

return Visuals
