-- VANTA Builder: usa el RemoteEvent y el ejemplo facilitados por el usuario.
-- Las coordenadas son de la rejilla del juego, no necesariamente studs del mundo.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local env = type(getgenv) == "function" and getgenv() or nil
if env and type(env.FrontlinesBuilderUnload) == "function" then pcall(env.FrontlinesBuilderUnload) end
local ok, rayfield = pcall(function() return loadstring(game:HttpGet("https://sirius.menu/gen2"))() end)
assert(ok and rayfield, "No se pudo cargar Rayfield Gen 2: " .. tostring(rayfield))
local window = rayfield:CreateWindow({ name = "VANTA Builder", subtitle = "Frontlines · rejilla experimental", sidebarLayout = true, theme = "cobalt" })
local state = { id = "Wall$180$0", x = "7", y = "-1", z = "-1", axis = "X", count = 3 }
local active, busy, sequence = true, false, 0
local function notify(message)
    if active and not window.unloaded then window:Notify({ title = "VANTA Builder", content = message, duration = 5 }) end
end
local function findRemote()
    local system = ReplicatedStorage:FindFirstChild("BuildingSystem")
    local libraries = system and system:FindFirstChild("Libraries")
    local grid = libraries and libraries:FindFirstChild("Grid")
    local remote = grid and grid:FindFirstChild("AddGridObject")
    if remote and remote:IsA("RemoteEvent") then return remote end
end
local function parseCoordinate(text)
    local value = tonumber(text)
    if not value or value ~= value or value < -10000 or value > 10000 or value ~= math.floor(value) then return end
    return value
end
local function snapshot()
    local x, y, z = parseCoordinate(state.x), parseCoordinate(state.y), parseCoordinate(state.z)
    if not x or not y or not z then return nil, "Usa coordenadas enteras entre -10000 y 10000." end
    if type(state.id) ~= "string" or state.id == "" or #state.id > 100 then return nil, "Introduce un identificador de objeto válido." end
    return { id = state.id, x = x, y = y, z = z, axis = state.axis, count = state.count }
end
local function send(data, index)
    local remote = findRemote()
    if not remote then return false, "No se encontró BuildingSystem.Libraries.Grid.AddGridObject." end
    local offset = index - 1
    local x = data.x + (data.axis == "X" and offset or 0)
    local y = data.y + (data.axis == "Y" and offset or 0)
    local z = data.z + (data.axis == "Z" and offset or 0)
    if x > 10000 or y > 10000 or z > 10000 then return false, "La fila supera el límite de coordenadas." end
    local sent, err = pcall(function() remote:FireServer(data.id, Vector3.new(x, y, z)) end)
    if not sent then return false, "No se pudo enviar: " .. tostring(err) end
    return true
end
local function start(count)
    if not active or window.unloaded then return end
    if busy then notify("Ya hay una fila en curso; usa Detener primero."); return end
    local data, err = snapshot()
    if not data then notify(err); return end
    if not findRemote() then notify("No se encontró BuildingSystem.Libraries.Grid.AddGridObject."); return end
    sequence = sequence + 1
    local thisSequence = sequence
    busy = true
    task.spawn(function()
        local sent = 0
        for i = 1, count == 1 and 1 or data.count do
            if not active or window.unloaded or sequence ~= thisSequence then break end
            local success, problem = send(data, i)
            if not success then
                if sequence == thisSequence then busy = false; notify(problem) end
                return
            end
            sent = sent + 1
            if i < (count == 1 and 1 or data.count) then task.wait(0.5) end
        end
        if sequence == thisSequence then
            busy = false
            notify("Solicitudes enviadas: " .. tostring(sent) .. ". El servidor decide si construye.")
        end
    end)
end
local function stop()
    sequence = sequence + 1
    busy = false
end
local function cleanup()
    if not active then return end
    stop()
    active = false
    if not window.unloaded then pcall(function() window:Unload() end) end
    if env and env.FrontlinesBuilderUnload == cleanup then env.FrontlinesBuilderUnload = nil end
end
if env then env.FrontlinesBuilderUnload = cleanup end
local tab = window:CreateTab({ name = "Construir" })
tab:CreateInput({ name = "ID de objeto", value = state.id, placeholder = "Wall$180$0", description = "Usa el valor exacto capturado; solo Wall está documentado aquí.", callback = function(v) state.id = v end })
tab:CreateInput({ name = "Rejilla X", value = state.x, placeholder = "7", callback = function(v) state.x = v end })
tab:CreateInput({ name = "Rejilla Y", value = state.y, placeholder = "-1", callback = function(v) state.y = v end })
tab:CreateInput({ name = "Rejilla Z", value = state.z, placeholder = "-1", callback = function(v) state.z = v end })
tab:CreateButton({ name = "Solicitar una pieza", description = "Envía una solicitud en las coordenadas indicadas.", callback = function() start(1) end })
tab:CreateDropdown({ name = "Eje de fila", options = { "X", "Y", "Z" }, value = "X", callback = function(v) if v == "X" or v == "Y" or v == "Z" then state.axis = v end end })
tab:CreateSlider({ name = "Piezas por fila", range = { 2, 10 }, increment = 1, value = 3, callback = function(v) state.count = v end })
tab:CreateButton({ name = "Solicitar fila", description = "Máximo 10 solicitudes, separadas 0,5 s. La rejilla puede no aceptar esta disposición.", callback = function() start(2) end })
tab:CreateButton({ name = "Detener fila", callback = function() stop(); notify("Fila detenida.") end })
local options = window:CreateTab({ name = "Opciones" })
options:CreateButton({ name = "Cerrar y limpiar", callback = cleanup })
notify("Introduce coordenadas de rejilla; el servidor puede rechazar las solicitudes.")
