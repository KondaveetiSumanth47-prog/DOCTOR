@echo off
title Online Doctor Appointment System - Backend
cd /d "%~dp0backend"

echo ===================================================
echo Starting Spring Boot Backend on http://localhost:8081
echo ===================================================

call mvnw.cmd spring-boot:run
pause
