-- MÓDULO: VISUAIS (COMPLETO)
local Visuals = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local lighting = game:GetService("Lighting")
local Workspace = workspace

Visuals.config = {
    armChamsEnabled = false,
    armChamsColor = Color3.fromRGB(255, 255, 255),
    armChamsMaterial = Enum.Material.ForceField,
    weaponChamsEnabled = false,
    weaponChamsColor = Color3.fromRGB(244, 224, 155),
    weaponChamsMaterial = Enum.Material.ForceField,
    selfChamsEnabled = false,
    selfChamsColor = Color3.fromRGB(128, 0, 128),
    selfChamsMaterial = Enum.Material.ForceField,
    selfChamsTransparency = 0.2,
    selfChamsHeadTransparency = 1,
    longNeckEnabled = false,
    longNeckHeight = 5,
    fullbrightEnabled = false,
    noFogEnabled = false,
    timeEnabled = false,
    timeValue = 12,
    currentSkybox = "Default"
}

Visuals.armChamsConnections = {}
Visuals.armChamsUpdater = nil
Visuals.selfChamsUpdater = nil
Visuals.selfChamsCharacter = nil
Visuals.gunplugin = nil

Visuals.originalLightingSettings = {
    Brightness = lighting.Brightness,
    ClockTime = lighting.ClockTime,
    GlobalShadows = lighting.GlobalShadows,
    OutdoorAmbient = lighting.OutdoorAmbient
}

