--[[
    VANTA Spy (Rayfield Gen 1)
    Solo lectura: explora orígenes de remotes sin esperar ejecución y registra llamadas salientes.
]]

local function getService(name)
    local ok, svc = pcall(function()
        return game:GetService(name)
    end)
    if ok then
        return svc
    end
    return nil
end

local Players = getService("Players")
local ReplicatedStorage = getService("ReplicatedStorage")
local Workspace = getService("Workspace")
local StarterGui = getService("StarterGui")
local StarterPack = getService("StarterPack")
local ReplicatedFirst = getService("ReplicatedFirst")
local Lighting = getService("Lighting")

local RAYFIELD_URL = "https://raw.githubusercontent.com/sirius-menu/rayfield/fe922012da6e6d33b41d656095ce62fd5be05047/source.lua"

local function loadRayfield()
    if type(_G) == "table" and _G.__VANTA_RAYFIELD_MOCK then
        return _G.__VANTA_RAYFIELD_MOCK
    end
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet(RAYFIELD_URL))()
    end)
    if ok and lib then
        return lib
    end
    return nil
end

local Rayfield = loadRayfield()
if not Rayfield then
    warn("[VANTA Spy] No se pudo cargar Rayfield Gen 1.")
    return
end

-- Capacidades del executor (solo detección, sin instalar hooks todavía)
local hasHookMetamethod = type(hookmetamethod) == "function"
local hasGetNamecallMethod = type(getnamecallmethod) == "function"
local hasCheckCaller = type(checkcaller) == "function"
local hasSetClipboard = type(setclipboard) == "function"
local hasGetGc = type(getgc) == "function"

local REMOTE_CLASSES = {
    RemoteEvent = true,
    RemoteFunction = true,
    UnreliableRemoteEvent = true,
}

local MAX_LOG_GROUPS = 150
local MAX_SERIALIZE_DEPTH = 3
local MAX_TABLE_KEYS = 12

local state = {
    capturing = false,
    destroyed = false,
    hookInstalled = false,
    oldNamecall = nil,
    originFilter = "",
    logFilter = "",
    origins = {},          -- { { instance, name, className, origin, path } }
    originMap = {},        -- [Instance] = true
    selectedOriginPath = nil,
    logs = {},             -- { [key] = { key, method, className, path, count, lastTime, lastArgs } }
    logOrder = {},         -- { key1, key2, ... }
    selectedLogKey = nil,
    snapshotCounts = nil,  -- { [key] = count } para comparar Antes / Después
    ignoredPaths = {},     -- { [path] = true }
    blockedPaths = {},     -- { [path] = true }
    lastGeneratedCode = "",
    connections = {},
}

local function safeFullName(inst)
    if not inst then
        return "nil"
    end
    local ok, res = pcall(function()
        return inst:GetFullName()
    end)
    if ok and type(res) == "string" then
        return res
    end
    return tostring(inst)
end

local function safeName(inst)
    if not inst then
        return "nil"
    end
    local ok, res = pcall(function()
        return inst.Name
    end)
    if ok and type(res) == "string" then
        return res
    end
    return "?"
end

local function safeClassName(inst)
    if not inst then
        return "Unknown"
    end
    local ok, res = pcall(function()
        return inst.ClassName
    end)
    if ok and type(res) == "string" then
        return res
    end
    return "Unknown"
end

local function isRemoteInstance(inst)
    if typeof and typeof(inst) ~= "Instance" then
        return false
    end
    local cls = safeClassName(inst)
    return REMOTE_CLASSES[cls] == true
end

local function detectOriginRoot(inst)
    local path = safeFullName(inst)
    local dot = string.find(path, "%.")
    if dot then
        return string.sub(path, 1, dot - 1)
    end
    return "Game"
end

