@echo off
title Online Doctor Appointment System - Launcher
echo ===================================================
echo Launching Online Doctor Appointment System...
echo ===================================================

start "Backend Server (Spring Boot)" cmd /k "%~dp0start_backend.bat"
timeout /t 5 /nobreak >nul
start "Frontend Server (Vite React)" cmd /k "%~dp0start_frontend.bat"
timeout /t 3 /nobreak >nul
start http://localhost:5173

echo.
echo Both servers have been launched in separate windows!
echo - Frontend: http://localhost:5173
echo - Backend:  http://localhost:8081
echo ===================================================
pause
