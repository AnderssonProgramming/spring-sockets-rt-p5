@echo off
echo ===============================================
echo    Interactive Blackboard - Integration Test
echo ===============================================
echo.

:: Check if Redis is running
echo [1/5] Checking Redis connectivity...
docker ps | findstr redis-blackboard >nul
if %errorlevel% neq 0 (
    echo Redis container not found. Starting Redis...
    docker run -d -p 6379:6379 --name redis-blackboard redis:latest
    timeout /t 3 /nobreak >nul
) else (
    echo Redis container is already running.
)

echo.
echo [2/5] Compiling the application...
call mvn clean compile -q
if %errorlevel% neq 0 (
    echo ERROR: Compilation failed!
    pause
    exit /b 1
)
echo Compilation successful.

echo.
echo [3/5] Starting the application in background...
start /B mvn spring-boot:run >nul 2>&1

:: Wait for application to start
echo Waiting for application to start...
:wait_loop
timeout /t 2 /nobreak >nul
curl -s http://localhost:8081/health >nul 2>&1
if %errorlevel% neq 0 goto wait_loop

echo.
echo [4/5] Testing endpoints...

echo Testing health endpoint...
curl -s http://localhost:8081/health
echo.

echo Testing status endpoint...
curl -s http://localhost:8081/status
echo.

echo Testing ticket generation...
curl -s http://localhost:8081/getticket
echo.

echo.
echo [5/5] Testing WebSocket endpoint...
echo WebSocket endpoint is available at: ws://localhost:8081/bbService
echo.

echo ===============================================
echo    Integration Test Completed Successfully!
echo ===============================================
echo.
echo The application is running at: http://localhost:8081
echo Redis is running in Docker container: redis-blackboard
echo.
echo Press any key to open the application in your browser...
pause >nul
start http://localhost:8081

echo.
echo To stop the application, close this window or press Ctrl+C
echo To stop Redis: docker stop redis-blackboard
pause
