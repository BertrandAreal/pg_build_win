These scripts create a PostgreSQL build environment for Windows, and build
PostgreSQL.

They're for NMake, the Microsoft version of make that uses cmd.exe. It comes
with Visual Studio. Yes, that's horrid, but it's better than trying to disentangle
the environment of mingw from that of Visual Studio.

You will require installs of ActiveState Perl, ActiveState TCL, Python.org
Python 2, MinGW, git (from git-scm.org), and the Microsoft SDK 7.1 to use these
scripts. Instructions on unattended installs for these tools are coming shortly;
just need to copy them from another machine.

Download Windows SDK 7.1
========================

You can download the SDK from:
 http://www.microsoft.com/en-us/download/details.aspx?id=8279 (web installer)
or
 http://www.microsoft.com/en-us/download/details.aspx?id=8442 (offline installers ISOs).

If using the offline installer, get GRMSDKX_EN_DVD.iso for x64 or 
GRMSDK_EN_DVD.iso for x86. You don't need to burn a CD to install it, 
see below for instructions.

You must already have .NET 4 client profile installed to be able to run the 
Windows SDK offline installer. It's installed by default on Windows 7 and
Win2k8 R2 but must be installed manually for older platforms. Get it here:

 http://www.microsoft.com/en-us/download/details.aspx?id=24872

Download required tools
=======================

Some of this will be automated later, but for now you must download the following
required tools. Don't install them; see below for that.

All these instructions assume you're on a 64-bit windows install. If you're on 32-bit, don't
bother downloading the 64-bit installers and omit all steps that refer to them. These instructions
and scripts are NOT TESTED on 32-bit windows, only on 64-bit Windows 7 and Windows Server 2008 R2.

Download:
  
* ActiveState TCL x64 and x86 from http://www.activestate.com/activetcl/downloads
* ActiveState Perl x86 and x64 from http://www.activestate.com/activeperl/downloads
* Python.org python 2.7 and 3.3, both in x86 and x64 versions from http://python.org
* mingw-get-inst from http://sourceforge.net/projects/mingw/files/Installer/mingw-get-inst/
* git from http://git-scm.com/download/win
* 7-zip from http://www.7-zip.org/download.html

You need MinGW even for MSVC builds because you need the "flex" executable
from it to build on x64; the version provided on the PostgreSQL site doesn't
run on win64. These scripts also use bison, wget and touch from mingw. All 
these tools come with msysgit too, so a future version may support using
msysgit instead of MinGW.

I also recommend:
* notepad++ from http://http://notepad-plus-plus.org/download/

Install the tools
=================

Open a command prompt and cd to the location you downloaded all the above tools to.

Now use the following commands to install the tools. On Windows the command prompt
doesn't wait until a spawned command completes; you can use "start /WAIT" to launch
them and wait, but it won't work with all installers.

You will need to adjust the file names to reflect the exact files you downloaded.

If you're on a 32-bit platform, omit the lines for 64-bit programs and for Perl, use 
PERL_PATH=Yes PERL_EXT=Yes for the 32-bit version since you aren't installing the 64-bit
version.

	start /wait mingw-get-inst-20120426.exe /silent
	c:\MinGW\bin\mingw-get.exe install msys-flex msys-bison g++ gdb mingw32-make msys-base
	start /wait msiexec /i 7z920-x64.msi /qb /passive /norestart
	start /wait Git-1.8.0-preview20121022.exe /silent
	start /wait msiexec /i ActivePerl-5.16.1.1601-MSWin32-x64-296175.msi /qb /passive PERL_PATH=Yes PERL_EXT=Yes
	start /wait msiexec /i ActivePerl-5.16.1.1601-MSWin32-x86-296175.msi /qb /passive PERL_PATH=No PERL_EXT=No
	start /wait ActiveTcl8.5.12.0.296033-win32-ix86-threaded.exe --directory %SystemDrive%\TCL_85_x86
	start /wait ActiveTcl8.5.12.0.296033-win32-x86_64-threaded.exe --directory %SystemDrive%\TCL_85_x64
	start /wait msiexec /i python-2.7.3.amd64.msi /qb /passive TARGETDIR=c:\Python27_x64 ALLUSERS=1
	start /wait msiexec /i python-2.7.3.msi /qb /passive TARGETDIR=c:\Python27_x86 ALLUSERS=1
	start /wait msiexec /i python-3.3.0.amd64.msi /qb /passive TARGETDIR=c:\Python33_x64 ALLUSERS=1
	
If you downloaded the offline install ISO for the Windows SDK, you can install it with:

	"c:\Program Files\7-Zip\7z.exe" x -owinsdk GRMSDKX_EN_DVD.iso
	start /wait winsdk\setup.exe -q -params:ADDLOCAL=ALL
	rd /s /q winsdk
	
(Change GRMSDKX_EN_DVD.iso to GRMSDK_EN_DVD.iso if you're on x64) 

Optionally also install notepad++:

	start /wait npp.6.2.2.Installer.exe /S

Configure the build
===================

Copy settings-template.mak to settings.mak and edit it to reflect your
environment. You can pass the settings on the command line instead, but
currently an empty settings.mak is still required. See settings-defaults.mak
for what you can override. You will want to set at least:

	LIBDIR=\where\to\put\libraries
	PGDIR=\where\to\put\pg\working\trees
	PG_GIT_URL=valid Git url for PostgreSQL
	PG_BRANCH=which pg branch to build, eg REL9_2_STABLE or master

It's preferable to use absolute paths for LIBDIR and PGDIR.

Anything inside LIBDIR and PGDIR will be deleted by "nmake reallyclean".

As cloning Pg from scratch takes time, I recommend cloning a bare copy of the Pg repo *outside* LIBDIR and PGDIR:

	git clone --bare --mirror git://git.postgresql.org/git/postgresql.git d:\postgresql-git

and specifying the path to it as PG_GIT_URL:

	PG_GIT_URL=d:\postgresql-git
	
SET UP VISUAL STUDIO ENVIRONMENT
================================
	
Set up your Visual Studio or Windows SDK environment for the build target you want.
Either use the Start menu option to launch a suitable prompt if you want the default
settings, or preferably open a new ordinary Command Prompt and use SetEnv.cmd
(SDK) or vcvars.bat (Studio) to set the environment up.

For windows SDK 7.1 32-bit release builds you'd use:

    "c:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.Cmd" /x86 /release /xp
	
For options:

    "c:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.Cmd" /?

The main options are "/x86" vs "/x64" and "/Debug" vs "/Release".
You probably want to pass "/xp" for 32-bit builds and "/2008" for 64-bit builds.

BUILD
=====

In a command prompt that's had its environment set up as per "SET UP
VISUAL STUDIO ENVIRONMENT", do a full build with:

    nmake /f pg_build_win\Makefile postgresql

Supported targets are:

POSTGRESQL:
-----------
* postgresql: Build PostgreSQL and its dependencies
* postgresql-check: Run the test suite
* postgresql-clean: Clean postgresql working tree, leave libraries alone

LIBRARIES:
----------

If you want to build individual libraries, each library Makefile
has "libname" and "libname-clean" targets, eg:

* zlib
* zlib-clean

CLEANING:
---------

* clean - remove built libraries and clean PostgreSQL working tree
* really-clean: Remove built libraries and downloaded files, delete PostgreSQL checkout and working tree
