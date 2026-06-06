-- loader.lua
local repo = 'https://raw.githubusercontent.com/Dekistermurgan/67/main/modules/'

print("═" .. string.rep("═", 40))
print("  Carregando THE RIFT...")
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
            print("✓ " .. name .. " carregado")
            return loaded
        else
            warn("✗ " .. name .. ": " .. err)
        end
    else
        warn("✗ " .. name .. ": download falhou")
    end
    return nil
end

-- Carrega bibliotecas
local libSrc = game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua')
local themeSrc = game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua')
local saveSrc = game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua')

_G.Library = loadstring(libSrc)()
_G.ThemeManager = loadstring(themeSrc)()
_G.SaveManager = loadstring(saveSrc)()

-- Carrega módulos em ordem
task.spawn(function()
    _G.Core = loadModule("1_core.lua", "Core")
    task.wait(0.1)
    
    _G.ESP = loadModule("2_esp.lua", "ESP")
    task.wait(0.1)
    
    _G.Exploits = loadModule("3_exploits.lua", "Exploits")
    task.wait(0.1)
    
    _G.Aimbot = loadModule("4_aimbot.lua", "Aimbot")
    task.wait(0.1)
    
    _G.Visuals = loadModule("5_visuals.lua", "Visuals")
    task.wait(0.1)
    
    _G.UI = loadModule("6_ui.lua", "UI")
    task.wait(0.1)
    
    _G.Main = loadModule("7_main.lua", "Main")
    
    -- Inicializa UI
    if _G.UI then
        _G.UI.Initialize(_G.Library, _G.ThemeManager, _G.SaveManager)
    end
    
    print("═" .. string.rep("═", 40))
    print("  ✅ THE RIFT - CARREGADO COM SUCESSO!")
    print("═" .. string.rep("═", 40))
end)
