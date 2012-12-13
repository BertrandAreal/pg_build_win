These scripts create a PostgreSQL build environment for Windows, and build
PostgreSQL.

They're for NMake, the Microsoft version of make that uses cmd.exe. It comes
with Visual Studio. Yes, that's horrid, but it's better than trying to disentangle
the environment of mingw from that of Visual Studio.

You will require installs of ActiveState Perl, ActiveState TCL, Python.org
Python 2, MinGW, git (from git-scm.org), and the Microsoft SDK 7.1 to use these
scripts. Instructions on unattended installs for these tools are coming shortly;
just need to copy them from another machine.

Edit:

    pg_build_win\settings.mak
	
to reflect your environment.

Set up your Visual Studio or Windows SDK environment for the build target you want.
For Windows SDK use SetEnv.Cmd ; for Visual Studio use vcvars.bat.

    "c:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.Cmd" /x86 /release /xp
	
Use 

    "c:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.Cmd" /?

for help.

Build with:

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
