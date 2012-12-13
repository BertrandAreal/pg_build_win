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
!IFNDEF PGDIR
PGDIR=\pg\postgresql
!ENDIF

!IFNDEF PG_GIT_URL
PG_GIT_URL=\pg\postgresql-git
!ENDIF

!IFNDEF PG_BRANCH
PG_BRANCH=REL9_2_STABLE
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
TCL_X86=$(TOOLPREFIX)\Tcl_x86
!ENDIF
!IFNDEF TCL_X64
TCL_X64=$(TOOLPREFIX)\Tcl_x64
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

!IFNDEF GIT
GIT=c:\Program Files (x86)\Git\bin\git.exe
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
