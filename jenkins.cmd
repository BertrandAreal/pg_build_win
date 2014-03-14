@echo off
::
:: This batch file does SDK-specific environment setup, loading the environment
:: for the particular SDK version selected. It must be written as a batch file
:: in order to import the environment exported from the vcvarsall.bat or
:: setenv.cmd script.
::
:: It's intended for use from a Jenkins server, with a matrix build that defines
:: the following variables, but you could call it from whatever you like as it
:: has no actual dependencies on Jenkins.
::
:: Expects environment vars to be set:
::
:: TA: Target Architecture. x86 or x64.
:: BT: Build Type. Release or Debug. Case sensitive.
:: SDK: Windows SDK to use. See IF statements below for supported SDKs
:: PGBW: Location of pg_build_win directory
::
:: You could use it in a Jenkins matrix build with a simple script like:
::
::     SET PGBW=C:\pg\pg_build_win
::     call %PGBW%\jenkins.cmd
::
:: where you use matrix variables to set SDK, BT, and TA

IF NOT DEFINED BT (
    ECHO Variable BT - Build Type - is not defined
    GOTO :ERROR
)
IF NOT DEFINED SDK (
    ECHO Variable SDK - SDK version - is not defined
    GOTO :ERROR
)
IF NOT DEFINED PGBW (
    ECHO Variable PGBW - pg_build_win directory - is not defined
    GOTO :ERROR
)

SET PATH=C:\Perl64\site\bin;C:\Perl64\bin;C:\Perl\site\bin;C:\Perl\bin;C:\Windows\System32

call %PGBW%\setupsdk.cmd
:: Should really test errorlevel here or use &&, but seem to have issues under
:: Jenkins control when doing so.
GOTO :RUN

:RUN
SET PGPORT=50533
IF /I "%TA"=="x86" SET /A PGPORT=PGPORT+1
IF /I "%BT"=="release" SET /A PGPORT=PGPORT+2
%PGBW%\buildcwd.pl postgresql-check && GOTO END
type src\test\regress\regression.diffs

:: TODO run installcheck, plcheck, etc too

:ERROR
ECHO BUILD ERROR
EXIT /B 1

:END
ECHO Build OK
EXIT /B 0
