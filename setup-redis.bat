@echo off
echo ==============================================
echo Redis Setup Script for Blackboard Application
echo ==============================================
echo.

echo Checking if Docker is available...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed or not in PATH
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b 1
)

echo Docker found! Setting up Redis...
echo.

echo Stopping existing Redis container (if any)...
docker stop redis-blackboard >nul 2>&1
docker rm redis-blackboard >nul 2>&1

echo Starting Redis container...
docker run -d -p 6379:6379 --name redis-blackboard redis:latest

if %errorlevel% equ 0 (
    echo.
    echo ✅ Redis container started successfully!
    echo.
    echo Testing Redis connection...
    timeout /t 3 /nobreak >nul
    docker exec redis-blackboard redis-cli ping
    
    if %errorlevel% equ 0 (
        echo.
        echo ✅ Redis is running and accessible on localhost:6379
        echo.
        echo You can now start the Spring Boot application with:
        echo mvn spring-boot:run
        echo.
        echo To stop Redis later, run:
        echo docker stop redis-blackboard
        echo.
    ) else (
        echo ❌ Redis connection test failed
    )
) else (
    echo ❌ Failed to start Redis container
    exit /b 1
)

echo ==============================================
echo Setup completed successfully!
echo ==============================================
pause