Visuals.skyboxes = {
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
Visuals.originalSkybox = originalSkybox

-- ========== ARM CHAMS ==========
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
        part.Material = Visuals.config.armChamsMaterial
        part.Color = Visuals.config.armChamsColor
    end
end

local function restorePartOriginal(part)
    if part:IsA('BasePart') then
        part.Material = Enum.Material.Plastic
        part.Color = Color3.fromRGB(255, 255, 255)
    end
end

local function applyArmChamsToCharacter(character)
    if not character or not Visuals.config.armChamsEnabled then return end
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
    if not Visuals.config.armChamsEnabled then return end
    local camera = Workspace.CurrentCamera
    if not camera then return end
    
    for _, obj in pairs(camera:GetDescendants()) do
        if obj.Name == "Skin" and obj:IsA("BasePart") then
            obj.Material = Visuals.config.armChamsMaterial
            obj.Color = Visuals.config.armChamsColor
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
    if not Visuals.config.armChamsEnabled then return end
    local character = LocalPlayer.Character
    if character then applyArmChamsToCharacter(character) end
    updateSkinColor()
end

local function setupArmChamsConnections()
    for _, conn in pairs(Visuals.armChamsConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    Visuals.armChamsConnections = {}
    
    if not Visuals.config.armChamsEnabled then return end
    
    local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        if Visuals.config.armChamsEnabled then
            applyArmChamsToCharacter(character)
        end
    end)
    table.insert(Visuals.armChamsConnections, charAddedConn)
    
    local cameraConn = Workspace.CurrentCamera.DescendantAdded:Connect(function(obj)
        if Visuals.config.armChamsEnabled then
            if (obj:IsA("BasePart") and (obj.Name == "Skin" or isArmPart(obj))) then
                task.wait(0.05)
                if obj.Name == "Skin" then
                    obj.Material = Visuals.config.armChamsMaterial
                    obj.Color = Visuals.config.armChamsColor
                elseif isArmPart(obj) then
                    applyChamToPart(obj)
                end
            end
        end
    end)
    table.insert(Visuals.armChamsConnections, cameraConn)
    
    if Visuals.armChamsUpdater then
        pcall(function() Visuals.armChamsUpdater:Disconnect() end)
    end
    Visuals.armChamsUpdater = RunService.RenderStepped:Connect(function()
        if Visuals.config.armChamsEnabled then applyArmChams() end
    end)
end

function Visuals.setArmChamsEnabled(v)
    Visuals.config.armChamsEnabled = v
    if v then
        applyArmChams()
        setupArmChamsConnections()
    else
        if Visuals.armChamsUpdater then
            pcall(function() Visuals.armChamsUpdater:Disconnect() end)
            Visuals.armChamsUpdater = nil
        end
        for _, conn in pairs(Visuals.armChamsConnections) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        Visuals.armChamsConnections = {}
        local character = LocalPlayer.Character
        if character then restoreArmChamsFromCharacter(character) end
        local camera = Workspace.CurrentCamera
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

function Visuals.setArmChamsColor(c) Visuals.config.armChamsColor = c; if Visuals.config.armChamsEnabled then applyArmChams() end end
function Visuals.setArmChamsMaterial(v) Visuals.config.armChamsMaterial = Enum.Material[v]; if Visuals.config.armChamsEnabled then applyArmChams() end end

-- ========== WEAPON CHAMS ==========
local function changeWeaponLook(gun)
    if not Visuals.config.weaponChamsEnabled or not gun then return end
    local parts = gun:FindFirstChild("Weapon")
    if not parts then return end
    for _, v in pairs(parts:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 1 then
            v.Material = Visuals.config.weaponChamsMaterial
            v.Color = Visuals.config.weaponChamsColor
        end
        if v:IsA("SurfaceAppearance") then v:Destroy() end
    end
end

function Visuals.setWeaponChamsEnabled(v)
    Visuals.config.weaponChamsEnabled = v
    if v and Workspace.Camera then 
        local currentGun = Workspace.Camera:FindFirstChild("CurrentWeapon")
        if currentGun then changeWeaponLook(currentGun) end
    end
end

function Visuals.setWeaponChamsColor(c) 
    Visuals.config.weaponChamsColor = c
    if Visuals.config.weaponChamsEnabled and Workspace.Camera then 
        local currentGun = Workspace.Camera:FindFirstChild("CurrentWeapon")
        if currentGun then changeWeaponLook(currentGun) end
    end
end

function Visuals.setWeaponMaterial(v) 
    Visuals.config.weaponChamsMaterial = Enum.Material[v]
    if Visuals.config.weaponChamsEnabled and Workspace.Camera then 
        local currentGun = Workspace.Camera:FindFirstChild("CurrentWeapon")
        if currentGun then changeWeaponLook(currentGun) end
    end
end

-- ========== SELF CHAMS ==========
local function findCharacterByCamera()
    local entitiesfolder = Workspace:FindFirstChild("game_assets") and Workspace.game_assets:FindFirstChild("Entities") or Workspace
    if not entitiesfolder or not Workspace.CurrentCamera then return nil end
    local cameraPos = Workspace.CurrentCamera.CFrame.Position
    local closest, closestDist = nil, 15
    for _, model in pairs(entitiesfolder:GetChildren()) do
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
    if not Visuals.config.selfChamsEnabled then return end
    local char = (Visuals.selfChamsCharacter and Visuals.selfChamsCharacter.Parent) and Visuals.selfChamsCharacter or findCharacterByCamera()
    if not char then return end
    Visuals.selfChamsCharacter = char
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("SurfaceAppearance") then child:Destroy() end
            end
            part.Material = Visuals.config.selfChamsMaterial
            part.Color = Visuals.config.selfChamsColor
            if part.Name == "Head" then
                part.Transparency = Visuals.config.selfChamsHeadTransparency
                for _, child in pairs(part:GetChildren()) do
                    if child:IsA("Decal") and child.Name == "Face" then child:Destroy() end
                end
            else
                part.Transparency = Visuals.config.selfChamsTransparency
            end
        end
    end
end

function Visuals.setSelfChamsEnabled(v)
    Visuals.config.selfChamsEnabled = v
    if v then
        if Visuals.selfChamsUpdater then pcall(function() Visuals.selfChamsUpdater:Disconnect() end) end
        Visuals.selfChamsUpdater = RunService.RenderStepped:Connect(applySelfChams)
        applySelfChams()
    elseif Visuals.selfChamsUpdater then
        pcall(function() Visuals.selfChamsUpdater:Disconnect() end)
        Visuals.selfChamsUpdater = nil
    end
end

function Visuals.setSelfChamsColor(c) Visuals.config.selfChamsColor = c; if Visuals.config.selfChamsEnabled then applySelfChams() end end
function Visuals.setSelfChamsMaterial(v) Visuals.config.selfChamsMaterial = Enum.Material[v]; if Visuals.config.selfChamsEnabled then applySelfChams() end end
function Visuals.setSelfChamsTransparency(v) Visuals.config.selfChamsTransparency = v; if Visuals.config.selfChamsEnabled then applySelfChams() end end
function Visuals.setSelfChamsHeadTransparency(v) Visuals.config.selfChamsHeadTransparency = v; if Visuals.config.selfChamsEnabled then applySelfChams() end end

-- ========== LONG NECK ==========
local function setupGunPlugin()
    local success, result = pcall(function()
        return require(game:GetService("ReplicatedFirst").GunSystem.GunController.Events.GunPlugin)
    end)
    if success then Visuals.gunplugin = result end
end
setupGunPlugin()

function Visuals.setLongNeckEnabled(v)
    Visuals.config.longNeckEnabled = v
    if Visuals.gunplugin then
        pcall(function()
            if v then Visuals.gunplugin:SetOverrideCameraHeight(Visuals.config.longNeckHeight)
            else Visuals.gunplugin:SetOverrideCameraHeight(0) end
        end)
    end
end

function Visuals.setLongNeckHeight(v)
    Visuals.config.longNeckHeight = v
    if Visuals.config.longNeckEnabled and Visuals.gunplugin then
        pcall(function() Visuals.gunplugin:SetOverrideCameraHeight(v) end)
    end
end

-- ========== LIGHTING ==========
function Visuals.setFullbright(v)
    Visuals.config.fullbrightEnabled = v
end

function Visuals.setNoFog(v)
    Visuals.config.noFogEnabled = v
end

function Visuals.setTimeEnabled(v)
    Visuals.config.timeEnabled = v
    if not v then lighting.ClockTime = Visuals.originalLightingSettings.ClockTime end
end

function Visuals.setTimeValue(v)
    Visuals.config.timeValue = v
    if Visuals.config.timeEnabled then lighting.ClockTime = v end
end

-- ========== SKYBOX ==========
function Visuals.applySkybox(skyboxName)
    local sky = lighting:FindFirstChild("Sky")
    if skyboxName == "Default" then
        if sky then sky:Destroy() end
        if Visuals.originalSkybox then
            local newSky = Instance.new("Sky")
            newSky.Parent = lighting
            newSky.SkyboxBk = Visuals.originalSkybox.SkyboxBk
            newSky.SkyboxDn = Visuals.originalSkybox.SkyboxDn
            newSky.SkyboxFt = Visuals.originalSkybox.SkyboxFt
            newSky.SkyboxLf = Visuals.originalSkybox.SkyboxLf
            newSky.SkyboxRt = Visuals.originalSkybox.SkyboxRt
            newSky.SkyboxUp = Visuals.originalSkybox.SkyboxUp
        end
    elseif Visuals.skyboxes[skyboxName] then
        if not sky then sky = Instance.new("Sky", lighting) end
        local data = Visuals.skyboxes[skyboxName]
        sky.SkyboxBk = "rbxassetid://" .. data[1]
        sky.SkyboxDn = "rbxassetid://" .. data[2]
        sky.SkyboxFt = "rbxassetid://" .. data[3]
        sky.SkyboxLf = "rbxassetid://" .. data[4]
        sky.SkyboxRt = "rbxassetid://" .. data[5]
        sky.SkyboxUp = "rbxassetid://" .. data[6]
    end
    Visuals.config.currentSkybox = skyboxName
end

-- Lighting loop
RunService.RenderStepped:Connect(function()
    if Visuals.config.fullbrightEnabled then
        lighting.Brightness = 10
        lighting.ClockTime = 12
        lighting.GlobalShadows = false
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    elseif not Visuals.config.fullbrightEnabled and not Visuals.config.timeEnabled then
        lighting.Brightness = Visuals.originalLightingSettings.Brightness
        lighting.GlobalShadows = Visuals.originalLightingSettings.GlobalShadows
        lighting.OutdoorAmbient = Visuals.originalLightingSettings.OutdoorAmbient
    end
    
    if Visuals.config.noFogEnabled and lighting:FindFirstChild("Atmosphere") then
        lighting.Atmosphere.Density = 0
    elseif lighting:FindFirstChild("Atmosphere") and not Visuals.config.noFogEnabled then
        lighting.Atmosphere.Density = Visuals.originalAtmosphereDensity or 0.5
    end
    
    if Visuals.config.timeEnabled then
        lighting.ClockTime = Visuals.config.timeValue
    end
end)

-- Setup weapon changer
local function setupWeaponChanger()
    local cam = Workspace.Camera
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
