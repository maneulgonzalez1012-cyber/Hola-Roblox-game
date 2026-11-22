-- Test de callbacks/remotes con mocks; no ejecuta Roblox.
local function signal()
    local callbacks = {}
    return {
        Connect = function(_, fn)
            local c = { active = true }
            function c:Disconnect() self.active = false end
            table.insert(callbacks, { fn = fn, connection = c })
            return c
        end,
        Fire = function(_, ...)
            for _, v in ipairs(callbacks) do if v.connection.active then v.fn(...) end end
        end,
    }
end
local controls, messages, visuals, calls = {}, {}, {}, {}
local window = { unloaded = false }
function window:CreateTab()
    return {
        CreateDropdown = function(_, p) controls[p.name] = p.callback end,
        CreateButton = function(_, p) controls[p.name] = p.callback end,
        CreateToggle = function(_, p) controls[p.name] = p.callback end,
        CreateSlider = function(_, p) controls[p.name] = p.callback end,
        CreateInput = function(_, p) controls[p.name] = p.callback end,
    }
end
function window:Notify(p) table.insert(messages, p.content) end
function window:Unload() self.unloaded = true end
local loadstring = function() return function() return { CreateWindow = function() return window end } end end
local env = {}
local getgenv = function() return env end
local pending = {}
local task = { spawn = function(fn)
    local co = coroutine.create(fn)
    local ok, err = coroutine.resume(co); assert(ok, err)
    if coroutine.status(co) ~= "dead" then table.insert(pending, co) end
end }
local function advance()
    local current = pending; pending = {}
    for _, co in ipairs(current) do
        local ok, err = coroutine.resume(co); assert(ok, err)
        if coroutine.status(co) ~= "dead" then table.insert(pending, co) end
    end
end
local Enum = { HighlightDepthMode = { AlwaysOnTop = 1 }, HumanoidStateType = { Jumping = "jump" } }
local Color3 = { fromRGB = function(r,g,b) return {r,g,b} end }
local CFrame = { new = function(x,y,z) return {X=x,Y=y,Z=z} end }
local Instance = {}
function Instance.new(class)
    local item = { class = class }
    function item:Destroy() self.destroyed = true end
    table.insert(visuals, item)
    return item
end
local function makePart()
    local p = { CanCollide = true, CFrame = {} }
    function p:IsA(n) return n == "BasePart" end
    return p
end
local function makeCharacter()
    local hum = { Health = 100, WalkSpeed = 16, JumpPower = 50, UseJumpPower = false }
    function hum:ChangeState(v) self.state = v end
    local character = { root = makePart(), head = makePart(), hum = hum }
    function character:FindFirstChild(n) if n == "HumanoidRootPart" then return self.root elseif n == "Head" then return self.head end end
    function character:FindFirstChildOfClass(n) if n == "Humanoid" then return self.hum end end
    function character:GetDescendants() return { self.root, self.head } end
    return character
end
local me = { Name = "dj", Character = makeCharacter(), Team = "blue", Neutral = false }
function me:WaitForChild(n) assert(n == "PlayerGui"); return {} end
local other = { Name = "other", Character = makeCharacter(), Team = "red", Neutral = false }
function other:IsA(n) return n == "Player" end
local players = { LocalPlayer = me, list = {me, other} }
function players:GetPlayers() return self.list end
function players:FindFirstChild(n) if n == "other" then return other elseif n == "dj" then return me end end
local function rem(name, class)
    local r = { class = class }
    function r:IsA(n) return n == self.class end
    function r:FireServer(arg) table.insert(calls, { name = name, arg = arg }) end
    function r:InvokeServer(arg)
        table.insert(calls, { name = name, arg = arg })
        if self.waiting then coroutine.yield() end
        if self.fail then error("server error") end
    end
    return r
end
local team = rem("TeamEvent", "RemoteEvent")
local itemHandler = rem("ItemHandler", "RemoteFunction")
local arrest = rem("arrest", "RemoteFunction")
local melee = rem("meleeEvent", "RemoteEvent")
local remotes = { TeamEvent = team, ItemHandler = itemHandler, arrest = arrest }
function remotes:FindFirstChild(n) return self[n] end
local pickups = {}
local function category(prefix)
    return { FindFirstChild = function(_, n)
        if n == "missing" then return nil end
        local p = pickups[prefix .. n] or { Name = prefix .. n }
        pickups[prefix .. n] = p
        return { FindFirstChild = function(_, name) if name == "ITEMPICKUP" then return p end end }
    end }
end
local cats = { giver = category("giver/"), single = category("single/") }
function cats:FindFirstChild(n) return self[n] end
local world = {}
function world:FindFirstChild(n) if n == "Remote" then return remotes elseif n == "Prison_ITEMS" then return cats end end
local storage = { FindFirstChild = function(_, n) if n == "meleeEvent" then return melee end end }
local heartbeat, jump = signal(), signal()
local game = { GameId = 73885730, PlaceId = 155615604 }
function game:GetService(n)
    if n == "Players" then return players elseif n == "Workspace" then return world
    elseif n == "ReplicatedStorage" then return storage elseif n == "RunService" then return { Heartbeat = heartbeat }
    elseif n == "UserInputService" then return { JumpRequest = jump } end
    error(n)
