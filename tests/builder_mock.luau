-- Prueba de callbacks y RemoteEvent con objetos simulados, no Roblox.
local controls, messages, requests = {}, {}, {}
local window = { unloaded = false }
function window:CreateTab()
    return {
        CreateInput = function(_, p) controls[p.name] = p.callback end,
        CreateButton = function(_, p) controls[p.name] = p.callback end,
        CreateDropdown = function(_, p) controls[p.name] = p.callback end,
        CreateSlider = function(_, p) controls[p.name] = p.callback end,
    }
end
function window:Notify(p) table.insert(messages, p.content) end
function window:Unload() self.unloaded = true end
local rayfield = { CreateWindow = function() return window end }
local loadstring = function() return function() return rayfield end end
local env = {}
local getgenv = function() return env end
local Vector3 = { new = function(x,y,z) return { X=x, Y=y, Z=z } end }
local pending = {}
local task = {}
function task.spawn(fn)
    local co = coroutine.create(fn)
    local ok, err = coroutine.resume(co)
    assert(ok, err)
    if coroutine.status(co) ~= "dead" then table.insert(pending, co) end
end
function task.wait(delay) assert(delay == 0.5); coroutine.yield() end
local function advance()
    local current = pending
    pending = {}
    for _, co in ipairs(current) do
        local ok, err = coroutine.resume(co)
        assert(ok, err)
        if coroutine.status(co) ~= "dead" then table.insert(pending, co) end
    end
end
local remote = { available = true, isEvent = true, fails = false }
function remote:IsA(name) return name == "RemoteEvent" and self.isEvent end
function remote:FireServer(id, pos)
    if self.fails then error("test failure") end
    table.insert(requests, { id = id, pos = pos })
end
local grid = { FindFirstChild = function(_, name) if name == "AddGridObject" and remote.available then return remote end end }
local libraries = { FindFirstChild = function(_, name) if name == "Grid" then return grid end end }
local system = { FindFirstChild = function(_, name) if name == "Libraries" then return libraries end end }
local storage = { FindFirstChild = function(_, name) if name == "BuildingSystem" then return system end end }
local game = {}
function game:GetService(name) assert(name == "ReplicatedStorage"); return storage end
function game:HttpGet(url) assert(url == "https://sirius.menu/gen2"); return "rayfield" end
local function runHub(...)
-- INSERT_SOURCE_HERE
end
local environment = getfenv(runHub)
environment.game, environment.Vector3, environment.task = game, Vector3, task
environment.loadstring, environment.getgenv = loadstring, getgenv
runHub()
assert(type(env.FrontlinesBuilderUnload) == "function")
controls["Solicitar una pieza"]()
assert(#requests == 1 and requests[1].id == "Wall$180$0")
assert(requests[1].pos.X == 7 and requests[1].pos.Y == -1 and requests[1].pos.Z == -1)
controls["Rejilla X"]("xyz"); controls["Solicitar una pieza"]()
assert(#requests == 1 and string.find(messages[#messages], "enteras"))
controls["Rejilla X"]("1.5"); controls["Solicitar una pieza"](); assert(#requests == 1)
controls["Rejilla X"]("-4"); controls["ID de objeto"](""); controls["Solicitar una pieza"](); assert(#requests == 1)
controls["ID de objeto"]("Otro$0$0"); controls["Rejilla Y"]("2"); controls["Rejilla Z"]("3")
controls["Eje de fila"]("Z"); controls["Piezas por fila"](3)
controls["Solicitar fila"](); assert(#requests == 2 and requests[2].id == "Otro$0$0" and requests[2].pos.X == -4 and requests[2].pos.Z == 3)
controls["Rejilla Z"]("100"); controls["ID de objeto"]("cambiado")
controls["Solicitar una pieza"](); assert(#requests == 2 and string.find(messages[#messages], "curso"))
advance(); assert(#requests == 3 and requests[3].pos.Z == 4 and requests[3].id == "Otro$0$0")
advance(); assert(#requests == 4 and requests[4].pos.Z == 5)
assert(string.find(messages[#messages], "servidor decide"))
controls["Solicitar fila"](); assert(#requests == 5)
controls["Detener fila"](); advance(); assert(#requests == 5)
remote.available = false; controls["Solicitar una pieza"](); assert(#requests == 5 and string.find(messages[#messages], "No se encontr"))
remote.available = true; remote.isEvent = false; controls["Solicitar una pieza"](); assert(#requests == 5)
remote.isEvent = true; remote.fails = true; controls["Solicitar una pieza"](); assert(#requests == 5 and string.find(messages[#messages], "No se pudo"))
remote.fails = false; controls["Rejilla Z"]("10000"); controls["Eje de fila"]("Z")
controls["Solicitar fila"](); assert(#requests == 6)
advance(); assert(#requests == 6 and string.find(messages[#messages], "límite"))
controls["Rejilla Z"]("-1"); controls["Solicitar fila"](); assert(#requests == 7)
controls["Cerrar y limpiar"](); advance()
assert(#requests == 7 and window.unloaded and env.FrontlinesBuilderUnload == nil)
print("OK: remoto, coordenadas, fila, errores, cancelación y limpieza")
