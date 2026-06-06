-- ============================================
-- BYPASS DO SERVICE MANAGER (PRIMEIRO)
-- ============================================
print("[1/3] Executando bypass do Service Manager...")

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

            print("[✓] BYPASS ativado com sucesso!")
        end
    else
        print("[✗] BYPASS falhou - ServiceManager não encontrado")
    end
end

task.wait(0.5)

-- ============================================
-- LOADER PRINCIPAL
-- ============================================
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
        warn("✗ " .. name .. ": download falhou - " .. tostring(result))
    end
    return nil
end

-- Carrega bibliotecas
print("[2/3] Carregando bibliotecas...")
local libSrc = game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua')
local themeSrc = game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua')
local saveSrc = game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua')

_G.Library = loadstring(libSrc)()
_G.ThemeManager = loadstring(themeSrc)()
_G.SaveManager = loadstring(saveSrc)()

-- Carrega módulos
print("[3/3] Carregando módulos...")

-- IMPORTANTE: Use os nomes CORRETOS dos seus arquivos
_G.Modules = {}
_G.Modules.Core = loadModule("1_core.lua", "Core")
task.wait(0.1)

_G.Modules.ESP = loadModule("2_esp.lua", "ESP")
task.wait(0.1)

_G.Modules.Exploits = loadModule("3_exploits.lua", "Exploits")
task.wait(0.1)

_G.Modules.Aimbot = loadModule("4_aimbot.lua", "Aimbot")
task.wait(0.1)

_G.Modules.Visuals = loadModule("5_visuals.lua", "Visuals")
task.wait(0.1)

_G.Modules.UI = loadModule("6_ui.lua", "UI")
task.wait(0.1)

-- Inicializa UI
if _G.Modules.UI then
    _G.Modules.UI.Initialize(_G.Library, _G.ThemeManager, _G.SaveManager)
end

print("═" .. string.rep("═", 40))
print("  ✅ THE RIFT - CARREGADO COM SUCESSO!")
print("═" .. string.rep("═", 40))
