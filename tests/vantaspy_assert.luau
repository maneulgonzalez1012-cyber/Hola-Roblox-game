local env = getfenv()
local uiState = env.__VANTA_TEST_UI
local spyState = env.__VANTA_SPY_STATE
assert(spyState, "Missing __VANTA_SPY_STATE")

-- 1. Origins scan without executing any remote
assert(#spyState.origins == 4, "Expected 4 unexecuted remotes, got " .. tostring(#spyState.origins))

-- 2. Filter origins
uiState.inputs["Buscar en Orígenes"]("Sell")
local dd = uiState.dropdowns["Remotes detectados"]
assert(#dd.Options == 1 and dd.Options[1] == "ReplicatedStorage.Remotes.SellItem", "Origin filter failed")
uiState.inputs["Buscar en Orígenes"]("")

-- 3. Select origin and copy path
dd.Callback("ReplicatedStorage.Remotes.SellItem")
uiState.buttons["Copiar ruta seleccionada"]()
assert(env.__VANTA_TEST_COPIED() == "ReplicatedStorage.Remotes.SellItem", "Clipboard copy failed")

-- 4. Enable capture & test __namecall with 0 args, nil in middle, cyclic table, and InvokeServer return
uiState.toggles["Activar Captura"](true)
assert(spyState.capturing == true, "Capture should be active")

env.__VANTA_TEST_SET_METHOD("FireServer")
env.__VANTA_TEST_CALL(env.__VANTA_TEST_SELL, "gold", nil, 123)
env.__VANTA_TEST_CALL(env.__VANTA_TEST_SELL, "gold", nil, 123)

local cyclic = { a = 1 }
cyclic.self = cyclic
env.__VANTA_TEST_CALL(env.__VANTA_TEST_MAP, cyclic)

env.__VANTA_TEST_SET_METHOD("InvokeServer")
local r1, r2 = env.__VANTA_TEST_CALL(env.__VANTA_TEST_BUY)
assert(r1 == "ok_response" and r2 == 42, "InvokeServer return values not preserved")

local sellKey = "FireServer | ReplicatedStorage.Remotes.SellItem"
assert(spyState.logs[sellKey] and spyState.logs[sellKey].count == 2, "Expected grouped count 2 for SellItem")

-- 5. Snapshot Antes / Después
uiState.buttons["Marcar Antes (Snapshot)"]()
env.__VANTA_TEST_SET_METHOD("FireServer")
env.__VANTA_TEST_CALL(env.__VANTA_TEST_SELL, "diamond")
assert(spyState.logs[sellKey].count == 3, "Expected count 3 after snapshot")

-- 6. Collapse / Expand GUI
uiState.buttons["Contraer / Expandir GUI"]()
assert(uiState.visible == false, "Expected GUI to collapse")
uiState.buttons["Contraer / Expandir GUI"]()
assert(uiState.visible == true, "Expected GUI to expand")

-- 7. Clean destroy
uiState.buttons["Cerrar VANTA Spy"]()
assert(spyState.destroyed == true and uiState.destroyed == true, "Expected clean destroy")

print("PASS: VANTA Spy suite")
