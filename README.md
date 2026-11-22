# Scripts Roblox

## VANTA Prison Life

Hub separado para **Prison Life de Aesthetical** (universo `73885730`, lugar `155615604`). Ofrece solicitudes manuales de objetos y equipos, viaje a lugares históricos o a un jugador, un intento de golpe/arresto a un usuario concreto, ESP, velocidad, salto, salto infinito y noclip local. Las funciones continuas están desactivadas al iniciar. Cerrar el hub restaura velocidad, salto y colisiones guardados y elimina las marcas. Para seleccionar a un jugador usa su nombre de usuario exacto, no el nombre mostrado.

Las convenciones de `Workspace.Remote.ItemHandler`, `TeamEvent`, `arrest`, `ReplicatedStorage.meleeEvent`, objetos y coordenadas provienen de ejemplos comunitarios antiguos: [objetos, equipos y coordenadas](https://github.com/GhoulScripts/Ghoul-Hub-V2---Grape-Theme-games/blob/main/Prison%20Life), [golpe y arresto](https://pastebin.com/QTC2SZNN) y [remotes y equipos](https://github.com/FreezysTESTLUA/PRISON-LIFE-SCRIPT/blob/main/SCRIPTS). Pueden haber cambiado y no constituyen una API oficial. Las solicitudes pueden fallar, requerir distancia, rol, gamepass u otros permisos; recibir respuesta no confirma que la acción se haya completado. `InvokeServer` puede quedarse esperando y solo se permite una invocación pendiente por hub. El juego ha recibido actualizaciones, de modo que posiciones históricas pueden ser incorrectas. No se ha probado en Roblox; los cambios de movimiento y colisión son locales.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/maneulgonzalez1012-cyber/Hola-Roblox-game/arena/24653128-hola-roblox-game/src/PrisonLife.obfuscated.lua"))()
```

La distribución usa Prometheus (VM, cadenas, flujo y expresiones), **no Luarmor**. Based on Prometheus by Elias Oelschner, https://github.com/prometheus-lua/Prometheus ([licencia](licenses/Prometheus-LICENSE.txt)). El código legible sigue público, por lo que la ofuscación no es secreto. Con las dependencias indicadas en Break In:

```sh
PROMETHEUS_DIR=/ruta/Prometheus LUAJIT=/ruta/LuaJIT/src/luajit python3 tools/obfuscate.py --prison-life
LUA=/ruta/luau/build/luau python3 tools/test_prisonlife.py
```

La prueba usa objetos simulados y no sustituye una prueba real en Roblox.

## VANTA Builder — Frontlines

Script separado basado únicamente en el ejemplo de remote facilitado por el usuario: `ReplicatedStorage.BuildingSystem.Libraries.Grid.AddGridObject`, con identificador predeterminado `Wall$180$0` y coordenadas de rejilla `(7, -1, -1)`. Puedes introducir otras coordenadas enteras o un identificador exacto obtenido del mismo juego, enviar una pieza o solicitar una fila de hasta diez posiciones consecutivas en X, Y o Z (cada 0,5 s). La fila puede detenerse; cerrar el hub también cancela las solicitudes pendientes. No se han deducido otros IDs ni el significado de las secciones del identificador.

Las coordenadas son las enviadas al remote, **no necesariamente posiciones del mundo en studs**; no existe conversión de ratón a rejilla, porque no se conoce su escala ni origen en ese juego. Los espacios, conexiones, inventario, recursos y demás validaciones dependen del servidor. Enviar una solicitud no confirma que la pieza se haya construido. No se ha verificado el remote ni probado el script dentro de Frontlines, y puede haber cambiado o no existir en una versión determinada. El script busca el remote de forma segura, sin limitar el ID del juego, pues no se ha confirmado a qué experiencia corresponde el ejemplo.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/maneulgonzalez1012-cyber/Hola-Roblox-game/arena/24653128-hola-roblox-game/src/FrontlinesBuilder.obfuscated.lua"))()
```

La distribución usa Prometheus (VM, cadenas, flujo y expresiones), **no Luarmor**. Based on Prometheus by Elias Oelschner, https://github.com/prometheus-lua/Prometheus ([licencia](licenses/Prometheus-LICENSE.txt)). El código legible sigue público, por lo que no hay secreto. Con las dependencias de la sección Break In:

```sh
PROMETHEUS_DIR=/ruta/Prometheus LUAJIT=/ruta/LuaJIT/src/luajit python3 tools/obfuscate.py --builder
LUA=/ruta/luau/build/luau python3 tools/test_builder.py
```

La prueba ejecuta fuente y distribución con mocks, no es una prueba en Roblox.

## VANTA Players — hitbox + ESP

Hub independiente para jugadores, con Rayfield Gen 2. El **hitbox expander** modifica localmente el tamaño, transparencia y colisión del `HumanoidRootPart` de otros jugadores; tiene tamaño ajustable de 2 a 30 studs. El **ESP** muestra un resaltado a través de paredes, nombre, vida y distancia. Ambos empiezan desactivados. El filtro de equipo excluye compañeros no neutrales por defecto; la distancia máxima es ajustable entre 50 y 2000 studs. Al desactivar, cerrar o cambiar de objetivo, se restauran las propiedades guardadas y se eliminan los marcadores. Si el executor permite `getgenv`, volver a ejecutar limpia la instancia anterior.

El cambio de hitbox es **solo local**: los juegos con validación de impactos en el servidor pueden ignorarlo. Puede no funcionar en juegos sin `HumanoidRootPart`, con estructuras distintas, streaming o restricciones propias; Roblox también limita los resaltados simultáneos. No se ha probado en Roblox ni se garantiza compatibilidad con todos los juegos o executors. Necesita `game:HttpGet`, `loadstring` y Rayfield desde `https://sirius.menu/gen2`.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/maneulgonzalez1012-cyber/Hola-Roblox-game/arena/24653128-hola-roblox-game/src/VantaPlayers.obfuscated.lua"))()
```

La distribución usa Prometheus con VM, cifrado de cadenas, aplanado de flujo y transformaciones de expresiones; **no usa Luarmor**. Based on Prometheus by Elias Oelschner, https://github.com/prometheus-lua/Prometheus ([licencia](licenses/Prometheus-LICENSE.txt)). La VM aumenta el tamaño y la carga; la fuente sigue pública y la ofuscación no es secreto. Con las dependencias y versiones indicadas en la sección Break In, se regenera y prueba con:

```sh
PROMETHEUS_DIR=/ruta/Prometheus LUAJIT=/ruta/LuaJIT/src/luajit python3 tools/obfuscate.py --players
LUA=/ruta/luau/build/luau python3 tools/test_players.py
```

Las pruebas usan mocks, no sustituyen probar el juego real.

## Break In (Story)

`src/BreakIn.client.lua` es un script independiente para **Break In (Story)** original (universo `1318971886`), con Rayfield Gen 2; no es para Break In 2. Incluye ataque automático, ESP, solicitudes de objetos, energía, curación con botiquín, roles, martillo, paquete de cola y sartén; caja fuerte, puerta y diálogo; teletransportes, velocidad, salto y salto infinito. La autoenergía está desactivada inicialmente y limita la frecuencia. Curar a todos envía una solicitud manual por jugador. La velocidad y el salto son cambios locales y se restauran al desactivar o cerrar el hub.

Los eventos y posiciones son experimentales: son ejemplos históricos, pueden haber cambiado o ser rechazados por el servidor y no se han probado en Roblox. Una solicitud enviada no confirma que haya funcionado; para curar a otros, los ejemplos mencionan equipar un MedKit. Fuentes comunitarias: [objetos, roles, martillo y caja](https://gist.github.com/NumanZaidan/6368ec43473cc22ee58a09854c12ee46), [posiciones y paquete](https://scriptrb.com/post.php?id=797), [diálogo y compra](https://scriptblox.com/script/Break-In-(Story)-Open-Source-3527), [curación](https://pastebin.com/f62GehWa), [puerta](https://pastebin.com/8Zu6tXtD) y [otros objetos](https://clubdark.net/forum/d/1428-break-in-kill-badguys-give-tools-heal-all-and-more). No son una API oficial. Para probar ambas versiones con objetos simulados, ejecuta `LUA=/ruta/al/luau python3 tools/test_breakin.py`. No sustituye una prueba en Roblox.

El loadstring usa Prometheus para renombrar identificadores, proteger cadenas, reescribir constantes en expresiones, aplanar flujo y compilar el script a instrucciones ejecutadas por una VM de registros en Lua. Based on Prometheus by Elias Oelschner, https://github.com/prometheus-lua/Prometheus ([licencia](licenses/Prometheus-LICENSE.txt)). **No usa Luarmor**. La VM incrementa el tamaño y el coste de ejecución; la compatibilidad con cada executor no está probada. El código fuente permanece público, por lo que la ofuscación no proporciona secreto.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/maneulgonzalez1012-cyber/Hola-Roblox-game/arena/24653128-hola-roblox-game/src/BreakIn.obfuscated.lua"))()
```

Para regenerar Break In se necesitan Python 3, LuaJIT y Prometheus. Instala las herramientas fuera de este repositorio y utiliza sus rutas absolutas:

```sh
git clone https://github.com/prometheus-lua/Prometheus.git
git -C Prometheus checkout a98c50165f2a53f6d765a82eee60dfea53803445
git clone https://github.com/LuaJIT/LuaJIT.git
git -C LuaJIT checkout 96f7b297326e9fd454b7186c6858b2773f94a0dc
make -C LuaJIT -j4

# Desde la raíz de este repositorio:
PROMETHEUS_DIR=/ruta/Prometheus LUAJIT=/ruta/LuaJIT/src/luajit python3 tools/obfuscate.py --break-in
LUA=/ruta/luau/build/luau python3 tools/test_breakin.py
```

La configuración reproducible está en `tools/prometheus_breakin.lua`; la compilación de Luau se explica más abajo.

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
