-- Hola Hub: ESP y expansor de HumanoidRootPart para executor.
-- La expansión solo modifica el cliente; el servidor decide si acepta los impactos.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
assert(localPlayer, "Hola Hub debe ejecutarse en el cliente")

local env = type(getgenv) == "function" and getgenv() or nil
if env and type(env.HolaHubUnload) == "function" then
    pcall(env.HolaHubUnload)
end

local compile = loadstring
local ok, Rayfield = pcall(function()
    return compile(game:HttpGet("https://sirius.menu/gen2"))()
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
    autoFire = false,
    autoFireInterval = 0.5,
    aimRadius = 250,
    speedOrbs = false,
    speedGems = false,
    speedZone = "City",
    speedInterval = 0.5,
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

-- Experimental: this aims the camera at a visible opponent, then attempts a
-- normal click or Tool activation. It does not forge a game-specific remote.
local lastFire = 0
local fireWarning = false
local function autoFireTick(dt)
    if not state.autoFire or game.PlaceId ~= 122446657157717 then return end
    lastFire = lastFire + dt
    if lastFire < state.autoFireInterval then return end
    lastFire = 0
    local camera = Workspace.CurrentCamera
    local ownCharacter = localPlayer.Character
    local ownHumanoid = ownCharacter and ownCharacter:FindFirstChildOfClass("Humanoid")
    if not camera or not ownHumanoid or ownHumanoid.Health <= 0 then return end

    local best, bestDistance
    local center = camera.ViewportSize / 2
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { ownCharacter }
    for _, candidate in ipairs(Players:GetPlayers()) do
        if candidate ~= localPlayer and (not state.teamCheck or not sameTeam(candidate)) then
            local character = candidate.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local head = character and character:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0 and head and head:IsA("BasePart") then
                local projected, onScreen = camera:WorldToViewportPoint(head.Position)
                local dx, dy = projected.X - center.X, projected.Y - center.Y
                local distance = math.sqrt(dx * dx + dy * dy)
                if onScreen and projected.Z > 0 and distance <= state.aimRadius
                    and (not bestDistance or distance < bestDistance) then
                    local origin = camera.CFrame.Position
                    local hit = Workspace:Raycast(origin, head.Position - origin, params)
                    if not hit or hit.Instance:IsDescendantOf(character) then
                        best, bestDistance = head, distance
                    end
                end
            end
        end
    end
    if not best then return end

    local click = type(mouse1click) == "function" and mouse1click or nil
    local tool = ownCharacter:FindFirstChildOfClass("Tool")
    if not click and not tool then
        if not fireWarning then
            fireWarning = true
            window:Notify({ title = "Auto disparo", content = "Sin arma Tool ni mouse1click compatible.", duration = 5 })
        end
        return
    end
    fireWarning = false
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, best.Position)
    local fired, err = pcall(function()
        if click then click() else tool:Activate() end
    end)
    if not fired then
        warn("Hola Hub: no se pudo disparar: " .. tostring(err))
    end
end

-- Legends of Speed: documented community remote; the server may reject it.
-- Kept separate from combat and disabled unless explicitly enabled.
local speedElapsed = 0
local speedWarning = false
local function speedTick(dt)
    if game.PlaceId ~= 3101667897 or not (state.speedOrbs or state.speedGems) then return end
    speedElapsed = speedElapsed + dt
    if speedElapsed < state.speedInterval then return end
    speedElapsed = 0
    local storage = game:GetService("ReplicatedStorage")
    local events = storage:FindFirstChild("rEvents")
    local orbEvent = events and events:FindFirstChild("orbEvent")
    if not orbEvent or not orbEvent:IsA("RemoteEvent") then
        if not speedWarning then
            speedWarning = true
            window:Notify({ title = "Legends of Speed", content = "No se encontró orbEvent; puede haber cambiado el juego.", duration = 5 })
        end
        return
    end
    local success, err = pcall(function()
        if state.speedOrbs then orbEvent:FireServer("collectOrb", "Red Orb", state.speedZone) end
        if state.speedGems then orbEvent:FireServer("collectOrb", "Gem", state.speedZone) end
    end)
    if not success then
        if not speedWarning then
            speedWarning = true
            warn("Hola Hub: error al recoger: " .. tostring(err))
            window:Notify({ title = "Legends of Speed", content = "Error al recoger; revisa la consola.", duration = 5 })
        end
    else
        speedWarning = false
    end
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

local combatTab = window:CreateTab({ name = "Combate" })
combatTab:CreateSection({ name = "Sniper Arena · experimental" })
local autoFireToggle = combatTab:CreateToggle({
    name = "Auto disparo",
    description = "Apunta y dispara a enemigos visibles; necesita un método de disparo compatible.",
    value = false,
    callback = function(value)
        if value and game.PlaceId ~= 122446657157717 then
            window:Notify({ title = "Auto disparo", content = "Solo funciona en Sniper Arena.", duration = 4 })
        end
        state.autoFire = value
        lastFire = 0
        fireWarning = false
    end,
})
combatTab:CreateSlider({ name = "Radio de mira", range = { 50, 600 }, increment = 10, value = 250, suffix = " px", callback = function(v) state.aimRadius = v end })
combatTab:CreateSlider({ name = "Intervalo de disparo", range = { 0.2, 2 }, increment = 0.1, value = 0.5, suffix = " s", callback = function(v) state.autoFireInterval = v end })

local speedTab = window:CreateTab({ name = "Legends of Speed" })
speedTab:CreateSection({ name = "Recolección · experimental" })
local function speedToggleNotice(value)
    if value and game.PlaceId ~= 3101667897 then
        window:Notify({ title = "Legends of Speed", content = "Entra al juego para utilizar esta función.", duration = 4 })
    end
end
speedTab:CreateToggle({ name = "Auto orbes rojos", value = false, callback = function(v)
    state.speedOrbs = v
    speedToggleNotice(v)
end })
speedTab:CreateToggle({ name = "Auto gemas", value = false, callback = function(v)
    state.speedGems = v
    speedToggleNotice(v)
end })
speedTab:CreateDropdown({
    name = "Zona de recolección",
    description = "Selecciona la zona que tienes desbloqueada.",
    options = { "City", "Snow City", "Magma City" }, value = "City",
    callback = function(v) state.speedZone = v end,
})
speedTab:CreateSlider({ name = "Intervalo de recolección", range = { 0.2, 2 }, increment = 0.1, value = 0.5, suffix = " s", callback = function(v) state.speedInterval = v end })

local settingsTab = window:CreateTab({ name = "Opciones" })
settingsTab:CreateButton({ name = "Cerrar y restaurar", callback = cleanup })

removalConnection = Players.PlayerRemoving:Connect(clearEntry)
local elapsed = 0
updateConnection = RunService.Heartbeat:Connect(function(dt)
    if window.unloaded then cleanup(); return end
    if state.speedOrbs or state.speedGems then
        local success, err = pcall(speedTick, dt)
        if not success then
            warn("Hola Hub: error de Legends of Speed: " .. tostring(err))
        end
    end
    if state.autoFire then
        local success, err = pcall(autoFireTick, dt)
        if not success then
            state.autoFire = false
            autoFireToggle:Set(false)
            warn("Hola Hub: auto disparo detenido: " .. tostring(err))
            window:Notify({ title = "Auto disparo", content = "Error; revisa la consola del executor.", duration = 5 })
        end
    end
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
