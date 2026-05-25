@echo off
title Backend Monedas API (Downloads)
echo ============================================
echo  Iniciando Backend desde Downloads
echo ============================================
echo.
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.11.10-hotspot
set PATH=%JAVA_HOME%\bin;%PATH%
cd /d "%~dp0apiMonedas\presentacion"
echo JDK: 
java -version 2>&1
echo.
echo Compilando e iniciando servidor...
echo.
call ..\mvnw spring-boot:run
pause
