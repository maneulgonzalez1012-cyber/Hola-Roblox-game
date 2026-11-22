-- Blade Ball: auto parry y visualizador de pelota (executor, cliente).
-- No se garantiza compatibilidad con actualizaciones del juego o del executor.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
assert(player, "Ejecuta el script desde el cliente")

local env = type(getgenv) == "function" and getgenv() or nil
if env then
    -- Limpia instancias anteriores, incluida la versión anterior del hub.
    if type(env.BladeBallUnload) == "function" then pcall(env.BladeBallUnload) end
    if type(env.HolaHubUnload) == "function" then pcall(env.HolaHubUnload) end
end

local compile = loadstring
local ok, Rayfield = pcall(function()
    return compile(game:HttpGet("https://sirius.menu/gen2"))()
end)
assert(ok and Rayfield, "No se pudo cargar Rayfield Gen 2: " .. tostring(Rayfield))
local window = Rayfield:CreateWindow({
    name = "Blade Ball Hub",
    subtitle = "Auto parry · Rayfield Gen 2",
    sidebarLayout = true,
    theme = "cobalt",
})

local settings = {
    autoParry = false,
    highlight = false,
    leadTime = 0.35,
    nearDistance = 12,
    cooldown = 0.5,
}
local active = true
local connection
local states = {}
local lastAttempt = -math.huge
local warningShown = false
local lastCharacter

local marker = Instance.new("Highlight")
marker.Name = "BladeBallMarker"
marker.Enabled = false
marker.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
marker.FillTransparency = 0.65
marker.OutlineTransparency = 0
marker.Parent = player:WaitForChild("PlayerGui")

local function notify(title, content)
    window:Notify({ title = title, content = content, duration = 4 })
end

local function isBladeBall()
    return game.GameId == 4777817887 or game.PlaceId == 13772394625
end

local function sendParry()
    -- The community-documented button is a local BindableEvent, not a server remote.
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local button = remotes and remotes:FindFirstChild("ParryButtonPress")
    if button and button:IsA("BindableEvent") then
        local success = pcall(function() button:Fire() end)
        if success then return true end
    end
    if type(mouse1click) == "function" then
        local success = pcall(mouse1click)
        if success then return true end
    end
    local success = pcall(function()
        local input = game:GetService("VirtualInputManager")
        input:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        input:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    return success
end

local function realBalls()
    local folder = Workspace:FindFirstChild("Balls")
    local found = {}
    if folder then
        for _, ball in ipairs(folder:GetChildren()) do
            if ball:IsA("BasePart") and ball:GetAttribute("realBall") == true then
                table.insert(found, ball)
            end
        end
    end
    return found
end

local function velocityOf(ball)
    local velocity = ball.AssemblyLinearVelocity
    if velocity.Magnitude < 0.1 then
        local zoomies = ball:FindFirstChild("zoomies")
        if zoomies and zoomies:IsA("LinearVelocity") then return zoomies.VectorVelocity end
    end
    return velocity
end

local function cleanup()
    if not active then return end
    active = false
    if connection then connection:Disconnect() end
    marker:Destroy()
    if not window.unloaded then pcall(function() window:Unload() end) end
    if env and env.BladeBallUnload == cleanup then env.BladeBallUnload = nil end
end
if env then env.BladeBallUnload = cleanup end

local main = window:CreateTab({ name = "Auto parry" })
main:CreateSection({ name = "Defensa" })
local parryToggle = main:CreateToggle({
    name = "Auto parry",
    description = "Intenta bloquear la pelota real cuando te apunta y se aproxima.",
    value = false,
    callback = function(value)
        settings.autoParry = value
        states = {}
        warningShown = false
        if value and not isBladeBall() then notify("Blade Ball", "Entra a Blade Ball para activar el parry.") end
    end,
})
main:CreateSlider({ name = "Anticipación", description = "Segundos estimados antes del impacto", range = { 0.1, 1 }, increment = 0.05, value = 0.35, suffix = " s", callback = function(v) settings.leadTime = v end })
main:CreateSlider({ name = "Distancia mínima", description = "Distancia de emergencia si la pelota se acerca", range = { 4, 30 }, increment = 1, value = 12, suffix = " studs", callback = function(v) settings.nearDistance = v end })
main:CreateSlider({ name = "Espera entre bloqueos", range = { 0.2, 1.5 }, increment = 0.05, value = 0.5, suffix = " s", callback = function(v) settings.cooldown = v end })
main:CreateButton({ name = "Probar bloqueo", callback = function()
    if not isBladeBall() then notify("Blade Ball", "Entra a Blade Ball primero."); return end
    notify("Prueba de bloqueo", sendParry() and "Se envió la señal local." or "No hay entrada compatible en este executor.")
end })

local visual = window:CreateTab({ name = "Pelota" })
visual:CreateToggle({ name = "Resaltar pelota real", description = "Rojo si te apunta; azul si apunta a otro jugador.", value = false, callback = function(v) settings.highlight = v end })
local options = window:CreateTab({ name = "Opciones" })
options:CreateButton({ name = "Cerrar y limpiar", callback = cleanup })

connection = RunService.Heartbeat:Connect(function()
    if window.unloaded then cleanup(); return end
    if not isBladeBall() then marker.Enabled = false; return end
    local character = player.Character
    if character ~= lastCharacter then
        states = {}
        lastCharacter = character
    end
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local balls = realBalls()
    local present = {}
    local selected
    for _, ball in ipairs(balls) do
        present[ball] = true
        local target = ball:GetAttribute("target")
        if not selected or target == player.Name then selected = ball end
        local ballState = states[ball]
        if not ballState then
            ballState = { target = target, fired = false, departed = false }
            states[ball] = ballState
        elseif ballState.target ~= target then
            ballState.target = target
            ballState.fired = false
            ballState.departed = false
        end

        if settings.autoParry and root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 and target == player.Name then
            local direction = root.Position - ball.Position
            local distance = direction.Magnitude
            local relativeVelocity = velocityOf(ball) - root.AssemblyLinearVelocity
            local closing = distance > 0.001 and relativeVelocity:Dot(direction.Unit) or 0
            if ballState.fired and closing <= 0 then ballState.departed = true end
            local now = os.clock()
            if ballState.fired and ballState.departed and now - lastAttempt >= settings.cooldown then
                ballState.fired = false
                ballState.departed = false
            end
            local eta = closing > 0 and distance / closing or math.huge
            if not ballState.fired and closing > 0 and (distance <= settings.nearDistance or eta <= settings.leadTime) and now - lastAttempt >= settings.cooldown then
                lastAttempt = now
                if sendParry() then
                    ballState.fired = true
                    warningShown = false
                elseif not warningShown then
                    warningShown = true
                    notify("Auto parry", "No se encontró una entrada de bloqueo compatible.")
                end
            end
        end
    end
    for ball in pairs(states) do if not present[ball] then states[ball] = nil end end
    marker.Adornee = selected
    marker.Enabled = settings.highlight and selected ~= nil
    if selected then
        local color = selected:GetAttribute("target") == player.Name and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(80, 180, 255)
        marker.FillColor = color
        marker.OutlineColor = color
    end
end)

notify("Blade Ball Hub", "Cargado. Activa Auto parry en la pestaña de defensa.")
