; =====================================================
; mono.nsi - Mono Setup Wizard for Windows
;            uses NullSoft Installer System
;            found at http://nsis.sourceforge.net/
; =====================================================
;
; (C) Copyright 2003 by Johannes Roith
; (C) Copyright 2003 by Daniel Morgan
;
; Authors: 
;       Johannes Roith <johannes@jroith.de>
;       Daniel Morgan <danmorg@sc.rr.com>
;
; This .nsi includes code from the NSIS Archives:
; function StrReplace
; by Hendri Adriaens
; HendriAdriaens@hotmail.com
; 
; =====================================================
;
; This script can build a binary setup wizard of mono.
; It is released under the GNU GPL.
;
; =====================================================
; SET MILESTONE & SOURCE DIR
; =====================================================
;
;
  !define MILESTONE "0.23" ;
  !define SOURCE_INSTALL_DIR "c:\mono-0.23\install\\*" ;

; =====================================================
; BUILDING
; =====================================================
;
; 1. Build mono. The install directory must not contain
;    anything else - everything gets packed in!!!
;
; 2. In your install directory, delete the *.a files.
;     Most people won't need them and it saves ~ 4 MB.
;
; 3. Get latest the latest NSIS from cvs or 
;    a development snapshot
;    from http://nsis.sourceforge.net/
;
;    Documentation for it can be found
;
; 4. Adapt the MILESTONE
;
; 5. Adapt the SOURCE_INSTALL_DIR above to match your 
;     install directory. Do not remove \\* at the end!!
;
; 6. Open this script in makensisw.exe
;
; 7. The output file is mono-[MILESTONE]-win32-1.exe
;    If there has been a mono-[MILESTONE]-win32-1.exe
;    created, then increment the number after win32- 
;    to indicate the win32 package build number, such as,
;    mono-[MILESTONE]-win32-2.exe  
;    Usually, this would be done if there were errors in
;    the 1st package that was released.
;
;
; =====================================================
; MONO & REGISTRY / DETECTING MONO
; =====================================================
;
;
; This setup creates several Registry Keys:
;
; HKEY_LOCAL_MACHINE SOFTWARE\Mono DefaultCLR
; HKEY_LOCAL_MACHINE SOFTWARE\Mono\${MILESTONE} SdkInstallRoot
; HKEY_LOCAL_MACHINE SOFTWARE\Mono\${MILESTONE} FrameworkAssemblyDirectory
; HKEY_LOCAL_MACHINE SOFTWARE\Mono\${MILESTONE} MonoConfigDir
;
; =====================================================
;
; To get the current Mono Install Directory:
;
; 1. Get DefaultCLR
; 2. Get HKEY_LOCAL_MACHINE SOFTWARE\Mono\$THE_DEFAULT_CLR_VALUE SdkInstallRoot
;
; =====================================================
;
; To get the current Mono assembly Directory:
;
; 1. Get DefaultCLR
; 2. Get HKEY_LOCAL_MACHINE SOFTWARE\Mono\$THE_DEFAULT_CLR_VALUE FrameworkAssemblyDirectory
; 
; =====================================================
; Do not edit below
; =====================================================
;
;
; =====================================================
; GENERAL SETTING - NEED NOT TO BE CHANGED
; =====================================================

 !define NAME "Mono" ;
 !define TARGET_INSTALL_DIR "c:\mono-${MILESTONE}" ;
 !define OUTFILE "mono-${MILESTONE}-win32-1.exe" ;

; =====================================================
; SCRIPT
; =====================================================


; [NOT ACTIVE] Beautification: This adds a Mono-specific Image on the left
; !define MUI_SPECIALBITMAP "mono.bmp"

 !define MUI_PRODUCT "${NAME}"
 !define MUI_VERSION "${MILESTONE}"
 !define FULLNAME "${MUI_PRODUCT} ${MUI_VERSION}"
 !define MUI_UI "${NSISDIR}\Contrib\UIs\modern2.exe"
 !define MUI_ICON "${NSISDIR}\Contrib\Icons\setup.ico"
 !define MUI_UNICON "${NSISDIR}\Contrib\Icons\normal-uninstall.ico"
 !define MUI_WELCOMEPAGE
 !define MUI_DIRECTORYPAGE
 !define MUI_DIRECTORYSELECTIONPAGE
 !include "${NSISDIR}\Contrib\Modern UI\System.nsh"
 !insertmacro MUI_SYSTEM
 !insertmacro MUI_LANGUAGE "ENGLISH"


 OutFile "${OUTFILE}"
 InstallDir "${TARGET_INSTALL_DIR}"


