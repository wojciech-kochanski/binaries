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
for /f "tokens=*" %%i in ('git log -1 --format="%%H" 2^>nul') do set BEFORE_HASH=%%i

echo  [ ] Pobieram zmiany z remote...
echo.
git pull
set PULL_RESULT=%ERRORLEVEL%
echo.

if %PULL_RESULT% NEQ 0 (
    echo +----------------------------------------------------------+
    echo ^|  [XX] BLAD: git pull zakonczyl sie bledem!             ^|
    echo +----------------------------------------------------------+
    echo.
    echo Nacisnij dowolny klawisz lub zamknij okno...
    pause >nul
    exit /b %PULL_RESULT%
)

for /f "tokens=*" %%i in ('git log -1 --format="%%H" 2^>nul') do set AFTER_HASH=%%i
for /f "tokens=*" %%i in ('git log -1 --format="%%ai" 2^>nul') do set AFTER_DATE=%%i
for /f "tokens=*" %%i in ('git log -1 --format="%%s" 2^>nul') do set AFTER_MSG=%%i
for /f "tokens=*" %%i in ('git log -1 --format="%%an" 2^>nul') do set AFTER_AUTHOR=%%i

if "%BEFORE_HASH%"=="%AFTER_HASH%" (
    echo +----------------------------------------------------------+
    echo ^|  [OK] Repozytorium jest aktualne. Nic do pobrania.    ^|
    echo +----------------------------------------------------------+
) else (
    echo +----------------------------------------------------------+
    echo ^|  [OK] Pobrano nowe zmiany z remote!                    ^|
    echo +----------------------------------------------------------+
    echo ^|  OSTATNI COMMIT:                                        ^|
    echo ^|    Data   : %AFTER_DATE%
    echo ^|    Autor  : %AFTER_AUTHOR%
    echo ^|    Koment.: %AFTER_MSG%
    echo +----------------------------------------------------------+
)

echo.
echo  Nacisnij dowolny klawisz lub zamknij okno...
pause >nul