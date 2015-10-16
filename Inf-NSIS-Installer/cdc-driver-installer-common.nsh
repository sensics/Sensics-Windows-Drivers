; Install wrapper for Sensics HMD controller CDC serial port inf
; Common code between silent and "normal" installer
;
; Authored by Sensics, Inc. <http://sensics.com/osvr>
;
; Copyright 2015 Sensics, Inc.
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
; 	http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.


!include LogicLib.nsh
!include WinVer.nsh

ManifestSupportedOS WinVista Win7 Win8 {8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a}

;Section -SETTINGS
;  SetOutPath "$INSTDIR"
;  SetOverwrite ifnewer
;SectionEnd

Var DPINST_ARGS_RUNTIME

!define DRIVER_NAME sensics_cdc

Section -CDC_INF
  Var /GLOBAL DPINST_RET
  !define CDC_DIR $PLUGINSDIR\cdc
  !define CDC_SRC_DIR ${REPO_ROOT}\CDC
  InitPluginsDir
  SetOutPath "${CDC_DIR}"
  DetailPrint "Temporarily extracting driver inf and cat along with installation tool."

  ; CDC driver inf
  File "${CDC_SRC_DIR}\${DRIVER_NAME}.inf"

  ; Signed catalog file
  File "${CDC_SRC_DIR}\${DRIVER_NAME}.cat"

  ; DIFx/DPInst configuration file
  File "${REPO_ROOT}\CDC-NSIS-Installer\dpinst.xml"

  File /oname=installer.ico "${INSTALLER_ICON}"

  ; Locally-vendored copies of dpinst from the WDK
  ; File /oname=$INSTDIR\dpinst32.exe redist\wdk10\x86\dpinst.exe
  ; File /oname=$INSTDIR\dpinst64.exe redist\wdk10\x64\dpinst.exe

  ; Directly-sourced versions of dpinst from the WDK, specified as a command-line define.
  File /oname=dpinst32.exe "${WDK_DIR}\Redist\DIFx\dpinst\MultiLin\x86\dpinst.exe"
  File /oname=dpinst64.exe "${WDK_DIR}\Redist\DIFx\dpinst\MultiLin\x64\dpinst.exe"

  StrCpy $DPINST_ARGS_RUNTIME ""
  IfSilent 0 SkipSilentFlag
  StrCpy $DPINST_ARGS_RUNTIME "/sw" ; dpinst takes this arg to be silent-ish.
  SkipSilentFlag:

  ${If} ${AtLeastWin10}
    DetailPrint "Windows 10 does not need USB-CDC driver installed."
    SetDetailsView show
    SetAutoClose false
  ${Else}
    DetailPrint "Running 'DPInst' driver installation tool."
    ${If} ${RunningX64}
      ExecWait '"${CDC_DIR}\dpinst64.exe" $DPINST_ARGS_RUNTIME /PATH "${CDC_DIR}"' $DPINST_RET
    ${Else}
      ExecWait '"${CDC_DIR}\dpinst32.exe" $DPINST_ARGS_RUNTIME /PATH "${CDC_DIR}"' $DPINST_RET
    ${EndIf}


    DetailPrint "'DPInst' completed with exit code $DPINST_RET"

    ; 512 is two drivers copied to the driver store, or any combination of up to 2 successes.
    ${If} $DPINST_RET U> 512
      DetailPrint "DPInst returned a value indicating a driver failed to install: $DPINST_RET"
      SetErrorLevel $DPINST_RET
      SetDetailsView show
      SetAutoClose false
    ${Else}
      DetailPrint "Driver installation completed successfully."
      SetErrorLevel 0
    ${EndIf}

  ${EndIf}
  DetailPrint "Cleaning up temporary files."

  SetOutPath $TEMP
  RMDir /r "${CDC_DIR}"

  ;SetOutPath $TEMP
  ;RMDir /r $INSTDIR
SectionEnd
