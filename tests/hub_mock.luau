-- Se inserta el script original u ofuscado en runHub para probar con mocks Luau.
local function signal()
    local e = { listeners = {} }
    function e:Connect(fn)
        local c = { connected = true }
        function c:Disconnect() self.connected = false end
        table.insert(self.listeners, { callback = fn, connection = c })
        return c
    end
    function e:Fire(...)
        for _, entry in ipairs(self.listeners) do
            if entry.connection.connected then entry.callback(...) end
        end
    end
    return e
end
local Vector3 = {}
local vectorMeta = {}
vectorMeta.__sub = function(a, b) return Vector3.new(a.X-b.X, a.Y-b.Y, a.Z-b.Z) end
vectorMeta.__index = function(v, k)
    if k == "Magnitude" then return math.sqrt(v.X*v.X + v.Y*v.Y + v.Z*v.Z) end
    if k == "Unit" then local n = v.Magnitude; return Vector3.new(v.X/n, v.Y/n, v.Z/n) end
    if k == "Dot" then return function(a,b) return a.X*b.X + a.Y*b.Y + a.Z*b.Z end end
end
function Vector3.new(x,y,z) return setmetatable({ X=x, Y=y, Z=z }, vectorMeta) end
local Color3 = { fromRGB = function(r,g,b) return { r=r, g=g, b=b } end }
local Enum = { HighlightDepthMode = { AlwaysOnTop = 1 } }
local marker
local Instance = {}
function Instance.new(class)
    assert(class == "Highlight")
    marker = {}
    function marker:Destroy() self.destroyed = true end
    return marker
end
local controls, messages = {}, {}
local window = { unloaded = false }
function window:CreateTab()
    return {
        CreateSection = function() end,
        CreateToggle = function(_, p) controls[p.name] = p.callback; return {} end,
        CreateSlider = function(_, p) controls[p.name] = p.callback; return {} end,
        CreateButton = function(_, p) controls[p.name] = p.callback end,
    }
end
function window:Notify(p) table.insert(messages, p) end
function window:Unload() self.unloaded = true end
local rayfield = { CreateWindow = function() return window end }
local loadstring = function() return function() return rayfield end end
local globals = {}
local getgenv = function() return globals end
local heartbeat = signal()
local t = 1
local os = { clock = function() return t end }
local root = { Position = Vector3.new(0,0,0), AssemblyLinearVelocity = Vector3.new(0,0,0) }
function root:IsA(name) return name == "BasePart" end
local humanoid = { Health = 100 }
local character = {}
function character:FindFirstChild(name) if name == "HumanoidRootPart" then return root end end
function character:FindFirstChildOfClass(name) if name == "Humanoid" then return humanoid end end
local player = { Name = "dj", Character = character }
function player:WaitForChild(name) assert(name == "PlayerGui"); return {} end
local ball = { Position = Vector3.new(0,0,100), AssemblyLinearVelocity = Vector3.new(0,0,-100), attrs = { realBall=true, target="other" } }
function ball:IsA(name) return name == "BasePart" end
function ball:GetAttribute(name) return self.attrs[name] end
function ball:FindFirstChild() return nil end
local folder = { children = {ball} }
function folder:GetChildren() return self.children end
local workspace = { FindFirstChild = function(_, name) if name == "Balls" then return folder end end }
local parries = 0
local button = { IsA = function(_, name) return name == "BindableEvent" end, Fire = function() parries = parries + 1 end }
local remotes = { FindFirstChild = function(_, name) if name == "ParryButtonPress" then return button end end }
local storage = { FindFirstChild = function(_, name) if name == "Remotes" then return remotes end end }
local players = { LocalPlayer = player }
local runService = { Heartbeat = heartbeat }
local game = { GameId = 4777817887, PlaceId = 13772394625 }
function game:GetService(name)
    if name == "Players" then return players end
    if name == "RunService" then return runService end
    if name == "Workspace" then return workspace end
    if name == "ReplicatedStorage" then return storage end
    error("unsupported service " .. name)
end
function game:HttpGet(url) assert(url == "https://sirius.menu/gen2"); return "rayfield" end
local function runHub()
-- INSERT_SOURCE_HERE
end
runHub()
assert(type(globals.BladeBallUnload) == "function")
controls["Auto parry"](true)
controls["Resaltar pelota real"](true)
heartbeat:Fire()
assert(parries == 0 and marker.Adornee == ball and marker.Enabled and marker.FillColor.b == 255)
ball.attrs.target = "dj"
heartbeat:Fire() -- far away, time-to-impact is one second
assert(parries == 0 and marker.FillColor.r == 255)
ball.Position = Vector3.new(0,0,30)
heartbeat:Fire()
assert(parries == 1) -- within lead time
heartbeat:Fire()
assert(parries == 1) -- no repeated firing while same ball is incoming
t = t + 0.6
ball.AssemblyLinearVelocity = Vector3.new(0,0,100)
heartbeat:Fire() -- moving away rearms only after departure
assert(parries == 1)
ball.AssemblyLinearVelocity = Vector3.new(0,0,-100)
heartbeat:Fire()
assert(parries == 2)
ball.attrs.target = "other"
heartbeat:Fire()
t = t + 0.6
ball.attrs.target = "dj"
heartbeat:Fire()
assert(parries == 3) -- target change rearms
folder.children = {}
heartbeat:Fire()
assert(not marker.Enabled)
folder.children = {ball}
game.GameId = 1; game.PlaceId = 1
t = t + 1
heartbeat:Fire()
assert(parries == 3 and not marker.Enabled)
game.GameId = 4777817887
controls["Auto parry"](false)
heartbeat:Fire()
assert(parries == 3)
controls["Probar bloqueo"]()
assert(parries == 4)
controls["Cerrar y limpiar"]()
assert(window.unloaded and marker.destroyed and globals.BladeBallUnload == nil)
heartbeat:Fire()
assert(parries == 4)
print("OK: parry, velocidad, debounce, visualizador y limpieza")
