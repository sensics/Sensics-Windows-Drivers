rem Load the shared variable definitions.
call "%~dp0..\shared.cmd"
pushd "%~dp0"

rem Remove old build products - cat invalidated by timestamp change.
del *.cat *.htm > nul

rem Update the date to today and the version to 7.whateveryouentered
"%WDK_DIR%\bin\x86\stampinf" -f sensics_cdc.inf -d * -v 7.%DRIVER_VER%

popd
pause
