@rem
@rem Work-in-progress script to auto install the required tools
@rem

start /wait mingw-get-inst-20120426.exe /silent
c:\MinGW\bin\mingw-get.exe install msys-flex msys-bison g++ gdb mingw32-make msys-base
start /wait msiexec /i 7z920-x64.msi /qb /passive /norestart
start /wait Git-1.8.0-preview20121022.exe /silent
start /wait msiexec /i ActivePerl-5.16.1.1601-MSWin32-x64-296175.msi /qb /passive PERL_PATH=Yes PERL_EXT=Yes
start /wait msiexec /i ActivePerl-5.16.1.1601-MSWin32-x86-296175.msi /qb /passive PERL_PATH=No PERL_EXT=No
start /wait msiexec /i python-2.7.3.amd64.msi /qb /passive TARGETDIR=%SystemDrive%\Python27_x64 ALLUSERS=1
start /wait msiexec /i python-2.7.3.msi /qb /passive TARGETDIR=%SystemDrive%\Python27_x86 ALLUSERS=1
start /wait msiexec /i python-3.3.0.amd64.msi /qb /passive TARGETDIR=%SystemDrive%\Python33_x64 ALLUSERS=1
start /wait msiexec /i python-3.3.0.msi /qb /passive TARGETDIR=%SystemDrive%\Python33_x64 ALLUSERS=1