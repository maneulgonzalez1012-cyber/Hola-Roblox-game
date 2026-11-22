-- Test fixture: tools/test_obfuscation.py inserts the script into runHub below.
local function signal()
    local event = { listeners = {} }
    function event:Connect(fn)
        local connection = { connected = true }
        function connection:Disconnect() self.connected = false end
        table.insert(self.listeners, { fn = fn, connection = connection })
        return connection
    end
    function event:Fire(...)
        for _, listener in ipairs(self.listeners) do
            if listener.connection.connected then listener.fn(...) end
        end
    end
    return event
end

local Vector3 = {}
local vectorMeta = { __sub = function(a, b) return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end }
function Vector3.new(x, y, z) return setmetatable({ X = x, Y = y, Z = z }, vectorMeta) end
local RaycastParams = { new = function() return {} end }
local CFrame = { lookAt = function(position, target) return { Position = position, target = target } end }
local Color3 = { fromRGB = function(r, g, b) return { r, g, b } end }
local UDim2 = { fromOffset = function() return {} end, fromScale = function() return {} end }
local Enum = { HighlightDepthMode = { AlwaysOnTop = 1 }, Font = { GothamBold = 1 }, RaycastFilterType = { Exclude = 1 } }
local instances = {}
local Instance = {}
function Instance.new(class)
    local obj = { ClassName = class, Enabled = true }
    function obj:Destroy() self.destroyed = true end
    table.insert(instances, obj)
    return obj
end
local controls = {}
local window = { unloaded = false }
function window:CreateTab(props)
    return {
        CreateSection = function() end,
        CreateToggle = function(_, p) controls[p.name] = p.callback end,
        CreateSlider = function(_, p) controls[p.name] = p.callback end,
        CreateDropdown = function(_, p) controls[p.name] = p.callback end,
        CreateColorPicker = function(_, p) controls[p.name] = p.callback end,
        CreateButton = function(_, p) controls[p.name] = p.callback end,
    }
end
function window:Notify() end
function window:Unload() self.unloaded = true end
local rayfield = { CreateWindow = function() return window end }
local loadstring = function() return function() return rayfield end end
local globals = {}
local getgenv = function() return globals end
local heartbeat, removing = signal(), signal()
local own = { Neutral = false, Team = "red", Character = nil }
function own:WaitForChild() return {} end
local root = { Size = Vector3.new(2, 2, 1), Transparency = 1, CanCollide = true }
function root:IsA(name) return name == "BasePart" end
local humanoid = { Health = 100 }
local character = {}
function character:FindFirstChildOfClass(name) return name == "Humanoid" and humanoid end
function character:FindFirstChild(name) return name == "HumanoidRootPart" and root or nil end
local target = { Name = "Target", DisplayName = "Target", Neutral = false, Team = "blue", Character = character }
local players = { LocalPlayer = own, PlayerRemoving = removing }
function players:GetPlayers() return { own, target } end
local runService = { Heartbeat = heartbeat }
local camera = { CFrame = { Position = Vector3.new(0, 0, 0) }, ViewportSize = setmetatable({ X = 800, Y = 600 }, { __div = function(v, n) return { X = v.X / n, Y = v.Y / n } end }) }
function camera:WorldToViewportPoint() return { X = 400, Y = 300, Z = 10 }, true end
local world = { CurrentCamera = camera, blocked = false }
function world:Raycast() if self.blocked then return { Instance = { IsDescendantOf = function() return false end } } end end
local requests = {}
local remote = { IsA = function(_, name) return name == "RemoteEvent" end }
function remote:FireServer(...) table.insert(requests, { ... }) end
local events = { available = true }
function events:FindFirstChild(name) if self.available and name == "orbEvent" then return remote end end
local storage = { FindFirstChild = function(_, name) if name == "rEvents" then return events end end }
local game = { PlaceId = 122446657157717 }
function game:GetService(name)
    if name == "Players" then return players end
    if name == "Workspace" then return world end
    if name == "ReplicatedStorage" then return storage end
    return runService
end
function game:HttpGet(url) assert(url == "https://sirius.menu/gen2"); return "rayfield" end
local function runHub()
-- INSERT_SOURCE_HERE
end
runHub()
assert(type(globals.HolaHubUnload) == "function")
controls["Activar ESP"](true)
heartbeat:Fire(0.2)
local highlight
for _, object in ipairs(instances) do
    if object.ClassName == "Highlight" then highlight = object end
end
assert(highlight and highlight.Enabled and highlight.Adornee == character)
controls["Activar expansor"](true)
controls["Tamaño"](12)
controls["Transparencia"](0.4)
heartbeat:Fire(0.2)
assert(root.Size.X == 12 and root.Size.Y == 12 and root.Transparency == 0.4 and root.CanCollide == false)
target.Team = "red"
heartbeat:Fire(0.2)
assert(root.Size.X == 2 and root.Size.Z == 1 and root.Transparency == 1 and root.CanCollide == true)
assert(highlight.destroyed)
target.Team = "blue"
heartbeat:Fire(0.2)
assert(root.Size.X == 12)

local head = { Position = Vector3.new(1, 2, 20), IsA = function(_, name) return name == "BasePart" end }
function character:FindFirstChild(name)
    if name == "Head" then return head end
    if name == "HumanoidRootPart" then return root end
end
local shots = 0
local tool = { Activate = function() shots = shots + 1 end }
own.Character = {
    FindFirstChildOfClass = function(_, name)
        if name == "Humanoid" then return { Health = 100 } end
        if name == "Tool" then return tool end
    end,
    FindFirstChild = function() return nil end,
}
controls["Auto disparo"](true)
heartbeat:Fire(0.5)
assert(shots == 1 and camera.CFrame.target == head.Position)
world.blocked = true
heartbeat:Fire(0.5)
assert(shots == 1)
world.blocked = false
target.Team = "red"
heartbeat:Fire(0.5)
assert(shots == 1)
target.Team = "blue"
game.PlaceId = 1
heartbeat:Fire(0.5)
assert(shots == 1)
game.PlaceId = 122446657157717
controls["Auto disparo"](false)
heartbeat:Fire(0.5)
assert(shots == 1)

controls["Auto orbes rojos"](true)
controls["Auto gemas"](true)
heartbeat:Fire(1)
assert(#requests == 0) -- No requests outside Legends of Speed.
game.PlaceId = 3101667897
heartbeat:Fire(0.5)
assert(#requests == 2 and requests[1][1] == "collectOrb" and requests[1][2] == "Red Orb" and requests[1][3] == "City")
assert(requests[2][2] == "Gem" and requests[2][3] == "City")
events.available = false
heartbeat:Fire(0.5)
assert(#requests == 2)
events.available = true
controls["Zona de recolección"]("Snow City")
controls["Auto orbes rojos"](false)
heartbeat:Fire(0.5)
assert(#requests == 3 and requests[3][2] == "Gem" and requests[3][3] == "Snow City")
controls["Auto gemas"](false)
heartbeat:Fire(1)
assert(#requests == 3)
controls["Cerrar y restaurar"]()
heartbeat:Fire(1)
assert(#requests == 3)
assert(root.Size.X == 2 and root.Transparency == 1 and root.CanCollide == true)
assert(window.unloaded and globals.HolaHubUnload == nil)
print("OK: ESP, hitbox, auto disparo, auto recolección, equipos y restauración")