local function serializeValue(val, depth, seen)
    depth = depth or 0
    seen = seen or {}
    local t = type(val)
    if t == "nil" then
        return "nil"
    elseif t == "boolean" or t == "number" then
        return tostring(val)
    elseif t == "string" then
        local clean = string.gsub(val, "[\r\n]", " ")
        if #clean > 48 then
            clean = string.sub(clean, 1, 45) .. "..."
        end
        return '"' .. clean .. '"'
    elseif t == "table" then
        if seen[val] then
            return "{<ciclo>}"
        end
        if depth >= MAX_SERIALIZE_DEPTH then
            return "{...}"
        end
        seen[val] = true
        local parts = {}
        local count = 0
        for k, v in pairs(val) do
            count = count + 1
            if count > MAX_TABLE_KEYS then
                table.insert(parts, "...")
                break
            end
            table.insert(parts, tostring(k) .. "=" .. serializeValue(v, depth + 1, seen))
        end
        seen[val] = nil
        return "{" .. table.concat(parts, ", ") .. "}"
    else
        if typeof and typeof(val) == "Instance" then
            return "<" .. safeClassName(val) .. ":" .. safeFullName(val) .. ">"
        end
        return "<" .. t .. ":" .. tostring(val) .. ">"
    end
end

local function serializeArgs(packed)
    local n = packed.n or #packed
    if n == 0 then
        return "(sin argumentos)"
    end
    local parts = {}
    for i = 1, n do
        parts[i] = serializeValue(packed[i], 0, {})
    end
    return table.concat(parts, ", ")
end

local function scanOrigins()
    state.origins = {}
    state.originMap = {}

    local roots = {}
    for _, svc in ipairs({ ReplicatedStorage, Workspace, Players, StarterGui, StarterPack, ReplicatedFirst, Lighting }) do
        if svc then
            table.insert(roots, svc)
        end
    end
    if #roots == 0 and game then
        table.insert(roots, game)
    end

    local function addIfRemote(inst)
        if state.originMap[inst] then
            return
        end
        if isRemoteInstance(inst) then
            state.originMap[inst] = true
            local path = safeFullName(inst)
            table.insert(state.origins, {
                instance = inst,
                name = safeName(inst),
                className = safeClassName(inst),
                origin = detectOriginRoot(inst),
                path = path,
            })
        end
    end

    for _, root in ipairs(roots) do
        addIfRemote(root)
        local ok, desc = pcall(function()
            return root:GetDescendants()
        end)
        if ok and type(desc) == "table" then
            for _, child in ipairs(desc) do
                addIfRemote(child)
            end
        end
    end

    table.sort(state.origins, function(a, b)
        if a.origin ~= b.origin then
            return a.origin < b.origin
        end
        return a.path < b.path
    end)
end

local function getFilteredOrigins()
    local needle = string.lower(state.originFilter or "")
    local out = {}
    for _, item in ipairs(state.origins) do
        if needle == "" or string.find(string.lower(item.path), needle, 1, true) or string.find(string.lower(item.className), needle, 1, true) then
            table.insert(out, item)
        end
    end
    return out
end

local function recordRemoteCall(self, method, packedArgs)
    if state.destroyed or not state.capturing then
        return
    end
    if not isRemoteInstance(self) then
        return
    end
    local path = safeFullName(self)
    if state.ignoredPaths[path] then
        return
    end
    local cls = safeClassName(self)
    local key = method .. " | " .. path
    local entry = state.logs[key]
    if not entry then
        if #state.logOrder >= MAX_LOG_GROUPS then
            local oldest = table.remove(state.logOrder, 1)
            if oldest then
                state.logs[oldest] = nil
            end
        end
        entry = {
            key = key,
            instance = self,
            method = method,
            className = cls,
            path = path,
            count = 0,
            lastTime = os.clock(),
            lastArgs = "",
            lastPacked = nil,
        }
        state.logs[key] = entry
        table.insert(state.logOrder, key)
    end
    entry.count = entry.count + 1
    entry.lastTime = os.clock()
    entry.lastArgs = serializeArgs(packedArgs)
    entry.lastPacked = packedArgs
end

