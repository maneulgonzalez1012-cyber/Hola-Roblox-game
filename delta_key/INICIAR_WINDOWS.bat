@echo off
setlocal
cd /d "%~dp0"
title VANTA Delta Key - Experimental
echo ================================================
echo  VANTA Delta Key - Preparacion para Windows
echo ================================================
echo Usar solamente en una red Wi-Fi privada.
echo Este programa NO usa Google ni garantiza obtener la key.
echo.

set "PYTHON="
py -3 -c "import sys;sys.exit(0 if sys.version_info >= (3,9) else 1)" >nul 2>&1
if not errorlevel 1 set "PYTHON=py -3"
if defined PYTHON goto setup
python -c "import sys;sys.exit(0 if sys.version_info >= (3,9) else 1)" >nul 2>&1
if not errorlevel 1 set "PYTHON=python"
if defined PYTHON goto setup
echo No se encontro Python 3.9 o superior.
where winget >nul 2>&1
if errorlevel 1 goto no_python
echo Se puede instalar Python 3.13 desde winget usando Internet.
choice /C SN /N /M "Instalar Python para tu usuario? [S/N]: "
if errorlevel 2 goto no_python
winget install --id Python.Python.3.13 --exact --scope user --accept-package-agreements --accept-source-agreements
if errorlevel 1 goto no_python
if exist "%LOCALAPPDATA%\Programs\Python\Python313\python.exe" set PYTHON="%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
if defined PYTHON goto setup
echo Python se instalo. Cierra y vuelve a abrir este archivo BAT.
pause
exit /b 1

:setup
echo Preparando entorno privado de Python...
if not exist ".venv\Scripts\python.exe" %PYTHON% -m venv .venv
if not exist ".venv\Scripts\python.exe" goto setup_error
.venv\Scripts\python.exe -m pip install -r requirements.txt
if errorlevel 1 goto setup_error
echo.
echo Se mostraran enlaces. Abre uno COMPLETO en Safari del iPhone.
echo Si Windows pregunta por el firewall, permite redes PRIVADAS solamente.
echo Manten esta ventana abierta hasta terminar.
echo.
.venv\Scripts\python.exe app.py --lan
if errorlevel 1 goto server_error
exit /b 0

:no_python
echo Instala Python 3.9 o superior desde https://www.python.org/downloads/windows/
echo Luego vuelve a abrir este BAT. Marca la opcion para agregar Python al PATH.
pause
exit /b 1

:setup_error
echo No se pudo preparar el entorno. Comprueba Internet y tu instalacion de Python.
pause
exit /b 1

:server_error
echo No se pudo iniciar el servidor, o este se detuvo con un error.
echo Comprueba si el puerto 8765 ya esta ocupado y vuelve a intentarlo.
pause
exit /b 1
