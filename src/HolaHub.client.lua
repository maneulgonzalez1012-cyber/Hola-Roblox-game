-- Hola Hub: ESP y expansor de HumanoidRootPart para executor.
-- La expansión solo modifica el cliente; el servidor decide si acepta los impactos.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
assert(localPlayer, "Hola Hub debe ejecutarse en el cliente")

local env = type(getgenv) == "function" and getgenv() or nil
if env and type(env.HolaHubUnload) == "function" then
    pcall(env.HolaHubUnload)
end

local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
end)
assert(ok and Rayfield, "No se pudo cargar Rayfield Gen 2: " .. tostring(Rayfield))

local window = Rayfield:CreateWindow({
    name = "Hola Hub",
    subtitle = "ESP y hitbox · Rayfield Gen 2",
    sidebarLayout = true,
    theme = "cobalt",
})

local state = {
    esp = false,
    names = true,
    distance = true,
    teamCheck = true,
    hitbox = false,
    size = 8,
    transparency = 0.7,
    color = Color3.fromRGB(80, 180, 255),
}

local entries = {}
local running = true
local updateConnection
local removalConnection
local playerGui = localPlayer:WaitForChild("PlayerGui")
local folder = Instance.new("Folder")
folder.Name = "HolaHubESP"
folder.Parent = playerGui

local function restore(entry)
    if not entry.part or not entry.original then return end
    local part, original = entry.part, entry.original
    pcall(function()
        part.Size = original.size
        part.Transparency = original.transparency
        part.CanCollide = original.canCollide
    end)
    entry.part, entry.original = nil, nil
end

local function clearEntry(player)
    local entry = entries[player]
    if not entry then return end
    restore(entry)
    if entry.highlight then entry.highlight:Destroy() end
    if entry.labelGui then entry.labelGui:Destroy() end
    entries[player] = nil
end

local function makeEntry(player, character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "HolaHubHighlight"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.Parent = folder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HolaHubLabel"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(220, 42)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
    billboard.Parent = folder

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextStrokeTransparency = 0
    label.TextColor3 = state.color
    label.Parent = billboard

    local entry = { character = character, highlight = highlight, labelGui = billboard, label = label }
    entries[player] = entry
    return entry
end

local function sameTeam(player)
    -- Neutral players are not automatically treated as teammates.
    return not localPlayer.Neutral and not player.Neutral
        and localPlayer.Team ~= nil and localPlayer.Team == player.Team
end

local function updatePlayer(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local eligible = character and humanoid and humanoid.Health > 0
        and root and root:IsA("BasePart")
        and (not state.teamCheck or not sameTeam(player))

    if not eligible or (not state.esp and not state.hitbox) then
        clearEntry(player)
        return
    end

    local entry = entries[player]
    if entry and entry.character ~= character then
        clearEntry(player)
        entry = nil
    end
    if not entry then entry = makeEntry(player, character) end

    entry.highlight.Enabled = state.esp
    entry.highlight.FillColor = state.color
    entry.highlight.OutlineColor = state.color
    local target = character:FindFirstChild("Head") or root
    entry.labelGui.Adornee = target
    entry.labelGui.Enabled = state.esp and (state.names or state.distance)
    entry.label.TextColor3 = state.color

    local parts = {}
    if state.names then table.insert(parts, player.DisplayName .. " (@" .. player.Name .. ")") end
    if state.distance then
        local ownCharacter = localPlayer.Character
        local ownRoot = ownCharacter and ownCharacter:FindFirstChild("HumanoidRootPart")
        if ownRoot and ownRoot:IsA("BasePart") then
            table.insert(parts, string.format("%d studs", math.floor((ownRoot.Position - root.Position).Magnitude + 0.5)))
        end
    end
    entry.label.Text = table.concat(parts, "\n")

    if state.hitbox then
        if entry.part ~= root then
            restore(entry)
            entry.part = root
            entry.original = { size = root.Size, transparency = root.Transparency, canCollide = root.CanCollide }
        end
        local size = state.size
        root.Size = Vector3.new(size, size, size)
        root.Transparency = state.transparency
        root.CanCollide = false
    else
        restore(entry)
    end
end

local function cleanup()
    if not running then return end
    running = false
    if updateConnection then updateConnection:Disconnect() end
    if removalConnection then removalConnection:Disconnect() end
    for player in pairs(entries) do clearEntry(player) end
    folder:Destroy()
    if not window.unloaded then pcall(function() window:Unload() end) end
    if env and env.HolaHubUnload == cleanup then env.HolaHubUnload = nil end
end
if env then env.HolaHubUnload = cleanup end

local espTab = window:CreateTab({ name = "ESP" })
espTab:CreateSection({ name = "Visuales" })
espTab:CreateToggle({ name = "Activar ESP", value = false, callback = function(v) state.esp = v end })
espTab:CreateToggle({ name = "Mostrar nombres", value = true, callback = function(v) state.names = v end })
espTab:CreateToggle({ name = "Mostrar distancia", value = true, callback = function(v) state.distance = v end })
espTab:CreateToggle({ name = "Excluir compañeros de equipo", value = true, callback = function(v) state.teamCheck = v end })
espTab:CreateColorPicker({ name = "Color del ESP", color = state.color, callback = function(v) state.color = v end })

local hitboxTab = window:CreateTab({ name = "Hitbox" })
hitboxTab:CreateSection({ name = "HumanoidRootPart" })
hitboxTab:CreateToggle({ name = "Activar expansor", value = false, callback = function(v) state.hitbox = v end })
hitboxTab:CreateSlider({ name = "Tamaño", range = { 2, 30 }, increment = 1, value = 8, suffix = " studs", callback = function(v) state.size = v end })
hitboxTab:CreateSlider({ name = "Transparencia", range = { 0, 1 }, increment = 0.1, value = 0.7, callback = function(v) state.transparency = v end })

local settingsTab = window:CreateTab({ name = "Opciones" })
settingsTab:CreateButton({ name = "Cerrar y restaurar", callback = cleanup })

removalConnection = Players.PlayerRemoving:Connect(clearEntry)
local elapsed = 0
updateConnection = RunService.Heartbeat:Connect(function(dt)
    if window.unloaded then cleanup(); return end
    elapsed = elapsed + dt
    if elapsed < 0.2 then return end
    elapsed = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local success, err = pcall(updatePlayer, player)
            if not success then
                clearEntry(player)
                warn("Hola Hub: error al actualizar " .. player.Name .. ": " .. tostring(err))
            end
        end
    end
end)

window:Notify({ title = "Hola Hub", content = "ESP y hitbox listos.", duration = 4 })
