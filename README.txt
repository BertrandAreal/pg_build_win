These scripts create a PostgreSQL build environment for Windows, and build
PostgreSQL.

They're for NMake, the Microsoft version of make that uses cmd.exe. It comes
with Visual Studio. Yes, that's horrid, but it's better than trying to disentangle
the environment of mingw from that of Visual Studio.

You will require installs of ActiveState Perl, ActiveState TCL, Python.org
Python 2, MinGW, git (from git-scm.org), and the Microsoft SDK 7.1 to use these
scripts. Instructions on unattended installs for these tools are coming shortly;
just need to copy them from another machine.

Install minGW:
==============

  http://sourceforge.net/projects/mingw/files/Installer/mingw-get-inst/
  
You need this even for MSVC builds because you need the "flex" executable
from it to build on x64; the version provided on the PostgreSQL site doesn't
run on win64.

These tools also require bison, wget and touch from mingw, since it must be 
available already.

All these tools come with msysgit too, so a future version may support using
msysgit instead of MinGW.

Install the Windows SDK
=======================

[docs need to be copied from another machine; pending]

Install Perl, Python and TCL
============================

[docs need to be copied from another machine; pending]

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
