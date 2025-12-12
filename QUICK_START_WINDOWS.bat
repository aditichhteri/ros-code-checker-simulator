@echo off
REM ========================================
REM ROS Code Checker - Windows Quick Start
REM ========================================

echo.
echo ========================================
echo  ROS Code Checker Setup
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ from python.org
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

echo [1/6] Python found!
echo.

REM Create virtual environment if it doesn't exist
if not exist "venv\" (
    echo [2/6] Creating virtual environment...
    python -m venv venv
    echo     Virtual environment created!
) else (
    echo [2/6] Virtual environment already exists
)
echo.

REM Activate virtual environment
echo [3/6] Activating virtual environment...
call venv\Scripts\activate.bat
echo     Activated!
echo.

REM Install dependencies
echo [4/6] Installing dependencies...
pip install --quiet flask
echo     Flask installed!
echo.

REM Build project files from markdown
echo [5/6] Building project files...
if exist "BUILD_PROJECT.py" (
    python BUILD_PROJECT.py
    echo     Project files created!
) else (
    echo     BUILD_PROJECT.py not found, skipping...
)
echo.

REM Create example files folder
if not exist "examples\" mkdir examples

REM Create good_talker.py
echo [6/6] Creating example ROS files...
(
echo #!/usr/bin/env python
echo import rospy
echo from std_msgs.msg import String
echo.
echo def talker^(^):
echo     pub = rospy.Publisher^('chatter', String, queue_size=10^)
echo     rospy.init_node^('talker', anonymous=True^)
echo     rate = rospy.Rate^(10^)
echo     
echo     while not rospy.is_shutdown^(^):
echo         hello_str = "hello world %%s" %% rospy.get_time^(^)
echo         rospy.loginfo^(hello_str^)
echo         pub.publish^(hello_str^)
echo         rate.sleep^(^)
echo.
echo if __name__ == '__main__':
echo     try:
echo         talker^(^)
echo     except rospy.ROSInterruptException:
echo         pass
) > examples\good_talker.py

REM Create bad_talker.py
(
echo #!/usr/bin/env python
echo import rospyy
echo from std_msgs.msg import String
echo.
echo def talker^(^):
echo     pub = rospy.Publisher^('chatter', String, queue_size=10^)
echo     rate = rospy.Rate^(10^)
echo     
echo     while not rospy.is_shutdown^(^):
echo         hello_str = "hello world %%s" %% rospy.get_time^(^)
echo         rospy.loginfo^(hello_str^)
echo         pub.publish^(hello_str^)
echo         rate.sleep^(^)
echo.
echo try:
echo     talker^(^)
echo except rospy.ROSInterruptException:
echo     pass
) > examples\bad_talker.py

echo     Example files created in examples\ folder!
echo.

echo ========================================
echo  Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Open a NEW Command Prompt window
echo 2. Navigate to this folder
echo 3. Run: START_WEB_APP.bat
echo.
echo Press any key to close this window...
pause >nul
