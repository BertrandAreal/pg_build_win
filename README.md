These scripts create a PostgreSQL build environment for Windows, and build
PostgreSQL.

The scripts use Perl as a wrapper around Microsoft's nmake, the build tool
that comes with the Microsoft Windows SDK and with Visual Studio.

You will need installs of ActiveState Perl, ActiveState TCL, Python.org
Python 2, MinGW, git (from git-scm.org), and the Microsoft SDK 7.1 to use these
scripts. If you want to use a different Windows SDK, see "Other SDKs".

I recommend that you avoid running these scripts on a machine you use to
run a real PostgreSQL instance you care about. These scripts won't break
anything (that I'm aware of), but on Windows it's generally risky to do dev
work on a production machine. As always, keep good backups and make a restore
point before proceeding.

Automatically installing tools and SDKs
=======================================

Use the PowerShell script:

    install_tools.ps1

to download and install all the required dependencies. Just open PowerShell
and run:

    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
    cd pg_build_win
    .\install_tools.ps1

The execution policy command will permit PowerShell to run the script without
changing any persistent settings.

If you use this script you can skip the SDK download and tools download/install
sections.

Manually installing the tools and SDKs
======================================

See `manual_install.md`

Configure the build
===================

Copy `settings_template.pl` to settings.pl and edit it to reflect your
environment. You can pass the settings on the command line instead, but
currently an empty settings.pl is still required.

Settings on the command line are passed as nmake variables, eg:

    SETTING="the value"

and in config.pl as Perl hashmap entries, eg:

    'SETTING' => 'the value',

To see what you can override, see the settings summary printed when you run
buildcwd.pl / buildgit.pl, or examine PgBuildWin\Config.pm .

There are two build modes offered; you must pick whether you want the build
scripts to manage the PostgreSQL sources trees for you by checking them out
from git, or whether you want to manage them yourself. These modes do not
affect libraries, only management of the PostgreSQL sources.

In either case, you must set LIBDIR to the absolute path you want to put
the dependencies that the build scripts manage for you, eg:

	LIBDIR=\where\to\put\libraries

Anything inside LIBDIR will be deleted by "build{git|cwd}.pl really-clean"

Automatic PostgreSQL source trees - buildgit.pl
-----------------------------------------------

If you use buildgit.pl specify where to put the source trees (PGDIR), where to
find a PostgreSQL git mirror (`PG_GIT_URL`), what branch to check out (`PG_BRANCH`)
and optionally the location of the git executable (GIT), the build scripts will
manage your builds for you under PGDIR. Eg, in settings.pl:

	'GIT' => 'c:\Program Files (x86)\Git\bin\git.exe',
	'PGDIR' => 'c:\postgresql-build',
	'PG_GIT_URL' => 'c:\postgresql-git-bare-mirror',
	'PG_BRANCH' => 'master'

Anything inside PGDIR will be deleted by "buildgit.pl really-clean". The source
tree will be reset using "git clean -fdx" when you "buildgit.pl clean" or
"buildgit.pl postgresql-clean", so don't do work in the script-managed
PostgreSQL trees; either push to a branch and have the tools build the branch,
or manually manage the source tree (see below).

Builds and installs will go in different locations (`PGBUILDDIR`) based on their settings
- /x86 vs /x64, /release vs /debug, SDK version, target OS, and Pg branch. For example,
`REL9_2_STABLE` built for /x86 /release /xp built with Windows SDK 7.1 with `PGDIR`
set to `c:\postgresql-build` will go in:

	D:\postgresql-build\Windows7.1SDK\xp\x86\Release\REL9_2_STABLE

As cloning Pg from scratch takes time and bandwidth, I recommend cloning a bare copy
of the Pg repo *outside* LIBDIR and PGDIR, eg:

	git clone --bare --mirror git://git.postgresql.org/git/postgresql.git d:/postgresql-git

and specifying the path to it as `PG_GIT_URL`:

	'PG_GIT_URL' => 'd:\postgresql-git'
	
To pull new changes into that repository use, "git fetch".

Manually managed PostgreSQL source trees - set PGBUILDDIR
---------------------------------------------------------

If you're developing PostgreSQL in an existing working tree or you're using
these scripts for a buildfarm / continuous integration setup, you or some other
tools might be managing your git checkouts, or you could even be working from
source tarballs.  In that case you won't want the build scripts messing around
with git.

buildcwd.pl will look for settings.pl in the current directory, then in the
scripts directory. This means that it'll execute any "settings.pl" in the
directory you invoke it in, so keep that in mind when running builds on
untrusted branches.

Just cd to the source tree and invoke buildcwd.pl from there:

For example:

        cd \path\to\pg_source_tree
	\path\to\pg_build_win\buildcwd.pl

If using buildcwd.pl, the scripts won't use git and you don't need it
installed.  In this mode, "buildcwd.pl postgresql-clean" and "buildcwd.pl
clean" will use "src\tools\msvc\clean.bat dist" to clean the source tree,
rather than using git.

(Optional) Download library source archives
===========================================

The build tools will download the source archives into LIBDIR\pkg for you if it
can't find them.

If you like, you can create LIBDIR\pkg and copy the source archives from
somewhere yourself for offline use. The filenames the build scripts look
for are specified in settings-default.mak and can be overridden in settings.mak.

Be warned that "build{cwd|git}.pl really-clean" will delete LIBDIR and its contents,
including any source packages you put there.
	
SET UP VISUAL STUDIO ENVIRONMENT
================================
	
Set up your Visual Studio or Windows SDK environment for the build target you
want.  Either use the Start menu option to launch a suitable prompt if you want
the default settings, or preferably open a new ordinary Command Prompt and use
`SetEnv.cmd` (SDK) or `vcvars.bat` (Studio) to set the environment up.

For windows SDK 7.1 32-bit release builds you'd use:

    "c:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.Cmd" /x86 /release /xp
	
For options:

    "c:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.Cmd" /?

The main options are "/x86" vs "/x64" and "/Debug" vs "/Release".
You probably want to pass "/xp" for 32-bit builds and "/2008" for 64-bit builds.

`vcvarsall.bat` for Visual Studio builds works a bit differently to the Windows
SDK 7.1 `SetEnv.cmd` script. They do not offer any control of the debug/release
state (`Configuration`) or the target platform; the only argument they accept
is an arcitecture. You must set the environment variables for `TARGET` and
`Configuration` yourself.

BUILD
=====

In a command prompt that's had its environment set up as per "SET UP
VISUAL STUDIO ENVIRONMENT", do a full build using:

    cd \some\postgresql\sources\
    \path\to\pg_build_win\buildcwd.pl postgresql

or to use automatically managed git trees:

    buildgit.pl  postgresql 

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

INSTALLATION
------------

To get a tree of installed PostgreSQL binaries, contrib modules,
etc including the library dependencies, use the "install" target.

By default, "install" will install the binaries to a directory named "binaries"
under PGBUILDDIR. Change this if desired by setting PGINSTALLDIR.

If you want just the PostgreSQL install but not the libraries, use
"postgresql-install".

The interpreters for the PLs are not copied over. Neither is the Visual
C++ redist for your SDK, which will need to be installed before the compiled
binaries will run on another machine.

CLEANING:
---------

* clean - remove built libraries and clean PostgreSQL working tree
* really-clean: Remove built libraries and downloaded files, delete PostgreSQL checkout and working tree

CACHING GIT
===========

Rather than making a new clone each time, you should really be using a local
cache of PostgreSQL git.

The initial clone may be created with:

    md c:\pg
    c:
    cd c:\pg
    "c:\Program Files (x86)\git\bin\git.exe" clone --bare --mirror git://git.postgresql.org/git/postgresql.git postgresql-git

The file `Scheduled Task - Update Git Mirror.xml` can be loaded into the
Windows Task Scheduler to regularly pull all remotes added to the git mirror.

You can then set `PG_GIT_URL` in `settings.pl` to the local mirror.

(Really, we should support using a `--reference` to the local mirror and still
allow a remote URL, but that's not supported yet.)

TROUBLESHOOTING
===============

SDK 7.1 / Visual Studio 2010 conflict with Visual Studio 2012
-------------------------------------------------------------
 
If you have Visual Studio 2012 installed on your computer, Windows SDK
7.1 may fail to compile programs with errors like:

LINK : fatal error LNK1123: failure during conversion to COFF: file invalid or corrupt

This is a known issue with Visual Studio 2010 that also appears to affect SDK
7.1, since the SDK uses the same compiler suite. The problem was fixed in
Visual Studio 2010 SP1, but not in SDK 7.1. To work around the problem you must
install Visual C++ Express Edition 2010 and then the Visual Studio 2010 Service
Pack 1 update. For details, see the readme.htm file in the VS 2010 SP1 compiler update.

Install the tools in the following order:

* VS Express 2010: http://www.microsoft.com/visualstudio/eng/products/visual-studio-2010-express
* Windows SDK 7.1
* VS 2010 SP1: http://www.microsoft.com/en-au/download/details.aspx?id=23691
* VS 2010 SP1 Compiler Update: http://www.microsoft.com/en-au/download/details.aspx?id=4422

SDK 7.1 install fails
---------------------

One possible cause of a Microsoft Windows SDK 7.1 install failure is if
newer versions of the Visual C++ 2010 redistributable runtime are installed.
Many program installers will add these for you.

The only workaround I'm aware of is to uninstall any VC++ 2010
redistributibles, install the SDK, then reinstall the redistributibles. Note
that uninstalling the redistributibles will cause some programs on your
computer to fail to run until they're reinstalled.

You can get the redists from:

 
* 2010 x86 SP1: http://www.microsoft.com/en-au/download/details.aspx?id=8328
* 2010 x64 SP1: http://www.microsoft.com/en-au/download/details.aspx?id=13523
* 2010 x86: http://www.microsoft.com/en-us/download/details.aspx?id=5555
* 2010 x64: http://www.microsoft.com/en-us/download/details.aspx?id=26999

Permission denied errors when cleaning
--------------------------------------

Unlike POSIX systems, on Windows a file or folder that is open by a program cannot
be deleted or renamed.

If you've run regression tests and they've crashed out without properly terminating
the server they've started, you will find that you can't clean your working directory
and you'll get "permission denied" errors for files/folders you obviously do have full
ownership and control of.

Open up Process Explorer (preferered) or Task Manager. Now find and terminate the problem
processes - look for psql.exe, pg_regress.exe and postgres.exe . If you have a real PostgreSQL
instance you use for real work on this machine, be careful not to terminate it.

postgres.exe or git.exe hung at max cpu forever, won't End Task
---------------------------------------------------------------

There appears to be a problem with building and testing PostgreSQL inside
deep directory trees (130+ characters, roundabout). See:

http://blog.2ndquadrant.com/postgresql-regression-tests-hanging-on-windows-check-path-depth/



Other SDKs
==========

Test reports for SDKs and Visual Studio versions listed as "untested"
below would be greatly appreciated, particularly if they come with
patches fixing any issues encountered. Add a GitHub issue with the results,
or better, send a pull request with a docs patch.

Visual Studio 6 is not and will never be supported.

Visual Studio 8 (2005)
------------------
Untested.

Visual Studio 9 (2008)
------------------
Untested.

Environment setup with vcvarsall.bat:

    "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" /?

Visual Studio 10 (2010)
------------------
Visual Studio 2010 and its express edition should work fine with no changes. Environment setup with vcvarsall.bat.

    "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" /?
	
vcvarsall.bat does not set TARGET_CPU, CONFIGURATION or PLATFORMTOOLSET so you must set these environment variables yourself.

Visual Studio 11 (2012)
------------------
Installing Visual Studio 2012 breaks Visual Studio 2010 (pre-SP1) and Windows SDK 7.1 . See TROUBLESHOOTING.

Environment setup with vcvarsall.bat or VsDevCmd.bat:

    "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat" /?

Build not supported for PostgreSQL 9.2 and older; 9.3 or newer is required
for Visual Studio 2012 build support.

Microsoft Platform SDK for Windows XP SP2 
-----------------------------------------
Untested

Microsoft Windows SDK for Windows 7 and .NET Framework 4 (7.1)
--------------------------------------------------------------
Known working, recommended. Environment setup with setenv.cmd.

    "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /?
	
Known compatibility issues with Visual Studio 2010, .NET 4.5, and Visual Studio 2012. See TROUBLESHOOTING.

Microsoft Windows SDK for Windows 8 and .NET Framework 4.5 (v8.0a)
------------------------------------------------------------------
You cannot compile PostgreSQL with this SDK because this version of the SDK does not include standalone compilers and build tools.

You must use Visual Studio 2012 or the express edition instead.

Obsolete versions
-----------------

The following obsolete SDK and Visual Studio releases are not supported and will never be supported by pg_build_win. Patches adding support will be rejected.

* Visual Studio 97
* Visual Studio 6
* Visual Studio 7 (.NET 2002, 2003)
* All Microsoft Platform SDK releases prior to Microsoft Platform SDK for Windows XP SP2

Unlisted SDKs
-------------

If you have test results for an SDK not listed above, please add a GitHub issue with the results.

RELEVANT DOCUMENTATION
======================

Compiling PostgreSQL from source on Windows: http://www.postgresql.org/docs/current/static/install-windows.html
Windows SDK unattended: http://support.microsoft.com/kb/2498225
ActivePerl unattended: http://docs.activestate.com/activeperl/5.16/install.html
ActiveTCL unattended: http://community.activestate.com/faq/unattended-installation-a
Python unattended: http://www.python.org/download/releases/2.5/msi/
