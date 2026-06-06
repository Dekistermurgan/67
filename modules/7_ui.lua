-- MÓDULO: UI COMPLETA
local UI = {}

function UI.Initialize(Library, ThemeManager, SaveManager)
    local Window = Library:CreateWindow({
        Title = 'WELCOME TO THE RIFT',
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
    
    -- Silent Aim Section
    local SilentAimSection = Tabs.Combat:AddLeftGroupbox('Silent Aim')
    SilentAimSection:AddToggle('SilentAimToggle', { Text = 'Enable Silent Aim', Default = false, Callback = function(v) if _G.SilentAim then _G.SilentAim.setEnabled(v) end end })
    SilentAimSection:AddToggle('SilentTeamCheck', { Text = 'Team Check', Default = true, Callback = function(v) if _G.SilentAim then _G.SilentAim.setTeamCheck(v) end end })
    SilentAimSection:AddDivider()
    SilentAimSection:AddDropdown('SilentAimPart', { Values = { 'Head', 'UpperTorso', 'HumanoidRootPart' }, Default = 1, Text = 'Target Part', Callback = function(v) if _G.SilentAim then _G.SilentAim.setAimPart(v) end end })
    SilentAimSection:AddSlider('SilentFOVRadius', { Text = 'FOV Radius', Default = 200, Min = 0, Max = 500, Rounding = 1, Callback = function(v) if _G.SilentAim then _G.SilentAim.setFOVRadius(v) end end })
    SilentAimSection:AddToggle('SilentFOVVisible', { Text = 'Show FOV Circle', Default = false, Callback = function(v) if _G.SilentAim then _G.SilentAim.setFOVVisible(v) end end })
    SilentAimSection:AddDivider()
    SilentAimSection:AddDropdown('SilentPredictionMode', { Text = 'Prediction Mode', Default = 'Axal', Values = { 'Axal', 'Priv9' }, Callback = function(v) if _G.SilentAim then _G.SilentAim.setPredictionMode(v) end end })
    SilentAimSection:AddToggle('SilentResolveY', { Text = 'Resolve Y (Ignore Vertical Velocity)', Default = false, Callback = function(v) if _G.SilentAim then _G.SilentAim.setResolveY(v) end end })
    SilentAimSection:AddToggle('SilentInstantBullet', { Text = 'Instant Bullet (No Prediction Time)', Default = false, Callback = function(v) if _G.SilentAim then _G.SilentAim.setInstantBullet(v) end end })
    SilentAimSection:AddToggle('SilentNoSpread', { Text = 'No Spread', Default = false, Callback = function(v) if _G.SilentAim then _G.SilentAim.setNoSpread(v) end end })
    
    -- Mouse Aimbot Section
    local MouseAimbotSection = Tabs.Combat:AddLeftGroupbox('Mouse Aimbot')
    local aimbotToggle = MouseAimbotSection:AddToggle('AimbotToggle', { Text = 'Enable Mouse Aimbot', Default = false, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setEnabled(v) end end })
    MouseAimbotSection:AddLabel('Toggle Aimbot Key'):AddKeyPicker('AimbotToggleKey', { Default = 'X', SyncToggleState = true, Mode = 'Toggle', Text = 'Toggle Aimbot Key', Callback = function(value) aimbotToggle:SetValue(value) end })
    MouseAimbotSection:AddDivider()
    MouseAimbotSection:AddDropdown('HitPart', { Values = { 'Head', 'UpperTorso', 'HumanoidRootPart' }, Default = 1, Text = 'Hit Part', Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setHitPart(v) end end })
    MouseAimbotSection:AddSlider('Smoothing', { Text = 'Smoothing', Default = 50, Min = 0, Max = 100, Rounding = 1, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setSmoothing(v) end end })
    
    -- Predictions Section
    local PredictionsSection = Tabs.Combat:AddLeftGroupbox('Mouse Aimbot Predictions')
    PredictionsSection:AddSlider('PredictionX', { Text = 'Lateral Prediction (s)', Default = 20, Min = 0, Max = 50, Rounding = 1, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setPredictionX(v) end end })
    PredictionsSection:AddSlider('BulletDropFactor', { Text = 'Bullet Drop Factor (%)', Default = 100, Min = 0, Max = 200, Rounding = 1, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setBulletDropFactor(v) end end })
    PredictionsSection:AddSlider('VerticalOffset', { Text = 'Vertical Offset (studs)', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) if _G.MouseAimbot then _G.MouseAimbot.setVerticalOffset(v) end end })
    
    -- Mouse FOV Section (COMPLETA)
    local MouseFOVSection = Tabs.Combat:AddRightGroupbox('Mouse Aimbot FOV')
    MouseFOVSection:AddToggle('ShowFOV', { Text = 'Show FOV Circle', Default = false, Callback = function(v) 
        if _G.MouseAimbot then _G.MouseAimbot.setFOVVisible(v) end 
    end })
    MouseFOVSection:AddSlider('FOVRadius', { Text = 'FOV Radius', Default = 200, Min = 0, Max = 500, Rounding = 1, Callback = function(v) 
        if _G.MouseAimbot then _G.MouseAimbot.setFOVRadius(v) end 
    end })
    MouseFOVSection:AddSlider('FOVThickness', { Text = 'FOV Thickness', Default = 2, Min = 1, Max = 10, Rounding = 1, Callback = function(v) 
        if _G.MouseAimbot then _G.MouseAimbot.setFOVThickness(v) end 
    end })
    MouseFOVSection:AddDropdown('FOVShape', { Text = 'FOV Shape', Default = 'Circle', Values = { 'Circle', 'Triangle', 'Star of David', 'Pentagon', 'Hexagon' }, Callback = function(v) 
        if _G.MouseAimbot then _G.MouseAimbot.setFOVShape(v) end 
    end })
    MouseFOVSection:AddToggle('FOVSpin', { Text = 'Spin FOV', Default = false, Callback = function(v) 
        if _G.MouseAimbot then _G.MouseAimbot.setFOVSpin(v) end 
    end })
    MouseFOVSection:AddSlider('FOVSpinSpeed', { Text = 'Spin Speed', Default = 45, Min = 0, Max = 360, Rounding = 1, Callback = function(v) 
        if _G.MouseAimbot then _G.MouseAimbot.setFOVSpinSpeed(v) end 
    end })
    MouseFOVSection:AddLabel('FOV Color'):AddColorPicker('FOVColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) 
        if _G.MouseAimbot then _G.MouseAimbot.setFOVColor(c) end 
    end })
    MouseFOVSection:AddToggle('FOVRainbow', { Text = 'Rainbow FOV', Default = false, Callback = function(v) 
        if _G.MouseAimbot then _G.MouseAimbot.setFOVRainbow(v) end 
    end })
    
    -- Gun Modifications Section (COMPLETA)
    local GunmodsSection = Tabs.Combat:AddRightGroupbox('Gun Modifications')
    GunmodsSection:AddToggle('NoRecoil', { Text = 'No Recoil', Default = true, Callback = function(v) getgenv().norecoilenabled = v end })
    GunmodsSection:AddToggle('NoGunSway', { Text = 'No Gun Sway', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setNoGunSway(v) end end })
    GunmodsSection:AddToggle('NoGunBob', { Text = 'No Gun Bob', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setNoGunBob(v) end end })
    GunmodsSection:AddToggle('InstantAim', { Text = 'Instant Aim', Default = false, Callback = function(v) if v and _G.Missing then _G.Missing.enableInstantAim() end end })
    GunmodsSection:AddToggle('SilentReload', { Text = 'Silent Reload', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setSilentReloadEnabled(v) end end })
    
    -- Offset Changer Section
    local OffsetSection = Tabs.Combat:AddRightGroupbox('Offset Changer')
    OffsetSection:AddToggle('OffsetToggle', { Text = 'Enable Offset Changer', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setOffsetEnabled(v) end end })
    OffsetSection:AddSlider('OffsetX', { Text = 'Offset X', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) if _G.Missing then _G.Missing.setOffsetX(v) end end })
    OffsetSection:AddSlider('OffsetY', { Text = 'Offset Y', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) if _G.Missing then _G.Missing.setOffsetY(v) end end })
    OffsetSection:AddSlider('OffsetZ', { Text = 'Offset Z', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) if _G.Missing then _G.Missing.setOffsetZ(v) end end })
    
    -- Hitsounds Section
    local SoundGroup = Tabs.Combat:AddLeftGroupbox('Hitsounds')
    local currentHitmarker = "Rust"
    local currentHeadshot = "CS"
    
    SoundGroup:AddToggle('HitsoundsToggle', { Text = 'Hitsounds', Default = false, Callback = function(v) 
        if _G.Missing then 
            _G.Missing.setupHitsounds(v, currentHitmarker, currentHeadshot, Library)
        end 
    end })
    SoundGroup:AddDropdown('HitmarkerSound', { Text = 'Hitmarker Sound', Default = 'Rust', Values = { "Rust", "Minecraft", "Pop", "CS", "Neverlose", "Gamesense", "nn dog" }, Callback = function(v) 
        currentHitmarker = v
        if _G.Missing then _G.Missing.playSoundPreview(_G.Missing.gameObjects.HITSOUND_OPTIONS[v]) end
    end })
    SoundGroup:AddDropdown('HeadshotSound', { Text = 'Headshot Sound', Default = 'CS', Values = { "Rust", "Minecraft", "Pop", "CS", "Neverlose", "Gamesense", "nn dog" }, Callback = function(v) 
        currentHeadshot = v
        if _G.Missing then _G.Missing.playSoundPreview(_G.Missing.gameObjects.HITSOUND_OPTIONS[v]) end
    end })
    
    -- ===== VISUALS TAB =====
    
    -- Scanner
    local ScannerGroup = Tabs.Visuals:AddLeftGroupbox("Scanner")
    ScannerGroup:AddButton("Run Scanner", function() if _G.Missing then _G.Missing.runScanner() end end)
    
    -- Player ESP (COMPLETA)
    local VisualMainSection = Tabs.Visuals:AddLeftGroupbox('Player ESP')
    VisualMainSection:AddToggle('ESPEnabled', { Text = 'Enable ESP', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setEnabled(v) end end })
    VisualMainSection:AddToggle('ShowBoxes', { Text = 'Show Boxes', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setBoxEnabled(v) end end })
    VisualMainSection:AddToggle('FilledBoxes', { Text = 'Filled Boxes', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setBoxFilled(v) end end })
    VisualMainSection:AddToggle('OutlinesBoxes', { Text = 'Outline Boxes', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setBoxOutline(v) end end })
    VisualMainSection:AddToggle('Skeleton', { Text = 'Skeleton', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setSkeleton(v) end end })
    VisualMainSection:AddToggle('ShowNames', { Text = 'Show Names', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setNames(v) end end })
    VisualMainSection:AddToggle('ShowDistances', { Text = 'Show Distances', Default = false, Callback = function(v) if _G.ESP then _G.ESP.setDistances(v) end end })
    VisualMainSection:AddLabel('Box Color'):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) if _G.ESP then _G.ESP.setBoxColor(c) end end })
    VisualMainSection:AddLabel('Box Outline Color'):AddColorPicker('BoxOutlineColor', { Default = Color3.fromRGB(0,0,0), Callback = function(c) if _G.ESP then _G.ESP.setBoxOutlineColor(c) end end })
    VisualMainSection:AddLabel('Skeleton Color'):AddColorPicker('SkeletonColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) if _G.ESP then _G.ESP.setSkeletonColor(c) end end })
    VisualMainSection:AddLabel('Name Color'):AddColorPicker('NameColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) if _G.ESP then _G.ESP.setNameColor(c) end end })
    VisualMainSection:AddLabel('Distance Color'):AddColorPicker('DistanceColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) if _G.ESP then _G.ESP.setDistanceColor(c) end end })
    VisualMainSection:AddSlider('MaxESPDistance', { Text = 'Max ESP Distance', Default = 1000, Min = 0, Max = 5000, Rounding = 1, Callback = function(v) if _G.ESP then _G.ESP.setMaxDistance(v) end end })
    
    -- Vehicle ESP
    local CarSection = Tabs.Visuals:AddRightGroupbox('Vehicle ESP')
    CarSection:AddToggle('CarESP', { Text = 'Vehicle ESP', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setCarEspEnabled(v) end end })
    
    -- ===== WORLD TAB =====
    
    local Remover = Tabs.World:AddLeftGroupbox('World Modifications')
    Remover:AddToggle('RemoveGrass', { Text = 'Remove Grass', Default = false, Callback = function(v) if _G.World then _G.World.setRemoveGrass(v) end end })
    Remover:AddToggle('NoTreeToggle', { Text = 'No Tree', Default = false, Callback = function(v) if _G.World then _G.World.setNoTree(v) end end })
    
    local lightingSection = Tabs.World:AddLeftGroupbox('Lighting')
    lightingSection:AddToggle('Fullbright', { Text = 'Fullbright', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setFullbright(v) end end })
    lightingSection:AddToggle('NoFog', { Text = 'No Fog', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setNoFog(v) end end })
    lightingSection:AddToggle('RemoveClouds', { Text = 'Remove Clouds', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setRemoveClouds(v) end end })
    lightingSection:AddToggle('TimeChanger', { Text = 'Time Changer', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setTimeEnabled(v) end end })
    lightingSection:AddSlider('TimeOfDay', { Text = 'Time Of Day', Default = 12, Min = 0, Max = 24, Rounding = 1, Callback = function(v) if _G.Visuals then _G.Visuals.setTimeValue(v) end end })
    
    local SkyboxSection = Tabs.World:AddRightGroupbox('Skybox Changer')
    SkyboxSection:AddDropdown('Skybox', { Text = 'Skybox', Default = 'Default', Values = { 'Default', 'Standard', 'Blue Sky', 'Vaporwave', 'Redshift', 'Blaze', 'Among Us', 'Dark Night', 'Bright Pink', 'Purple Sky', 'Galaxy' }, Callback = function(v) if _G.Visuals then _G.Visuals.applySkybox(v) end end })
    
    -- ===== CHARACTER TAB =====
    
    local ArmChamsSection = Tabs.Character:AddLeftGroupbox('Arm Chams (First Person)')
    ArmChamsSection:AddToggle('ArmChamsToggle', { Text = "Enable Arm Chams", Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setArmChamsEnabled(v) end end })
    ArmChamsSection:AddLabel('Arm Color'):AddColorPicker('ArmChamsColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) if _G.Visuals then _G.Visuals.setArmChamsColor(c) end end })
    ArmChamsSection:AddDropdown('ArmChamsMaterial', { Values = { "ForceField", "Plastic", "SmoothPlastic", "Neon", "Glass", "Metal", "Wood", "Concrete" }, Default = "ForceField", Text = "Arm Material", Callback = function(v) if _G.Visuals then _G.Visuals.setArmChamsMaterial(v) end end })
    
    local WeaponChamsSection = Tabs.Character:AddLeftGroupbox('Weapon Chams')
    WeaponChamsSection:AddToggle('WeaponChamsToggle', { Text = "Weapon Chams", Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setWeaponChamsEnabled(v) end end })
    WeaponChamsSection:AddLabel('Weapon Chams Color'):AddColorPicker('WeaponChamsColor', { Default = Color3.fromRGB(244,224,155), Callback = function(c) if _G.Visuals then _G.Visuals.setWeaponChamsColor(c) end end })
    WeaponChamsSection:AddDropdown('WeaponMaterial', { Values = { "ForceField", "Plastic", "SmoothPlastic", "Neon", "Glass", "Metal", "Wood", "Concrete" }, Default = "ForceField", Text = "Weapon Material", Callback = function(v) if _G.Visuals then _G.Visuals.setWeaponMaterial(v) end end })
    
    local SelfChamsSection = Tabs.Character:AddRightGroupbox('Self Chams')
    SelfChamsSection:AddToggle('SelfChamsToggle', { Text = "Self Chams", Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsEnabled(v) end end })
    SelfChamsSection:AddLabel('Self Chams Color'):AddColorPicker('SelfChamsColor', { Default = Color3.fromRGB(128,0,128), Callback = function(c) if _G.Visuals then _G.Visuals.setSelfChamsColor(c) end end })
    SelfChamsSection:AddDropdown('SelfChamsMaterial', { Values = { "ForceField", "Neon", "Plastic", "SmoothPlastic", "Metal", "Glass", "Wood", "Concrete" }, Default = "ForceField", Text = "Material", Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsMaterial(v) end end })
    SelfChamsSection:AddSlider('SelfChamsTransparency', { Text = 'Body Transparency', Default = 0.2, Min = 0, Max = 1, Rounding = 2, Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsTransparency(v) end end })
    SelfChamsSection:AddSlider('SelfChamsHeadTransparency', { Text = 'Head Transparency', Default = 1, Min = 0, Max = 1, Rounding = 2, Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsHeadTransparency(v) end end })
    
    -- ===== EXPLOIT TAB =====
    
    local ExploitGroup = Tabs.Exploit:AddLeftGroupbox('Movement Exploits')
    ExploitGroup:AddToggle('FlyEnabled', { Text = 'Enable Fly', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setFlyEnabled(v) end end })
    ExploitGroup:AddSlider('FlySpeed', { Text = 'Fly Speed', Default = 50, Min = 10, Max = 300, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setFlySpeed(v) end end })
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('SpeedhackToggle', { Text = 'Speedhack', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setSpeedhackEnabled(v) end end })
    ExploitGroup:AddSlider('SpeedhackSlider', { Text = 'Speedhack Speed', Default = 20, Min = 5, Max = 100, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setSpeedhackSpeed(v) end end })
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('AntiAimToggle', { Text = 'Anti-Aim', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setAntiAimEnabled(v) end end })
    ExploitGroup:AddDropdown('AntiAimMode', { Text = 'Anti-Aim Mode', Default = 'Up', Values = { 'Up', 'Down', 'Random', 'Custom' }, Callback = function(v) if _G.Exploits then _G.Exploits.setAntiAimMode(v) end end })
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('SpinbotToggle', { Text = 'Spinbot', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setSpinbotEnabled(v) end end })
    ExploitGroup:AddSlider('SpinbotSpeed', { Text = 'Spinbot Speed (rad/s)', Default = 5, Min = 1, Max = 100, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setSpinbotSpeed(v) end end })
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('AutoJump', { Text = 'Auto Jump (Bunny Hop)', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setAutoJumpEnabled(v) end end })
    ExploitGroup:AddToggle('ClimbSpeedToggle', { Text = 'Climb Speed', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setClimbSpeedEnabled(v) end end })
    ExploitGroup:AddSlider('ClimbSpeedValue', { Text = 'Climb Speed', Default = 15, Min = 0, Max = 50, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setClimbSpeedValue(v) end end })
    
    -- Hitbox Expander Section
    local HitboxExpanderSection = Tabs.Exploit:AddRightGroupbox('Hitbox Expander')
    HitboxExpanderSection:AddToggle('HitboxExpanderToggle', { Text = 'Enable Hitbox Expander', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setHitboxExpanderEnabled(v) end end })
    HitboxExpanderSection:AddSlider('HitboxExpanderRadius', { Text = 'Hitbox Radius', Default = 5, Min = 1, Max = 10, Rounding = 1, Callback = function(v) if _G.Missing then _G.Missing.setHitboxExpanderRadius(v) end end })
    
    -- Zombie Expander Section
    local ZombieSection = Tabs.Exploit:AddRightGroupbox('Zombie Expander')
    ZombieSection:AddToggle('ZombieExpanderToggle', { Text = 'Zombie Expander', Default = false, Callback = function(v) if _G.World then _G.World.setZombieExpander(v) end end })
    ZombieSection:AddSlider('ZombieHitboxSize', { Text = 'Hitbox Size', Default = 16, Min = 1, Max = 50, Rounding = 1, Callback = function(v) if _G.World then _G.World.setZombieHitboxSize(v) end end })
    ZombieSection:AddSlider('ZombieHeadTransparency', { Text = 'Head Transparency', Default = 0.9, Min = 0, Max = 1, Rounding = 2, Callback = function(v) if _G.World then _G.World.setZombieHeadTransparency(v) end end })
    
    -- Long Neck Section
    local LongNeckSection = Tabs.Exploit:AddRightGroupbox('Long Neck')
    LongNeckSection:AddToggle('LongNeckToggle', { Text = 'Long Neck', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setLongNeckEnabled(v) end end })
    LongNeckSection:AddSlider('LongNeckHeight', { Text = 'Neck Height', Default = 5, Min = 1, Max = 7, Rounding = 1, Callback = function(v) if _G.Visuals then _G.Visuals.setLongNeckHeight(v) end end })
    
    -- Car Speed Section
    local CarSpeedSection = Tabs.Exploit:AddRightGroupbox('Car Speed')
    CarSpeedSection:AddToggle('CarSpeedToggle', { Text = 'Car Speed', Default = false, Callback = function(v) if _G.World then _G.World.setCarSpeedEnabled(v) end end })
    CarSpeedSection:AddSlider('CarForwardMaxSpeed', { Text = 'Forward Max Speed', Default = 100, Min = 50, Max = 300, Rounding = 1, Callback = function(v) if _G.World then _G.World.setCarForwardMaxSpeed(v) end end })
    CarSpeedSection:AddSlider('CarReverseMaxSpeed', { Text = 'Reverse Max Speed', Default = 40, Min = 20, Max = 150, Rounding = 1, Callback = function(v) if _G.World then _G.World.setCarReverseMaxSpeed(v) end end })
    CarSpeedSection:AddSlider('CarAcceleration', { Text = 'Acceleration', Default = 60, Min = 10, Max = 200, Rounding = 1, Callback = function(v) if _G.World then _G.World.setCarAcceleration(v) end end })
    CarSpeedSection:AddSlider('CarDeceleration', { Text = 'Deceleration', Default = 100, Min = 20, Max = 300, Rounding = 1, Callback = function(v) if _G.World then _G.World.setCarDeceleration(v) end end })
    CarSpeedSection:AddSlider('CarBraking', { Text = 'Braking Force', Default = 35, Min = 10, Max = 150, Rounding = 1, Callback = function(v) if _G.World then _G.World.setCarBraking(v) end end })
    CarSpeedSection:AddSlider('CarSteeringReduction', { Text = 'Steering Reduction', Default = 35, Min = 0, Max = 100, Rounding = 2, Callback = function(v) if _G.World then _G.World.setCarSteeringReduction(v) end end })
    CarSpeedSection:AddButton('Toggle No Car Damage', function() if _G.World then _G.World.toggleNoCarDamage() end end)
    
    -- No Inventory Blur
    local VisualModsSection = Tabs.Combat:AddLeftGroupbox('Visual Mods')
    VisualModsSection:AddToggle('NoInventoryBlur', { Text = 'No Inventory Blur', Default = false, Callback = function(v) if _G.Missing then _G.Missing.setNoInventoryBlur(v) end end })
    
    -- ===== UI SETTINGS =====
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu Settings')
    MenuGroup:AddButton('Unload', function() Library:Unload() end)
    MenuGroup:AddLabel('Menu Bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
    
    -- Configurar tema e saves
    Library.ToggleKeybind = 'End'
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder('CatHook')
    ThemeManager:ApplyToTab(Tabs['UI Settings'])
    
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
    SaveManager:SetFolder('CatHook/Aftermath')
    SaveManager:BuildConfigSection(Tabs['UI Settings'])
    SaveManager:LoadAutoloadConfig()
    
    print("UI Carregada com sucesso!")
end

return UI
