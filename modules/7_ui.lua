-- MÓDULO: UI (Interface Linoria)
local UI = {}

local Library = nil
local ThemeManager = nil
local SaveManager = nil

-- Função para inicializar a UI (chamada depois que todos os módulos estão carregados)
function UI.Initialize(lib, theme, save)
    Library = lib
    ThemeManager = theme
    SaveManager = save
    
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
    SilentAimSection:AddToggle('SilentAimToggle', { Text = 'Enable Silent Aim', Default = false, Callback = function(v) _G.SilentAim.setEnabled(v) end })
    SilentAimSection:AddToggle('SilentTeamCheck', { Text = 'Team Check', Default = true, Callback = function(v) _G.SilentAim.setTeamCheck(v) end })
    SilentAimSection:AddDivider()
    SilentAimSection:AddDropdown('SilentAimPart', { Values = { 'Head', 'UpperTorso', 'HumanoidRootPart' }, Default = 1, Text = 'Target Part', Callback = function(v) _G.SilentAim.setAimPart(v) end })
    SilentAimSection:AddSlider('SilentFOVRadius', { Text = 'FOV Radius', Default = 200, Min = 0, Max = 500, Rounding = 1, Callback = function(v) _G.SilentAim.setFOVRadius(v) end })
    SilentAimSection:AddToggle('SilentFOVVisible', { Text = 'Show FOV Circle', Default = false, Callback = function(v) _G.SilentAim.setFOVVisible(v) end })
    SilentAimSection:AddDivider()
    SilentAimSection:AddDropdown('SilentPredictionMode', { Text = 'Prediction Mode', Default = 'Axal', Values = { 'Axal', 'Priv9' }, Callback = function(v) _G.SilentAim.setPredictionMode(v) end })
    SilentAimSection:AddToggle('SilentResolveY', { Text = 'Resolve Y (Ignore Vertical Velocity)', Default = false, Callback = function(v) _G.SilentAim.setResolveY(v) end })
    SilentAimSection:AddToggle('SilentInstantBullet', { Text = 'Instant Bullet (No Prediction Time)', Default = false, Callback = function(v) _G.SilentAim.setInstantBullet(v) end })
    SilentAimSection:AddToggle('SilentNoSpread', { Text = 'No Spread', Default = false, Callback = function(v) _G.SilentAim.setNoSpread(v) end })
    
    -- Mouse Aimbot Section
    local MouseAimbotSection = Tabs.Combat:AddLeftGroupbox('Mouse Aimbot')
    local aimbotToggle = MouseAimbotSection:AddToggle('AimbotToggle', { Text = 'Enable Mouse Aimbot', Default = false, Callback = function(v) _G.MouseAimbot.setEnabled(v) end })
    MouseAimbotSection:AddLabel('Toggle Aimbot Key'):AddKeyPicker('AimbotToggleKey', { Default = 'X', SyncToggleState = true, Mode = 'Toggle', Text = 'Toggle Aimbot Key', Callback = function(value) aimbotToggle:SetValue(value) end })
    MouseAimbotSection:AddDivider()
    MouseAimbotSection:AddDropdown('HitPart', { Values = { 'Head', 'UpperTorso', 'HumanoidRootPart' }, Default = 1, Text = 'Hit Part', Callback = function(v) _G.MouseAimbot.setHitPart(v) end })
    MouseAimbotSection:AddSlider('Smoothing', { Text = 'Smoothing', Default = 50, Min = 0, Max = 100, Rounding = 1, Callback = function(v) _G.MouseAimbot.setSmoothing(v) end })
    
    -- Predictions Section
    local PredictionsSection = Tabs.Combat:AddLeftGroupbox('Mouse Aimbot Predictions')
    PredictionsSection:AddSlider('PredictionX', { Text = 'Lateral Prediction (s)', Default = 20, Min = 0, Max = 50, Rounding = 1, Callback = function(v) _G.MouseAimbot.setPredictionX(v) end })
    PredictionsSection:AddSlider('BulletDropFactor', { Text = 'Bullet Drop Factor (%)', Default = 100, Min = 0, Max = 200, Rounding = 1, Callback = function(v) _G.MouseAimbot.setBulletDropFactor(v) end })
    PredictionsSection:AddSlider('VerticalOffset', { Text = 'Vertical Offset (studs)', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) _G.MouseAimbot.setVerticalOffset(v) end })
    
    -- Mouse FOV Section
    local MouseFOVSection = Tabs.Combat:AddRightGroupbox('Mouse Aimbot FOV')
    MouseFOVSection:AddToggle('ShowFOV', { Text = 'Show FOV Circle', Default = false, Callback = function(v) _G.MouseAimbot.setFOVVisible(v) end })
    MouseFOVSection:AddSlider('FOVRadius', { Text = 'FOV Radius', Default = 200, Min = 0, Max = 500, Rounding = 1, Callback = function(v) _G.MouseAimbot.setFOVRadius(v) end })
    MouseFOVSection:AddSlider('FOVThickness', { Text = 'FOV Outline Thickness', Default = 2, Min = 0, Max = 10, Rounding = 1, Callback = function(v) _G.MouseAimbot.setFOVThickness(v) end })
    
    -- Gun Modifications Section
    local GunmodsSection = Tabs.Combat:AddRightGroupbox('Gun Modifications')
    GunmodsSection:AddToggle('NoRecoil', { Text = 'No Recoil', Default = true, Callback = function(v) getgenv().norecoilenabled = v end })
    GunmodsSection:AddToggle('SilentReload', { Text = 'Silent Reload', Default = false, Callback = function(v) _G.Exploits.setSilentReloadEnabled(v) end })
    
    -- Offset Changer Section
    local OffsetSection = Tabs.Combat:AddRightGroupbox('Offset Changer')
    -- (Offset não movido ainda, manter no UI por enquanto)
    
    -- ===== VISUALS TAB =====
    
    -- Scanner
    local ScannerGroup = Tabs.Visuals:AddLeftGroupbox("Scanner")
    ScannerGroup:AddButton("Run Scanner", function() 
        if _G.Scanner then _G.Scanner.runScanner() end
    end)
    
    -- Player ESP
    local VisualMainSection = Tabs.Visuals:AddLeftGroupbox('Player ESP')
    VisualMainSection:AddToggle('ESPEnabled', { Text = 'Enable ESP', Default = false, Callback = function(v) _G.ESP.setEnabled(v) end })
    VisualMainSection:AddToggle('ShowBoxes', { Text = 'Show Boxes', Default = false, Callback = function(v) _G.ESP.setBoxEnabled(v) end })
    VisualMainSection:AddToggle('Skeleton', { Text = 'Skeleton', Default = false, Callback = function(v) _G.ESP.setSkeleton(v) end })
    VisualMainSection:AddToggle('ShowNames', { Text = 'Show Names', Default = false, Callback = function(v) _G.ESP.setNames(v) end })
    VisualMainSection:AddToggle('ShowDistances', { Text = 'Show Distances', Default = false, Callback = function(v) _G.ESP.setDistances(v) end })
    VisualMainSection:AddLabel('Box Color'):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) _G.ESP.setBoxColor(c) end })
    VisualMainSection:AddLabel('Name Color'):AddColorPicker('NameColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) _G.ESP.setNameColor(c) end })
    VisualMainSection:AddSlider('MaxESPDistance', { Text = 'Max ESP Distance', Default = 1000, Min = 0, Max = 5000, Rounding = 1, Callback = function(v) _G.ESP.setMaxDistance(v) end })
    
    -- Vehicle ESP
    local CarSection = Tabs.Visuals:AddRightGroupbox('Vehicle ESP')
    CarSection:AddToggle('CarESP', { Text = 'Vehicle ESP', Default = false, Callback = function(v) _G.carEspEnabled = v end })
    
    -- ===== WORLD TAB =====
    
    local Remover = Tabs.World:AddLeftGroupbox('World Modifications')
    Remover:AddToggle('RemoveGrass', { Text = 'Remove Grass', Default = false, Callback = function(v) _G.World.setRemoveGrass(v) end })
    Remover:AddToggle('NoTreeToggle', { Text = 'No Tree', Default = false, Callback = function(v) _G.World.setNoTree(v) end })
    
    local lightingSection = Tabs.World:AddLeftGroupbox('Lighting')
    lightingSection:AddToggle('Fullbright', { Text = 'Fullbright', Default = false, Callback = function(v) _G.Visuals.setFullbright(v) end })
    lightingSection:AddToggle('NoFog', { Text = 'No Fog', Default = false, Callback = function(v) _G.Visuals.setNoFog(v) end })
    lightingSection:AddToggle('TimeChanger', { Text = 'Time Changer', Default = false, Callback = function(v) _G.Visuals.setTimeEnabled(v) end })
    lightingSection:AddSlider('TimeOfDay', { Text = 'Time Of Day', Default = 12, Min = 0, Max = 24, Rounding = 1, Callback = function(v) _G.Visuals.setTimeValue(v) end })
    
    local SkyboxSection = Tabs.World:AddRightGroupbox('Skybox Changer')
    SkyboxSection:AddDropdown('Skybox', { Text = 'Skybox', Default = 'Default', Values = { 'Default', 'Standard', 'Blue Sky', 'Vaporwave', 'Redshift', 'Blaze', 'Among Us', 'Dark Night', 'Bright Pink', 'Purple Sky', 'Galaxy' }, Callback = function(v) _G.Visuals.applySkybox(v) end })
    
    -- ===== CHARACTER TAB =====
    
    local ArmChamsSection = Tabs.Character:AddLeftGroupbox('Arm Chams (First Person)')
    ArmChamsSection:AddToggle('ArmChamsToggle', { Text = "Enable Arm Chams", Default = false, Callback = function(v) _G.Visuals.setArmChamsEnabled(v) end })
    ArmChamsSection:AddLabel('Arm Color'):AddColorPicker('ArmChamsColor', { Default = Color3.fromRGB(255,255,255), Callback = function(c) _G.Visuals.setArmChamsColor(c) end })
    ArmChamsSection:AddDropdown('ArmChamsMaterial', { Values = { "ForceField", "Plastic", "SmoothPlastic", "Neon", "Glass", "Metal", "Wood", "Concrete" }, Default = "ForceField", Text = "Arm Material", Callback = function(v) _G.Visuals.setArmChamsMaterial(v) end })
    
    local WeaponChamsSection = Tabs.Character:AddLeftGroupbox('Weapon Chams')
    WeaponChamsSection:AddToggle('WeaponChamsToggle', { Text = "Weapon Chams", Default = false, Callback = function(v) _G.Visuals.setWeaponChamsEnabled(v) end })
    WeaponChamsSection:AddLabel('Weapon Chams Color'):AddColorPicker('WeaponChamsColor', { Default = Color3.fromRGB(244,224,155), Callback = function(c) _G.Visuals.setWeaponChamsColor(c) end })
    
    local SelfChamsSection = Tabs.Character:AddRightGroupbox('Self Chams')
    SelfChamsSection:AddToggle('SelfChamsToggle', { Text = "Self Chams", Default = false, Callback = function(v) _G.Visuals.setSelfChamsEnabled(v) end })
    SelfChamsSection:AddLabel('Self Chams Color'):AddColorPicker('SelfChamsColor', { Default = Color3.fromRGB(128,0,128), Callback = function(c) _G.Visuals.setSelfChamsColor(c) end })
    
    -- ===== EXPLOIT TAB =====
    
    local ExploitGroup = Tabs.Exploit:AddLeftGroupbox('Movement Exploits')
    ExploitGroup:AddToggle('FlyEnabled', { Text = 'Enable Fly', Default = false, Callback = function(v) _G.Exploits.setFlyEnabled(v) end })
    ExploitGroup:AddSlider('FlySpeed', { Text = 'Fly Speed', Default = 50, Min = 10, Max = 300, Rounding = 1, Callback = function(v) _G.Exploits.setFlySpeed(v) end })
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('SpeedhackToggle', { Text = 'Speedhack', Default = false, Callback = function(v) _G.Exploits.setSpeedhackEnabled(v) end })
    ExploitGroup:AddSlider('SpeedhackSlider', { Text = 'Speedhack Speed', Default = 20, Min = 5, Max = 100, Rounding = 1, Callback = function(v) _G.Exploits.setSpeedhackSpeed(v) end })
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('AntiAimToggle', { Text = 'Anti-Aim', Default = false, Callback = function(v) _G.Exploits.setAntiAimEnabled(v) end })
    ExploitGroup:AddDropdown('AntiAimMode', { Text = 'Anti-Aim Mode', Default = 'Up', Values = { 'Up', 'Down', 'Random', 'Custom' }, Callback = function(v) _G.Exploits.setAntiAimMode(v) end })
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('SpinbotToggle', { Text = 'Spinbot', Default = false, Callback = function(v) _G.Exploits.setSpinbotEnabled(v) end })
    ExploitGroup:AddSlider('SpinbotSpeed', { Text = 'Spinbot Speed (rad/s)', Default = 5, Min = 1, Max = 100, Rounding = 1, Callback = function(v) _G.Exploits.setSpinbotSpeed(v) end })
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('AutoJump', { Text = 'Auto Jump (Bunny Hop)', Default = false, Callback = function(v) _G.Exploits.setAutoJumpEnabled(v) end })
    ExploitGroup:AddToggle('ClimbSpeedToggle', { Text = 'Climb Speed', Default = false, Callback = function(v) _G.Exploits.setClimbSpeedEnabled(v) end })
    ExploitGroup:AddSlider('ClimbSpeedValue', { Text = 'Climb Speed', Default = 15, Min = 0, Max = 50, Rounding = 1, Callback = function(v) _G.Exploits.setClimbSpeedValue(v) end })
    
    -- Hitbox Expander
    local HitboxExpanderSection = Tabs.Exploit:AddRightGroupbox('Hitbox Expander')
    HitboxExpanderSection:AddToggle('HitboxExpanderToggle', { Text = 'Enable Hitbox Expander', Default = false, Callback = function(v) 
        if _G.HitboxExpander then _G.HitboxExpander.setEnabled(v) end
    end })
    HitboxExpanderSection:AddSlider('HitboxExpanderRadius', { Text = 'Hitbox Radius', Default = 5, Min = 1, Max = 10, Rounding = 1, Callback = function(v) 
        if _G.HitboxExpander then _G.HitboxExpander.setRadius(v) end
    end })
    
    -- Zombie Expander
    local ZombieSection = Tabs.Exploit:AddRightGroupbox('Zombie Expander')
    ZombieSection:AddToggle('ZombieExpanderToggle', { Text = 'Zombie Expander', Default = false, Callback = function(v) _G.World.setZombieExpander(v) end })
    ZombieSection:AddSlider('ZombieHitboxSize', { Text = 'Hitbox Size', Default = 16, Min = 1, Max = 50, Rounding = 1, Callback = function(v) _G.World.setZombieHitboxSize(v) end })
    
    -- Long Neck
    local LongNeckSection = Tabs.Exploit:AddRightGroupbox('Long Neck')
    LongNeckSection:AddToggle('LongNeckToggle', { Text = 'Long Neck', Default = false, Callback = function(v) _G.Visuals.setLongNeckEnabled(v) end })
    LongNeckSection:AddSlider('LongNeckHeight', { Text = 'Neck Height', Default = 5, Min = 1, Max = 7, Rounding = 1, Callback = function(v) _G.Visuals.setLongNeckHeight(v) end })
    
    -- Car Speed
    local CarSpeedSection = Tabs.Exploit:AddRightGroupbox('Car Speed')
    CarSpeedSection:AddToggle('CarSpeedToggle', { Text = 'Car Speed', Default = false, Callback = function(v) _G.World.setCarSpeedEnabled(v) end })
    CarSpeedSection:AddSlider('CarForwardMaxSpeed', { Text = 'Forward Max Speed', Default = 100, Min = 50, Max = 300, Rounding = 1, Callback = function(v) _G.World.setCarForwardMaxSpeed(v) end })
    CarSpeedSection:AddSlider('CarReverseMaxSpeed', { Text = 'Reverse Max Speed', Default = 40, Min = 20, Max = 150, Rounding = 1, Callback = function(v) _G.World.setCarReverseMaxSpeed(v) end })
    CarSpeedSection:AddButton('Toggle No Car Damage (Loop 1s)', function() _G.World.toggleNoCarDamage() end)
    
    -- ===== UI SETTINGS =====
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu Settings')
    MenuGroup:AddButton('Unload', function() 
        if Library then Library:Unload() end
    end)
    MenuGroup:AddLabel('Menu Bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
    
    -- Finalizar
    if Library then
        Library.ToggleKeybind = 'End'
    end
    
    if ThemeManager then
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder('CatHook')
        ThemeManager:ApplyToTab(Tabs['UI Settings'])
    end
    
    if SaveManager then
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
        SaveManager:SetFolder('CatHook/Aftermath')
        SaveManager:BuildConfigSection(Tabs['UI Settings'])
        SaveManager:LoadAutoloadConfig()
    end
    
    print("UI Inicializada com sucesso!")
end

return UI
