-- VANTA Players: ajustes visuales y de hitbox locales para jugadores (executor).
-- No cambia las validaciones del servidor ni garantiza impactos.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local me = Players.LocalPlayer
assert(me, "Ejecuta el script desde el cliente")

local env = type(getgenv) == "function" and getgenv() or nil
if env and type(env.VantaPlayersUnload) == "function" then pcall(env.VantaPlayersUnload) end
local ok, library = pcall(function() return loadstring(game:HttpGet("https://sirius.menu/gen2"))() end)
assert(ok and library, "No se pudo cargar Rayfield Gen 2: " .. tostring(library))
local window = library:CreateWindow({ name = "VANTA Players", subtitle = "Hitbox + ESP · cliente", sidebarLayout = true, theme = "cobalt" })
local settings = { hitbox = false, esp = false, teamCheck = true, size = 10, transparency = 0.75, distance = 500 }
local folder = Instance.new("Folder")
folder.Name = "VantaPlayersVisuals"
folder.Parent = me:WaitForChild("PlayerGui")
local active, connection, elapsed = true, nil, 0
local originals, markers = {}, {}

local function restore(part)
    local saved = originals[part]
    if not saved then return end
    originals[part] = nil
    pcall(function()
        part.Size = saved.size
        part.Transparency = saved.transparency
        part.CanCollide = saved.canCollide
    end)
end
local function restoreAll()
    for part in pairs(originals) do restore(part) end
end
local function removeMarker(player)
    local marker = markers[player]
    if not marker then return end
    markers[player] = nil
    marker.highlight:Destroy()
    marker.billboard:Destroy()
end
local function clearMarkers()
    for player in pairs(markers) do removeMarker(player) end
end
local function rootOf(character)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then return root end
end
local function eligible(player)
    if player == me then return end
    if settings.teamCheck and not me.Neutral and not player.Neutral and me.Team and me.Team == player.Team then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = rootOf(character)
    local myRoot = rootOf(me.Character)
    if not humanoid or humanoid.Health <= 0 or not root or not myRoot then return end
    local distance = (root.Position - myRoot.Position).Magnitude
    if distance > settings.distance then return end
    return character, humanoid, root, distance
end
local function updateMarker(player, character, humanoid, root, distance)
    local marker = markers[player]
    if marker and marker.character ~= character then removeMarker(player); marker = nil end
    if not marker then
        local highlight = Instance.new("Highlight")
        highlight.Name = "VantaESP"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = Color3.fromRGB(255, 60, 80)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.7
        highlight.Parent = folder
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "VantaLabel"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 48)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = folder
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextSize = 14
        label.RichText = false
        label.Parent = billboard
        marker = { character = character, highlight = highlight, billboard = billboard, label = label }
        markers[player] = marker
    end
    marker.highlight.Adornee = character
    marker.billboard.Adornee = root
    marker.label.Text = player.Name .. " | " .. tostring(math.floor(humanoid.Health)) .. " HP | " .. tostring(math.floor(distance)) .. " studs"
end
local function tick()
    local presentParts, presentPlayers = {}, {}
    for _, target in ipairs(Players:GetPlayers()) do
        local character, humanoid, root, distance = eligible(target)
        if root then
            if settings.hitbox then
                presentParts[root] = true
                if not originals[root] then
                    originals[root] = { size = root.Size, transparency = root.Transparency, canCollide = root.CanCollide }
                end
                root.Size = Vector3.new(settings.size, settings.size, settings.size)
                root.Transparency = settings.transparency
                root.CanCollide = false
            end
            if settings.esp then
                presentPlayers[target] = true
                updateMarker(target, character, humanoid, root, distance)
            end
        end
    end
    for part in pairs(originals) do if not presentParts[part] then restore(part) end end
    for player in pairs(markers) do if not presentPlayers[player] then removeMarker(player) end end
end
local function cleanup()
    if not active then return end
    active = false
    if connection then connection:Disconnect() end
    restoreAll()
    clearMarkers()
    folder:Destroy()
    if not window.unloaded then pcall(function() window:Unload() end) end
    if env and env.VantaPlayersUnload == cleanup then env.VantaPlayersUnload = nil end
end
if env then env.VantaPlayersUnload = cleanup end

local main = window:CreateTab({ name = "Hitbox" })
main:CreateToggle({ name = "Hitbox expander", description = "Cambia el HumanoidRootPart localmente; el servidor puede ignorarlo.", value = false, callback = function(v) settings.hitbox = v; if not v then restoreAll() end end })
main:CreateSlider({ name = "Tamaño hitbox", range = { 2, 30 }, increment = 1, value = 10, suffix = " studs", callback = function(v) settings.size = v end })
main:CreateSlider({ name = "Transparencia hitbox", range = { 0, 1 }, increment = 0.05, value = 0.75, callback = function(v) settings.transparency = v end })
local visual = window:CreateTab({ name = "ESP" })
visual:CreateToggle({ name = "ESP jugadores", description = "Resalta a través de paredes y muestra nombre, vida y distancia.", value = false, callback = function(v) settings.esp = v; if not v then clearMarkers() end end })
local options = window:CreateTab({ name = "Opciones" })
options:CreateToggle({ name = "Ignorar equipo", description = "Excluye compañeros con equipo asignado; jugadores neutrales sí aparecen.", value = true, callback = function(v) settings.teamCheck = v end })
options:CreateSlider({ name = "Distancia máxima", range = { 50, 2000 }, increment = 50, value = 500, suffix = " studs", callback = function(v) settings.distance = v end })
options:CreateButton({ name = "Cerrar y limpiar", callback = cleanup })
connection = RunService.Heartbeat:Connect(function(dt)
    if window.unloaded then cleanup(); return end
    elapsed = elapsed + dt
    if elapsed < 0.25 then return end
    elapsed = 0
    tick()
end)
window:Notify({ title = "VANTA Players", content = "Cargado. Activa hitbox y ESP cuando quieras.", duration = 4 })
