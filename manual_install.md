Download Windows SDK 7.1
========================

Skip this if you used `install_tools.ps1`.

You can download the SDK from:
 http://www.microsoft.com/en-us/download/details.aspx?id=8279 (web installer)
or
 http://www.microsoft.com/en-us/download/details.aspx?id=8442 (offline installers ISOs).

If using the offline installer, get `GRMSDKX_EN_DVD.iso` for x64 or 
`GRMSDK_EN_DVD.iso` for x86. You don't need to burn a CD to install it, 
see below for instructions.

You must already have .NET 4 client profile installed to be able to run the 
Windows SDK offline installer. It's installed by default on Windows 7 and
Win2k8 R2 but must be installed manually for older platforms. Get it here:

 http://www.microsoft.com/en-us/download/details.aspx?id=24872

If you have Visual Studio 2010 redistributible packages installed or have
version 2010 or 2012 of Visual Studio installed, additional steps are required
to install the Windows SDK 7.1 correctly. See TROUBLESHOOTING.

If installation fails, you might have a newer version of the Visual c++ 2010 runtime installed. See TROUBLESHOOTING.

Download required tools
=======================

Skip this if you used `install_tools.ps1`.

All these instructions assume you're on a 64-bit windows install. If you're on 32-bit, don't
bother downloading the 64-bit installers and omit all steps that refer to them. These instructions
and scripts are NOT TESTED on 32-bit windows, only on 64-bit Windows 7 and Windows Server 2008 R2.

Download:
  
* ActiveState Perl x86 and x64 from http://www.activestate.com/activeperl/downloads
  (Perl is not an optional dependency, it's required to run these build scripts and
   the PostgreSQL Windows build infrastructure).
* mingw-get-inst from http://sourceforge.net/projects/mingw/files/Installer/mingw-get-inst/
* git from http://git-scm.com/download/win
* 7-zip from http://www.7-zip.org/download.html

... and optionally:

* ActiveState TCL x64 and x86 from http://www.activestate.com/activetcl/downloads
* Python.org python 2.7 and 3.3, both in x86 and x64 versions from http://python.org

msysgit or mingw are required for "flex", "bison", "touch" and "curl". Perl
wrappers for touch and curl may be used in future, but flex and bison are not
negotiable for git builds. If you get an error like:

    Could not find usable FLEX. Looked in MAKEARGS, git install, mingw. See README.
     at C:/pg/pg_build_win/PgBuildWin/Config.pm line 222.

then you probably need to put msysgit or Mingw/msys's bin dir on your PATH,
or set the GIT or MINGW keys in MAKEARGS in your settings.pl to the install location
of msysgit or mingw32, eg

    $cfg { 
		#...
		'makeargs' => {
			#...
			'GIT' => 'C:\Program Files (x86)\Git',
			#....
	}
	
	

I also recommend:

* notepad++ from http://http://notepad-plus-plus.org/download/

Install the tools
=================

Skip this if you used `install_tools.ps1`.

Open a command prompt and cd to the location you downloaded all the above tools to.

Now use the following commands to install the tools. On Windows the command prompt
doesn't wait until a spawned command completes; you can use "start /WAIT" to launch
them and wait, but it won't work with all installers.

You will need to adjust the file names to reflect the exact files you downloaded.

On 64-bit platforms:

	start /wait msiexec /i ActivePerl-5.16.1.1601-MSWin32-x64-296175.msi /qb /passive PERL_PATH=Yes PERL_EXT=Yes
	start /wait msiexec /i ActivePerl-5.16.1.1601-MSWin32-x86-296175.msi /qb /passive PERL_PATH=No PERL_EXT=No

On 32-bit platforms:

	start /wait msiexec /i ActivePerl-5.16.1.1601-MSWin32-x86-296175.msi /qb /passive PERL_PATH=Yes PERL_EXT=Yes

Then for x64 install all the below, and for x68 install only the non-64-bit versions:


	start /wait mingw-get-inst-20120426.exe /silent
	c:\MinGW\bin\mingw-get.exe install msys-flex msys-bison g++ gdb mingw32-make msys-base
	start /wait msiexec /i 7z920-x64.msi /qb /passive /norestart
	start /wait Git-1.8.0-preview20121022.exe /silent
	start /wait msiexec /i python-2.7.3.amd64.msi /qb /passive TARGETDIR=%SystemDrive%\Python27_x64 ALLUSERS=1
	start /wait msiexec /i python-2.7.3.msi /qb /passive TARGETDIR=%SystemDrive%\Python27_x86 ALLUSERS=1
	start /wait msiexec /i python-3.3.0.amd64.msi /qb /passive TARGETDIR=%SystemDrive%\Python33_x64 ALLUSERS=1
	start /wait msiexec /i python-3.3.0.msi /qb /passive TARGETDIR=%SystemDrive%\Python33_x64 ALLUSERS=1
	
Now install TCL if you want it. These installers don't run fully unattended.
	start /wait ActiveTcl8.5.*-win32-ix86-threaded.exe --directory %SystemDrive%\TCL_85_x86
	start /wait ActiveTcl8.5.*-win32-x86_64-threaded.exe --directory %SystemDrive%\TCL_85_x64
	
If you downloaded the offline install ISO for the Windows SDK, you can install it with:

	"%PROGRAMFILES%\7-Zip\7z.exe" x -owinsdk GRMSDKX_EN_DVD.iso
	start /wait winsdk\setup.exe -q -params:ADDLOCAL=ALL
	rd /s /q winsdk
	
(Change GRMSDKX_EN_DVD.iso to GRMSDK_EN_DVD.iso if you're on x64) 

Optionally also install notepad++:

	start /wait npp.6.2.2.Installer.exe /S
