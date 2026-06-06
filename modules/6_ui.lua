-- MÓDULO 6: UI (Interface completa)
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

    -- SCANNER
    local ScannerGroup = Tabs.Visuals:AddLeftGroupbox("Scanner")
    ScannerGroup:AddButton("Run Scanner", function() 
        if _G.runScanner then _G.runScanner() end
    end)

    -- AIMBOT
    local AimBotSection = Tabs.Combat:AddLeftGroupbox('AimBot')
    local aimbotToggle = AimBotSection:AddToggle('AimbotToggle', { Text = 'Aimbot', Default = false, Callback = function(v) if _G.Aimbot then _G.Aimbot.setEnabled(v) end end })
    AimBotSection:AddLabel('Toggle Aimbot Key'):AddKeyPicker('AimbotToggleKey', { Default = 'X', SyncToggleState = true, Mode = 'Toggle', Text = 'Toggle Aimbot Key', Callback = function(value) aimbotToggle:SetValue(value) end })
    AimBotSection:AddLabel('Aim Key (Hold)'):AddKeyPicker('AimbotHoldKey', { Default = 'MB2', SyncToggleState = false, Mode = 'Hold', Text = 'Aim Key', ChangedCallback = function(New)
        if New == "MB2" then if _G.Aimbot then _G.Aimbot.setKeybind(Enum.UserInputType.MouseButton2) end
        elseif New == "MB1" then if _G.Aimbot then _G.Aimbot.setKeybind(Enum.UserInputType.MouseButton1) end
        else if _G.Aimbot then _G.Aimbot.setKeybind(Enum.KeyCode[New]) end end
    end })
    AimBotSection:AddDivider()
    AimBotSection:AddDropdown('HitPart', { Values = { 'Head', 'UpperTorso', 'HumanoidRootPart' }, Default = 1, Text = 'Hit Part', Callback = function(v) if _G.Aimbot then _G.Aimbot.setHitPart(v) end end })
    AimBotSection:AddSlider('Smoothing', { Text = 'Smoothing', Default = 50, Min = 0, Max = 100, Rounding = 1, Callback = function(v) if _G.Aimbot then _G.Aimbot.setSmoothing(v) end end })

    -- PREDICTIONS
    local PredictionsSection = Tabs.Combat:AddLeftGroupbox('Predictions & Bullet Drop')
    PredictionsSection:AddSlider('PredictionX', { Text = 'Lateral Prediction (s)', Default = 20, Min = 0, Max = 50, Rounding = 1, Callback = function(v) if _G.Aimbot then _G.Aimbot.setPredictionX(v) end end })
    PredictionsSection:AddSlider('BulletDropFactor', { Text = 'Bullet Drop Factor (%)', Default = 100, Min = 0, Max = 200, Rounding = 1, Callback = function(v) if _G.Aimbot then _G.Aimbot.setBulletDropFactor(v) end end })
    PredictionsSection:AddSlider('VerticalOffset', { Text = 'Vertical Offset (studs)', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) if _G.Aimbot then _G.Aimbot.setVerticalOffset(v) end end })

    -- FOV SETTINGS
    local AimbotFOVSection = Tabs.Combat:AddRightGroupbox('FOV Settings')
    AimbotFOVSection:AddToggle('ShowFOV', { Text = 'Show FOV Circle', Default = false, Callback = function(v) if _G.Aimbot then _G.Aimbot.setFOVVisible(v) end end })
    AimbotFOVSection:AddSlider('FOVRadius', { Text = 'FOV Radius', Default = 200, Min = 0, Max = 500, Rounding = 1, Callback = function(v) if _G.Aimbot then _G.Aimbot.setFOVRadius(v) end end })
    AimbotFOVSection:AddSlider('FOVThickness', { Text = 'FOV Outline Thickness', Default = 2, Min = 0, Max = 10, Rounding = 1, Callback = function(v) if _G.Aimbot then _G.Aimbot.setFOVThickness(v) end end })
    AimbotFOVSection:AddDropdown('FOVShape', { Text = 'FOV Shape', Default = 'Circle', Values = { 'Circle', 'Triangle', 'Star of David', 'Pentagon', 'Hexagon' }, Callback = function(v) if _G.Aimbot then _G.Aimbot.setFOVShape(v) end end })
    AimbotFOVSection:AddToggle('FOVSpin', { Text = 'Spin FOV', Default = false, Callback = function(v) if _G.Aimbot then _G.Aimbot.setFOVSpin(v) end end })
    AimbotFOVSection:AddSlider('FOVSpinSpeed', { Text = 'Spin Speed', Default = 45, Min = 0, Max = 360, Rounding = 1, Callback = function(v) if _G.Aimbot then _G.Aimbot.setFOVSpinSpeed(v) end end })
    AimbotFOVSection:AddLabel('FOV Color'):AddColorPicker('FOVColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(c) if _G.Aimbot then _G.Aimbot.setFOVColor(c) end end })
    AimbotFOVSection:AddToggle('FOVRainbow', { Text = 'Rainbow FOV', Default = false, Callback = function(v) if _G.Aimbot then _G.Aimbot.setFOVRainbow(v) end end })

    -- GUN MODIFICATIONS
    local GunmodsSection = Tabs.Combat:AddRightGroupbox('Gun Modifications')
    GunmodsSection:AddToggle('NoRecoil', { Text = 'No Recoil', Default = true, Callback = function(v) getgenv().norecoilenabled = v end })
    GunmodsSection:AddToggle('InstantAim', { Text = 'Instant Aim', Default = false, Callback = function(state)
        if state then
            for _, v in next, getgc(true) do
                if type(v) == 'table' then
                    for i, val in next, v do
                        if type(i) == 'string' and i:find('GunAim') then
                            if type(val) == 'number' then v[i] = 100000000
                            elseif type(val) == 'function' then hookfunction(val, function() return 100000000 end) end
                        end
                    end
                end
            end
        end
    end end })

    -- ESP
    local VisualMainSection = Tabs.Visuals:AddLeftGroupbox('Player ESP')
    VisualMainSection:AddToggle('ESPEnabled', { Text = 'Enable ESP', Default = false, Callback = function(v) _G.gameObjects.ESPEnabled = v end })
    VisualMainSection:AddToggle('ShowBoxes', { Text = 'Show Boxes', Default = false, Callback = function(v) _G.gameObjects.boxEnabled = v end })
    VisualMainSection:AddToggle('FilledBoxes', { Text = 'Filled Boxes', Default = false, Callback = function(v) _G.gameObjects.boxFilledEnabled = v end })
    VisualMainSection:AddToggle('OutlinesBoxes', { Text = 'Outline Boxes', Default = false, Callback = function(v) _G.gameObjects.boxOutlineEnabled = v end })
    VisualMainSection:AddToggle('Skeleton', { Text = 'Skeleton', Default = false, Callback = function(v) _G.gameObjects.skeletonEnabled = v end })
    VisualMainSection:AddToggle('ShowNames', { Text = 'Show Names', Default = false, Callback = function(v) _G.gameObjects.nameEnabled = v end })
    VisualMainSection:AddToggle('ShowDistances', { Text = 'Show Distances', Default = false, Callback = function(v) _G.gameObjects.distanceEnabled = v end })
    VisualMainSection:AddLabel('Box Color'):AddColorPicker('BoxColor', { Default = _G.gameObjects.boxColor, Callback = function(c) _G.gameObjects.boxColor = c end })
    VisualMainSection:AddLabel('Box Outline Color'):AddColorPicker('BoxOutlineColor', { Default = _G.gameObjects.boxOutlineColor, Callback = function(c) _G.gameObjects.boxOutlineColor = c end })
    VisualMainSection:AddLabel('Skeleton Color'):AddColorPicker('SkeletonColor', { Default = _G.gameObjects.skeletonColor, Callback = function(c) _G.gameObjects.skeletonColor = c end })
    VisualMainSection:AddLabel('Name Color'):AddColorPicker('NameColor', { Default = _G.gameObjects.nameColor, Callback = function(c) _G.gameObjects.nameColor = c end })
    VisualMainSection:AddLabel('Distance Color'):AddColorPicker('DistanceColor', { Default = _G.gameObjects.distanceColor, Callback = function(c) _G.gameObjects.distanceColor = c end })
    VisualMainSection:AddSlider('MaxESPDistance', { Text = 'Max ESP Distance', Default = 1000, Min = 0, Max = 5000, Rounding = 1, Callback = function(v) _G.gameObjects.maxESPDistance = v end })

    -- CAR ESP
    local CarSection = Tabs.Visuals:AddRightGroupbox('Vehicle ESP')
    CarSection:AddToggle('CarESP', { Text = 'Vehicle ESP', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setCarEspEnabled(v) end end })

    -- WORLD
    local Remover = Tabs.World:AddLeftGroupbox('World Modifications')
    Remover:AddToggle('RemoveGrass', { Text = 'Remove Grass', Default = false, Callback = function(v) 
        pcall(function() sethiddenproperty(workspace.Terrain, "Decoration", not v) end)
    end })
    Remover:AddToggle('NoTreeToggle', { Text = 'No Tree', Default = false, Callback = function(state)
        if state then
            local lastCheck = 0
            local cache = {}
            _G.noTreeConnection = RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - lastCheck > 5 or #cache == 0 then
                    lastCheck = now
                    cache = {}
                    for _, part in ipairs(workspace:GetDescendants()) do
                        if part:IsA("BasePart") and (part.Name == "Leaves" or part.Name == "Tree") then
                            table.insert(cache, part)
                        end
                    end
                    for _, part in ipairs(cache) do
                        part.Transparency = 1
                        part.CanCollide = false
                        part.Anchored = true
                    end
                end
            end)
        else
            if _G.noTreeConnection then _G.noTreeConnection:Disconnect(); _G.noTreeConnection = nil end
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and (part.Name == "Leaves" or part.Name == "Tree") then
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
        end
    end })

    local lightingSection = Tabs.World:AddLeftGroupbox('Lighting')
    lightingSection:AddToggle('Fullbright', { Text = 'Fullbright', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setFullbright(v) end end })
    lightingSection:AddToggle('NoFog', { Text = 'No Fog', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setNoFog(v) end end })
    lightingSection:AddToggle('RemoveClouds', { Text = 'Remove Clouds', Default = false, Callback = function(v)
        if workspace.Terrain:FindFirstChild("Clouds") then
            workspace.Terrain.Clouds.Enabled = not v
        end
    end })
    lightingSection:AddToggle('TimeChanger', { Text = 'Time Changer', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setTimeEnabled(v) end end })
    lightingSection:AddSlider('TimeOfDay', { Text = 'Time Of Day', Default = 12, Min = 0, Max = 24, Rounding = 1, Callback = function(v) if _G.Visuals then _G.Visuals.setTimeValue(v) end end })

    local SkyboxSection = Tabs.World:AddRightGroupbox('Skybox Changer')
    SkyboxSection:AddDropdown('Skybox', { Text = 'Skybox', Default = 'Default', Values = { 'Default', 'Standard', 'Blue Sky', 'Vaporwave', 'Redshift', 'Blaze', 'Among Us', 'Dark Night', 'Bright Pink', 'Purple Sky', 'Galaxy' }, Callback = function(v) if _G.Visuals then _G.Visuals.applySkybox(v) end end })

    -- CHARACTER
    local ArmChamsSection = Tabs.Character:AddLeftGroupbox('Arm Chams (First Person)')
    ArmChamsSection:AddToggle('ArmChamsToggle', { Text = "Enable Arm Chams", Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setArmChamsEnabled(v) end end })
    ArmChamsSection:AddLabel('Arm Color'):AddColorPicker('ArmChamsColor', { Default = _G.gameObjects.armChamsColor, Callback = function(c) if _G.Visuals then _G.Visuals.setArmChamsColor(c) end end })
    ArmChamsSection:AddDropdown('ArmChamsMaterial', { Values = { "ForceField", "Plastic", "SmoothPlastic", "Neon", "Glass", "Metal", "Wood", "Concrete" }, Default = "ForceField", Text = "Arm Material", Callback = function(v) if _G.Visuals then _G.Visuals.setArmChamsMaterial(v) end end })

    local WeaponChamsSection = Tabs.Character:AddLeftGroupbox('Weapon Chams')
    WeaponChamsSection:AddToggle('WeaponChamsToggle', { Text = "Weapon Chams", Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setWeaponChamsEnabled(v) end end })
    WeaponChamsSection:AddLabel('Weapon Chams Color'):AddColorPicker('WeaponChamsColor', { Default = _G.gameObjects.weaponChamsColor, Callback = function(c) if _G.Visuals then _G.Visuals.setWeaponChamsColor(c) end end })
    WeaponChamsSection:AddDropdown('WeaponMaterial', { Values = { "ForceField", "Plastic", "SmoothPlastic", "Neon", "Glass", "Metal", "Wood", "Concrete" }, Default = "ForceField", Text = "Weapon Material", Callback = function(v) if _G.Visuals then _G.Visuals.setWeaponMaterial(v) end end })

    local SelfChamsSection = Tabs.Character:AddRightGroupbox('Self Chams')
    SelfChamsSection:AddToggle('SelfChamsToggle', { Text = "Self Chams", Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsEnabled(v) end end })
    SelfChamsSection:AddLabel('Self Chams Color'):AddColorPicker('SelfChamsColor', { Default = _G.gameObjects.selfChamsColor, Callback = function(c) if _G.Visuals then _G.Visuals.setSelfChamsColor(c) end end })
    SelfChamsSection:AddDropdown('SelfChamsMaterial', { Values = { "ForceField", "Neon", "Plastic", "SmoothPlastic", "Metal", "Glass", "Wood", "Concrete" }, Default = "ForceField", Text = "Material", Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsMaterial(v) end end })
    SelfChamsSection:AddSlider('SelfChamsTransparency', { Text = 'Body Transparency', Default = 0.2, Min = 0, Max = 1, Rounding = 2, Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsTransparency(v) end end })
    SelfChamsSection:AddSlider('SelfChamsHeadTransparency', { Text = 'Head Transparency', Default = 1, Min = 0, Max = 1, Rounding = 2, Callback = function(v) if _G.Visuals then _G.Visuals.setSelfChamsHeadTransparency(v) end end })

    -- EXPLOIT
    local ExploitGroup = Tabs.Exploit:AddLeftGroupbox('Movement Exploits')
    ExploitGroup:AddToggle('FlyEnabled', { Text = 'Enable Fly', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setFlyEnabled(v) end end })
    ExploitGroup:AddSlider('FlySpeed', { Text = 'Fly Speed', Default = 50, Min = 10, Max = 300, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setFlySpeed(v) end end })
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('SpeedhackToggle', { Text = 'Speedhack', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setSpeedhackEnabled(v) end end })
    ExploitGroup:AddSlider('SpeedhackSlider', { Text = 'Speedhack Speed', Default = 20, Min = 5, Max = 100, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setSpeedhackSpeed(v) end end })
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('AntiAimToggle', { Text = 'Anti-Aim', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setAntiAimEnabled(v) end end })
    ExploitGroup:AddDropdown('AntiAimMode', { Text = 'Anti-Aim Mode', Default = 'Up', Values = { 'Up', 'Down', 'Random', 'Custom' }, Callback = function(v) if _G.Exploits then _G.Exploits.setAntiAimMode(v) end end })
    
    local RandomSpeedBox = ExploitGroup:AddDependencyBox()
    RandomSpeedBox:AddSlider('AntiAimRandomSpeed', { Text = 'Random Switch Speed (seconds)', Default = 0.5, Min = 0.1, Max = 3, Rounding = 2, Callback = function(v) if _G.Exploits then _G.Exploits.setAntiAimRandomSpeed(v) end end })
    RandomSpeedBox:SetupDependencies({ { Toggles.AntiAimToggle, true }, { Options.AntiAimMode, 'Random' } })
    
    local CustomBox = ExploitGroup:AddDependencyBox()
    CustomBox:AddSlider('AntiAimPitch', { Text = 'Custom Pitch', Default = 0, Min = -3.14, Max = 3.14, Rounding = 2, Callback = function(v) if _G.Exploits then _G.Exploits.setAntiAimPitch(v) end end })
    CustomBox:AddSlider('AntiAimYaw', { Text = 'Custom Yaw', Default = 0, Min = -3.14, Max = 3.14, Rounding = 2, Callback = function(v) if _G.Exploits then _G.Exploits.setAntiAimYaw(v) end end })
    CustomBox:SetupDependencies({ { Toggles.AntiAimToggle, true }, { Options.AntiAimMode, 'Custom' } })
    
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('SpinbotToggle', { Text = 'Spinbot', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setSpinbotEnabled(v) end end })
    ExploitGroup:AddSlider('SpinbotSpeed', { Text = 'Spinbot Speed (rad/s)', Default = 5, Min = 1, Max = 100, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setSpinbotSpeed(v) end end })
    ExploitGroup:AddDivider()
    ExploitGroup:AddToggle('AutoJump', { Text = 'Auto Jump (Bunny Hop)', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setAutoJumpEnabled(v) end end })
    ExploitGroup:AddToggle('ClimbSpeedToggle', { Text = 'Climb Speed', Default = false, Callback = function(v) if _G.Exploits then _G.Exploits.setClimbSpeedEnabled(v) end end })
    ExploitGroup:AddSlider('ClimbSpeedValue', { Text = 'Climb Speed', Default = 15, Min = 0, Max = 50, Rounding = 1, Callback = function(v) if _G.Exploits then _G.Exploits.setClimbSpeedValue(v) end end })

    local LongNeckSection = Tabs.Exploit:AddRightGroupbox('Long Neck')
    LongNeckSection:AddToggle('LongNeckToggle', { Text = 'Long Neck', Default = false, Callback = function(v) if _G.Visuals then _G.Visuals.setLongNeckEnabled(v) end end })
    LongNeckSection:AddSlider('LongNeckHeight', { Text = 'Neck Height', Default = 5, Min = 1, Max = 7, Rounding = 1, Callback = function(v) if _G.Visuals then _G.Visuals.setLongNeckHeight(v) end end })

    -- UI SETTINGS
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu Settings')
    MenuGroup:AddButton('Unload', function() Library:Unload() end)
    MenuGroup:AddLabel('Menu Bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

    Library.ToggleKeybind = Options.MenuKeybind
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
    ThemeManager:SetFolder('CatHook')
    SaveManager:SetFolder('CatHook/Aftermath')
    SaveManager:BuildConfigSection(Tabs['UI Settings'])
    ThemeManager:ApplyToTab(Tabs['UI Settings'])
    SaveManager:LoadAutoloadConfig()
    
    print("UI Carregada!")
end

return UI
