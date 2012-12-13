#
# Command and tool locations, working directories, etc.
#

# Working directory locations
!IFNDEF LIBDIR
LIBDIR=d:\libs
!ENDIF
!IFNDEF PKGDIR
PKGDIR=$(LIBDIR)\pkg
!ENDIF
!IFNDEF PGDIR
PGDIR=d:\postgresql
!ENDIF

PG_GIT_URL=D:\postgresql\postgresql-git
PG_BRANCH=REL9_2_STABLE

TOOLPREFIX=d:

# These will be the paths you get if you installed
# with the recommended unattended install settings.
PERL_X86=$(TOOLPREFIX)\perl
PERL_X64=$(TOOLPREFIX)\perl64
PYTHON2_X86=$(TOOLPREFIX)\Python27_x86
PYTHON2_X64=$(TOOLPREFIX)\Python27_x64
PYTHON3_X86=$(TOOLPREFIX)\Python33_x86
PYTHON3_X64=$(TOOLPREFIX)\Python33_x64
TCL_X86=$(TOOLPREFIX)\Tcl_x86
TCL_X64=$(TOOLPREFIX)\Tcl_x64

MINGW=$(TOOLPREFIX)\MinGW
MSYS=$(MINGW)\msys\1.0\

7ZIP=c:\Program Files\7-Zip\7z.exe
GIT=c:\Program Files (x86)\Git\bin\git.exe

# Tools the scripts can download and install
# for you.
ZLIB_URL=http://zlib.net/zlib127.zip
ZLIB_VERSION=1.2.7

# Override to specify a particular perl executable
PERL_CMD=perl

# Where to find wget for downloading sources
WGET=$(MSYS)\bin\wget.exe

# FIXME: currently we don't respect $(FLEX) and $(BISON)
# We assume they're in the msys directory.
FLEX=$(MSYS)\bin\flex.exe
TOUCH=$(MSYS)\bin\touch.exe