-- VANTA Desert Detectors. Estructura y remote históricos; sujetos al servidor.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local me = Players.LocalPlayer
assert(me, "Ejecuta este script en el cliente")
local env = type(getgenv) == "function" and getgenv() or nil
if env and type(env.DesertDetectorsUnload) == "function" then pcall(env.DesertDetectorsUnload) end
local ok, rayfield = pcall(function() return loadstring(game:HttpGet("https://sirius.menu/gen2"))() end)
assert(ok and rayfield, "No se pudo cargar Rayfield Gen 2: " .. tostring(rayfield))
local window = rayfield:CreateWindow({ name = "VANTA Desert Detectors", subtitle = "tesoros · experimental", sidebarLayout = true, theme = "cobalt" })
local visuals = Instance.new("Folder")
visuals.Name = "VantaDesertVisuals"
visuals.Parent = me:WaitForChild("PlayerGui")
local state = { esp = false, amount = 12000 }
local active, heartbeat, elapsed = true, nil, 0
local markers = {}
local function notify(message)
    if active and not window.unloaded then window:Notify({ title = "Desert Detectors", content = message, duration = 5 }) end
end
local function inGame()
    return game.PlaceId == 73010525850196 or game.PlaceId == 86161665059642
end
local function checkGame()
    if not active or window.unloaded then return false end
    if not inGame() then notify("Entra en Desert Detectors de Diggin' Devs."); return false end
    return true
end
local function partFor(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true) end
    return nil
end
local function playerRoot()
    local character = me.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return root and root:IsA("BasePart") and root or nil
end
local function lootFolder()
    return Workspace:FindFirstChild("Loot")
end
local function clearMarker(obj)
    local marker = markers[obj]
    if not marker then return end
    markers[obj] = nil
    marker.label:Destroy()
    marker.highlight:Destroy()
end
local function clearMarkers()
    for obj in pairs(markers) do clearMarker(obj) end
end
local function describe(obj)
    local name = tostring(obj.Name)
    if #name > 60 then name = string.sub(name, 1, 60) end
    local rarity = obj:GetAttribute("Rarity")
    local material = obj:GetAttribute("Material")
    local details = {}
    for _, info in ipairs({ { "Rareza", rarity }, { "Material", material } }) do
        local value = info[2]
        if (type(value) == "string" or type(value) == "number") and tostring(value) ~= "" then
            table.insert(details, info[1] .. ": " .. string.sub(tostring(value), 1, 30))
        end
    end
    if #details > 0 then name = name .. "\n" .. table.concat(details, " | ") end
    return name
end
local function updateESP()
    local present = {}
    local root, folder = playerRoot(), lootFolder()
    if state.esp and inGame() and folder then
        local count = 0
        for _, item in ipairs(folder:GetChildren()) do
            local part = partFor(item)
            if part and count < 60 then
                count = count + 1
                present[item] = true
                local marker = markers[item]
                if not marker then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "VantaTreasureHighlight"
                    highlight.Adornee = item
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Color3.fromRGB(255, 200, 65)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.65
                    highlight.Parent = visuals
                    local label = Instance.new("BillboardGui")
                    label.Name = "VantaTreasureName"
                    label.AlwaysOnTop = true
                    label.Size = UDim2.new(0, 180, 0, 55)
                    label.StudsOffset = Vector3.new(0, 3, 0)
                    label.MaxDistance = 1500
                    label.Parent = visuals
                    local text = Instance.new("TextLabel")
                    text.BackgroundTransparency = 1
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.TextColor3 = Color3.fromRGB(255, 240, 160)
                    text.TextStrokeTransparency = 0.15
                    text.TextScaled = true
                    text.Font = Enum.Font.GothamBold
                    text.Parent = label
                    marker = { highlight = highlight, label = label, text = text }
                    markers[item] = marker
                end
                marker.label.Adornee = part
                local distance = root and math.floor((root.Position - part.Position).Magnitude + 0.5)
                marker.text.Text = describe(item) .. (distance and ("\n" .. tostring(distance) .. " studs") or "")
            end
        end
    end
    for obj in pairs(markers) do if not present[obj] then clearMarker(obj) end end
end
local function nearestLoot()
    local folder, root = lootFolder(), playerRoot()
    if not folder or not root then return nil end
    local closest, best
    for _, item in ipairs(folder:GetChildren()) do
        local part = partFor(item)
        if part then
            local distance = (root.Position - part.Position).Magnitude
            if not best or distance < best then closest, best = part, distance end
        end
    end
    return closest