;========================
; Uninstaller
;========================

Section "Uninstall"

  Delete $INSTDIR\Uninst.exe ; delete Uninstaller

  MessageBox MB_YESNO "Mono was installed into $INSTDIR. Should this directory be removed completly?" IDNO GoNext1
  RMDir /r $INSTDIR
  GoNext1:

  DeleteRegKey HKLM SOFTWARE\Mono\${MILESTONE}
  MessageBox MB_YESNO "Mono ${MILESTONE} has been removed. Should the wrappers and the Mono registry key be removed also? This could disable other Mono installations as well, but will remove Mono ${MILESTONE} 100%." IDNO GoNext2

  ; Complete Uninstall

  DeleteRegKey HKLM SOFTWARE\Mono
  Delete $WINDIR\monobasepath.bat
  Delete $WINDIR\mcs.bat
  Delete $WINDIR\mbas.bat
  Delete $WINDIR\mint.bat
  Delete $WINDIR\mono.bat
  Delete $WINDIR\monodis.bat
  Delete $WINDIR\monoilasm.bat
  Delete $WINDIR\sqlsharp.bat
  Delete $WINDIR\secutil.bat
  Delete $WINDIR\cert2spc.bat
  Delete $WINDIR\monoresgen.bat
  Delete $WINDIR\monosn.bat

  GoNext2:


SectionEnd



 Section
 SetOutPath $INSTDIR
 File /r "${SOURCE_INSTALL_DIR}"
 WriteUninstaller Uninst.exe

 WriteRegStr HKEY_LOCAL_MACHINE SOFTWARE\Mono\${MILESTONE} SdkInstallRoot $INSTDIR
 WriteRegStr HKEY_LOCAL_MACHINE SOFTWARE\Mono\${MILESTONE} FrameworkAssemblyDirectory $INSTDIR\lib
 WriteRegStr HKEY_LOCAL_MACHINE SOFTWARE\Mono\${MILESTONE} MonoConfigDir $INSTDIR\etc\mono
 ;WriteRegStr HKEY_LOCAL_MACHINE SOFTWARE\Mono\${MILESTONE} GtkSharpLibPath $INSTDIR\lib
 WriteRegStr HKEY_LOCAL_MACHINE SOFTWARE\Mono DefaultCLR ${MILESTONE}

 ;original string is like C:\mono-0.20\install
 StrCpy $5 $INSTDIR 
 Push $5
 Push "\" ;search for this string
 Push "/" ;replace with this string
 Call StrReplace
 ;resulting string which is like C:/mono-0.20/install
 Pop $6

;========================
; Write the wrapper files
;========================

; create bin/mono wrapper to be used if the user has cygwin
FileOpen $0 "$INSTDIR\bin\mono.exe.sh" "w"
FileWrite $0 "#!/bin/sh$\r$\n"
FileWrite $0 "export MONO_PATH=$6/lib$\r$\n"
FileWrite $0 "export MONO_CFG_DIR=$6/etc/mono$\r$\n"
FileWrite $0 '$6/bin/mono.exe "$$@"'
FileClose $0

; create bin/mint wrapper to be used if the user has cygwin
FileOpen $0 "$INSTDIR\bin\mint.exe.sh" "w"
FileWrite $0 "#!/bin/sh$\r$\n"
FileWrite $0 "export MONO_PATH=$6/lib$\r$\n"
FileWrite $0 "export MONO_CFG_DIR=$6/etc/mono$\r$\n"
FileWrite $0 '$6/bin/mint.exe "$$@"'
FileClose $0

; create bin/mcs wrapper to be used if the user has cygwin
FileOpen $0 "$INSTDIR\bin\mcs.exe.sh" "w"
FileWrite $0 "#!/bin/sh$\r$\n"
FileWrite $0 "export MONO_PATH=$6/lib$\r$\n"
FileWrite $0 "export MONO_CFG_DIR=$6/etc/mono$\r$\n"
FileWrite $0 '$6/bin/mono.exe $6/bin/mcs.exe "$$@"'
FileClose $0

