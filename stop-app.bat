@echo off
echo ==============================================
echo Stopping Blackboard Application and Redis
echo ==============================================
echo.

echo Stopping Redis container...
docker stop redis-blackboard >nul 2>&1

if %errorlevel% equ 0 (
    echo ✅ Redis container stopped successfully!
) else (
    echo ⚠️  Redis container was not running or failed to stop
)

echo.
echo Checking for running Spring Boot processes...
for /f "tokens=2" %%i in ('netstat -ano ^| findstr :8081') do (
    echo Stopping process %%i...
    taskkill /F /PID %%i >nul 2>&1
)

echo.
echo ✅ All services stopped!
echo.
pause
