@echo off
title Online Doctor Appointment System - Backend
cd /d "%~dp0backend"

echo ===================================================
echo Starting Spring Boot Backend on http://localhost:8081
echo ===================================================

REM Default to local MySQL when DATABASE_URL is not provided
if "%DATABASE_URL%"=="" (
    if "%DB_URL%"=="" (
        set "DB_URL=jdbc:mysql://localhost:3306/doctor_appointment?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
    )
    if "%DB_USERNAME%"=="" (
        set "DB_USERNAME=root"
    )
    if "%DB_PASSWORD%"=="" (
        set "DB_PASSWORD=Sumanth@123"
    )
)

call mvnw.cmd spring-boot:run
pause