; create bin/mbas wrapper to be used if the user has cygwin
FileOpen $0 "$INSTDIR\bin\mbas.exe.sh" "w"
FileWrite $0 "#!/bin/sh$\r$\n"
FileWrite $0 "export MONO_PATH=$6/lib$\r$\n"
FileWrite $0 "export MONO_CFG_DIR=$6/etc/mono$\r$\n"
FileWrite $0 '$6/bin/mono.exe $6/bin/mbas.exe "$$@"'
FileClose $0

; create bin/sqlsharp wrapper to be used if the user has cygwin
FileOpen $0 "$INSTDIR\bin\sqlsharp.exe.sh" "w"
FileWrite $0 "#!/bin/sh$\r$\n"
FileWrite $0 "export MONO_PATH=$6/lib$\r$\n"
FileWrite $0 "export MONO_CFG_DIR=$6/etc/mono$\r$\n"
FileWrite $0 '$6/bin/mono.exe $6/bin/sqlsharp.exe "$$@"'
FileClose $0

; create bin/monodis wrapper to be used if the user has cygwin
FileOpen $0 "$INSTDIR\bin\monodis.exe.sh" "w"
FileWrite $0 "#!/bin/sh$\r$\n"
FileWrite $0 "export MONO_PATH=$6/lib$\r$\n"
FileWrite $0 "export MONO_CFG_DIR=$6/etc/mono$\r$\n"
FileWrite $0 '$6/bin/monodis.exe "$$@"'
FileClose $0

; create bin/monoresgen wrapper to be used if the user has cygwin
FileOpen $0 "$INSTDIR\bin\monoresgen.exe.sh" "w"
FileWrite $0 "#!/bin/sh$\r$\n"
FileWrite $0 "export MONO_PATH=$6/lib$\r$\n"
FileWrite $0 "export MONO_CFG_DIR=$6/etc/mono$\r$\n"
FileWrite $0 '$6/bin/mono.exe $6/bin/monoresgen.exe "$$@"'
FileClose $0

; create bin/monoilasm wrapper to be used if the user has cygwin
FileOpen $0 "$INSTDIR\bin\monoilasm.exe.sh" "w"
FileWrite $0 "#!/bin/sh$\r$\n"
FileWrite $0 "export MONO_PATH=$6/lib$\r$\n"
FileWrite $0 "export MONO_CFG_DIR=$6/etc/mono$\r$\n"
FileWrite $0 '$6/bin/mono.exe $6/bin/ilasm.exe "$$@"'
FileClose $0

; create bin/monosn wrapper to be used if the user has cygwin
FileOpen $0 "$INSTDIR\bin\monosn.exe.sh" "w"
FileWrite $0 "#!/bin/sh$\r$\n"
FileWrite $0 "export MONO_PATH=$6/lib$\r$\n"
FileWrite $0 "export MONO_CFG_DIR=$6/etc/mono$\r$\n"
FileWrite $0 '$6/bin/mono.exe $6/bin/monosn.exe "$$@"'
FileClose $0

; create bin/secutil wrapper to be used if the user has cygwin
FileOpen $0 "$INSTDIR\bin\secutil.exe.sh" "w"
FileWrite $0 "#!/bin/sh$\r$\n"
FileWrite $0 "export MONO_PATH=$6/lib$\r$\n"
FileWrite $0 "export MONO_CFG_DIR=$6/etc/mono$\r$\n"
FileWrite $0 '$6/bin/mono.exe $6/bin/secutil.exe "$$@"'
FileClose $0

; create bin/cert2spc wrapper to be used if the user has cygwin
FileOpen $0 "$INSTDIR\bin\cert2spc.exe.sh" "w"
FileWrite $0 "#!/bin/sh$\r$\n"
FileWrite $0 "export MONO_PATH=$6/lib$\r$\n"
FileWrite $0 "export MONO_CFG_DIR=$6/etc/mono$\r$\n"
FileWrite $0 '$6/bin/mono.exe $6/bin/cert2spc.exe "$$@"'
FileClose $0

;
; These wrappers are copied to the windows directory.
;

;========================
; Write the path file
;========================

FileOpen $0 "$WINDIR\monobasepath.bat" "w"
FileWrite $0 "set MONO_BASEPATH=$INSTDIR$\r$\n"
FileWrite $0 "set MONO_PATH=%MONO_BASEPATH%\lib$\r$\n"
FileWrite $0 "set MONO_CFG_DIR=%MONO_BASEPATH%\etc\mono"
FileClose $0


