-- Mocks de cliente: no demuestran comportamiento del servidor Roblox.
local function signal()
    local callbacks = {}
    return {
        Connect = function(_, fn)
            local c = { active = true }
            function c:Disconnect() self.active = false end
            table.insert(callbacks, { fn = fn, c = c })
            return c
        end,
        Fire = function(_, ...) for _, c in ipairs(callbacks) do if c.c.active then c.fn(...) end end end,
    }
end
local controls, messages, created, calls = {}, {}, {}, {}
local window = { unloaded = false }
function window:CreateTab()
    return {
        CreateButton = function(_, p) controls[p.name] = p.callback end,
        CreateSlider = function(_, p) controls[p.name] = p.callback end,
        CreateToggle = function(_, p) controls[p.name] = p.callback end,
    }
end
function window:Notify(p) table.insert(messages, p.content) end
function window:Unload() self.unloaded = true end
local loadstring = function() return function() return { CreateWindow = function() return window end } end end
local env = {}
local getgenv = function() return env end
local vecmt = {}
vecmt.__sub = function(a, b) local x = a.x - b.x; return { Magnitude = math.abs(x) } end
local Vector3 = { new = function(x, y, z) return setmetatable({ x = x, y = y, z = z }, vecmt) end }
local cfmeta = { __add = function(a, b) return { x = a.x + b.x, y = a.y + b.y, z = a.z + b.z } end }
local function part(x)
    local p = { Position = Vector3.new(x, 0, 0), CFrame = setmetatable({ x = x, y = 0, z = 0 }, cfmeta) }
    function p:IsA(c) return c == "BasePart" end
    return p
end
local function model(name, x, rarity)
    local m = { Name = name, PrimaryPart = part(x), rarity = rarity }
    function m:IsA(c) return c == "Model" end
    function m:FindFirstChildWhichIsA(c) if c == "BasePart" then return self.PrimaryPart end end
    function m:GetAttribute(n) if n == "Rarity" then return self.rarity end end
    return m
end
local root = part(0)
local character = {}
function character:FindFirstChild(n) if n == "HumanoidRootPart" then return root end end
local me = { Character = character }
function me:WaitForChild(n) assert(n == "PlayerGui"); return {} end
local crate = { class = "RemoteEvent" }
function crate:IsA(c) return c == self.class end
function crate:FireServer(v) table.insert(calls, v) end
local storage = { crate = crate }
function storage:FindFirstChild(n) if n == "Purchase_Crate" then return self.crate end end
local a, b = model("Fossil", 10, "Rare"), model("Bottle", 5)
local loot = { items = { a, b } }
function loot:GetChildren() return self.items end
local merchant = model("Buffalo Bill", 20)
local world = { loot = loot }
function world:FindFirstChild(n) if n == "Loot" then return self.loot end end
function world:GetDescendants() return { merchant } end
local heartbeat = signal()
local game = { PlaceId = 73010525850196 }
function game:GetService(n)
    if n == "Players" then return { LocalPlayer = me } elseif n == "Workspace" then return world
    elseif n == "ReplicatedStorage" then return storage elseif n == "RunService" then return { Heartbeat = heartbeat } end
    error(n)
end
function game:HttpGet(url) assert(url == "https://sirius.menu/gen2"); return "rayfield" end
local Instance = {}
function Instance.new(class)
    local v = { class = class }
    function v:Destroy() self.destroyed = true end
    table.insert(created, v)
    return v
end
local Color3 = { fromRGB = function(r,g,b) return {r,g,b} end }
local UDim2 = { new = function(...) return {...} end }
local Enum = { HighlightDepthMode = { AlwaysOnTop = 1 }, Font = { GothamBold = 1 } }
local function runHub(...)
-- INSERT_SOURCE_HERE
end
local e = getfenv(runHub)
e.game, e.Instance, e.Color3, e.UDim2, e.Vector3, e.Enum = game, Instance, Color3, UDim2, Vector3, Enum
e.loadstring, e.getgenv = loadstring, getgenv
runHub()
assert(type(env.DesertDetectorsUnload) == "function")
controls["ESP tesoros y nombre"](true)
assert(#created == 7 and created[2].Adornee == a and created[5].Adornee == b)
assert(string.find(created[4].Text, "Fossil") and string.find(created[4].Text, "Rare"))
assert(string.find(created[7].Text, "Bottle") and string.find(created[7].Text, "5 studs"))
controls["Ir al tesoro cercano"](); assert(root.CFrame.x == 5 and root.CFrame.y == 4)
controls["Ir al vendedor cercano"](); assert(root.CFrame.x == 20)
controls["Cantidad solicitada (histórica)"](24000)
controls["Intentar dinero (experimental)"](); assert(#calls == 1 and calls[1] == -200)
assert(string.find(messages[#messages], "no garantiza"))
controls["Cantidad solicitada (histórica)"](math.huge)
controls["Intentar dinero (experimental)"](); assert(#calls == 2 and calls[2] == -1000)
storage.crate = nil; controls["Intentar dinero (experimental)"](); assert(#calls == 2 and string.find(messages[#messages], "parcheado"))
storage.crate = crate; crate.class = "RemoteFunction"; controls["Intentar dinero (experimental)"](); assert(#calls == 2)
crate.class = "RemoteEvent"
loot.items = { b }; heartbeat:Fire(1); assert(created[2].destroyed and created[3].destroyed and not created[5].destroyed)
controls["Diagnóstico"](); assert(string.find(messages[#messages], "Objetos: 1"))
world.loot = nil; heartbeat:Fire(1); assert(created[5].destroyed and created[6].destroyed)
controls["Ir al tesoro cercano"](); assert(string.find(messages[#messages], "No hay"))
world.loot = loot; game.PlaceId = 1; controls["Intentar dinero (experimental)"](); assert(#calls == 2)
game.PlaceId = 86161665059642; controls["ESP tesoros y nombre"](true); assert(#created == 10)
controls["ESP tesoros y nombre"](false); assert(created[8].destroyed and created[9].destroyed)
controls["Cerrar y limpiar"](); assert(window.unloaded and env.DesertDetectorsUnload == nil and created[1].destroyed)
heartbeat:Fire(1); controls["Intentar dinero (experimental)"](); assert(#calls == 2)
print("OK: ESP, nombres, rareza, proximidad, cash histórico, guardas y limpieza")
