@echo off
title Online Doctor Appointment System - Frontend
cd /d "%~dp0frontend"

echo ===================================================
echo Starting React Vite Frontend on http://localhost:5173
echo ===================================================

call npm run dev
pause
