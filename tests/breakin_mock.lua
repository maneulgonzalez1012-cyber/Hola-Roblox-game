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
local Enum = { HighlightDepthMode = { AlwaysOnTop = 1 }, HumanoidStateType = { Jumping = "Jumping" } }
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
local humanoid = { Health = 100, MaxHealth = 100, WalkSpeed = 16, JumpPower = 50, UseJumpPower = false }
function humanoid:ChangeState(state) self.lastState = state end
local jump = { callbacks = {} }
function jump:Connect(fn)
    local c = { active = true }
    function c:Disconnect() self.active = false end
    table.insert(self.callbacks, { fn = fn, connection = c })
    return c
end
function jump:Fire() for _, v in ipairs(self.callbacks) do if v.connection.active then v.fn() end end end
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
local events = { unavailable = false }
function events:FindFirstChild(name)
    if self.unavailable or name == "Missing" then return nil end
    return { IsA = function(_, n) return n == "RemoteEvent" end,
        FireServer = function(_, ...) table.insert(requests,{name=name,args={...}}) end }
end
local storage = { FindFirstChild = function(_,n) if n == "RemoteEvents" then return events end end }
local other = { Name = "Other" }
local players = { LocalPlayer = player }
function players:GetPlayers() return { player, other } end
local game = { GameId = 1318971886, PlaceId = 3851622790 }
function game:GetService(name)
    if name == "Players" then return players end
    if name == "RunService" then return { Heartbeat = heartbeat } end
    if name == "UserInputService" then return { JumpRequest = jump } end
    if name == "ReplicatedStorage" then return storage end
    if name == "Workspace" then return world end
    error(name)
end
function game:HttpGet(url) assert(url == "https://sirius.menu/gen2"); return "rayfield" end
local function runHub(...)
-- INSERT_SOURCE_HERE
end
-- Prometheus resolves Roblox globals from the Luau function environment.
local environment = getfenv(runHub)
environment.game = game
environment.Instance = Instance
environment.Enum = Enum
environment.Color3 = Color3
environment.CFrame = CFrame
environment.loadstring = loadstring
environment.getgenv = getgenv
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
-- Un enemigo muerto se ignora; si faltan remotes no se envía y se avisa.
callbacks["Alcance"](30)
near.humanoid.Health = 0
heartbeat:Fire(0.5)
assert(#requests == 4 and requests[4].args[1] == far)
events.unavailable = true
local oldMessages = #messages
heartbeat:Fire(0.5)
assert(#requests == 4 and #messages == oldMessages + 1)
heartbeat:Fire(0.5)
assert(#messages == oldMessages + 1) -- sin spam de avisos
events.unavailable = false
player.Character = nil
heartbeat:Fire(0.5)
assert(#requests == 4)
player.Character = character
callbacks["Auto ataque"](false)
heartbeat:Fire(1)
assert(#requests == 4)
requests = {}
local function expect(button, name, ...)
    local previous = #requests
    callbacks[button]()
    assert(#requests == previous + 1 and requests[#requests].name == name, button)
    local args = {...}
    for i, v in ipairs(args) do assert(requests[#requests].args[i] == v, button .. " arg " .. i) end
end
for _, item in ipairs({ "Pizza", "Pizza2", "Pizza3", "EpicPizza", "Cure", "LinkedSword", "Lollipop", "Sword", "Gun", "Pan", "Pie" }) do
    callbacks["Objeto"](item); expect("Solicitar objeto", "GiveTool", item)
end
expect("Solicitar energía", "Energy", "Cat")
expect("Intentar amistad con el gato", "Cattery")
expect("Solicitar paquete de cola", "BloxyPack", 1)
expect("Solicitar sartén de tienda", "BuyItem", "Pan", 0)
expect("Solicitar martillo del sótano", "BasementWeapon", true, "Hammer")
expect("Solicitar rol policía", "OutsideRole", "Gun", true)
expect("Solicitar rol SWAT", "OutsideRole", "SwatGun", true)
expect("Intentar curarme con botiquín", "HealPlayer", player)
expect("Solicitar desbloqueo de puerta", "UnlockDoor")
expect("Solicitar diálogo 244", "DoDialogue", 244, true)
local before = #requests
callbacks["Intentar curar a todos"]()
assert(#requests == before + 2 and requests[before+1].args[1] == player and requests[before+2].args[1] == other)
callbacks["Alcantarilla"](); assert(root.CFrame.x == 129 and root.CFrame.z == -125)
callbacks["Velocidad personalizada"](true); callbacks["Velocidad"](42)
callbacks["Salto personalizado"](true); callbacks["Potencia de salto"](100)
assert(humanoid.WalkSpeed == 42 and humanoid.JumpPower == 100 and humanoid.UseJumpPower)
callbacks["Salto infinito"](true); jump:Fire(); assert(humanoid.lastState == "Jumping")
callbacks["Velocidad personalizada"](false); callbacks["Salto personalizado"](false)
assert(humanoid.WalkSpeed == 16 and humanoid.JumpPower == 50 and humanoid.UseJumpPower == false)
callbacks["Auto energía"](true); humanoid.Health = 50
before = #requests
heartbeat:Fire(2); assert(#requests == before)
heartbeat:Fire(1); assert(#requests == before + 1 and requests[#requests].name == "Energy" and requests[#requests].args[1] == "Cat")
humanoid.Health = 100; heartbeat:Fire(3); assert(#requests == before + 1)
humanoid.Health = 50; events.unavailable = true
local lastMessages = #messages
heartbeat:Fire(3); heartbeat:Fire(3); assert(#messages == lastMessages + 1 and #requests == before + 1)
events.unavailable = false; callbacks["Auto energía"](false)
callbacks["Velocidad personalizada"](true); callbacks["Salto personalizado"](true)
game.GameId = 1; game.PlaceId = 1
before = #requests
callbacks["Solicitar objeto"](); callbacks["Intentar curar a todos"](); heartbeat:Fire(3)
assert(#requests == before and humanoid.WalkSpeed == 16 and humanoid.JumpPower == 50)
humanoid.lastState = nil; jump:Fire(); assert(humanoid.lastState == nil)
game.GameId = 1318971886; game.PlaceId = 3851622790
heartbeat:Fire(0.2); assert(humanoid.WalkSpeed == 42 and humanoid.JumpPower == 100)
callbacks["Cerrar y limpiar"]()
assert(window.unloaded and visuals[1].destroyed and globals.BreakInHubUnload == nil)
assert(humanoid.WalkSpeed == 16 and humanoid.JumpPower == 50 and not humanoid.UseJumpPower)
humanoid.lastState = nil; jump:Fire(); assert(humanoid.lastState == nil)
heartbeat:Fire(3); assert(#requests == before)
print("OK: combate, remotes, curación, movimiento, guardas y limpieza")
