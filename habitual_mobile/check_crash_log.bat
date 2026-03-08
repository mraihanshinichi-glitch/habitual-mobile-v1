@echo off
echo ========================================
echo Checking for crash logs...
echo ========================================
echo.

echo Checking connected devices:
adb devices
echo.

echo ========================================
echo Flutter logs (last 100 lines):
echo ========================================
adb logcat -d | findstr /i "flutter" | more

echo.
echo ========================================
echo Fatal errors (last 50 lines):
echo ========================================
adb logcat -d | findstr /i "fatal error crash exception" | more

echo.
echo ========================================
echo Habitual app logs:
echo ========================================
adb logcat -d | findstr /i "habitual" | more

echo.
echo Press any key to exit...
pause > nul
