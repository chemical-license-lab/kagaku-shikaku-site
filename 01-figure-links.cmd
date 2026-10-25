@echo off
chcp 65001 >nul
echo ==========================================================
echo   化学資格研究所：大規模大気特論の図解リンク追加
 echo ==========================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-analysis.ps1"
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
 echo 更新に失敗しました。HTMLの上書きは原則行われていません。
) else (
 echo 処理完了。GitHub Desktopで変更を確認してください。
)
pause
exit /b %result%
