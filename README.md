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

La versión distribuida codifica el código con un desplazamiento reversible y lo reconstruye al ejecutarse; es **ofuscación básica**, no cifrado seguro. El código legible sigue público en [`src/HolaHub.client.lua`](src/HolaHub.client.lua), por lo que no está oculto. El loadstring anterior, que apunta a ese archivo, sigue cargando la versión legible.

Para regenerar el archivo ofuscado tras modificar el código, ejecuta `python3 tools/obfuscate.py` y publica ambos archivos. Rayfield se carga desde `https://sirius.menu/gen2` ([documentación oficial](https://docs.sirius.menu/rayfield-gen2/getting-started)).

Si tu executor admite `readfile`, puedes guardar el archivo como `HolaHub.client.lua` en su carpeta de archivos y usar:

```lua
loadstring(readfile("HolaHub.client.lua"))()
```
