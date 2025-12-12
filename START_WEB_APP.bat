@echo off
REM ========================================
REM ROS Code Checker - Start Web Application
REM ========================================

echo.
echo ========================================
echo  Starting ROS Code Checker Web App
echo ========================================
echo.

REM Check if virtual environment exists
if not exist "venv\" (
    echo ERROR: Virtual environment not found!
    echo Please run QUICK_START_WINDOWS.bat first
    pause
    exit /b 1
)

REM Activate virtual environment
echo [1/3] Activating virtual environment...
call venv\Scripts\activate.bat
echo     Activated!
echo.

REM Check if web_interface folder exists
if not exist "web_interface\" (
    echo ERROR: web_interface folder not found!
    echo Please make sure you're in the project root folder
    pause
    exit /b 1
)

REM Navigate to web interface folder
echo [2/3] Navigating to web_interface folder...
cd web_interface
echo     Done!
echo.

REM Start the Flask application
echo [3/3] Starting Flask web server...
echo.
echo ========================================
echo  Web App Running!
echo ========================================
echo.
echo Open your browser and go to:
echo http://localhost:5000
echo.
echo Press CTRL+C to stop the server
echo ========================================
echo.

python app.py

REM If the script exits, return to parent folder
cd ..
pause
