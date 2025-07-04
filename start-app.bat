@echo off
echo ==============================================
echo Starting Blackboard Application
echo ==============================================
echo.

echo Checking if Redis is running...
docker exec redis-blackboard redis-cli ping >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Redis is not running!
    echo Please run setup-redis.bat first to start Redis.
    echo.
    choice /c YN /m "Do you want to start Redis now?"
    if !errorlevel! equ 1 (
        call setup-redis.bat
    ) else (
        echo Exiting...
        pause
        exit /b 1
    )
)

echo ✅ Redis is running!
echo.

echo Starting Spring Boot application...
echo The application will be available at: http://localhost:8081
echo.
echo Press Ctrl+C to stop the application
echo.

mvn spring-boot:run
