-- ============================================
-- BYPASS DO SERVICE MANAGER (NECESSÁRIO)
-- ============================================
do
    local ServiceManagerEnv

    for i, v in getgc(true) do
        if type(v) == "table" then
            local mt = getrawmetatable(v)
            if rawget(v, "newcclosure") and rawget(v, "vx") and mt and type(mt.__index) == "table" then
                ServiceManagerEnv = v
                break
            end
        end
    end

    if ServiceManagerEnv then
        do
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

            print("✅ THE RIFT - Bypass ativado")
        end
    else
        print("❌ THE RIFT - Falha no bypass")
    end
end

-- ============================================
-- LOADER PRINCIPAL
-- ============================================
local repo = 'https://raw.githubusercontent.com/Dekistermurgan/67/main/modules/'

print("═" .. string.rep("═", 40))
print("  Carregando THE RIFT Script...")
print("═" .. string.rep("═", 40))

local function loadModule(url, name)
    print("▶ " .. name)
    local success, result = pcall(function()
        return game:HttpGet(repo .. url)
    end)
    if success and result then
        local fn, err = loadstring(result)
        if fn then
            local loaded = fn()
            print("✓ " .. name .. " carregado!")
            return loaded
        else
            warn("✗ " .. name .. ": " .. err)
        end
    else
        warn("✗ " .. name .. ": falha no download")
    end
    return nil
end

-- Carrega bibliotecas primeiro
local librarySource = nil
local themeSource = nil
local saveSource = nil
local repoLib = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

pcall(function()
    librarySource = game:HttpGet(repoLib .. 'Library.lua')
    themeSource = game:HttpGet(repoLib .. 'addons/ThemeManager.lua')
    saveSource = game:HttpGet(repoLib .. 'addons/SaveManager.lua')
end)

if not librarySource or not themeSource or not saveSource then
    warn("Falha ao carregar bibliotecas")
    return
end

_G.Library = loadstring(librarySource)()
_G.ThemeManager = loadstring(themeSource)()
_G.SaveManager = loadstring(saveSource)()

-- Carrega os módulos
task.spawn(function()
    _G.SilentAim = loadModule("1_silentaim.lua", "Silent Aim")
    task.wait(0.2)
    
    _G.MouseAimbot = loadModule("2_mouseaim.lua", "Mouse Aimbot")
    task.wait(0.2)
    
    _G.ESP = loadModule("3_esp.lua", "ESP")
    task.wait(0.2)
    
    _G.Exploits = loadModule("4_exploits.lua", "Exploits")
    task.wait(0.2)
    
    _G.Visuals = loadModule("5_visuals.lua", "Visuals")
    task.wait(0.2)
    
    _G.World = loadModule("6_world.lua", "World")
    task.wait(0.2)
    
    _G.UI = loadModule("7_ui.lua", "UI")
    
    -- Inicializa a UI
    if _G.UI and _G.Library and _G.ThemeManager and _G.SaveManager then
        _G.UI.Initialize(_G.Library, _G.ThemeManager, _G.SaveManager)
    end
    
    -- Configura dependências do ESP
    if _G.ESP then
        pcall(function()
            local custommeshcharacter = require(game.ReplicatedFirst:WaitForChild("GunSystemPlugins"):WaitForChild("CustomMeshCharacter"))
            local playerlist = require(game.ReplicatedStorage:WaitForChild("CustomCharacter"):WaitForChild("PlayerList"))
            local gameassets = workspace:FindFirstChild("game_assets")
            local entitiesfolder = gameassets and gameassets:FindFirstChild("Entities") or workspace
            
            _G.ESP.SetCustomMeshCharacter(custommeshcharacter)
            _G.ESP.SetPlayerList(playerlist)
            _G.ESP.SetEntitiesFolder(entitiesfolder)
            _G.ESP.Refresh()
            
            if _G.MouseAimbot then
                _G.MouseAimbot.setEntitiesFolder(entitiesfolder)
            end
        end)
    end
    
    print("═" .. string.rep("═", 40))
    print("  ✅ THE RIFT - CARREGADO COM SUCESSO!")
    print("═" .. string.rep("═", 40))
end)
