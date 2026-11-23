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
local clipboard
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
    local m = { Name = name, ClassName = "Model", PrimaryPart = part(x), rarity = rarity }
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
crate.Name, crate.ClassName = "Purchase_Crate", "RemoteEvent"
function crate:GetFullName() return "ReplicatedStorage.Purchase_Crate" end
local storage = { crate = crate }
function storage:GetDescendants() if self.crate then return {self.crate} else return {} end end
function storage:FindFirstChild(n) if n == "Purchase_Crate" then return self.crate end end
local a, b = model("Fossil", 10, "Rare"), model("Bottle", 5)
local nested = { Name = "Deep", ClassName = "Folder", items = { b } }
function nested:IsA(c) return c == "Folder" end
function nested:GetChildren() return self.items end
for i = 1, 80 do table.insert(nested.items, model("Treasure" .. i, i + 100)) end
local loot = { Name = "Loot", ClassName = "Folder", items = { a, nested } }
function loot:IsA(c) return c == "Folder" end
function loot:GetChildren() return self.items end
local merchant = model("Buffalo Bill", 20)
local world = { loot = loot }
function world:FindFirstChild(n) if n == "Loot" then return self.loot elseif n == "Treasures" then return self.alt end end
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
e.setclipboard = function(s) clipboard = s end
runHub()
assert(type(env.DesertDetectorsUnload) == "function")
controls["ESP tesoros y nombre"](true)
-- 82 objetos, incluyendo los anidados: no existe el antiguo límite de 60.
assert(#created == 165 and created[2].Adornee == a.PrimaryPart)
assert(string.find(created[3].Text, "Fossil") and string.find(created[3].Text, "Rare"))
assert(string.find(created[5].Text, "Bottle") and string.find(created[5].Text, "5 studs"))
assert(created[2].MaxDistance == 1000000)
controls["Ir al tesoro cercano"](); assert(root.CFrame.x == 5 and root.CFrame.y == 4)
controls["Ir al vendedor cercano"](); assert(root.CFrame.x == 20)
assert(controls["Intentar dinero (experimental)"] == nil and #calls == 0)
controls["Diagnóstico"](); assert(string.find(messages[#messages], "Objetos: 82"))
assert(string.find(clipboard, "Purchase_Crate", 1, true) and string.find(clipboard, "Loot", 1, true))
nested.items = { b }; heartbeat:Fire(1)
assert(created[6].destroyed and not created[4].destroyed)
world.loot = nil; heartbeat:Fire(1); assert(created[2].destroyed and created[4].destroyed)
controls["Ir al tesoro cercano"](); assert(string.find(messages[#messages], "No hay"))
world.alt = { Name = "Treasures", ClassName = "Folder", items = { b } }
function world.alt:IsA(c) return c == "Folder" end
function world.alt:GetChildren() return self.items end
heartbeat:Fire(1); assert(#created == 167 and created[166].Adornee == b.PrimaryPart)
world.alt = nil; world.loot = loot; game.PlaceId = 1; controls["Ir al tesoro cercano"](); assert(#calls == 0)
game.PlaceId = 86161665059642; controls["ESP tesoros y nombre"](true); assert(#created == 169)
controls["ESP tesoros y nombre"](false); assert(created[166].destroyed and created[168].destroyed)
controls["Cerrar y limpiar"](); assert(window.unloaded and env.DesertDetectorsUnload == nil and created[1].destroyed)
heartbeat:Fire(1); controls["Ir al tesoro cercano"](); assert(#calls == 0)
print("OK: 82 tesoros, subcarpetas, nombres, viaje, diagnóstico y limpieza")
