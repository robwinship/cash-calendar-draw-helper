@echo off
REM Push updates to cash-calendar-draw-helper GitHub repository

cd /d "c:\Users\Admin\OneDrive\Documents\Coding\RNG"

echo Staging changes...
git add -A

echo Committing updates...
git commit -m "feat: implement week-based draw system with auto-incrementing dates and week grouping"

echo Pushing to main branch...
git push origin main

echo.
echo ✓ Deploy complete! 
echo Live at: https://robwinship.github.io/cash-calendar-draw-helper/
echo.
pause
