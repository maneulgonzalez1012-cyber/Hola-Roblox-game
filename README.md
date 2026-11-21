# Hola Hub

Script de cliente para executor con **Rayfield Gen 2**, ESP de jugadores y expansor de hitbox. El repositorio solo contenía el README inicial; este script se creó desde cero.

## Funciones

- ESP mediante `Highlight` a través de paredes; nombres y distancia opcionales; color configurable.
- Filtro de equipo compartido por ESP y hitbox, activado por defecto. Los jugadores neutrales no se consideran compañeros automáticamente.
- Expansión local del `HumanoidRootPart`, con tamaño y transparencia configurables. Al desactivarla, cambiar de equipo, reaparecer o cerrar, se restauran las propiedades originales capturadas.
- El botón **Cerrar y restaurar** desconecta el script y elimina sus objetos. Si el executor proporciona `getgenv`, ejecutar de nuevo el script cierra la instancia anterior.

La hitbox se modifica **solo en el cliente**: si el servidor valida los impactos u otros scripts cambian estas propiedades, puede no tener efecto o interferir. El script no se ha probado dentro de Roblox; la compatibilidad depende del juego y del executor.

## Ejecutar

Ejecuta este loadstring en un executor que admita `game:HttpGet` y `loadstring`:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/maneulgonzalez1012-cyber/Hola-Roblox-game/arena/24653128-hola-roblox-game/src/HolaHub.obfuscated.lua"))()
```

La versión distribuida se genera con [Obscura](https://github.com/p4inz-code/obscura): renombra variables locales, codifica cadenas y constantes e inserta bloques de código inactivo. No es una máquina virtual ni cifrado seguro. El código legible sigue público en [`src/HolaHub.client.lua`](src/HolaHub.client.lua), y también está en el historial, de modo que no es secreto. El loadstring anterior que apunta a ese archivo sigue cargando la versión legible.

Rayfield se carga desde `https://sirius.menu/gen2` ([documentación oficial](https://docs.sirius.menu/rayfield-gen2/getting-started)).

## Regenerar la versión ofuscada

Se necesitan Node.js 22+, npm, Python 3, CMake y un compilador C++17. Las siguientes instrucciones construyen las herramientas fuera de este repositorio, fijando las versiones usadas:

```sh
# En un directorio de trabajo externo al repositorio:
git clone https://github.com/p4inz-code/obscura.git
git -C obscura checkout 3a832af1f5ae518b7399d8e697519cadb715a590
(cd obscura && npm ci && npm run build)
git clone --depth 1 --branch 0.701 https://github.com/luau-lang/luau.git
cmake -S luau -B luau/build -DCMAKE_BUILD_TYPE=Release -DLUAU_BUILD_TESTS=OFF
cmake --build luau/build --target Luau.Repl.CLI Luau.Ast -j 4
g++ -O2 -std=c++17 -DOBSCURA_NATIVE_TEST -I luau/Ast/include -I luau/Analysis/include -I luau/Common/include obscura/packages/core/native-src/ObscuraSerializer.cpp luau/build/libLuau.Ast.a luau/build/libLuau.Common.a -o luau/build/obscura_native

# Ejecutar desde la raíz de Hola-Roblox-game, con rutas absolutas a las herramientas:
OBSCURA_CLI=/ruta/obscura/packages/cli/dist/cli.js OBSCURA_NATIVE_BIN=/ruta/luau/build/obscura_native python3 tools/obfuscate.py
LUAU=/ruta/luau/build/luau python3 tools/test_obfuscation.py
```

La prueba ejecuta ambas variantes en Luau con objetos simulados: verifica ESP, hitbox, filtro de equipo y restauración. No sustituye una prueba en Roblox con un executor.

Si tu executor admite `readfile`, puedes guardar el archivo como `HolaHub.client.lua` en su carpeta de archivos y usar:

```lua
loadstring(readfile("HolaHub.client.lua"))()
```
