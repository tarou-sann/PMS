@echo off
chcp 65001 >nul 2>&1
setlocal

title PMS Application Launcher
cd /d "%~dp0"

echo ================================================================
echo                    PMS APPLICATION LAUNCHER
echo ================================================================
echo.
echo Current directory: %CD%
echo.

echo Starting Backend Server...
echo Opening backend window...
start "PMS Backend Server" cmd /k "cd backend && echo Backend Starting... && python app.py --host 0.0.0.0 --port 5000"

echo.
echo Waiting 8 seconds for backend to initialize...
timeout /t 8 /nobreak >nul

echo.
echo Starting Frontend...
echo Opening frontend window...
start "PMS Frontend" cmd /k "cd frontend\pms_frontend && echo Frontend Starting... && flutter run -d chrome --web-port 3000"

echo.
echo Waiting for Flutter to compile and open browser...
echo (Flutter will automatically open Chrome when ready)
timeout /t 5 /nobreak >nul

REM Removed this line that was causing the second browser:
REM start "" "http://localhost:3000"

echo.
echo ================================================================
echo            PMS APPLICATION IS NOW RUNNING!
echo ================================================================
echo.
echo URLs:
echo   Frontend:     http://localhost:3000 (auto-opened by Flutter)
echo   Backend API:  http://localhost:5000/api
echo   Health Check: http://localhost:5000/api/health
echo.
echo Windows opened:
echo   - PMS Backend Server: Shows Flask logs
echo   - PMS Frontend: Shows Flutter build process
echo   - Chrome Browser: Automatically opened by Flutter
echo.
echo Note: Flutter automatically opens Chrome when ready.
echo If you need to open additional browsers, use the options below.
echo.
echo To stop the application:
echo   - Close the Backend and Frontend windows
echo   - Or press Ctrl+C in those windows
echo.
echo ================================================================

echo.
choice /c YN /m "Keep this launcher open for quick access to URLs"
if errorlevel 2 goto end

echo.
echo Quick Actions:
echo   B - Open Backend API in browser
echo   F - Open Frontend in new browser window
echo   H - Open Health Check in browser
echo   Q - Quit launcher
echo.

:menu
set /p choice="Enter choice (B/F/H/Q): "

if /i "%choice%"=="B" (
    start "" "http://localhost:5000/api"
    echo Backend API opened in browser
    goto menu
)
if /i "%choice%"=="F" (
    start "" "http://localhost:3000"
    echo Frontend opened in new browser window
    goto menu
)
if /i "%choice%"=="H" (
    start "" "http://localhost:5000/api/health"
    echo Health check opened in browser
    goto menu
)
if /i "%choice%"=="Q" goto end

echo Invalid choice. Please enter B, F, H, or Q.
goto menu

:end
echo.
echo Launcher closing. Your services will continue running.
echo To stop them, close the Backend and Frontend windows.
pause