local function buildLuauSnippet(entry)
    if not entry then
        return ""
    end
    local packed = entry.lastPacked or { n = 0 }
    local n = packed.n or #packed
    if n == 0 then
        return entry.path .. ":" .. entry.method .. "()"
    end
    local argLines = {}
    for i = 1, n do
        table.insert(argLines, "    [" .. tostring(i) .. "] = " .. serializeValue(packed[i], 0, {}))
    end
    return "local args = {\n" .. table.concat(argLines, ",\n") .. "\n}\n" .. entry.path .. ":" .. entry.method .. "(table.unpack(args, 1, " .. tostring(n) .. "))"
end

local function installHook()
    if state.hookInstalled then
        return true
    end
    if not hasHookMetamethod or not hasGetNamecallMethod then
        return false
    end
    local ok, err = pcall(function()
        state.oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if state.capturing and not state.destroyed then
                if method == "FireServer" or method == "InvokeServer" then
                    local packed = table.pack(...)
                    pcall(recordRemoteCall, self, method, packed)
                    local path = safeFullName(self)
                    if state.blockedPaths[path] then
                        return nil
                    end
                end
            end
            return state.oldNamecall(self, ...)
        end)
    end)
    if ok then
        state.hookInstalled = true
        return true
    else
        warn("[VANTA Spy] Error al instalar hook: " .. tostring(err))
        return false
    end
end

