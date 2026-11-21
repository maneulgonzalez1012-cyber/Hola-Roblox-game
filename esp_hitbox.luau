-- ESP y expansor de hitbox local para executors con Rayfield.
-- Ejecutar de nuevo limpia la instancia anterior.
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
local tab = window:CreateTab("Principal", 4483362458)

local espEnabled = false
local hitboxEnabled = false
local hitboxSize = 10
local highlights = {}
local originals = {}
local connections = {}
local running = true

local function removeHighlight(player)
    local highlight = highlights[player]
    if highlight then
        highlight:Destroy()
        highlights[player] = nil
    end
end

local function restore(part)
    local original = originals[part]
    if not original then return end
    if part.Parent then
        part.Size = original.Size
        part.Transparency = original.Transparency
        part.CanCollide = original.CanCollide
    end
    originals[part] = nil
end

local function restoreAll()
    for part in pairs(originals) do
        restore(part)
    end
end

local function updatePlayer(player)
    if player == localPlayer then return end
    local character = player.Character
    local existing = highlights[player]

    if not espEnabled or not character then
        removeHighlight(player)
    elseif not existing or existing.Parent ~= character then
        removeHighlight(player)
        local highlight = Instance.new("Highlight")
        highlight.Name = "LocalESP"
        highlight.FillColor = Color3.fromRGB(255, 70, 70)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
        highlights[player] = highlight
    end

    if hitboxEnabled and character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            if not originals[root] then
                originals[root] = {
                    Size = root.Size,
                    Transparency = root.Transparency,
                    CanCollide = root.CanCollide,
                }
            end
            root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            root.Transparency = 0.7
            root.CanCollide = false
        end
    end
end

local function cleanup()
    if not running then return end
    running = false
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    for player in pairs(highlights) do
        removeHighlight(player)
    end
    restoreAll()
    Rayfield:Destroy()
    if env.HolaEspHitboxCleanup == cleanup then
        env.HolaEspHitboxCleanup = nil
    end
end

env.HolaEspHitboxCleanup = cleanup

tab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(value)
        espEnabled = value
        if not value then
            for player in pairs(highlights) do removeHighlight(player) end
        end
    end,
})

tab:CreateToggle({
    Name = "Expandir hitbox",
    CurrentValue = false,
    Flag = "Hitbox",
    Callback = function(value)
        hitboxEnabled = value
        if not value then restoreAll() end
    end,
})

tab:CreateSlider({
    Name = "Tamaño de hitbox",
    Range = {2, 30},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 10,
    Flag = "HitboxSize",
    Callback = function(value) hitboxSize = value end,
})

tab:CreateButton({ Name = "Cerrar y restaurar", Callback = cleanup })

table.insert(connections, Players.PlayerRemoving:Connect(function(player)
    removeHighlight(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then restore(root) end
end))

table.insert(connections, RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        updatePlayer(player)
    end
    for part in pairs(originals) do
        if not part.Parent then originals[part] = nil end
    end
end))
