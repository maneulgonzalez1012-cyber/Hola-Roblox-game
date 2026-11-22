-- VANTA Prison Life: cliente para Prison Life de Aesthetical.
-- Remotes y coordenadas de fuentes comunitarias históricas; el servidor decide.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local me = Players.LocalPlayer
assert(me, "Ejecuta el script en el cliente")
local env = type(getgenv) == "function" and getgenv() or nil
if env and type(env.PrisonLifeUnload) == "function" then pcall(env.PrisonLifeUnload) end
local ok, rayfield = pcall(function() return loadstring(game:HttpGet("https://sirius.menu/gen2"))() end)
assert(ok and rayfield, "No se pudo cargar Rayfield Gen 2: " .. tostring(rayfield))
local window = rayfield:CreateWindow({ name = "VANTA Prison Life", subtitle = "Prison Life · experimental", sidebarLayout = true, theme = "cobalt" })
local state = { item = "M9", target = "", esp = false, teamCheck = false, speedOn = false, speed = 24, jumpOn = false, jumpPower = 75, infiniteJump = false, noclip = false }
local active, heartbeat, jumpConnection, elapsed = true, nil, nil, 0
local invokeBusy = false
local markers, collisions = {}, {}
local motionHumanoid, oldSpeed, oldJump, oldUseJump
local folder = Instance.new("Folder")
folder.Name = "VantaPrisonLifeVisuals"
folder.Parent = me:WaitForChild("PlayerGui")
local function notify(message)
    if active and not window.unloaded then window:Notify({ title = "Prison Life", content = message, duration = 4 }) end
end
local function inGame()
    return game.GameId == 73885730 or game.PlaceId == 155615604
end
local function checkGame()
    if not active or window.unloaded then return false end
    if not inGame() then notify("Entra en Prison Life de Aesthetical."); return false end
    return true
end
local function remote(name, class)
    local remotes = Workspace:FindFirstChild("Remote")
    local obj = remotes and remotes:FindFirstChild(name)
    if obj and obj:IsA(class) then return obj end
end
local function fireTeam(color)
    if not checkGame() then return end
    local event = remote("TeamEvent", "RemoteEvent")
    if not event then notify("No se encontró TeamEvent."); return end
    local sent, err = pcall(function() event:FireServer(color) end)
    notify(sent and "Solicitud de equipo enviada; depende del servidor." or "Error: " .. tostring(err))
end
local items = {
    ["M9"] = { "giver", "M9" }, ["Remington 870"] = { "giver", "Remington 870" },
    ["AK-47"] = { "giver", "AK-47" }, ["M4A1"] = { "giver", "M4A1" },
    ["Riot Shield"] = { "giver", "Riot Shield" }, ["Key card"] = { "single", "Key card" },
    ["Crude Knife"] = { "single", "Crude Knife" }, ["Hammer"] = { "single", "Hammer" },
    ["Breakfast"] = { "giver", "Breakfast" }, ["Lunch"] = { "giver", "Lunch" }, ["Dinner"] = { "giver", "Dinner" },
}
local function invokeOnce(name, argument)
    if not checkGame() then return end
    if invokeBusy then notify("Hay una solicitud esperando respuesta del servidor."); return end
    local fn = remote(name, "RemoteFunction")
    if not fn then notify("No se encontró " .. name .. "."); return end
    invokeBusy = true
    task.spawn(function()
        local sent, err = pcall(function() fn:InvokeServer(argument) end)
        invokeBusy = false
        if not active or window.unloaded then return end
        notify(sent and "Solicitud terminada; la acción depende del servidor." or "Error: " .. tostring(err))
    end)
end
local function requestItem()
    if not checkGame() then return end
    local info = items[state.item]
    local all = Workspace:FindFirstChild("Prison_ITEMS")
    local category = info and all and all:FindFirstChild(info[1])
    local item = category and category:FindFirstChild(info[2])
    local pickup = item and item:FindFirstChild("ITEMPICKUP")
    if not pickup then notify("No se encontró el objeto seleccionado."); return end
    invokeOnce("ItemHandler", pickup)
end
local function root(character)
    local part = character and character:FindFirstChild("HumanoidRootPart")
    if part and part:IsA("BasePart") then return part end