end
local function nearestMerchant()
    local root = playerRoot()
    if not root then return nil end
    local closest, best
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name = string.lower(obj.Name)
            if name == "buffalo bill" or name == "buffalobill" or name == "abigail" then
                local part = partFor(obj)
                if part then
                    local distance = (root.Position - part.Position).Magnitude
                    if not best or distance < best then closest, best = part, distance end
                end
            end
        end
    end
    return closest
end
local function moveNear(part, missing)
    if not checkGame() then return end
    local root = playerRoot()
    if not root then notify("Personaje no disponible."); return end
    if not part then notify(missing); return end
    root.CFrame = part.CFrame + Vector3.new(0, 4, 0)
    notify("Teletransporte local intentado; el servidor puede devolver tu personaje.")
end
local function tryCash()
    if not checkGame() then return end
    local remote = ReplicatedStorage:FindFirstChild("Purchase_Crate")
    if not remote or not remote:IsA("RemoteEvent") then
        notify("No se encontró Purchase_Crate; el método histórico puede estar parcheado.")
        return
    end
    local sent = pcall(function() remote:FireServer(-(state.amount / 120)) end)
    notify(sent and "Solicitud histórica enviada una vez. Comprueba tu saldo; no garantiza dinero." or "No se pudo enviar la solicitud.")
end
local function cleanup()
    if not active then return end
    active = false
    if heartbeat then heartbeat:Disconnect() end
    clearMarkers()
    visuals:Destroy()
    if not window.unloaded then pcall(function() window:Unload() end) end
    if env and env.DesertDetectorsUnload == cleanup then env.DesertDetectorsUnload = nil end
end
if env then env.DesertDetectorsUnload = cleanup end
local treasure = window:CreateTab({ name = "Tesoros" })
treasure:CreateToggle({ name = "ESP tesoros y nombre", description = "Marca objetos replicados en Workspace.Loot; no revela lo que no recibe el cliente.", value = false, callback = function(v) state.esp = v; if v then updateESP() else clearMarkers() end end })
treasure:CreateButton({ name = "Ir al tesoro cercano", description = "Solo objetos replicados; el servidor puede impedir el viaje.", callback = function() if checkGame() then moveNear(nearestLoot(), "No hay tesoros replicados con posición.") end end })
treasure:CreateButton({ name = "Diagnóstico", description = "Muestra si existe Loot y el remote histórico.", callback = function()
    if not checkGame() then return end
    local folder, remote = lootFolder(), ReplicatedStorage:FindFirstChild("Purchase_Crate")
    local count = folder and #folder:GetChildren() or 0
    local report = "Desert Detectors | PlaceId=" .. tostring(game.PlaceId) .. " | Loot=" .. tostring(folder ~= nil)
        .. " | objetos=" .. tostring(count) .. " | Purchase_Crate=" .. tostring(remote and remote:IsA("RemoteEvent") or false)
    print(report)
    if type(setclipboard) == "function" then pcall(setclipboard, report) end
    notify("Diagnóstico en consola/portapapeles. Objetos: " .. tostring(count) .. ".")
end })
local money = window:CreateTab({ name = "Dinero" })
money:CreateSlider({ name = "Cantidad solicitada (histórica)", range = { 1200, 120000 }, increment = 1200, value = 12000, callback = function(v)
    if type(v) == "number" and v == v then state.amount = math.clamp(v, 1200, 120000) end
end })
money:CreateButton({ name = "Intentar dinero (experimental)", description = "Método de 2025; podría estar parcheado o afectar el inventario. No garantiza dinero.", callback = tryCash })
money:CreateButton({ name = "Ir al vendedor cercano", description = "Busca Buffalo Bill o Abigail replicados para vender manualmente.", callback = function() if checkGame() then moveNear(nearestMerchant(), "No se encontró un vendedor replicado; acércate y vuelve a intentar.") end end })
local options = window:CreateTab({ name = "Opciones" })
options:CreateButton({ name = "Cerrar y limpiar", callback = cleanup })
heartbeat = RunService.Heartbeat:Connect(function(dt)
    if window.unloaded then cleanup(); return end
    elapsed = elapsed + dt
    if elapsed < 1 then return end
    elapsed = 0
    updateESP()
end)
notify(inGame() and "Cargado; el ESP y el dinero son experimentales." or "Entra en Desert Detectors de Diggin' Devs.")
