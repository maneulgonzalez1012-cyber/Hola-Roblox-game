-- ESP + hitbox local | Rayfield
-- Ejecutar de nuevo cierra y restaura la instancia anterior.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local env = getgenv()

if type(env.HolaEspHitboxCleanup) == "function" then
    env.HolaEspHitboxCleanup()
end

env.DISABLE_RAYFIELD_REQUESTS = true
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local window = Rayfield:CreateWindow({
    Name = "ESP + Hitbox",
    LoadingTitle = "ESP + Hitbox",
    LoadingSubtitle = "Rayfield",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})
local visualTab = window:CreateTab("ESP", 4483362458)
local hitboxTab = window:CreateTab("Hitbox", 4483362458)
local settingsTab = window:CreateTab("Opciones", 4483362458)

local config = {
    esp = false,
    names = true,
    distance = true,
    teamCheck = false,
    color = Color3.fromRGB(255, 70, 70),
    throughWalls = true,
    hitbox = false,
    hitboxSize = 10,
    hitboxTransparency = 0.7,
}
local visuals = {}
local originals = {}
local connections = {}
local running = true

local function eligible(player)
    return player ~= localPlayer and not (config.teamCheck
        and localPlayer.Team ~= nil and player.Team == localPlayer.Team)
end

local function removeVisual(player)
    local visual = visuals[player]
    if visual then
        visual.highlight:Destroy()
        visual.label:Destroy()
        visuals[player] = nil
    end
end

local function restore(part)
    local original = originals[part]
    if not original then return end
    if part.Parent then
        part.Size = original.size
        part.Transparency = original.transparency
        part.CanCollide = original.canCollide
    end
    originals[part] = nil
end

local function restoreAll()
    for part in pairs(originals) do restore(part) end
end

local function makeVisual(player, character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "HolaLocalESP"
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.Adornee = character
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HolaLocalLabel"
    billboard.Size = UDim2.fromOffset(200, 42)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character

    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Size = UDim2.fromScale(1, 1)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 14
    text.TextStrokeTransparency = 0
    text.Parent = billboard

    local visual = { character = character, highlight = highlight, label = billboard, text = text }
    visuals[player] = visual
    return visual
end

local function updatePlayer(player, localRoot)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local valid = eligible(player) and character and humanoid and humanoid.Health > 0
    local visual = visuals[player]

    if not config.esp or not valid or not root then
        removeVisual(player)
    else
        if not visual or visual.character ~= character or not visual.highlight.Parent or not visual.label.Parent then
            removeVisual(player)
            visual = makeVisual(player, character)
        end
        visual.highlight.FillColor = config.color
        visual.highlight.OutlineColor = config.color
        visual.highlight.DepthMode = config.throughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        visual.label.AlwaysOnTop = config.throughWalls
        visual.label.Adornee = character:FindFirstChild("Head") or root
        visual.text.TextColor3 = config.color
        local pieces = {}
        if config.names then table.insert(pieces, player.DisplayName) end
        if config.distance and localRoot then
            table.insert(pieces, string.format("%d studs", math.floor((localRoot.Position - root.Position).Magnitude + 0.5)))
        end
        visual.text.Text = table.concat(pieces, " | ")
        visual.label.Enabled = #pieces > 0
    end

    if config.hitbox and valid and root and root:IsA("BasePart") then
        if not originals[root] then
            originals[root] = {
                size = root.Size,
                transparency = root.Transparency,
                canCollide = root.CanCollide,
                player = player,
            }
        end
        root.Size = Vector3.new(config.hitboxSize, config.hitboxSize, config.hitboxSize)
        root.Transparency = config.hitboxTransparency
        root.CanCollide = false
    end
end

local function refresh()
    local character = localPlayer.Character
    local localRoot = character and character:FindFirstChild("HumanoidRootPart")
    for _, player in ipairs(Players:GetPlayers()) do
        updatePlayer(player, localRoot)
    end
    for part, original in pairs(originals) do
        local character = original.player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not part.Parent then
            originals[part] = nil
        elseif not config.hitbox or not eligible(original.player) or not character
            or not humanoid or humanoid.Health <= 0
            or character:FindFirstChild("HumanoidRootPart") ~= part then
            restore(part)
        end
    end
end

local function cleanup()
    if not running then return end
    running = false
    for _, connection in ipairs(connections) do connection:Disconnect() end
    for player in pairs(visuals) do removeVisual(player) end
    restoreAll()
    Rayfield:Destroy()
    if env.HolaEspHitboxCleanup == cleanup then env.HolaEspHitboxCleanup = nil end
end
env.HolaEspHitboxCleanup = cleanup

visualTab:CreateToggle({Name = "Activar ESP", CurrentValue = false, Flag = "ESP", Callback = function(value)
    config.esp = value
    refresh()
end})
visualTab:CreateToggle({Name = "Mostrar nombres", CurrentValue = true, Flag = "Names", Callback = function(value)
    config.names = value
    refresh()
end})
visualTab:CreateToggle({Name = "Mostrar distancia", CurrentValue = true, Flag = "Distance", Callback = function(value)
    config.distance = value
    refresh()
end})
visualTab:CreateToggle({Name = "Ver a través de paredes", CurrentValue = true, Flag = "Walls", Callback = function(value)
    config.throughWalls = value
    refresh()
end})
visualTab:CreateColorPicker({Name = "Color del ESP", Color = config.color, Flag = "Color", Callback = function(value)
    config.color = value
    refresh()
end})

hitboxTab:CreateToggle({Name = "Expandir hitbox", CurrentValue = false, Flag = "Hitbox", Callback = function(value)
    config.hitbox = value
    refresh()
end})
hitboxTab:CreateSlider({Name = "Tamaño", Range = {2, 30}, Increment = 1, Suffix = "studs", CurrentValue = 10, Flag = "Size", Callback = function(value)
    config.hitboxSize = value
    refresh()
end})
hitboxTab:CreateSlider({Name = "Transparencia", Range = {0, 100}, Increment = 5, Suffix = "%", CurrentValue = 70, Flag = "Transparency", Callback = function(value)
    config.hitboxTransparency = value / 100
    refresh()
end})

settingsTab:CreateToggle({Name = "Excluir mi equipo", CurrentValue = false, Flag = "TeamCheck", Callback = function(value)
    config.teamCheck = value
    refresh()
end})
settingsTab:CreateButton({Name = "Cerrar y restaurar", Callback = cleanup})

table.insert(connections, Players.PlayerRemoving:Connect(function(player)
    removeVisual(player)
    for part, original in pairs(originals) do
        if original.player == player then restore(part) end
    end
end))

local elapsed = 0
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < 0.2 then return end
    elapsed = 0
    refresh()
end))
