-- Break In (Story) / Rayfield Gen 2. Ejecutar en el cliente con un executor.
-- Los nombres de eventos provienen de ejemplos de la comunidad y pueden cambiar.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
assert(player, "Ejecuta el script en el cliente")

local env = type(getgenv) == "function" and getgenv() or nil
if env and type(env.BreakInHubUnload) == "function" then pcall(env.BreakInHubUnload) end

local compile = loadstring
local ok, Rayfield = pcall(function()
    return compile(game:HttpGet("https://sirius.menu/gen2"))()
end)
assert(ok and Rayfield, "No se pudo cargar Rayfield Gen 2: " .. tostring(Rayfield))
local window = Rayfield:CreateWindow({
    name = "Break In Hub",
    subtitle = "Break In (Story) · Rayfield Gen 2",
    sidebarLayout = true,
    theme = "cobalt",
})

local state = {
    attack = false,
    enemyESP = false,
    range = 30,
    interval = 0.5,
    item = "Apple",
}
local running = true
local connection
local elapsed = 0
local warning = false
local folder = Instance.new("Folder")
folder.Name = "BreakInHubVisuals"
folder.Parent = player:WaitForChild("PlayerGui")
local markers = {}

local function notify(title, content)
    window:Notify({ title = title, content = content, duration = 4 })
end

local function inGame()
    return game.GameId == 1318971886 or game.PlaceId == 3851622790
end

local function getRemote(name)
    local events = ReplicatedStorage:FindFirstChild("RemoteEvents")
    local event = events and events:FindFirstChild(name)
    if event and event:IsA("RemoteEvent") then return event end
end

local function sendRemote(name, ...)
    if not inGame() then return false, "Entra en Break In (Story)." end
    local event = getRemote(name)
    if not event then return false, "Evento " .. name .. " no encontrado." end
    local success, err = pcall(event.FireServer, event, ...)
    if not success then return false, "No se pudo enviar: " .. tostring(err) end
    return true
end

local function action(name, ...)
    local success, err = sendRemote(name, ...)
    notify("Break In", success and "Solicitud enviada; depende del servidor." or err)
end

local function enemies()
    local result = {}
    local seen = {}
    for _, folderName in ipairs({ "BadGuys", "BadGuysBoss", "BadGuysFront" }) do
        local group = Workspace:FindFirstChild(folderName)
        if group then
            for _, enemy in ipairs(group:GetChildren()) do
                if enemy:IsA("Model") and not seen[enemy] then
                    seen[enemy] = true
                    table.insert(result, enemy)
                end
            end
        end
    end
    return result
end

local function removeMarker(enemy)
    if markers[enemy] then markers[enemy]:Destroy(); markers[enemy] = nil end
end

local function updateVisuals(list)
    local present = {}
    if state.enemyESP and inGame() then
        for _, enemy in ipairs(list) do
            present[enemy] = true
            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if not markers[enemy] then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "BreakInEnemy"
                    highlight.Adornee = enemy
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Color3.fromRGB(255, 85, 85)
                    highlight.OutlineColor = Color3.fromRGB(255, 215, 215)
                    highlight.FillTransparency = 0.65
                    highlight.Parent = folder
                    markers[enemy] = highlight
                end
            else
                removeMarker(enemy)
            end
        end
    end
    for enemy in pairs(markers) do if not present[enemy] then removeMarker(enemy) end end
end

local function nearestEnemy(list)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then return end
    local best, distance = nil, state.range
    for _, enemy in ipairs(list) do
        local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
        if enemyHumanoid and enemyHumanoid.Health > 0 and enemyRoot and enemyRoot:IsA("BasePart") then
            local d = (root.Position - enemyRoot.Position).Magnitude
            if d <= distance then best, distance = enemy, d end
        end
    end
    return best
end

local function cleanup()
    if not running then return end
    running = false
    if connection then connection:Disconnect() end
    for enemy in pairs(markers) do removeMarker(enemy) end
    folder:Destroy()
    if not window.unloaded then pcall(function() window:Unload() end) end
    if env and env.BreakInHubUnload == cleanup then env.BreakInHubUnload = nil end
end
if env then env.BreakInHubUnload = cleanup end