-- Construcción de UI Rayfield Gen 1
local Window = Rayfield:CreateWindow({
    Name = "VANTA Spy (Gen 1)",
    LoadingTitle = "VANTA Spy",
    LoadingSubtitle = "Orígenes y captura en solo lectura",
    ShowText = "VANTA Spy",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local OriginsTab = Window:CreateTab("Orígenes", 4483362458)
local SpyTab = Window:CreateTab("Captura", 4483362458)
local DiagTab = Window:CreateTab("Diagnóstico", 4483362458)

-- === PESTAÑA ORÍGENES ===
local OriginsSummary = OriginsTab:CreateParagraph({
    Title = "Mapa de Orígenes",
    Content = "Escaneando remotes visibles sin esperar ejecución...",
})

local OriginDetailParagraph = OriginsTab:CreateParagraph({
    Title = "Detalle del Remote",
    Content = "Selecciona un remote de la lista para ver su ruta completa y clase.",
})

local OriginDropdown = OriginsTab:CreateDropdown({
    Name = "Remotes detectados",
    Options = { "(sin resultados)" },
    CurrentOption = { "(sin resultados)" },
    MultipleOptions = false,
    Callback = function(selected)
        local choice = type(selected) == "table" and selected[1] or selected
        state.selectedOriginPath = choice
        for _, item in ipairs(state.origins) do
            if item.path == choice then
                OriginDetailParagraph:Set({
                    Title = item.name .. " [" .. item.className .. "]",
                    Content = "Origen: " .. item.origin .. "\nRuta: " .. item.path,
                })
                return
            end
        end
    end,
})

local function refreshOriginsUI()
    scanOrigins()
    local filtered = getFilteredOrigins()
    local counts = {}
    local options = {}
    for _, item in ipairs(filtered) do
        counts[item.origin] = (counts[item.origin] or 0) + 1
        table.insert(options, item.path)
    end
    if #options == 0 then
        options = { "(sin resultados)" }
    end
    local summaryParts = {}
    for origin, count in pairs(counts) do
        table.insert(summaryParts, origin .. ": " .. tostring(count))
    end
    table.sort(summaryParts)
    OriginsSummary:Set({
        Title = "Orígenes (" .. tostring(#filtered) .. " visibles)",
        Content = #summaryParts > 0 and table.concat(summaryParts, " | ") or "No se encontraron remotes visibles.",
    })
    OriginDropdown:Refresh(options)
end

OriginsTab:CreateInput({
    Name = "Buscar en Orígenes",
    PlaceholderText = "Nombre, ruta o clase...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        state.originFilter = text or ""
        refreshOriginsUI()
    end,
})

OriginsTab:CreateButton({
    Name = "Refrescar Orígenes",
    Callback = function()
        refreshOriginsUI()
    end,
})

OriginsTab:CreateButton({
    Name = "Copiar ruta seleccionada",
    Callback = function()
        if not state.selectedOriginPath then
            return
        end
        if hasSetClipboard then
            setclipboard(state.selectedOriginPath)
            Rayfield:Notify({ Title = "VANTA Spy", Content = "Ruta copiada al portapapeles.", Duration = 3 })
        else
            Rayfield:Notify({ Title = "VANTA Spy", Content = "Portapapeles no disponible en este executor.", Duration = 3 })
        end
    end,
})

-- === PESTAÑA CAPTURA ===
local SpySummary = SpyTab:CreateParagraph({
    Title = "Registro de Llamadas (Solo lectura)",
    Content = "Captura inactiva. Activa el interruptor para observar llamadas salientes.",
})

local SpyDetail = SpyTab:CreateParagraph({
    Title = "Últimos argumentos",
    Content = "Selecciona una llamada capturada para inspeccionar sus argumentos.",
})

local function getFilteredLogs()
    local needle = string.lower(state.logFilter or "")
    local out = {}
    for _, key in ipairs(state.logOrder) do
        local entry = state.logs[key]
        if entry and (needle == "" or string.find(string.lower(entry.path), needle, 1, true) or string.find(string.lower(entry.method), needle, 1, true)) then
            table.insert(out, entry)
        end
    end
    return out
end

local LogDropdown = SpyTab:CreateDropdown({
    Name = "Llamadas agrupadas",
    Options = { "(sin capturas)" },
    CurrentOption = { "(sin capturas)" },
    MultipleOptions = false,
    Callback = function(selected)
        local choice = type(selected) == "table" and selected[1] or selected
        state.selectedLogKey = choice
        local entry = state.logs[choice]
        if entry then
            SpyDetail:Set({
                Title = entry.method .. " x" .. tostring(entry.count),
                Content = "Ruta: " .. entry.path .. "\nArgs: " .. entry.lastArgs,
            })
        end
    end,
})

local function refreshLogsUI()
    local filtered = getFilteredLogs()
    local options = {}
    local lines = {}
    for _, entry in ipairs(filtered) do
        table.insert(options, entry.key)
        local deltaText = ""
        if state.snapshotCounts then
            local prev = state.snapshotCounts[entry.key] or 0
            local diff = entry.count - prev
            if diff > 0 then
                deltaText = " (+" .. tostring(diff) .. " nuevo)"
            end
        end
        if #lines < 6 then
            table.insert(lines, string.format("[%s] %s x%d%s", entry.method, entry.path, entry.count, deltaText))
        end
    end
    if #options == 0 then
        options = { "(sin capturas)" }
    end
    SpySummary:Set({
        Title = (state.capturing and "Capturando" or "Pausado") .. " (" .. tostring(#filtered) .. " grupos)",
        Content = #lines > 0 and table.concat(lines, "\n") or "Sin llamadas registradas.",
    })
    LogDropdown:Refresh(options)
end

SpyTab:CreateToggle({
    Name = "Activar Captura",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            local ok = installHook()
            if not ok then
                state.capturing = false
                Rayfield:Notify({ Title = "VANTA Spy", Content = "hookmetamethod/getnamecallmethod no disponibles.", Duration = 4 })
                return
            end
            state.capturing = true
        else
            state.capturing = false
        end
        refreshLogsUI()
    end,
})

SpyTab:CreateInput({
    Name = "Filtrar llamadas",
    PlaceholderText = "Nombre o método...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        state.logFilter = text or ""
        refreshLogsUI()
    end,
})

SpyTab:CreateButton({
    Name = "Marcar Antes (Snapshot)",
    Callback = function()
        state.snapshotCounts = {}
        for k, entry in pairs(state.logs) do
            state.snapshotCounts[k] = entry.count
        end
        refreshLogsUI()
    end,
})

SpyTab:CreateButton({
    Name = "Limpiar registros",
    Callback = function()
        state.logs = {}
        state.logOrder = {}
        state.snapshotCounts = nil
        state.selectedLogKey = nil
        refreshLogsUI()
    end,
})

SpyTab:CreateButton({
    Name = "Copiar código Luau",
    Callback = function()
        local entry = state.selectedLogKey and state.logs[state.selectedLogKey]
        if not entry then
            return
        end
        local code = buildLuauSnippet(entry)
        state.lastGeneratedCode = code
        if hasSetClipboard then
            setclipboard(code)
            Rayfield:Notify({ Title = "VANTA Spy", Content = "Código Luau copiado.", Duration = 3 })
        end
    end,
})

SpyTab:CreateButton({
    Name = "Reproducir llamada",
    Callback = function()
        local entry = state.selectedLogKey and state.logs[state.selectedLogKey]
        if not entry or not entry.instance then
            return
        end
        local packed = entry.lastPacked or { n = 0 }
        local n = packed.n or #packed
        local ok, err = pcall(function()
            local fn = entry.instance[entry.method]
            if type(fn) == "function" then
                fn(entry.instance, table.unpack(packed, 1, n))
            end
        end)
        if not ok then
            Rayfield:Notify({ Title = "VANTA Spy", Content = "Error al reproducir: " .. tostring(err), Duration = 3 })
        end
    end,
})

SpyTab:CreateButton({
    Name = "Ignorar / Mostrar seleccionado",
    Callback = function()
        local entry = state.selectedLogKey and state.logs[state.selectedLogKey]
        if not entry then
            return
        end
        if state.ignoredPaths[entry.path] then
            state.ignoredPaths[entry.path] = nil
        else
            state.ignoredPaths[entry.path] = true
        end
    end,
})

SpyTab:CreateButton({
    Name = "Bloquear / Desbloquear seleccionado",
    Callback = function()
        local entry = state.selectedLogKey and state.logs[state.selectedLogKey]
        if not entry then
            return
        end
        if state.blockedPaths[entry.path] then
            state.blockedPaths[entry.path] = nil
        else
            state.blockedPaths[entry.path] = true
        end
    end,
})

-- === PESTAÑA DIAGNÓSTICO Y VENTANA ===
DiagTab:CreateParagraph({
    Title = "Capacidades del Executor",
    Content = table.concat({
        "hookmetamethod: " .. (hasHookMetamethod and "disponible" or "no disponible"),
        "getnamecallmethod: " .. (hasGetNamecallMethod and "disponible" or "no disponible"),
        "checkcaller: " .. (hasCheckCaller and "disponible" or "no disponible"),
        "setclipboard: " .. (hasSetClipboard and "disponible" or "no disponible"),
        "getgc: " .. (hasGetGc and "disponible" or "no disponible"),
    }, "\n"),
})

DiagTab:CreateButton({
    Name = "Contraer / Expandir GUI",
    Callback = function()
        if Rayfield.IsVisible and Rayfield.SetVisibility then
            local vis = Rayfield:IsVisible()
            Rayfield:SetVisibility(not vis)
        end
    end,
})

DiagTab:CreateButton({
    Name = "Cerrar VANTA Spy",
    Callback = function()
        state.destroyed = true
        state.capturing = false
        for _, conn in ipairs(state.connections) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        state.connections = {}
        if Rayfield.Destroy then
            Rayfield:Destroy()
        end
    end,
})

-- Escaneo inicial
refreshOriginsUI()

-- Seguimiento en vivo de nuevos remotes
if game and game.DescendantAdded then
    local ok, conn = pcall(function()
        return game.DescendantAdded:Connect(function(inst)
            if state.destroyed then
                return
            end
            if isRemoteInstance(inst) and not state.originMap[inst] then
                refreshOriginsUI()
            end
        end)
    end)
    if ok and conn then
        table.insert(state.connections, conn)
    end
end

-- API de inspección para pruebas automatizadas
if type(_G) == "table" then
    _G.__VANTA_SPY_STATE = state
    _G.__VANTA_SPY_REFRESH_ORIGINS = refreshOriginsUI
    _G.__VANTA_SPY_REFRESH_LOGS = refreshLogsUI
end