end
function game:HttpGet(url) assert(url == "https://sirius.menu/gen2"); return "rayfield" end
local function runHub(...)
-- INSERT_SOURCE_HERE
end
local e = getfenv(runHub)
e.game, e.Instance, e.Enum, e.Color3, e.CFrame = game, Instance, Enum, Color3, CFrame
e.loadstring, e.getgenv, e.task = loadstring, getgenv, task
runHub()
assert(type(env.PrisonLifeUnload) == "function")
controls["Solicitar objeto"](); assert(#calls == 1 and calls[1].name == "ItemHandler" and calls[1].arg == pickups["giver/M9"])
controls["Objeto"]("Key card"); controls["Solicitar objeto"](); assert(calls[2].arg == pickups["single/Key card"])
controls["Solicitar guardia"](); controls["Solicitar preso"](); controls["Solicitar neutral"]()
assert(calls[3].arg == "Bright blue" and calls[4].arg == "Bright orange" and calls[5].arg == "Medium stone grey")
controls["Patio"](); assert(me.Character.root.CFrame.X == 793.991333)
controls["Nombre de usuario"]("other")
controls["Ir a jugador"](); assert(me.Character.root.CFrame == other.Character.root.CFrame)
controls["Solicitar golpe"](); assert(calls[6].name == "meleeEvent" and calls[6].arg == other)
controls["Solicitar arresto"](); assert(calls[7].name == "arrest" and calls[7].arg == other.Character.head)
controls["Nombre de usuario"]("unknown"); controls["Solicitar golpe"](); assert(#calls == 7)
controls["ESP jugadores"](true); heartbeat:Fire(0.2); assert(#visuals == 2 and visuals[2].Adornee == other.Character)
other.Team = "blue"; controls["Ignorar equipo en ESP"](true); heartbeat:Fire(0.2); assert(visuals[2].destroyed)
other.Team = "red"; heartbeat:Fire(0.2); assert(#visuals == 3)
controls["Velocidad personalizada"](true); controls["Velocidad"](45)
controls["Salto personalizado"](true); controls["Potencia de salto"](100)
assert(me.Character.hum.WalkSpeed == 45 and me.Character.hum.JumpPower == 100 and me.Character.hum.UseJumpPower)
controls["Salto infinito"](true); jump:Fire(); assert(me.Character.hum.state == "jump")
controls["Noclip"](true); heartbeat:Fire(0.1); assert(not me.Character.root.CanCollide and not me.Character.head.CanCollide)
local old = me.Character
me.Character = makeCharacter(); heartbeat:Fire(0.2)
assert(old.root.CanCollide and old.hum.WalkSpeed == 16 and old.hum.JumpPower == 50 and not old.hum.UseJumpPower)
assert(not me.Character.root.CanCollide and me.Character.hum.WalkSpeed == 45)
controls["Noclip"](false); assert(me.Character.root.CanCollide)
remotes.ItemHandler = nil; controls["Solicitar objeto"](); assert(#calls == 7 and string.find(messages[#messages], "ItemHandler"))
remotes.ItemHandler = itemHandler; itemHandler.class = "RemoteEvent"; controls["Solicitar objeto"](); assert(#calls == 7)
itemHandler.class = "RemoteFunction"
itemHandler.waiting = true; controls["Solicitar objeto"](); assert(#calls == 8)
controls["Solicitar objeto"](); assert(#calls == 8 and string.find(messages[#messages], "esperando"))
itemHandler.waiting = false; advance(); assert(string.find(messages[#messages], "depende"))
itemHandler.fail = true; controls["Solicitar objeto"](); assert(#calls == 9 and string.find(messages[#messages], "Error"))
itemHandler.fail = false
game.GameId = 1; game.PlaceId = 1; controls["Solicitar guardia"](); controls["Solicitar objeto"](); heartbeat:Fire(0.2)
assert(#calls == 9 and me.Character.hum.WalkSpeed == 16 and visuals[3].destroyed)
game.GameId = 73885730; game.PlaceId = 155615604; heartbeat:Fire(0.2)
controls["Noclip"](true); heartbeat:Fire(0.1); assert(not me.Character.root.CanCollide)
itemHandler.waiting = true; controls["Solicitar objeto"](); assert(#calls == 10)
controls["Cerrar y limpiar"]()
local lastMessages = #messages
itemHandler.waiting = false; advance(); assert(#messages == lastMessages)
assert(env.PrisonLifeUnload == nil and window.unloaded and visuals[1].destroyed and me.Character.root.CanCollide)
assert(me.Character.hum.WalkSpeed == 16 and me.Character.hum.JumpPower == 50 and not me.Character.hum.UseJumpPower)
me.Character.hum.state = nil; jump:Fire(); heartbeat:Fire(1); assert(me.Character.hum.state == nil and #calls == 10)
print("OK: objetos, equipos, jugadores, ESP, movimiento, guardas y limpieza")
