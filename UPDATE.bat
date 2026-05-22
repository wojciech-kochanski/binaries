@echo off
if "%~1"=="--running" goto :main
cmd /k ""%~f0" --running"
exit

:main
chcp 65001 >nul
cls

echo.
echo +----------------------------------------------------------+
echo ^|             GIT UPDATE - RESET + PULL                   ^|
echo +----------------------------------------------------------+
echo.

git diff --quiet
set CHANGES_TRACKED=%ERRORLEVEL%

set UNTRACKED_COUNT=0
for /f %%i in ('git ls-files --others --exclude-standard') do set UNTRACKED_COUNT=1

if %CHANGES_TRACKED%==0 if %UNTRACKED_COUNT%==0 (
    echo  [OK] Brak lokalnych zmian od ostatniego pull.
    echo.
    goto :do_pull
)

echo +----------------------------------------------------------+
echo ^|  [!!] UWAGA: Wykryto lokalne zmiany! Odrzucam je...    ^|
echo +----------------------------------------------------------+
echo.
git checkout -- .
git clean -fd
echo.
echo  [OK] Lokalne zmiany zostaly odrzucone.
echo.

:do_pull
for /f "tokens=*" %%i in ('git log -1 --format^=%%H 2^>nul') do set BEFORE_HASH=%%i

echo  [ ] Pobieram zmiany z remote...
echo.
git pull
set PULL_RESULT=%ERRORLEVEL%
echo.

if %PULL_RESULT% NEQ 0 (
    powershell -Command "Write-Host '+----------------------------------------------------------+' -ForegroundColor Red; Write-Host '|  [XX] BLAD: git pull zakonczyl sie bledem!             |' -ForegroundColor Red; Write-Host '+----------------------------------------------------------+' -ForegroundColor Red"
    echo.
    echo Nacisnij dowolny klawisz lub zamknij okno...
    pause >nul
    exit /b %PULL_RESULT%
)

for /f "tokens=*" %%i in ('git log -1 --format^=%%H 2^>nul') do set AFTER_HASH=%%i
for /f "tokens=*" %%i in ('git log -1 --format^=%%ai 2^>nul') do set AFTER_DATE=%%i
for /f "tokens=*" %%i in ('git log -1 --format^=%%s 2^>nul') do set AFTER_MSG=%%i
for /f "tokens=*" %%i in ('git log -1 --format^=%%an 2^>nul') do set AFTER_AUTHOR=%%i

if "%BEFORE_HASH%"=="%AFTER_HASH%" (
    powershell -Command "Write-Host '+----------------------------------------------------------+' -ForegroundColor Green; Write-Host '|  [OK] Repozytorium jest aktualne. Nic do pobrania.    |' -ForegroundColor Green; Write-Host '+----------------------------------------------------------+' -ForegroundColor Green"
) else (
    powershell -Command "Write-Host '+----------------------------------------------------------+' -ForegroundColor Green; Write-Host '|  [OK] Pobrano nowe zmiany z remote!                    |' -ForegroundColor Green; Write-Host '+----------------------------------------------------------+' -ForegroundColor Green; Write-Host '|  OSTATNI COMMIT:' -ForegroundColor Green; Write-Host ('|    Data   : %AFTER_DATE%') -ForegroundColor Green; Write-Host ('|    Autor  : %AFTER_AUTHOR%') -ForegroundColor Green; Write-Host ('|    Koment.: %AFTER_MSG%') -ForegroundColor Green; Write-Host '+----------------------------------------------------------+' -ForegroundColor Green"
)

echo.
echo  Nacisnij dowolny klawisz lub zamknij okno...
pause >nul