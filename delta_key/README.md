# VANTA Delta Key — experimental

Intenta obtener la key desde una URL `https://auth.platorelay.com/a?d=...`. Usa una interfaz HTML para iPhone y un servidor Python. **No está probado contra una sesión real ni garantiza éxito.** Basado en la secuencia de [Delta-solve-keysystem-tool](https://github.com/xiaobai1023/Delta-solve-keysystem-tool), cuya licencia MIT se incluye en `UPSTREAM-LICENSE.txt`. Su funcionamiento y vigencia no están verificados.

## Windows: iniciar con el BAT y conectar el iPhone

1. Descarga el ZIP y **extrae todos los archivos** a una carpeta en la computadora Windows. No ejecutes el BAT desde dentro del ZIP.
2. Conecta Windows y el iPhone a una Wi-Fi privada. Ejecuta `INICIAR_WINDOWS.bat` con doble clic. Si falta Python, el BAT ofrece instalarlo con winget; si no está disponible, instala Python desde python.org y vuelve a abrir el BAT. El BAT crea un entorno local e instala la dependencia con Internet.
3. Si el firewall de Windows pregunta, permite el acceso de Python solo en **redes privadas**. Mantén abierta la ventana negra del BAT: ahí aparecerán uno o más enlaces completos con una IP, puerto y token después de `#`.
4. En el iPhone, abre Safari o Chrome y escribe uno de esos enlaces **completos**, incluido el token. Si hay varias direcciones prueba la que corresponda al Wi-Fi en `ipconfig`; las otras pueden ser de adaptadores virtuales o VPN.
5. La página indica si se conectó a la computadora y la ventana del BAT muestra `[OK]` al recibir una conexión remota autorizada. Esto demuestra conectividad, **no prueba que estén en la misma Wi-Fi**: redes enrutadas o VPN también podrían permitirla. Si no carga, revisa Wi-Fi, IP y firewall; algunas redes bloquean la comunicación entre dispositivos.
6. En Delta del iPhone, copia el enlace de key. Pégalo en la página y pulsa **Intentar obtener key**. Si devuelve una key, cópiala manualmente y pégala en Delta. No hay garantía de éxito. Para terminar, cierra la ventana del BAT.

La URL local contiene un token secreto; no la publiques ni la compartas con terceros. El token cambia al reiniciar. Si recargas la página, vuelve a abrir el enlace completo.

## Inicio manual para macOS / Linux

1. Instala Python 3.9+ en tu computadora. En una terminal, dentro de `delta_key`, ejecuta:
   ```sh
   python3 -m venv .venv
   .venv/bin/python -m pip install -r requirements.txt
   .venv/bin/python app.py --lan
   ```
   En Windows usa `py -m venv .venv`, luego `.venv\Scripts\python -m pip install -r requirements.txt` y `.venv\Scripts\python app.py --lan`.
2. Conecta computadora y iPhone a la **misma red Wi-Fi privada**. Averigua la IP local de la computadora (`ipconfig` en Windows; Ajustes del Sistema > Red en macOS).
3. La terminal muestra una URL `http://127.0.0.1:8765/#...`. En el iPhone abre esa misma URL, sustituyendo `127.0.0.1` por la IP local de la computadora; conserva `:8765/#` y todo el token que sigue. Por ejemplo, si la IP es `192.168.1.5`, empieza con `http://192.168.1.5:8765/#` y añade el token mostrado. Puede ser necesario permitir Python en el firewall para redes privadas.
4. Pega la URL de Delta en la página y pulsa **Intentar obtener key**. Copia la key si aparece. Cierra el servidor con Ctrl+C.

Para usarlo solo en la misma computadora, inicia `.venv/bin/python app.py` sin `--lan` y abre la URL que muestra. Para ejecutarlo en el propio iPhone se necesita una app de Python compatible con `pycryptodome` y servidores locales; **no se ha comprobado esa configuración**. Abrir el HTML por sí solo no ejecuta Python.

## Privacidad y limitaciones

- El tráfico entre iPhone y computadora usa HTTP **sin cifrar**. No usar Wi-Fi pública/compartida ni reenviar puertos. El token del enlace limita accesos casuales, pero no protege frente a alguien que pueda espiar la red. No compartas el enlace con token.
- Las peticiones al proveedor salen desde **la computadora**, no usan las cookies ni cuenta Google del iPhone. Una vinculación a dispositivo/IP, CAPTCHA, controles de servidor, cambios del protocolo o servicio desactualizado pueden impedir el resultado.
- La URL de Delta y la key se mantienen en memoria durante la solicitud; el servidor no las escribe ni registra. No se verifica la key contra el dispositivo.
- No solicitamos contraseñas, cookies ni HWID. Las peticiones van únicamente a `auth.platorelay.com`; no se sigue ningún redirect de red y se valida el dominio del ticket de retorno.
- El cliente simula una huella de navegador; **no** controla Chrome ni usa tu sesión Google. Usar la herramienta puede incumplir las condiciones del proveedor. El código es legible; Luarmor es para Luau y no está disponible aquí para este Python/HTML.
