-- La prueba inserta el script en runHub y ejecuta fuente y distribución en Luau.
local function signal()
    local listeners = {}
    return {
        Connect = function(_, fn)
            local c = { active = true }
            function c:Disconnect() self.active = false end
            table.insert(listeners, { fn = fn, connection = c })
            return c
        end,
        Fire = function(_, ...)
            for _, v in ipairs(listeners) do if v.connection.active then v.fn(...) end end
        end,
    }
end
local vec = {}
vec.__sub = function(a, b) return setmetatable({ X = a.X-b.X, Y = a.Y-b.Y, Z = a.Z-b.Z }, vec) end
vec.__index = function(a, key) if key == "Magnitude" then return math.sqrt(a.X*a.X + a.Y*a.Y + a.Z*a.Z) end end
local Vector3 = { new = function(x, y, z) return setmetatable({ X=x, Y=y, Z=z }, vec) end }
local Color3 = { fromRGB = function(r,g,b) return {r,g,b} end }
local UDim2 = { new = function(...) return {...} end }
local Enum = { HighlightDepthMode = { AlwaysOnTop = 1 } }
local objects = {}
local Instance = {}
function Instance.new(class)
    local item = { class = class }
    function item:Destroy() self.destroyed = true end
    table.insert(objects, item)
    return item
end
local controls = {}
local window = { unloaded = false }
function window:CreateTab()
    return {
        CreateToggle = function(_, p) controls[p.name] = p.callback end,
        CreateSlider = function(_, p) controls[p.name] = p.callback end,
        CreateButton = function(_, p) controls[p.name] = p.callback end,
    }
end
function window:Notify() end
function window:Unload() self.unloaded = true end
local library = { CreateWindow = function() return window end }
local loadstring = function() return function() return library end end
local globals = {}
local getgenv = function() return globals end
local function character(x, health)
    local root = { Position = Vector3.new(x,0,0), Size = Vector3.new(2,2,1), Transparency = 1, CanCollide = true }
    function root:IsA(name) return name == "BasePart" end
    local hum = { Health = health }
    local model = { root = root, hum = hum }
    function model:FindFirstChild(name) if name == "HumanoidRootPart" then return self.root end end
    function model:FindFirstChildOfClass(name) if name == "Humanoid" then return self.hum end end
    return model
end
local me = { Name = "dj", Character = character(0,100), Team = "blue", Neutral = false }
function me:WaitForChild(name) assert(name == "PlayerGui"); return {} end
local enemy = { Name = "opponent", Character = character(20,80), Team = "red", Neutral = false }
local ally = { Name = "ally", Character = character(30,100), Team = "blue", Neutral = false }
local neutral = { Name = "neutral", Character = character(700,100), Neutral = true }
local players = { LocalPlayer = me, list = { me, enemy, ally, neutral } }
function players:GetPlayers() return self.list end
local heartbeat = signal()
local game = {}
function game:GetService(name)
    if name == "Players" then return players end
    if name == "RunService" then return { Heartbeat = heartbeat } end
    error(name)
end
function game:HttpGet(url) assert(url == "https://sirius.menu/gen2"); return "rayfield" end
local function runHub(...)
-- INSERT_SOURCE_HERE
end
local environment = getfenv(runHub)
environment.game, environment.Instance, environment.Enum = game, Instance, Enum
environment.Color3, environment.Vector3, environment.UDim2 = Color3, Vector3, UDim2
environment.loadstring, environment.getgenv = loadstring, getgenv
runHub()
assert(type(globals.VantaPlayersUnload) == "function")
heartbeat:Fire(1); assert(#objects == 1 and enemy.Character.root.Size.X == 2)
controls["Hitbox expander"](true); controls["ESP jugadores"](true)
heartbeat:Fire(0.25)
local root = enemy.Character.root
assert(root.Size.X == 10 and root.Transparency == 0.75 and root.CanCollide == false)
assert(ally.Character.root.Size.X == 2 and neutral.Character.root.Size.X == 2)
assert(#objects == 4 and objects[2].Adornee == enemy.Character and objects[3].Adornee == root)
assert(objects[4].Text == "opponent | 80 HP | 20 studs")
controls["Tamaño hitbox"](24); controls["Transparencia hitbox"](0.4)
heartbeat:Fire(0.25); assert(root.Size.X == 24 and root.Transparency == 0.4)
controls["Ignorar equipo"](false); controls["Distancia máxima"](1000)
heartbeat:Fire(0.25); assert(ally.Character.root.Size.X == 24 and neutral.Character.root.Size.X == 24)
controls["Ignorar equipo"](true); controls["Distancia máxima"](50)
heartbeat:Fire(0.25); assert(ally.Character.root.Size.X == 2 and neutral.Character.root.Size.X == 2)
local oldMarker = objects[2]
enemy.Character = character(10, 45)
heartbeat:Fire(0.25)
assert(root.Size.X == 2 and root.Transparency == 1 and root.CanCollide == true and oldMarker.destroyed)
local fresh = enemy.Character.root
assert(fresh.Size.X == 24 and objects[#objects].Text == "opponent | 45 HP | 10 studs")
enemy.Character.hum.Health = 0
heartbeat:Fire(0.25); assert(fresh.Size.X == 2 and objects[#objects].Parent.destroyed)
enemy.Character.hum.Health = 50
heartbeat:Fire(0.25); assert(fresh.Size.X == 24)
players.list = { me, ally, neutral }
heartbeat:Fire(0.25); assert(fresh.Size.X == 2)
players.list = { me, enemy }
heartbeat:Fire(0.25); assert(fresh.Size.X == 24)
me.Character = nil
heartbeat:Fire(0.25); assert(fresh.Size.X == 2)
me.Character = character(0,100)
heartbeat:Fire(0.25); assert(fresh.Size.X == 24)
controls["Hitbox expander"](false); assert(fresh.Size.X == 2 and fresh.CanCollide)
controls["ESP jugadores"](false); assert(objects[#objects-2].destroyed and objects[#objects-1].destroyed)
controls["Hitbox expander"](true); controls["ESP jugadores"](true)
heartbeat:Fire(0.25); assert(fresh.Size.X == 24)
controls["Cerrar y limpiar"]()
assert(fresh.Size.X == 2 and fresh.Transparency == 1 and fresh.CanCollide)
assert(window.unloaded and objects[1].destroyed and globals.VantaPlayersUnload == nil)
heartbeat:Fire(1); assert(fresh.Size.X == 2)
print("OK: ESP, hitbox, equipos, distancia, respawn y limpieza")
