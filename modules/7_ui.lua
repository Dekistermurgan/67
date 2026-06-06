-- MÓDULO: UI (COMPLETA)
local UI = {}

function UI.Initialize(Library, ThemeManager, SaveManager)
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
    
    -- ===== COMBAT TAB =====
    
    -- Silent Aim
    local SilentAimSection = Tabs.Combat:AddLeftGroupbox('Silent Aim')
    SilentAimSection:AddToggle('SilentAimToggle', { Text = 'Enable Silent Aim', Default = false, Callback = function(v) if _G.SilentAim then _G.SilentAim.setEnabled(v) end end })
    SilentAimSection:AddToggle('SilentTeamCheck', { Text = 'Team Check', Default = true, Callback = function(v) if _G.SilentAim then _G.SilentAim.setTeamCheck(v) end end })
    SilentAimSection:AddDivider()
    SilentAimSection:AddDropdown('SilentAimPart', { Values = { 'Head', 'UpperTorso', 'HumanoidRootPart' }, Default = 1, Text = 'Target Part', Callback = function(v) if _G.SilentAim then _G.SilentAim.setAimPart(v) end end })
    SilentAimSection:AddSlider('SilentFOVRadius', { Text = 'FOV Radius', Default = 200, Min = 0, Max = 500, Rounding = 1, Callback = function(v) if _G.SilentAim then _G.SilentAim.setFOVRadius(v) end end })
    SilentAimSection:AddToggle('SilentFOVVisible', { Text = 'Show FOV Circle', Default = false, Callback = function(v) if _G.SilentAim then _G.SilentAim.setFOVVisible(v) end end })
    SilentAimSection:AddDivider()
    SilentAimSection:AddDropdown('SilentPredictionMode', { Text = 'Prediction Mode', Default = 'Axal', Values = { 'Axal', 'Priv9' }, Callback = function(v) if _G.SilentAim then _G.SilentAim.setPredictionMode(v) end end })
    SilentAimSection:AddToggle('SilentResolveY', { Text = 'Resolve Y', Default = false, Callback = function(v) if _G.SilentAim then _G.SilentAim.setResolveY(v) end end })
    SilentAimSection:AddToggle('SilentInstantBullet', { Text = 'Instant Bullet', Default = false, Callback = function(v) if _G.SilentAim then _G.SilentAim.setInstantBullet(v) end end })
    SilentAimSection:AddToggle('SilentNoSpread', { Text = 'No Spread', Default = false, Callback = function(v) if _G.SilentAim then _G.SilentAim.setNoSpread(v) end end })
    
    -- Mouse Aimbot
    local MouseAimbotSection = Tabs.Combat:AddLeftGroupbox('Mouse Aimbot')
    local aimbotToggle = MouseAimbotSection:AddToggle('AimbotToggle', { Text = 'Enable Mouse Aimbot', Default = false, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setEnabled(v) end end })
    MouseAimbotSection:AddLabel('Aim Key (Hold)'):AddKeyPicker('AimbotHoldKey', { Default = 'MB2', SyncToggleState = false, Mode = 'Hold', Text = 'Aim Key', ChangedCallback = function(New)
        if New == "MB2" then 
            if _G.MouseAimbot then _G.MouseAimbot.setKeybind(Enum.UserInputType.MouseButton2) end
        elseif New == "MB1" then 
            if _G.MouseAimbot then _G.MouseAimbot.setKeybind(Enum.UserInputType.MouseButton1) end
        else 
            if _G.MouseAimbot then _G.MouseAimbot.setKeybind(Enum.KeyCode[New]) end
        end
    end })
    MouseAimbotSection:AddDivider()
    MouseAimbotSection:AddDropdown('HitPart', { Values = { 'Head', 'UpperTorso', 'HumanoidRootPart' }, Default = 1, Text = 'Hit Part', Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setHitPart(v) end end })
    MouseAimbotSection:AddSlider('Smoothing', { Text = 'Smoothing', Default = 50, Min = 0, Max = 100, Rounding = 1, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setSmoothing(v) end end })
    
    -- Predictions
    local PredictionsSection = Tabs.Combat:AddLeftGroupbox('Predictions')
    PredictionsSection:AddSlider('PredictionX', { Text = 'Lateral Prediction (s)', Default = 20, Min = 0, Max = 50, Rounding = 1, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setPredictionX(v) end end })
    PredictionsSection:AddSlider('BulletDropFactor', { Text = 'Bullet Drop Factor (%)', Default = 100, Min = 0, Max = 200, Rounding = 1, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setBulletDropFactor(v) end end })
    PredictionsSection:AddSlider('VerticalOffset', { Text = 'Vertical Offset', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setVerticalOffset(v) end end })
    
    -- FOV Settings
    local FOVSection = Tabs.Combat:AddRightGroupbox('FOV Settings')
    FOVSection:AddToggle('ShowFOV', { Text = 'Show FOV', Default = false, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setFOVVisible(v) end end })
    FOVSection:AddSlider('FOVRadius', { Text = 'FOV Radius', Default = 200, Min = 0, Max = 500, Rounding = 1, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setFOVRadius(v) end end })
    FOVSection:AddSlider('FOVThickness', { Text = 'FOV Thickness', Default = 2, Min = 1, Max = 10, Rounding = 1, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setFOVThickness(v) end end })
    FOVSection:AddDropdown('FOVShape', { Text = 'FOV Shape', Default = 'Circle', Values = { 'Circle', 'Triangle', 'Star of David', 'Pentagon', 'Hexagon' }, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setFOVShape(v) end end })
    FOVSection:AddToggle('FOVSpin', { Text = 'Spin FOV', Default = false, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setFOVSpin(v) end end })
    FOVSection:AddSlider('FOVSpinSpeed', { Text = 'Spin Speed', Default = 45, Min = 0, Max = 360, Rounding = 1, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setFOVSpinSpeed(v) end end })
    FOVSection:AddLabel('FOV Color'):AddColorPicker('FOVColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) if _G.MouseAimbot then _G.MouseAimbot.setFOVColor(c) end end })
    FOVSection:AddToggle('FOVRainbow', { Text = 'Rainbow FOV', Default = false, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setFOVRainbow(v) end end })
    
    -- Gun Mods
    local GunSection = Tabs.Combat:AddRightGroupbox('Gun Modifications')
    GunSection:AddToggle('NoRecoil', { Text = 'No Recoil', Default = true, Callback = function(v) getgenv().norecoilenabled = v end })
    GunSection:AddToggle('NoGunSway', { Text = 'No Gun Sway', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setNoGunSway(v) end end })
    GunSection:AddToggle('NoGunBob', { Text = 'No Gun Bob', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setNoGunBob(v) end end })
    GunSection:AddToggle('InstantAim', { Text = 'Instant Aim', Default = false, Callback = function(v) if v and _G.Missing then _G.Missing.enableInstantAim() end end })
    GunSection:AddToggle('SilentReload', { Text = 'Silent Reload', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setSilentReloadEnabled(v) end end })
    
    -- Offset
    local OffsetSection = Tabs.Combat:AddRightGroupbox('Offset Changer')
    OffsetSection:AddToggle('OffsetToggle', { Text = 'Enable Offset', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setOffsetEnabled(v) end end })
    OffsetSection:AddSlider('OffsetX', { Text = 'Offset X', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) if _G.Missing then _G.Missing.setOffsetX(v) end end })
    OffsetSection:AddSlider('OffsetY', { Text = 'Offset Y', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) if _G.Missing then _G.Missing.setOffsetY(v) end end })
    OffsetSection:AddSlider('OffsetZ', { Text = 'Offset Z', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) if _G.Missing then _G.Missing.setOffsetZ(v) end end })
    
    -- ===== VISUALS TAB =====
    
    -- Scanner
    local ScannerGroup = Tabs.Visuals:AddLeftGroupbox("Scanner")
    ScannerGroup:AddButton("Run Scanner", function() if _G.Missing then _G.Missing.runScanner() end end)
    
    -- ESP
    local ESPGroup = Tabs.Visuals:AddLeftGroupbox('Player ESP')
    ESPGroup:AddToggle('ESPEnabled', { Text = 'Enable ESP', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setEnabled(v) end end })
    ESPGroup:AddToggle('ShowBoxes', { Text = 'Show Boxes', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setBoxEnabled(v) end end })
    ESPGroup:AddToggle('FilledBoxes', { Text = 'Filled Boxes', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setBoxFilled(v) end end })
    ESPGroup:AddToggle('OutlineBoxes', { Text = 'Outline Boxes', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setBoxOutline(v) end end })
    ESPGroup:AddToggle('Skeleton', { Text = 'Skeleton', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setSkeleton(v) end end })
    ESPGroup:AddToggle('ShowNames', { Text = 'Show Names', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setNames(v) end end })
    ESPGroup:AddToggle('ShowDistances', { Text = 'Show Distances', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setDistances(v) end end })
    ESPGroup:AddLabel('Box Color'):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) if _G.ESP then _G.ESP.setBoxColor(c) end end })
    ESPGroup:AddLabel('Name Color'):AddColorPicker('NameColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) if _G.ESP then _G.ESP.setNameColor(c) end end })
    ESPGroup:AddSlider('MaxDistance', { Text = 'Max ESP Distance', Default = 1000, Min = 0, Max = 5000, Rounding = 1, Callback = function(v) if _G.ESP then _G.ESP.setMaxDistance(v) end end })
    
    -- Car ESP
    local CarESPGroup = Tabs.Visuals:AddRightGroupbox('Vehicle ESP')
    CarESPGroup:AddToggle('CarESP', { Text = 'Vehicle ESP', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setCarEspEnabled(v) end end })
    
    -- ===== WORLD TAB =====
    
    -- World Mods
    local WorldGroup = Tabs.World:AddLeftGroupbox('World Modifications')
    WorldGroup:AddToggle('RemoveGrass', { Text = 'Remove Grass', Default = false, Callback = function(v) if _G.World then _G.World.setRemoveGrass(v) end end })
    WorldGroup:AddToggle('NoTree', { Text = 'No Tree', Default = false, Callback = function(v) if _G.World then _G.World.setNoTree(v) end end })
    WorldGroup:AddToggle('RemoveClouds', { Text = 'Remove Clouds', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setRemoveClouds(v) end end })
    WorldGroup:AddToggle('NoInventoryBlur', { Text = 'No Inventory Blur', Default = false, Callback = function(v) if _G.World then _G.World.setNoInventoryBlur(v) end end })
    
    -- Lighting
    local LightingGroup = Tabs.World:AddLeftGroupbox('Lighting')
    LightingGroup:AddToggle('Fullbright', { Text = 'Fullbright', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setFullbright(v) end end })
    LightingGroup:AddToggle('NoFog', { Text = 'No Fog', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setNoFog(v) end end })
    LightingGroup:AddToggle('TimeChanger', { Text = 'Time Changer', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setTimeEnabled(v) end end })
    LightingGroup:AddSlider('TimeOfDay', { Text = 'Time Of Day', Default = 12, Min = 0, Max = 24, Rounding = 1, Callback = function(v) if _G.Visuals then _G.Visuals.setTimeValue(v) end end })
    
    -- Skybox
    local SkyboxGroup = Tabs.World:AddRightGroupbox('Skybox Changer')
    SkyboxGroup:AddDropdown('Skybox', { Text = 'Skybox', Default = 'Default', Values = { 'Default', 'Standard', 'Blue Sky', 'Vaporwave', 'Redshift', 'Blaze', 'Among Us', 'Dark Night', 'Bright Pink', 'Purple Sky', 'Galaxy' }, Callback = function(v) if _G.Visuals then _G.Visuals.applySkybox(v) end end })
    
    -- ===== CHARACTER TAB =====
    
    -- Arm Chams
    local ArmGroup = Tabs.Character:AddLeftGroupbox('Arm Chams')
    ArmGroup:AddToggle('ArmChams', { Text = 'Enable Arm Chams', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setArmChamsEnabled(v) end end })
    ArmGroup:AddLabel('Arm Color'):AddColorPicker('ArmColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) if _G.Visuals then _G.Visuals.setArmChamsColor(c) end end })
    ArmGroup:AddDropdown('ArmMaterial', { Values = { "ForceField", "Plastic", "SmoothPlastic", "Neon", "Glass", "Metal", "Wood", "Concrete" }, Default = "ForceField", Text = "Material", Callback = function(v) if _G.Visuals then _G.Visuals.setArmChamsMaterial(v) end end })
    
    -- Weapon Chams
    local WeaponGroup = Tabs.Character:AddLeftGroupbox('Weapon Chams')
    WeaponGroup:AddToggle('WeaponChams', { Text = 'Enable Weapon Chams', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setWeaponChamsEnabled(v) end end })
    WeaponGroup:AddLabel('Weapon Color'):AddColorPicker('WeaponColor', { Default = Color3.fromRGB(244,224,155), Callback = function(c) if _G.Visuals then _G.Visuals.setWeaponChamsColor(c) end end })
    WeaponGroup:AddDropdown('WeaponMaterial', { Values = { "ForceField", "Plastic", "SmoothPlastic", "Neon", "Glass", "Metal", "Wood", "Concrete" }, Default = "ForceField", Text = "Material", Callback = function(v) if _G.Visuals then _G.Visuals.setWeaponMaterial(v) end end })
    
    -- Self Chams
    local SelfGroup = Tabs.Character:AddRightGroupbox('Self Chams')
    SelfGroup:AddToggle('SelfChams', { Text = 'Enable Self Chams', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsEnabled(v) end end })
    SelfGroup:AddLabel('Self Color'):AddColorPicker('SelfColor', { Default = Color3.fromRGB(128,0,128), Callback = function(c) if _G.Visuals then _G.Visuals.setSelfChamsColor(c) end end })
    SelfGroup:AddDropdown('SelfMaterial', { Values = { "ForceField", "Neon", "Plastic", "SmoothPlastic", "Metal", "Glass", "Wood", "Concrete" }, Default = "ForceField", Text = "Material", Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsMaterial(v) end end })
    SelfGroup:AddSlider('BodyTransparency', { Text = 'Body Transparency', Default = 20, Min = 0, Max = 100, Rounding = 1, Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsTransparency(v / 100) end end })
    SelfGroup:AddSlider('HeadTransparency', { Text = 'Head Transparency', Default = 100, Min = 0, Max = 100, Rounding = 1, Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsHeadTransparency(v / 100) end end })
    
    -- ===== EXPLOIT TAB =====
    
    -- Movement
    local MoveGroup = Tabs.Exploit:AddLeftGroupbox('Movement Exploits')
    MoveGroup:AddToggle('Fly', { Text = 'Fly (Press P)', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setFlyEnabled(v) end end })
    MoveGroup:AddSlider('FlySpeed', { Text = 'Fly Speed', Default = 50, Min = 10, Max = 300, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setFlySpeed(v) end end })
    MoveGroup:AddDivider()
    MoveGroup:AddToggle('Speedhack', { Text = 'Speedhack', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setSpeedhackEnabled(v) end end })
    MoveGroup:AddSlider('SpeedhackSpeed', { Text = 'Speed', Default = 20, Min = 5, Max = 100, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setSpeedhackSpeed(v) end end })
    MoveGroup:AddDivider()
    MoveGroup:AddToggle('AntiAim', { Text = 'Anti-Aim', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setAntiAimEnabled(v) end end })
    MoveGroup:AddDropdown('AntiAimMode', { Text = 'Mode', Default = 'Up', Values = { 'Up', 'Down', 'Random', 'Custom' }, Callback = function(v) if _G.Exploits then _G.Exploits.setAntiAimMode(v) end end })
    MoveGroup:AddDivider()
    MoveGroup:AddToggle('Spinbot', { Text = 'Spinbot', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setSpinbotEnabled(v) end end })
    MoveGroup:AddSlider('SpinbotSpeed', { Text = 'Spin Speed', Default = 5, Min = 1, Max = 100, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setSpinbotSpeed(v) end end })
    MoveGroup:AddDivider()
    MoveGroup:AddToggle('AutoJump', { Text = 'Auto Jump (Bunny Hop)', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setAutoJumpEnabled(v) end end })
    MoveGroup:AddToggle('ClimbSpeed', { Text = 'Climb Speed', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setClimbSpeedEnabled(v) end end })
    MoveGroup:AddSlider('ClimbSpeedValue', { Text = 'Climb Speed', Default = 15, Min = 0, Max = 50, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setClimbSpeedValue(v) end end })
    
    -- Hitbox
    local HitboxGroup = Tabs.Exploit:AddRightGroupbox('Hitbox Expander')
    HitboxGroup:AddToggle('HitboxExpander', { Text = 'Enable Hitbox Expander', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setHitboxExpanderEnabled(v) end end })
    HitboxGroup:AddSlider('HitboxRadius', { Text = 'Hitbox Radius', Default = 5, Min = 1, Max = 10, Rounding = 1, Callback = function(v) if _G.Missing then _G.Missing.setHitboxExpanderRadius(v) end end })
    
    -- Zombie
    local ZombieGroup = Tabs.Exploit:AddRightGroupbox('Zombie Expander')
    ZombieGroup:AddToggle('ZombieExpander', { Text = 'Enable Zombie Expander', Default = false, Callback = function(v) if _G.World then _G.World.setZombieExpander(v) end end })
    ZombieGroup:AddSlider('ZombieSize', { Text = 'Hitbox Size', Default = 16, Min = 1, Max = 50, Rounding = 1, Callback = function(v) if _G.World then _G.World.setZombieHitboxSize(v) end end })
    ZombieGroup:AddSlider('ZombieHeadTransparency', { Text = 'Head Transparency', Default = 90, Min = 0, Max = 100, Rounding = 1, Callback = function(v) if _G.World then _G.World.setZombieHeadTransparency(v / 100) end end })
    
    -- Long Neck
    local NeckGroup = Tabs.Exploit:AddRightGroupbox('Long Neck')
    NeckGroup:AddToggle('LongNeck', { Text = 'Long Neck', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setLongNeckEnabled(v) end end })
    NeckGroup:AddSlider('NeckHeight', { Text = 'Height', Default = 5, Min = 1, Max = 7, Rounding = 1, Callback = function(v) if _G.Visuals then _G.Visuals.setLongNeckHeight(v) end end })
    
    -- Car Speed
    local CarGroup = Tabs.Exploit:AddRightGroupbox('Car Speed')
    CarGroup:AddToggle('CarSpeed', { Text = 'Car Speed Mod', Default = false, Callback = function(v) if _G.World then _G.World.setCarSpeedEnabled(v) end end })
    CarGroup:AddSlider('ForwardSpeed', { Text = 'Forward Max Speed', Default = 100, Min = 50, Max = 300, Rounding = 1, Callback = function(v) if _G.World then _G.World.setCarForwardMaxSpeed(v) end end })
    CarGroup:AddSlider('ReverseSpeed', { Text = 'Reverse Max Speed', Default = 40, Min = 20, Max = 150, Rounding = 1, Callback = function(v) if _G.World then _G.World.setCarReverseMaxSpeed(v) end end })
    CarGroup:AddSlider('Acceleration', { Text = 'Acceleration', Default = 60, Min = 10, Max = 200, Rounding = 1, Callback = function(v) if _G.World then _G.World.setCarAcceleration(v) end end })
    CarGroup:AddButton('Toggle No Car Damage', function() if _G.World then _G.World.toggleNoCarDamage() end end)
    
    -- ===== UI SETTINGS =====
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu Settings')
    MenuGroup:AddButton('Unload', function() Library:Unload() end)
    MenuGroup:AddLabel('Menu Bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
    
    -- Finalizar
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
    
    print("✅ UI Carregada!")
end

return UI
