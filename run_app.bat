@echo off
set EMULATOR=%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe
set ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe

echo Iniciando emulador Pixel_5...
start "" "%EMULATOR%" -avd Pixel_5 -no-snapshot-load

echo Esperando que el emulador arranque (60 segundos)...
ping -n 60 127.0.0.1 > nul

echo Verificando dispositivo...
"%ADB%" devices

echo Corriendo app Flutter...
cd /d "%~dp0"
flutter run -d emulator-5554

pause
