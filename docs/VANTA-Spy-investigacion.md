# VANTA Spy — investigación y diseño inicial

**Estado:** investigación y propuesta; **todavía no es un script funcional**. No se ha probado Delta en iPhone, ni Rayfield en esa instalación, ni un juego real. Se interpreta «Gen1» como Rayfield de primera generación; confirmar si se refiere a otra cosa.

## Objetivo y límites

Construir una herramienta local, enfocada en iPhone/Delta, para entender qué llamadas y objetos **observables desde el cliente** intervienen en una acción del juego. Ejemplo: iniciar captura, vender un objeto manualmente, detener captura y comparar las llamadas que aparecieron. El servidor decide si acepta la acción; observar o repetir un mensaje no equivale a cambiar dinero ni revela la lógica del servidor.

SimpleSpy se presenta como herramienta que intercepta llamadas remotas cliente→servidor; no es un lector de toda la RAM del dispositivo ([proyecto original](https://github.com/exxtremestuffs/SimpleSpySource)). `getgc`, cuando un executor lo proporciona, enumera determinados objetos administrados por el recolector de Luau en un estado accesible; no equivale a leer memoria nativa arbitraria de iOS, otras apps ni el servidor ([referencia de API Wave](https://getwave.gg/documentation)). No debe prometerse acceso a contraseñas o datos privados de otros jugadores.

## Qué encontramos

1. **SimpleSpy clásico.** Su [código fuente](https://github.com/exxtremestuffs/SimpleSpySource/blob/master/SimpleSpy.lua) observa llamadas `FireServer` / `InvokeServer` usando hooks; incluye serialización de argumentos, filtros, bloqueo y reproducción de código. El repositorio original está archivado y su código declara **MPL 2.0**; si se reutilizara código sujeto a esa licencia, habría que cumplirla. Aquí proponemos implementación propia, no ejecutar ni copiar ciegamente loaders ajenos.
2. **Tipos de remotes.** Roblox documenta `RemoteEvent`, `UnreliableRemoteEvent` y `RemoteFunction`; las funciones esperan respuesta y pueden ceder ejecución, a diferencia de eventos ([Roblox: remotes](https://create.roblox.com/docs/scripting/events/remote)). Un logger no debe alterar esa semántica ni fingir que un evento garantiza un resultado.
3. **Datos entrantes.** Un `RemoteEvent` replicado y visible puede observarse desde `OnClientEvent` al conectar un observador; no se recuperan mensajes anteriores y pueden existir remotes que todavía no se han replicado. `OnClientInvoke` es un callback, no una señal: envolverlo sin interrumpir al juego tiene complejidades adicionales; no prometemos capturarlo en el primer prototipo.
4. **Frontera del servidor.** Un objeto visible solo en el servidor no se replica al cliente; los valores de operaciones y permisos pueden validarse en el servidor ([Roblox: argumentos no replicados y seguridad](https://create.roblox.com/docs/scripting/events/remote), [validación](https://github.com/Roblox/creator-docs/blob/main/content/en-us/scripting/security/client-server-boundary.md)). Por eso un spy no puede garantizar todos los tesoros ni dinero.
5. **Actors/Parallel Luau.** Hooks del estado principal pueden no observar llamadas desde otros estados. Algunos proyectos implementan instrumentación separada por actor con APIs específicas ([Cobalt: diseño del motor](https://deepwiki.com/notpoiu/cobalt/2-remote-spy-engine)). La existencia de esas técnicas no demuestra que Delta iOS las soporte. Se reportará «no verificado», no «captura todo».
6. **Compatibilidad.** `hookmetamethod`, `getnamecallmethod`, `hookfunction`, `getgc`, `getconnections` y el portapapeles no forman una API uniforme de Roblox para LocalScripts; son capacidades que varían según el executor. Una prueba que solo compruebe `type(...) == "function"` indica presencia, no que el hook funcione correctamente. Las páginas sobre Delta dan versiones y capacidades contradictorias; se necesita una prueba real en el dispositivo, sin enviar credenciales.
7. **Interfaz Gen1.** El [ejemplo de Rayfield](https://github.com/sirius-menu/rayfield/blob/fe922012da6e6d33b41d656095ce62fd5be05047/example.lua) usa `CreateWindow` con campos `Name`/`LoadingTitle` y `CreateTab("Nombre")`, no la API de Gen2 de nuestros hubs. Conviene fijar la versión de la biblioteca y probarla en móvil, pues una URL de rama mutable puede cambiar. Su carga remota y disponibilidad son dependencias externas; no se ha comprobado en Delta iOS.

## Qué significaría «tres veces mejor»

Es un objetivo de diseño, no una ventaja medida ni promesa. Se propone compararlo con una versión concreta de SimpleSpy en el mismo dispositivo y juego de prueba:

- **Menos ruido:** agrupar por identidad/ruta y método, contador, última hora, búsqueda y filtros; un evento muy frecuente no debería llenar la pantalla con miles de filas.
- **Comprensión:** captura «antes/después» de una acción; diferenciar llamadas salientes, señales entrantes y cambios de objetos replicados. Marcar datos incompletos o no serializables en vez de inventarlos.
- **Usabilidad móvil y seguridad:** modo solo lectura por defecto, botones grandes, pausa/limpiar, lista limitada y resumen copiable. No enviar registros a un servidor ni copiar datos sensibles automáticamente.

Para medirlo: reproducir las mismas secuencias locales, contar eventos conocidos, pérdidas/duplicados, coste de CPU y memoria y pasos hasta encontrar una venta. Registrar números reales y versión de executor; no decir «3×» antes de hacer la comparación.

## Arquitectura propuesta

1. **Comprobación de capacidades:** mostrar qué funciones existen, con estados `disponible`, `probada` o `no disponible`; no instalar hooks para probarlos silenciosamente.
2. **Captura saliente:** usar `hookmetamethod(game, "__namecall", ...)` y `getnamecallmethod` solo si están disponibles y el usuario activa captura. Un segundo modo para llamadas directas `remote.FireServer(remote, ...)` requeriría `hookfunction`; no asumir cobertura total del primer modo. Tener cuidado con registros duplicados cuando se usan ambos. Las llamadas deben conservar exactamente argumentos, retornos, errores y comportamiento de `InvokeServer`, incluyendo valores `nil`; nunca bloquear, volver a invocar ni modificar argumentos por defecto.
3. **Captura entrante acotada:** suscribir `OnClientEvent` de remotes detectados y añadidos después; desconectar las conexiones al cerrar. Registrar cobertura y errores por cada conexión. `UnreliableRemoteEvent` debe tratarse de forma separada si el entorno lo permite. `OnClientInvoke` y Actors son fases posteriores, no garantías iniciales.
4. **Normalización:** conservar longitud explícita de argumentos (`table.pack`), límite de profundidad/tamaño, protección de tablas cíclicas, valores especiales y referencias a instancias. No interpretar cadenas como código. Evitar ejecutar metamétodos o asumir que una ruta sigue existiendo.
5. **Memoria local, opcional:** un explorador por petición que muestre conteos y tipos de objetos obtenidos con `getgc`, con límites y filtros. Los datos pueden ser sensibles; no hacer volcado indiscriminado ni escaneo constante. Falta diseñar pruebas por executor antes de implementarlo.
6. **Privacidad:** por defecto guardar solo metadatos; revelar argumentos localmente cuando dj lo solicite, advertir de posibles tokens o IDs, redactar antes de compartir y nunca enviar automáticamente. Evitar chat y credenciales en reportes. Exportación opcional exclusivamente manual.
7. **Ciclo de vida:** pausar, reanudar, limitar eventos, desconectar listeners, limpiar interfaz y controlar reinicios. Un hook puede no poder retirarse limpiamente si otro script se enganchó después; jamás sobrescribir ciegamente hooks de terceros. Si no se puede desmontar, marcar el observador inactivo y avisar que hace falta reiniciar la sesión.
8. **Interfaz:** Rayfield Gen1 para botones/controles y, solo si hace falta para una lista de registros legible, componentes locales complementarios. No depender de Gen2 por accidente. Mostrar que la instrumentación puede implicar riesgos de detección o sanción.

## Fases de entrega

- **Fase 0:** confirmar executor y probar presencia y funcionamiento real de APIs sin capturar ni revelar información privada.
- **Fase 1:** prototipo solo lectura de remotes salientes en VM principal, historia limitada, búsqueda, pausa, limpieza, diagnóstico y exportación manual redactada. Sin reproducción ni modificación.
- **Fase 2:** señales entrantes y comparación antes/después con límites; comprobar que no se pierden argumentos ni se altera el juego. Exploración `getgc` solo si es segura y compatible.
- **Fase 3:** evaluar, no prometer, llamadas directas, `UnreliableRemoteEvent`, callbacks, Actors y serialización avanzada según resultados reales. Reproducción opcional solo tras pruebas separadas y advertencias; nunca necesaria para el observador básico.

## Validación necesaria

- **Mock:** llamadas simuladas con cero argumentos, `nil` intermedios, valores anidados/cíclicos, llamadas frecuentes, errores y resultados múltiples; verificar que el original se invoca exactamente una vez y que argumentos/retornos se conservan. Probar límites de memoria y limpieza, sin interferir con hooks ajenos.
- **Roblox Studio controlado:** experiencia de prueba propia con remotes conocidos, llamadas directas y normales, señales entrantes, errores y pérdida de replicación. Comparar eventos registrados con el registro del juego de prueba.
- **iPhone/Delta:** captura y pausa con el executor y versión reales; comprobar rendimiento, portapapeles, interfaz, cierre, coexistencia de hooks y número de llamadas capturadas. Sin prueba real no afirmar compatibilidad ni que el espía esté «indetectable».

## Aplicación a Desert Detectors

Se puede observar qué mensajes aparecen al vender un objeto normalmente y comparar sus tipos y ruta. Si la venta usa un método no interceptado, un Actor, estado no replicado o un canal diferente, la captura puede quedar vacía. Un remote observado no demuestra que se pueda cambiar su argumento o que el servidor dé dinero; primero habría que corroborar efectos sin alterar datos sensibles ni asumir que el servidor acepta solicitudes fabricadas.
