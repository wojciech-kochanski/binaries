@echo off
if "%~1"=="--running" goto :main
cmd /k ""%~f0" --running"
exit

:main
chcp 65001 >nul
cls

:: Wlacz kolory ANSI w cmd
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

set GREEN=[32m
set RESET=[0m

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
    echo +----------------------------------------------------------+
    echo ^|  [XX] BLAD: git pull zakonczyl sie bledem!             ^|
    echo +----------------------------------------------------------+
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
    echo %GREEN%+----------------------------------------------------------+%RESET%
    echo %GREEN%^|  [OK] Repozytorium jest aktualne. Nic do pobrania.    ^|%RESET%
    echo %GREEN%+----------------------------------------------------------+%RESET%
) else (
    echo %GREEN%+----------------------------------------------------------+%RESET%
    echo %GREEN%^|  [OK] Pobrano nowe zmiany z remote!                    ^|%RESET%
    echo %GREEN%+----------------------------------------------------------+%RESET%
    echo %GREEN%^|  OSTATNI COMMIT:                                        ^|%RESET%
    echo %GREEN%^|    Data   : %AFTER_DATE%%RESET%
    echo %GREEN%^|    Autor  : %AFTER_AUTHOR%%RESET%
    echo %GREEN%^|    Koment.: %AFTER_MSG%%RESET%
    echo %GREEN%+----------------------------------------------------------+%RESET%
)

echo.
echo  Nacisnij dowolny klawisz lub zamknij okno...
pause >nul