;========================
; Write the mcs file
;========================

FileOpen $0 "$WINDIR\mcs.bat" "w"

FileWrite $0 "@echo off$\r$\n"
FileWrite $0 "call monobasepath.bat$\r$\n"
FileWrite $0 "set MONOARGS=$\r$\n"
FileWrite $0 ":loop$\r$\n"
FileWrite $0 "if x%1 == x goto :done$\r$\n"
FileWrite $0 "set MONOARGS=%MONOARGS% %1$\r$\n"
FileWrite $0 "shift$\r$\n"
FileWrite $0 "goto loop$\r$\n"
FileWrite $0 ":done$\r$\n"
FileWrite $0 "setlocal$\r$\n"
FileWrite $0 'set path="%MONO_BASEPATH%\bin\;%MONO_BASEPATH%\lib\;%path%"$\r$\n'
FileWrite $0 "%MONO_BASEPATH%\bin\mono.exe %MONO_BASEPATH%\bin\mcs.exe %MONOARGS%$\r$\n"
FileWrite $0 "endlocal$\r$\n"

FileClose $0

;========================
; Write the mbas file
;========================

FileOpen $0 "$WINDIR\mbas.bat" "w"

FileWrite $0 "@echo off$\r$\n"
FileWrite $0 "call monobasepath.bat$\r$\n"
FileWrite $0 "set MONOARGS=$\r$\n"
FileWrite $0 ":loop$\r$\n"
FileWrite $0 "if x%1 == x goto :done$\r$\n"
FileWrite $0 "set MONOARGS=%MONOARGS% %1$\r$\n"
FileWrite $0 "shift$\r$\n"
FileWrite $0 "goto loop$\r$\n"
FileWrite $0 ":done$\r$\n"
FileWrite $0 "setlocal$\r$\n"
FileWrite $0 'set path="%MONO_BASEPATH%\bin\;%MONO_BASEPATH%\lib\;%path%"$\r$\n'
FileWrite $0 "%MONO_BASEPATH%\bin\mono.exe %MONO_BASEPATH%\bin\mbas.exe %MONOARGS%$\r$\n"
FileWrite $0 "endlocal$\r$\n"

FileClose $0

;========================
; Write the mint file
;========================

FileOpen $0 "$WINDIR\mint.bat" "w"

FileWrite $0 "@echo off$\r$\n"
FileWrite $0 "call monobasepath.bat$\r$\n"
FileWrite $0 "set MONOARGS=$\r$\n"
FileWrite $0 ":loop$\r$\n"
FileWrite $0 "if x%1 == x goto :done$\r$\n"
FileWrite $0 "set MONOARGS=%MONOARGS% %1$\r$\n"
FileWrite $0 "shift$\r$\n"
FileWrite $0 "goto loop$\r$\n"
FileWrite $0 ":done$\r$\n"
FileWrite $0 "setlocal$\r$\n"
FileWrite $0 'set path="%MONO_BASEPATH%\bin\;%MONO_BASEPATH%\lib\;%path%"$\r$\n'
FileWrite $0 "%MONO_BASEPATH%\bin\mint.exe %MONOARGS%$\r$\n"
FileWrite $0 "endlocal$\r$\n"

FileClose $0

;========================
; Write the mono file
;========================

FileOpen $0 "$WINDIR\mono.bat" "w"

FileWrite $0 "@echo off$\r$\n"
FileWrite $0 "call monobasepath.bat$\r$\n"
FileWrite $0 "set MONOARGS=$\r$\n"
FileWrite $0 ":loop$\r$\n"
FileWrite $0 "if x%1 == x goto :done$\r$\n"
FileWrite $0 "set MONOARGS=%MONOARGS% %1$\r$\n"
FileWrite $0 "shift$\r$\n"
FileWrite $0 "goto loop$\r$\n"
FileWrite $0 ":done$\r$\n"
FileWrite $0 "setlocal$\r$\n"
FileWrite $0 'set path="%MONO_BASEPATH%\bin\;%MONO_BASEPATH%\lib\;%path%"$\r$\n'
FileWrite $0 "%MONO_BASEPATH%\bin\mono.exe %MONOARGS%$\r$\n"
FileWrite $0 "endlocal$\r$\n"

FileClose $0

;========================
; Write monodis
;========================

FileOpen $0 "$WINDIR\monodis.bat" "w"

