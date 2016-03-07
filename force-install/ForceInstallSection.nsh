; Install wrapper for old VID/PID force installer
;
; Authored by Sensics, Inc. <http://sensics.com/osvr>
;
; Copyright 2016 Sensics, Inc.
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


!define FORCEINSTALL_DIR $PLUGINSDIR\ForceInstall

Section -ForceInstall
  InitPluginsDir
  SetOutPath "${FORCEINSTALL_DIR}"
  ; libwdi
  File "${REPO_ROOT}\force-install\libwdi-COPYING"
  File "${REPO_ROOT}\force-install\libwdi-COPYING-LGPL"
  File "${REPO_ROOT}\force-install\libwdi-README"
  File "${REPO_ROOT}\force-install\libwdi-source.txt"
  File "${REPO_ROOT}\force-install\libwdi.dll"

  ; VC runtime
  File "${REPO_ROOT}\force-install\msvcp140.dll"
  File "${REPO_ROOT}\force-install\vcruntime140.dll"

  ; the tool itself
  File "${REPO_ROOT}\force-install\README.txt"
  File "${REPO_ROOT}\force-install\force-install-libwdi.exe"

  ; Run the tool
  nsExec::ExecToLog '"${FORCEINSTALL_DIR}\force-install-libwdi.exe" "--auto"'
  ; Don't care about return code
  Pop $0

  SetOutPath $TEMP
  RMDir /r "${FORCEINSTALL_DIR}"
  SetErrorLevel 0
SectionEnd
