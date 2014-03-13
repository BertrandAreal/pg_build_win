@echo off
::
:: This script sources the appropriate SDK environment variables script given an SDK
:: version.
::
:: This wonderful article enumerates registry keys and install names:
::
::   http://stackoverflow.com/questions/10922913/visual-studio-express-2012-editions-exe-names-and-registry-path
::
:: (Windows SDK install locations are awful to find)
::
IF NOT DEFINED TA (
    ECHO Variable TA - Target Architecture - is not defined
    GOTO :ERROR
)
:: Use x86-to-x64 cross-compilers for Visual Studio; that'll work on both
:: x86 and x64 hosts, and work with Express editions that don't have native
:: 64-bit compilers.
::
:: For now, though, seem to be OK just using the cross compilers.
::
IF /I %TA%==x86 SET vcarch=x86
IF /I %TA%==x64 SET vcarch=x86_amd64

:: If %PROCESSOR_ARCHITECTURE% is AMD64 we must explicitly look under the Wow6432Node
:: in the Registry. If it's not, then either we're on 32-bit native, or we're under wow3264
:: and the registry translation is done for us. We can tell the difference with
:: %PROCESSOR_ARCHITEW6432%, but do not care.
SET WOW=
IF /I %PROCESSOR_ARCHITECTURE%==AMD64 SET WOW=Wow6432Node\

:: These paths point to the Common7\IDE\ subdir
SET VS2010EXREG=HKLM\SOFTWARE\%WOW%Microsoft\VCExpress\10.0
SET VS2012EXREG=HKLM\SOFTWARE\%WOW%Microsoft\WDExpress\11.0
SET VS2013EXREG=HKLM\SOFTWARE\%WOW%Microsoft\WDExpress\12.0

::
:: The Visual Studio installs all put their scripts in Program Files (x86).
::
::

IF /I %SDK%==winsdk71 (
    IF NOT DEFINED BT (
        ECHO If you use the Windows SDK rather than Visual Studio you must set a build type
        ECHO with the BT environment variable before requesting SDK environment setup.
        GOTO :ERROR
    )
    FOR /F "usebackq tokens=2,* skip=2" %%L IN (
        `reg query "HKLM\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v7.1" /v InstallationFolder`
    ) DO SET sdkpath=%%M
    call "%%sdkpath%%\bin\setenv.cmd" /%TA% /%BT%
    GOTO :EOF
)
IF /I %SDK%==vs2010ex (
    SET SDKREGKEY=%VS2010EXREG% && GOTO :LOADVCENV
)
IF /I %SDK%==vs2012ex (
    SET SDKREGKEY=%VS2012EXREG% && GOTO :LOADVCENV
)
IF /I %SDK%==vs2013ex (
    SET SDKREGKEY=%VS2013EXREG% && GOTO :LOADVCENV
)
:: TODO add non-Express versions of Visual Studio

:: Didn't match anything, or failed
ECHO SDK %SDK% unrecognised
GOTO :ERROR


::Function LOADVCENV. Expects %SDKREGKEY%, runs vcvarsall
:LOADVCENV
FOR /F "usebackq tokens=2,* skip=2" %%L IN (
    `reg query "%SDKREGKEY%" /v InstallDir`
) DO SET sdkpath=%%M
call "%sdkpath%\..\..\VC\vcvarsall.bat" %vcarch% && GOTO :EOF
ECHO Failed to configure SDK %SDK%
GOTO :ERROR

:ERROR
EXIT /B 1

:EOF
