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
function Vector3.new(x, y, z) return { X = x, Y = y, Z = z } end
local Color3 = { fromRGB = function(r, g, b) return { r, g, b } end }
local UDim2 = { fromOffset = function() return {} end, fromScale = function() return {} end }
local Enum = { HighlightDepthMode = { AlwaysOnTop = 1 }, Font = { GothamBold = 1 } }
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
local game = {}
function game:GetService(name) return name == "Players" and players or runService end
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
controls["Cerrar y restaurar"]()
assert(root.Size.X == 2 and root.Transparency == 1 and root.CanCollide == true)
assert(window.unloaded and globals.HolaHubUnload == nil)
print("OK: ESP, hitbox, filtro de equipo y restauración")
