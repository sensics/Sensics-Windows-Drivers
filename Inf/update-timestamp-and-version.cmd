rem Load the shared variable definitions.
call "%~dp0..\shared.cmd"
pushd "%~dp0"

set MAJOR_VERSION_OVERRIDE=10

rem Remove old build products - cat invalidated by timestamp change.
del *.cat *.htm > nul

rem Update the date to today and the version to MAJOR_VERSION_OVERRIDE.whateveryouentered
"%WDK_DIR%\bin\x86\stampinf" -f sensics_cdc.inf -d * -v %MAJOR_VERSION_OVERRIDE%.%DRIVER_VER%
s
rem Update the date to today and the version to 1.whateveryouentered
"%WDK_DIR%\bin\x86\stampinf" -f sensics_display.inf -d * -v 1.%DRIVER_VER%

popd
pause