local combat = window:CreateTab({ name = "Combate" })
combat:CreateSection({ name = "Enemigos" })
combat:CreateToggle({ name = "Auto ataque", description = "Envía golpes al enemigo más cercano; depende del servidor.", value = false, callback = function(v)
    state.attack = v
    state.attackElapsed = 0
    warning = false
    if v and not inGame() then notify("Break In", "Entra en Break In (Story).") end
end })
combat:CreateSlider({ name = "Alcance", range = { 5, 100 }, increment = 5, value = 30, suffix = " studs", callback = function(v) state.range = v end })
combat:CreateSlider({ name = "Intervalo de ataque", range = { 0.2, 2 }, increment = 0.1, value = 0.5, suffix = " s", callback = function(v) state.interval = v end })
combat:CreateToggle({ name = "Resaltar enemigos", value = false, callback = function(v) state.enemyESP = v end })

local items = window:CreateTab({ name = "Objetos" })
items:CreateDropdown({ name = "Objeto", options = { "Apple", "Cookie", "Chips", "BloxyCola", "Pizza3", "MedKit", "Bat", "Plank", "Key", "TeddyBloxpin" }, value = "Apple", callback = function(v) if v then state.item = v end end })
items:CreateButton({ name = "Solicitar objeto", callback = function() action("GiveTool", state.item) end })
items:CreateButton({ name = "Solicitar energía", description = "Usa el evento Cat documentado por la comunidad.", callback = function() action("Energy", "Cat") end })
items:CreateButton({ name = "Intentar amistad con el gato", callback = function() action("Cattery") end })

local story = window:CreateTab({ name = "Historia" })
local function safeCode()
    local note = Workspace:FindFirstChild("CodeNote")
    local gui = note and note:FindFirstChild("SurfaceGui")
    local label = gui and gui:FindFirstChild("TextLabel")
    if label and label:IsA("TextLabel") then return label.Text end
end
story:CreateButton({ name = "Mostrar código de la caja", callback = function()
    if not inGame() then notify("Caja fuerte", "Entra en Break In (Story)."); return end
    local code = safeCode()
    notify("Caja fuerte", code and code ~= "" and code or "No se encontró la nota del código.")
end })
story:CreateButton({ name = "Solicitar apertura de caja", callback = function()
    if not inGame() then notify("Caja fuerte", "Entra en Break In (Story)."); return end
    local code = safeCode()
    if not code or code == "" then notify("Caja fuerte", "No se encontró la nota del código."); return end
    action("Safe", code)
end })

local locations = {
    { "Casa", -36, 3, -200 },
    { "Sótano", 71, -15, -163 },
    { "Ático", -16, 35, -220 },
    { "Tienda", -422, 3, -121 },
    { "Sala del jefe", -39, -287, -1480 },
}
local travel = window:CreateTab({ name = "Viaje" })
for _, location in ipairs(locations) do
    local destination = location
    travel:CreateButton({ name = destination[1], description = "Posición comunitaria: puede haber cambiado.", callback = function()
        if not inGame() then notify("Viaje", "Entra en Break In (Story)."); return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or not root:IsA("BasePart") then notify("Viaje", "Personaje no disponible."); return end
        root.CFrame = CFrame.new(destination[2], destination[3], destination[4])
    end })
end

local options = window:CreateTab({ name = "Opciones" })
options:CreateButton({ name = "Cerrar y limpiar", callback = cleanup })
connection = RunService.Heartbeat:Connect(function(dt)
    if window.unloaded then cleanup(); return end
    elapsed = elapsed + dt
    if elapsed < 0.2 then return end
    local delta = elapsed
    elapsed = 0
    if not inGame() then updateVisuals({}); return end
    local list = enemies()
    updateVisuals(list)
    if not state.attack then return end
    -- Independent cooldown without spawning duplicate loops.
    if not state.attackElapsed then state.attackElapsed = 0 end
    state.attackElapsed = state.attackElapsed + delta
    if state.attackElapsed < state.interval then return end
    state.attackElapsed = 0
    local target = nearestEnemy(list)
    if not target then return end
    local success, err = sendRemote("HitBadguy", target, 10)
    if not success and not warning then warning = true; notify("Auto ataque", err) end
    if success then warning = false end
end)
notify("Break In Hub", "Cargado para Break In (Story).")
