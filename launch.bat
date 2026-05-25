@echo off
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
set ANDROID_SDK_ROOT=%LOCALAPPDATA%\Android\Sdk

echo Aceptando licencias...
echo y | "%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat" --licenses

echo Lanzando emulador Pixel_5...
start "" "%ANDROID_SDK_ROOT%\emulator\emulator.exe" -avd Pixel_5 -no-snapshot-load

echo Esperando que el emulador arranque...
ping -n 30 127.0.0.1 > nul

echo Corriendo la app Flutter...
cd /d "%~dp0"
flutter run -d emulator-5554
