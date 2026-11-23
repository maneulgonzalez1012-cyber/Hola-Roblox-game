-- Mock Luau harness for VANTA Spy (source and obfuscated builds)

local function makeInstance(name, className, parent)
    local inst = {
        Name = name,
        ClassName = className,
        Parent = parent,
        _children = {},
    }
    function inst:GetFullName()
        if self.Parent and self.Parent.GetFullName and self.Parent ~= game then
            return self.Parent:GetFullName() .. "." .. self.Name
        end
        return self.Name
    end
    function inst:GetDescendants()
        local out = {}
        for _, child in ipairs(self._children) do
            table.insert(out, child)
            for _, sub in ipairs(child:GetDescendants()) do
                table.insert(out, sub)
            end
        end
        return out
    end
    if parent and parent._children then
        table.insert(parent._children, inst)
    end
    return inst
end

local env = getfenv()
env._G = env
env.typeof = function(v)
    if type(v) == "table" and v.ClassName then
        return "Instance"
    end
    return type(v)
end

local replicatedStorage = makeInstance("ReplicatedStorage", "ReplicatedStorage", nil)
local remotesFolder = makeInstance("Remotes", "Folder", replicatedStorage)
local sellRemote = makeInstance("SellItem", "RemoteEvent", remotesFolder)
local buyRemote = makeInstance("PurchaseCrate", "RemoteFunction", remotesFolder)
local pingRemote = makeInstance("PingUnreliable", "UnreliableRemoteEvent", replicatedStorage)

local workspaceSvc = makeInstance("Workspace", "Workspace", nil)
local mapRemote = makeInstance("InteractDoor", "RemoteEvent", workspaceSvc)

local services = {
    ReplicatedStorage = replicatedStorage,
    Workspace = workspaceSvc,
    Players = makeInstance("Players", "Players", nil),
    StarterGui = makeInstance("StarterGui", "StarterGui", nil),
    StarterPack = makeInstance("StarterPack", "StarterPack", nil),
    ReplicatedFirst = makeInstance("ReplicatedFirst", "ReplicatedFirst", nil),
    Lighting = makeInstance("Lighting", "Lighting", nil),
}

local descendantListeners = {}
local gameObj = {
    DescendantAdded = {
        Connect = function(_, fn)
            table.insert(descendantListeners, fn)
            return {
                Disconnect = function() end,
            }
        end,
    },
}
function gameObj:GetService(name)
    return services[name]
end
function gameObj:GetDescendants()
    local out = {}
    for _, svc in pairs(services) do
        table.insert(out, svc)
        for _, d in ipairs(svc:GetDescendants()) do
            table.insert(out, d)
        end
    end
    return out
end

local currentMethod = ""
local activeNamecall = function(self, methodName, ...)
    if methodName == "InvokeServer" then
        return "ok_response", 42
    end
    return nil
end

env.game = gameObj
env.getnamecallmethod = function()
    return currentMethod
end
env.hookmetamethod = function(_target, _metamethod, fn)
    local prev = activeNamecall
    activeNamecall = fn
    return function(self, ...)
        return prev(self, currentMethod, ...)
    end
end
env.checkcaller = function()
    return false
end
local copiedText = nil
env.setclipboard = function(txt)
    copiedText = txt
end
env.getgc = function()
    return {}
end

local uiState = {
    visible = true,
    destroyed = false,
    buttons = {},
    toggles = {},
    inputs = {},
    dropdowns = {},
    paragraphs = {},
}

env.__VANTA_RAYFIELD_MOCK = {
    CreateWindow = function(_, _cfg)
        return {
            CreateTab = function(_, _name, _icon)
                return {
                    CreateParagraph = function(_, cfg)
                        local p = { Title = cfg.Title, Content = cfg.Content }
                        function p:Set(newCfg)
                            p.Title = newCfg.Title
                            p.Content = newCfg.Content
                        end
                        table.insert(uiState.paragraphs, p)
                        return p
                    end,
                    CreateDropdown = function(_, cfg)
                        local d = { Name = cfg.Name, Options = cfg.Options, Callback = cfg.Callback }
                        function d:Refresh(opts)
                            d.Options = opts
                        end
                        uiState.dropdowns[cfg.Name] = d
                        return d
                    end,
                    CreateInput = function(_, cfg)
                        uiState.inputs[cfg.Name] = cfg.Callback
                        return {}
                    end,
                    CreateButton = function(_, cfg)
                        uiState.buttons[cfg.Name] = cfg.Callback
                        return {}
                    end,
                    CreateToggle = function(_, cfg)
                        uiState.toggles[cfg.Name] = cfg.Callback
                        return {}
                    end,
                }
            end,
        }
    end,
    Notify = function() end,
    IsVisible = function()
        return uiState.visible
    end,
    SetVisibility = function(_, v)
        uiState.visible = v
    end,
    Destroy = function()
        uiState.destroyed = true
    end,
}

env.__VANTA_TEST_UI = uiState
env.__VANTA_TEST_COPIED = function() return copiedText end
env.__VANTA_TEST_SET_METHOD = function(m) currentMethod = m end
env.__VANTA_TEST_CALL = function(...) return activeNamecall(...) end
env.__VANTA_TEST_SELL = sellRemote
env.__VANTA_TEST_BUY = buyRemote
env.__VANTA_TEST_MAP = mapRemote
