-- LOADER PRINCIPAL
local repo = 'https://raw.githubusercontent.com/SEU_USER/SEU_REPO/main/modules/'

local function loadModule(url, name)
    print("Carregando " .. name .. "...")
    local success, result = pcall(function()
        return game:HttpGet(repo .. url)
    end)
    if success and result then
        local fn, err = loadstring(result)
        if fn then
            local loaded = fn()
            print(name .. " carregado com sucesso!")
            return loaded
        else
            warn("Erro no " .. name .. ": " .. err)
        end
    else
        warn("Falha ao baixar " .. name)
    end
    return nil
end

-- Carrega em ordem (importante pra dependências)
task.spawn(function()
    loadModule("1_silentaim.lua", "Silent Aim")
    task.wait(0.5)
    
    loadModule("2_mouseaim.lua", "Mouse Aimbot")
    task.wait(0.5)
    
    loadModule("3_esp.lua", "ESP")
    task.wait(0.5)
    
    loadModule("4_exploits.lua", "Exploits")
    task.wait(0.5)
    
    loadModule("5_visuals.lua", "Visuals")
    task.wait(0.5)
    
    loadModule("6_world.lua", "World")
    task.wait(0.5)
    
    loadModule("7_ui.lua", "UI")
    
    print("Todos os módulos carregados!")
end)