end
local function targetPlayer()
    if not checkGame() then return end
    local target = Players:FindFirstChild(state.target)
    if not target or not target:IsA("Player") or target == me then notify("Escribe el nombre de usuario exacto de otro jugador."); return end
    return target
end
local function restoreMotion()
    if motionHumanoid then pcall(function()
        if oldSpeed ~= nil then motionHumanoid.WalkSpeed = oldSpeed end
        if oldJump ~= nil then motionHumanoid.JumpPower = oldJump; motionHumanoid.UseJumpPower = oldUseJump end
    end) end
    motionHumanoid, oldSpeed, oldJump, oldUseJump = nil, nil, nil, nil
end
local function syncMotion()
    local character = inGame() and me.Character
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if hum ~= motionHumanoid then restoreMotion(); motionHumanoid = hum end
    if not hum then return end
    if state.speedOn then
        if oldSpeed == nil then oldSpeed = hum.WalkSpeed end
        hum.WalkSpeed = state.speed
    elseif oldSpeed ~= nil then hum.WalkSpeed = oldSpeed; oldSpeed = nil end
    if state.jumpOn then
        if oldJump == nil then oldJump, oldUseJump = hum.JumpPower, hum.UseJumpPower end
        hum.UseJumpPower = true; hum.JumpPower = state.jumpPower
    elseif oldJump ~= nil then hum.JumpPower = oldJump; hum.UseJumpPower = oldUseJump; oldJump, oldUseJump = nil, nil end
end
local function restoreCollision(part)
    local value = collisions[part]
    if value == nil then return end
    collisions[part] = nil
    pcall(function() part.CanCollide = value end)