FileWrite $0 "@echo off$\r$\n"
FileWrite $0 "call monobasepath.bat$\r$\n"
FileWrite $0 "set MONOARGS=$\r$\n"
FileWrite $0 ":loop$\r$\n"
FileWrite $0 "if x%1 == x goto :done$\r$\n"
FileWrite $0 "set MONOARGS=%MONOARGS% %1$\r$\n"
FileWrite $0 "shift$\r$\n"
FileWrite $0 "goto loop$\r$\n"
FileWrite $0 ":done$\r$\n"
FileWrite $0 "setlocal$\r$\n"
FileWrite $0 'set path="%MONO_BASEPATH%\bin\;%MONO_BASEPATH%\lib\;%path%"$\r$\n'
FileWrite $0 "%MONO_BASEPATH%\bin\monodis.exe %MONOARGS%$\r$\n"
FileWrite $0 "endlocal$\r$\n"

FileClose $0

;========================
; Write monoilasm
;========================

FileOpen $0 "$WINDIR\monoilasm.bat" "w"

FileWrite $0 "@echo off$\r$\n"
FileWrite $0 "call monobasepath.bat$\r$\n"
FileWrite $0 "set MONOARGS=$\r$\n"
FileWrite $0 ":loop$\r$\n"
FileWrite $0 "if x%1 == x goto :done$\r$\n"
FileWrite $0 "set MONOARGS=%MONOARGS% %1$\r$\n"
FileWrite $0 "shift$\r$\n"
FileWrite $0 "goto loop$\r$\n"
FileWrite $0 ":done$\r$\n"
FileWrite $0 "setlocal$\r$\n"
FileWrite $0 'set path="%MONO_BASEPATH%\bin\;%MONO_BASEPATH%\lib\;%path%"$\r$\n'
FileWrite $0 "%MONO_BASEPATH%\bin\mono.exe %MONO_BASEPATH%\bin\ilasm.exe %MONOARGS%$\r$\n"
FileWrite $0 "endlocal$\r$\n"

FileClose $0


;========================
; Write the sqlsharp file
;========================

FileOpen $0 "$WINDIR\sqlsharp.bat" "w"

FileWrite $0 "@echo off$\r$\n"
FileWrite $0 "call monobasepath.bat$\r$\n"
FileWrite $0 "set MONOARGS=$\r$\n"
FileWrite $0 ":loop$\r$\n"
FileWrite $0 "if x%1 == x goto :done$\r$\n"
FileWrite $0 "set MONOARGS=%MONOARGS% %1$\r$\n"
FileWrite $0 "shift$\r$\n"
FileWrite $0 "goto loop$\r$\n"
FileWrite $0 ":done$\r$\n"
FileWrite $0 "setlocal$\r$\n"
FileWrite $0 'set path="%MONO_BASEPATH%\bin\;%MONO_BASEPATH%\lib\;%path%"$\r$\n'
FileWrite $0 "%MONO_BASEPATH%\bin\mono.exe %MONO_BASEPATH%\bin\sqlsharp.exe %MONOARGS%$\r$\n"
FileWrite $0 "endlocal$\r$\n"

FileClose $0

;========================
; Write the secutil file
;========================

FileOpen $0 "$WINDIR\secutil.bat" "w"

FileWrite $0 "@echo off$\r$\n"
FileWrite $0 "call monobasepath.bat$\r$\n"
FileWrite $0 "set MONOARGS=$\r$\n"
FileWrite $0 ":loop$\r$\n"
FileWrite $0 "if x%1 == x goto :done$\r$\n"
FileWrite $0 "set MONOARGS=%MONOARGS% %1$\r$\n"
FileWrite $0 "shift$\r$\n"
FileWrite $0 "goto loop$\r$\n"
FileWrite $0 ":done$\r$\n"
FileWrite $0 "setlocal$\r$\n"
FileWrite $0 'set path="%MONO_BASEPATH%\bin\;%MONO_BASEPATH%\lib\;%path%"$\r$\n'
FileWrite $0 "%MONO_BASEPATH%\bin\mono.exe %MONO_BASEPATH%\bin\secutil.exe %MONOARGS%$\r$\n"
FileWrite $0 "endlocal$\r$\n"

FileClose $0

;========================
; Write the cert2spc file
;========================

FileOpen $0 "$WINDIR\cert2spc.bat" "w"

