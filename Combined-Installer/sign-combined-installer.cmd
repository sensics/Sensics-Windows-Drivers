
rem Load the shared variable definitions.
call "%~dp0..\shared.cmd"

pushd "%~dp0"

"%WDK_DIR%\bin\x86\Signtool" sign /v /n %CERTNAME% /t %TIMESTAMP_SERVER% Sensics-Combined-Driver-Installer*.exe

popd
