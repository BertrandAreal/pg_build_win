#
# Command and tool locations, working directories, etc.
#

# Working directory locations
!IFNDEF LIBDIR
LIBDIR=\pg\libs
!ENDIF
!IFNDEF PKGDIR
PKGDIR=$(LIBDIR)\pkg
!ENDIF

# These settings only apply if USE_GIT is set
!IFDEF USE_GIT

!IFNDEF PG_GIT_URL
!ERROR If USE_GIT is set, you must set PG_GIT_URL so we know where to get sources from. See the README.
!ENDIF
!IFNDEF PGDIR
!ERROR If USE_GIT is set you must specify PGDIR as the root of a tree to put builds in
!ENDIF
!IFNDEF PG_BRANCH
!ERROR If USE_GIT is set you must specify PG_BRANCH so we know what to check out
!ENDIF
!IFNDEF GIT
!ERROR If USE_GIT is set you must set GIT to the location of the git executable, or "git" if it's on the PATH
!ENDIF

!ENDIF


!IFNDEF TOOLPREFIX
TOOLPREFIX=c:
!ENDIF


# These will be the paths you get if you installed
# with the recommended unattended install settings.
!IFNDEF PERL_X86
PERL_X86=$(TOOLPREFIX)\perl
!ENDIF
!IFNDEF PERL_X64
PERL_X64=$(TOOLPREFIX)\perl64
!ENDIF
!IFNDEF PYTHON2_X86
PYTHON2_X86=$(TOOLPREFIX)\Python27_x86
!ENDIF
!IFNDEF PYTHON2_X64
PYTHON2_X64=$(TOOLPREFIX)\Python27_x64
!ENDIF
!IFNDEF PYTHON3_X86
PYTHON3_X86=$(TOOLPREFIX)\Python33_x86
!ENDIF
!IFNDEF PYTHON3_X64
PYTHON3_X64=$(TOOLPREFIX)\Python33_x64
!ENDIF
!IFNDEF TCL_X86
TCL_X86=$(TOOLPREFIX)\Tcl_85_x86
!ENDIF
!IFNDEF TCL_X64
TCL_X64=$(TOOLPREFIX)\Tcl_85_x64
!ENDIF

!IFNDEF MINGW
MINGW=$(TOOLPREFIX)\MinGW
!ENDIF

!IFNDEF MSYS
MSYS=$(MINGW)\msys\1.0\
!ENDIF

!IFNDEF 7ZIP
7ZIP=c:\Program Files\7-Zip\7z.exe
!ENDIF

# Tools the scripts can download and install
# for you.
!IFNDEF ZLIB_URL
ZLIB_URL=http://zlib.net/zlib127.zip
!ENDIF
!IFNDEF ZLIB_VERSION
ZLIB_VERSION=1.2.7
!ENDIF

# Override to specify a particular perl executable
!IFNDEF PERL_CMD
PERL_CMD=perl
!ENDIF

# Where to find wget for downloading sources
WGET=$(MSYS)\bin\wget.exe

# FIXME: currently we don't respect $(FLEX) and $(BISON)
# We assume they're in the msys directory.
FLEX=$(MSYS)\bin\flex.exe
TOUCH=$(MSYS)\bin\touch.exe