FileWrite $0 "@echo off$\r$\n"
FileWrite $0 "call monobasepath.bat$\r$\n"
FileWrite $0 "set MONOARGS=$\r$\n"
FileWrite $0 ":loop$\r$\n"
FileWrite $0 "if x%1 == x goto :done$\r$\n"
FileWrite $0 "set MONOARGS=%MONOARGS% %1$\r$\n"
FileWrite $0 "shift$\r$\n"
FileWrite $0 "goto loop$\r$\n"
FileWrite $0 ":done$\r$\n"
FileWrite $0 "setlocal$\r$\n"
FileWrite $0 'set path="%MONO_BASEPATH%\bin\;%MONO_BASEPATH%\lib\;%path%"$\r$\n'
FileWrite $0 "%MONO_BASEPATH%\bin\mono.exe %MONO_BASEPATH%\bin\cert2spc.exe %MONOARGS%$\r$\n"
FileWrite $0 "endlocal$\r$\n"

FileClose $0


;========================
; Write the monoresgen file
;========================

FileOpen $0 "$WINDIR\monoresgen.bat" "w"

FileWrite $0 "@echo off$\r$\n"
FileWrite $0 "call monobasepath.bat$\r$\n"
FileWrite $0 "set MONOARGS=$\r$\n"
FileWrite $0 ":loop$\r$\n"
FileWrite $0 "if x%1 == x goto :done$\r$\n"
FileWrite $0 "set MONOARGS=%MONOARGS% %1$\r$\n"
FileWrite $0 "shift$\r$\n"
FileWrite $0 "goto loop$\r$\n"
FileWrite $0 ":done$\r$\n"
FileWrite $0 "setlocal$\r$\n"
FileWrite $0 'set path="%MONO_BASEPATH%\bin\;%MONO_BASEPATH%\lib\;%path%"$\r$\n'
FileWrite $0 "%MONO_BASEPATH%\bin\mono.exe %MONO_BASEPATH%\bin\monoresgen.exe %MONOARGS%$\r$\n"
FileWrite $0 "endlocal$\r$\n"

FileClose $0

;========================
; Write the monosn file
;========================

FileOpen $0 "$WINDIR\monosn.bat" "w"

FileWrite $0 "@echo off$\r$\n"
FileWrite $0 "call monobasepath.bat$\r$\n"
FileWrite $0 "set MONOARGS=$\r$\n"
FileWrite $0 ":loop$\r$\n"
FileWrite $0 "if x%1 == x goto :done$\r$\n"
FileWrite $0 "set MONOARGS=%MONOARGS% %1$\r$\n"
FileWrite $0 "shift$\r$\n"
FileWrite $0 "goto loop$\r$\n"
FileWrite $0 ":done$\r$\n"
FileWrite $0 "setlocal$\r$\n"
FileWrite $0 'set path="%MONO_BASEPATH%\bin\;%MONO_BASEPATH%\lib\;%path%"$\r$\n'
FileWrite $0 "%MONO_BASEPATH%\bin\monosn.exe %MONOARGS%$\r$\n"
FileWrite $0 "endlocal$\r$\n"

FileClose $0

SectionEnd

; function StrReplace
; by Hendri Adriaens
; HendriAdriaens@hotmail.com
; found in the NSIS Archives
function StrReplace
  Exch $0 ;this will replace wrong characters
  Exch
  Exch $1 ;needs to be replaced
  Exch
  Exch 2
  Exch $2 ;the orginal string
  Push $3 ;counter
  Push $4 ;temp character
  Push $5 ;temp string
  Push $6 ;length of string that need to be replaced
  Push $7 ;length of string that will replace
  Push $R0 ;tempstring
  Push $R1 ;tempstring
  Push $R2 ;tempstring
  StrCpy $3 "-1"
  StrCpy $5 ""
  StrLen $6 $1
  StrLen $7 $0
  Loop:
  IntOp $3 $3 + 1
  StrCpy $4 $2 $6 $3
  StrCmp $4 "" ExitLoop
  StrCmp $4 $1 Replace
  Goto Loop
  Replace:
  StrCpy $R0 $2 $3
  IntOp $R2 $3 + $6
  StrCpy $R1 $2 "" $R2
  StrCpy $2 $R0$0$R1
  IntOp $3 $3 + $7
  Goto Loop
  ExitLoop:
  StrCpy $0 $2
  Pop $R2
  Pop $R1
  Pop $R0
  Pop $7
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Exch $0
FunctionEnd
