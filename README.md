# Blade Ball Hub

Script de executor exclusivo para **Blade Ball**, con Rayfield Gen 2. Reemplaza las funciones del hub anterior. Las versiones anteriores siguen existiendo en el historial de Git.

## Funciones

- **Auto parry:** detecta pelotas reales en `Workspace.Balls` que apunten al jugador y estima el tiempo de impacto usando la velocidad relativa. La anticipación, distancia mínima y espera son ajustables. Está desactivado al iniciar.
- **Resaltar pelota real:** azul por defecto y roja si te apunta.
- **Probar bloqueo:** intenta enviar una señal local de bloqueo para comprobar la entrada.
- **Cerrar y limpiar:** desconecta el script y borra el marcador. Si el executor admite `getgenv`, ejecutar de nuevo cierra la instancia anterior.

El bloqueo intenta usar el `BindableEvent` local `Remotes.ParryButtonPress`, o, si no está disponible, `mouse1click` y `VirtualInputManager`. La estructura del juego, los permisos y la latencia pueden afectar el resultado; la señal local no confirma que se haya realizado un parry. Las convenciones de pelota y bloqueo se basan en [ejemplos públicos](https://github.com/InfernoKarl/opensrc/blob/main/BladeBall/Scripts/autoparry.lua), no en una API oficial. El script **no se ha probado dentro de Roblox** ni se garantiza su compatibilidad con el juego actual o con executores móviles.

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/maneulgonzalez1012-cyber/Hola-Roblox-game/arena/24653128-hola-roblox-game/src/HolaHub.obfuscated.lua"))()
```

Necesita un executor con `game:HttpGet` y `loadstring`. Rayfield se carga desde `https://sirius.menu/gen2`. La versión distribuida se ofusca con [Obscura](https://github.com/p4inz-code/obscura); el código legible sigue público en `src/HolaHub.client.lua`, por lo que la ofuscación no proporciona secreto.

## Regenerar y probar

Para reconstruir la versión ofuscada se necesitan Node.js 22+, npm, Python 3, CMake y un compilador C++17. Las herramientas se instalan fuera del repositorio:

```sh
git clone https://github.com/p4inz-code/obscura.git
git -C obscura checkout 3a832af1f5ae518b7399d8e697519cadb715a590
(cd obscura && npm ci && npm run build)
git clone --depth 1 --branch 0.701 https://github.com/luau-lang/luau.git
cmake -S luau -B luau/build -DCMAKE_BUILD_TYPE=Release -DLUAU_BUILD_TESTS=OFF
cmake --build luau/build --target Luau.Repl.CLI Luau.Ast -j 4
g++ -O2 -std=c++17 -DOBSCURA_NATIVE_TEST -I luau/Ast/include -I luau/Analysis/include -I luau/Common/include obscura/packages/core/native-src/ObscuraSerializer.cpp luau/build/libLuau.Ast.a luau/build/libLuau.Common.a -o luau/build/obscura_native

# Desde la raíz de este repositorio, con rutas absolutas:
OBSCURA_CLI=/ruta/obscura/packages/cli/dist/cli.js OBSCURA_NATIVE_BIN=/ruta/luau/build/obscura_native python3 tools/obfuscate.py
LUAU=/ruta/luau/build/luau python3 tools/test_obfuscation.py
```

La prueba ejecuta el original y el ofuscado en Luau con objetos simulados: valida selección de objetivo, aproximación, control de repetición, resaltado y limpieza. No sustituye una prueba real en Roblox.
