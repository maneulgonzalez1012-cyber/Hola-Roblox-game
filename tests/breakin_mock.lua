-- Plantilla para pruebas: el script se inserta en runHub por tools/test_breakin.py.
local callbacks, messages, visuals, requests = {}, {}, {}, {}
local heartbeat = { callbacks = {} }
function heartbeat:Connect(fn)
    local c = { active = true }
    function c:Disconnect() self.active = false end
    table.insert(self.callbacks, { fn = fn, connection = c })
    return c
end
function heartbeat:Fire(dt)
    for _, v in ipairs(self.callbacks) do if v.connection.active then v.fn(dt) end end
end
local vec = {}
vec.__sub = function(a, b) return setmetatable({ x = a.x-b.x, y = a.y-b.y, z = a.z-b.z }, vec) end
vec.__index = function(v, k) if k == "Magnitude" then return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z) end end
local function position(x,y,z) return setmetatable({x=x,y=y,z=z},vec) end
local Enum = { HighlightDepthMode = { AlwaysOnTop = 1 } }
local Color3 = { fromRGB = function(r,g,b) return {r,g,b} end }
local CFrame = { new = function(x,y,z) return {x=x,y=y,z=z} end }
local Instance = {}
function Instance.new(class)
    local obj = { class = class }
    function obj:Destroy() self.destroyed = true end
    table.insert(visuals, obj)
    return obj
end
local window = { unloaded = false }
function window:CreateTab()
    return {
        CreateSection = function() end,
        CreateToggle = function(_, p) callbacks[p.name] = p.callback end,
        CreateSlider = function(_, p) callbacks[p.name] = p.callback end,
        CreateDropdown = function(_, p) callbacks[p.name] = p.callback end,
        CreateButton = function(_, p) callbacks[p.name] = p.callback end,
    }
end
function window:Notify(p) table.insert(messages,p) end
function window:Unload() self.unloaded = true end
local rayfield = { CreateWindow = function() return window end }
local loadstring = function() return function() return rayfield end end
local globals = {}
local getgenv = function() return globals end
local root = { Position = position(0,0,0) }
function root:IsA(n) return n == "BasePart" end
local humanoid = { Health = 100 }
local character = {}
function character:FindFirstChild(n) if n == "HumanoidRootPart" then return root end end
function character:FindFirstChildOfClass(n) if n == "Humanoid" then return humanoid end end
local player = { Character = character }
function player:WaitForChild() return {} end
local function enemy(distance)
    local part = { Position = position(distance,0,0), IsA = function(_,n) return n == "BasePart" end }
    local npc = { humanoid = { Health = 100 } }
    function npc:IsA(n) return n == "Model" end
    function npc:FindFirstChild(n) if n == "HumanoidRootPart" then return part end end
    function npc:FindFirstChildOfClass(n) if n == "Humanoid" then return self.humanoid end end
    return npc
end
local near, far = enemy(10), enemy(20)
local group = { GetChildren = function() return { far, near } end }
local label = { Text = "1234", IsA = function(_,n) return n == "TextLabel" end }
local gui = { FindFirstChild = function(_,n) if n == "TextLabel" then return label end end }
local note = { FindFirstChild = function(_,n) if n == "SurfaceGui" then return gui end end }
local world = {}
function world:FindFirstChild(n) if n == "BadGuys" then return group end; if n == "CodeNote" then return note end end
local events = {}
function events:FindFirstChild(name)
    if name == "Missing" then return nil end
    return { IsA = function(_, n) return n == "RemoteEvent" end,
        FireServer = function(_, ...) table.insert(requests,{name=name,args={...}}) end }
end
local storage = { FindFirstChild = function(_,n) if n == "RemoteEvents" then return events end end }
local game = { GameId = 1318971886, PlaceId = 3851622790 }
function game:GetService(name)
    if name == "Players" then return { LocalPlayer = player } end
    if name == "RunService" then return { Heartbeat = heartbeat } end
    if name == "ReplicatedStorage" then return storage end
    if name == "Workspace" then return world end
    error(name)
end
function game:HttpGet(url) assert(url == "https://sirius.menu/gen2"); return "rayfield" end
local function runHub()
-- INSERT_SOURCE_HERE
end
runHub()
assert(type(globals.BreakInHubUnload) == "function")
heartbeat:Fire(1); assert(#requests == 0)
callbacks["Auto ataque"](true)
heartbeat:Fire(0.5)
assert(#requests == 1 and requests[1].name == "HitBadguy" and requests[1].args[1] == near and requests[1].args[2] == 10)
callbacks["Alcance"](5)
heartbeat:Fire(0.5); assert(#requests == 1)
callbacks["Resaltar enemigos"](true)
heartbeat:Fire(0.2); assert(#visuals == 3 and not visuals[2].destroyed)
callbacks["Resaltar enemigos"](false)
heartbeat:Fire(0.2); assert(visuals[2].destroyed and visuals[3].destroyed)
callbacks["Objeto"]("MedKit")
callbacks["Solicitar objeto"]()
assert(requests[2].name == "GiveTool" and requests[2].args[1] == "MedKit")
callbacks["Solicitar apertura de caja"]()
assert(requests[3].name == "Safe" and requests[3].args[1] == "1234")
callbacks["Casa"]()
assert(root.CFrame.x == -36 and root.CFrame.z == -200)
game.GameId = 1; game.PlaceId = 1
callbacks["Solicitar objeto"](); heartbeat:Fire(1)
assert(#requests == 3)
callbacks["Cerrar y limpiar"]()
assert(window.unloaded and visuals[1].destroyed and globals.BreakInHubUnload == nil)
heartbeat:Fire(1); assert(#requests == 3)
print("OK: combate, alcance, objetos, caja, viaje y limpieza")
