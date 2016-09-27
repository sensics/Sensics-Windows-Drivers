; Install wrapper for Sensics HMD controller CDC serial port + other infs
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

!define CDC_DRIVER_NAME sensics_cdc
!define DISPLAY_DRIVER_NAME sensics_display


!define ATMEL_USB_DFU_DIR atmel_usb_dfu
!define ATMEL_USB_DFU_SRC ${REPO_ROOT}\vendor\${ATMEL_USB_DFU_DIR}


Section -CDC_INF
  Var /GLOBAL DPINST_RET
  !define INF_DIR $PLUGINSDIR\cdc
  !define INF_SRC_DIR ${REPO_ROOT}\Inf
  InitPluginsDir
  SetOutPath "${INF_DIR}"
  DetailPrint "Temporarily extracting driver infs and cat along with installation tool."

  ; CDC driver inf + signed catalog file
    DetailPrint "USB-CDC driver:"
    File "${INF_SRC_DIR}\${CDC_DRIVER_NAME}.inf"
    File "${INF_SRC_DIR}\${CDC_DRIVER_NAME}.cat"

  ; Nearly-dummy display driver inf + signed catalog file
  DetailPrint "Display interface driver:"
  File "${INF_SRC_DIR}\${DISPLAY_DRIVER_NAME}.inf"
  File "${INF_SRC_DIR}\${DISPLAY_DRIVER_NAME}.cat"

  ; Atmel USB DFU driver
  DetailPrint "Atmel DFU firmware upgrade interface driver:"
  SetOutPath "${INF_DIR}\${ATMEL_USB_DFU_DIR}"
  File "${ATMEL_USB_DFU_SRC}\README.txt"
  File "${ATMEL_USB_DFU_SRC}\COPYING_GPL.txt"
  File "${ATMEL_USB_DFU_SRC}\atmel_usb_dfu.inf"
  File "${ATMEL_USB_DFU_SRC}\atmel_usb_dfu.cat"

  SetOutPath "${INF_DIR}\${ATMEL_USB_DFU_DIR}\x86"
  File "${ATMEL_USB_DFU_SRC}\x86\libusb0.sys"
  File "${ATMEL_USB_DFU_SRC}\x86\libusb0_x86.dll"

  SetOutPath "${INF_DIR}\${ATMEL_USB_DFU_DIR}\amd64"
  File "${ATMEL_USB_DFU_SRC}\amd64\libusb0.sys"
  File "${ATMEL_USB_DFU_SRC}\amd64\libusb0.dll"

  SetOutPath "${INF_DIR}\${ATMEL_USB_DFU_DIR}\ia64"
  File "${ATMEL_USB_DFU_SRC}\ia64\libusb0.sys"
  File "${ATMEL_USB_DFU_SRC}\ia64\libusb0.dll"

  SetOutPath "${INF_DIR}"

  DetailPrint "Driver installer support files:"
  ; DIFx/DPInst configuration file
  File "${REPO_ROOT}\Inf-NSIS-Installer\dpinst.xml"

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


  DetailPrint "Running 'DPInst' driver installation tool."
  ${If} ${RunningX64}
    ExecWait '"${INF_DIR}\dpinst64.exe" $DPINST_ARGS_RUNTIME /PATH "${INF_DIR}"' $DPINST_RET
  ${Else}
    ExecWait '"${INF_DIR}\dpinst32.exe" $DPINST_ARGS_RUNTIME /PATH "${INF_DIR}"' $DPINST_RET
  ${EndIf}


  DetailPrint "'DPInst' completed with exit code $DPINST_RET"

  ; This is the maximum value to not have any failures reported (0x0000FFFF)
  ; https://msdn.microsoft.com/en-us/library/windows/hardware/ff544790(v=vs.85).aspx
  ${If} $DPINST_RET U> 65535
    DetailPrint "DPInst returned a value indicating a driver failed to install: $DPINST_RET"
    SetErrorLevel $DPINST_RET
    SetDetailsView show
    SetAutoClose false
  ${Else}
    DetailPrint "Driver installation completed successfully."
    SetErrorLevel 0
  ${EndIf}

  DetailPrint "Cleaning up temporary files."

  SetOutPath $TEMP
  RMDir /r "${INF_DIR}"

  ;SetOutPath $TEMP
  ;RMDir /r $INSTDIR
SectionEnd