end
local function clearCollisions() for part in pairs(collisions) do restoreCollision(part) end end
local function updateCollision()
    local present = {}
    if state.noclip and inGame() and me.Character then
        for _, part in ipairs(me.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                present[part] = true
                if collisions[part] == nil then collisions[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end
    for part in pairs(collisions) do if not present[part] then restoreCollision(part) end end
end
local function removeMarker(player)
    if markers[player] then markers[player]:Destroy(); markers[player] = nil end
end
local function clearMarkers() for player in pairs(markers) do removeMarker(player) end end
local function updateESP()
    local present = {}
    if state.esp and inGame() then
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local hum = character and character:FindFirstChildOfClass("Humanoid")
            local sameTeam = state.teamCheck and not me.Neutral and not player.Neutral and me.Team and player.Team == me.Team
            if player ~= me and not sameTeam and hum and hum.Health > 0 and root(character) then
                present[player] = true
                if not markers[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "PrisonLifeESP"
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Color3.fromRGB(255, 70, 80)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.65
                    highlight.Parent = folder
                    markers[player] = highlight
                end
                markers[player].Adornee = character
            end
        end
    end
    for player in pairs(markers) do if not present[player] then removeMarker(player) end end
end
local function cleanup()
    if not active then return end
    active = false
    if heartbeat then heartbeat:Disconnect() end
    if jumpConnection then jumpConnection:Disconnect() end
    restoreMotion(); clearCollisions(); clearMarkers(); folder:Destroy()
    if not window.unloaded then pcall(function() window:Unload() end) end
    if env and env.PrisonLifeUnload == cleanup then env.PrisonLifeUnload = nil end
end
if env then env.PrisonLifeUnload = cleanup end

local itemTab = window:CreateTab({ name = "Objetos" })
itemTab:CreateDropdown({ name = "Objeto", options = { "M9", "Remington 870", "AK-47", "M4A1", "Riot Shield", "Key card", "Crude Knife", "Hammer", "Breakfast", "Lunch", "Dinner" }, value = "M9", callback = function(v) if items[v] then state.item = v end end })
itemTab:CreateButton({ name = "Solicitar objeto", description = "El servidor puede rechazarlo; algunos objetos requieren permisos.", callback = requestItem })
local teamTab = window:CreateTab({ name = "Equipos" })
teamTab:CreateButton({ name = "Solicitar preso", callback = function() fireTeam("Bright orange") end })
teamTab:CreateButton({ name = "Solicitar guardia", callback = function() fireTeam("Bright blue") end })
teamTab:CreateButton({ name = "Solicitar neutral", callback = function() fireTeam("Medium stone grey") end })
local travel = window:CreateTab({ name = "Viajes" })
for _, data in ipairs({
    { "Patio", 793.991333, 98.1899414, 2521.31543 }, { "Prisión", 916.409973, 99.9899902, 2439.09375 },
    { "Cafetería", 876.026489, 99.9899597, 2322.52856 }, { "Sala de guardias", 837.90686, 99.9900055, 2311.51904 },
    { "Base criminal", -920.417664, 95.3272018, 2138.17847 },
}) do
    local location = data
    travel:CreateButton({ name = location[1], description = "Coordenadas históricas; el mapa puede haber cambiado.", callback = function()
        if not checkGame() then return end
        local part = root(me.Character)
        if not part then notify("Personaje no disponible."); return end
        part.CFrame = CFrame.new(location[2], location[3], location[4])
    end })
end
local people = window:CreateTab({ name = "Jugadores" })
people:CreateInput({ name = "Nombre de usuario", value = "", placeholder = "Nombre exacto", callback = function(v) state.target = v end })
people:CreateButton({ name = "Ir a jugador", callback = function()
    local target = targetPlayer(); if not target then return end
    local mine, theirs = root(me.Character), root(target.Character)
    if not mine or not theirs then notify("Personaje no disponible."); return end
    mine.CFrame = theirs.CFrame
end })
people:CreateButton({ name = "Solicitar golpe", description = "Una solicitud meleeEvent; depende del servidor.", callback = function()
    local target = targetPlayer(); if not target then return end
    local event = ReplicatedStorage:FindFirstChild("meleeEvent")
    if not event or not event:IsA("RemoteEvent") then notify("No se encontró meleeEvent."); return end
    local sent, err = pcall(function() event:FireServer(target) end)
    notify(sent and "Solicitud enviada; depende del servidor." or "Error: " .. tostring(err))
end })
people:CreateButton({ name = "Solicitar arresto", description = "Un intento; el servidor puede requerir ser guardia y estar cerca.", callback = function()
    local target = targetPlayer(); if not target then return end
    local head = target.Character and target.Character:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then notify("Cabeza del jugador no disponible."); return end
    invokeOnce("arrest", head)
end })
people:CreateToggle({ name = "ESP jugadores", value = false, callback = function(v) state.esp = v; if not v then clearMarkers() end end })
people:CreateToggle({ name = "Ignorar equipo en ESP", value = false, callback = function(v) state.teamCheck = v end })
local movement = window:CreateTab({ name = "Movimiento" })
movement:CreateToggle({ name = "Velocidad personalizada", value = false, callback = function(v) state.speedOn = v; syncMotion() end })
movement:CreateSlider({ name = "Velocidad", range = { 16, 100 }, increment = 1, value = 24, callback = function(v) state.speed = v; syncMotion() end })
movement:CreateToggle({ name = "Salto personalizado", value = false, callback = function(v) state.jumpOn = v; syncMotion() end })
movement:CreateSlider({ name = "Potencia de salto", range = { 50, 200 }, increment = 5, value = 75, callback = function(v) state.jumpPower = v; syncMotion() end })
movement:CreateToggle({ name = "Salto infinito", value = false, callback = function(v) state.infiniteJump = v end })
movement:CreateToggle({ name = "Noclip", description = "Colisiones locales; se restauran al desactivar.", value = false, callback = function(v) state.noclip = v; if not v then clearCollisions() end end })
local options = window:CreateTab({ name = "Opciones" })
options:CreateButton({ name = "Cerrar y limpiar", callback = cleanup })
jumpConnection = UserInputService.JumpRequest:Connect(function()
    if not active or not inGame() or not state.infiniteJump then return end
    local hum = me.Character and me.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
heartbeat = RunService.Heartbeat:Connect(function(dt)
    if window.unloaded then cleanup(); return end
    if state.noclip then updateCollision() end
    elapsed = elapsed + dt
    if elapsed < 0.2 then return end
    elapsed = 0
    if not inGame() then restoreMotion(); clearCollisions(); clearMarkers(); return end
    syncMotion(); updateESP()
end)
notify(inGame() and "Cargado; acciones sujetas al servidor." or "Entra en Prison Life de Aesthetical.")
