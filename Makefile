# NMakefile to build Pg libs
#
# Useful docs:
#  http://msdn.microsoft.com/en-us/library/cbes8ded(v=vs.80).aspx
#  http://msdn.microsoft.com/en-us/library/y5d8s7f6(v=vs.80).aspx
#  http://msdn.microsoft.com/en-us/library/7y32zxwh(v=vs.80).aspx

!IFNDEF TARGET_CPU
!ERROR "TARGET_CPU is not set. See the README."
!ENDIF

!IFNDEF CONFIGURATION
!ERROR "CONFIGURATION is not set. See the README."
!ENDIF

!IFNDEF SDKVERSION
!ERROR "SDKVERSION is unset. You need to invoke this makefile via buildall.pl, not directly."
!ENDIF

# TARGET_CPU and CONFIGURATION are set by setenv from the winsdk. 
# Pass /x86 or /x64 to set TARGET_CPU and /Release or /Debug to set CONFIGURATION .
#
# These vars are not set by vcvarsall.bat. You must set CONFIGURATION on the
# nmake command line or in the environment. TARGET_CPU can be set with vcvarsall
# or by opening the appropriate command prompt in the first place.
#
LIBBUILDDIR=$(LIBDIR)\$(SDKVERSION)\$(TARGET_CPU)\$(CONFIGURATION)

# By default the tools will build PostgreSQL from git in a tree it creates.
# If you want to you can instead specify a PGBUILDDIR location, in which case
# it'll build in that directory instead of checking out from git.
#
# 

!IFDEF USE_GIT
PGBUILDDIR=$(PGDIR)\$(SDKVERSION)\$(TARGET_PLATFORM)\$(TARGET_CPU)\$(CONFIGURATION)\$(PG_BRANCH)
!ELSE
!IFNDEF PGBUILDDIR
!ERROR USE_GIT is not set, so you must set PGBUILDDIR to the location of a PostgreSQL source tree
!ENDIF
!ENDIF

!IFNDEF PGINSTALLDIR
PGINSTALLDIR=$(PGBUILDDIR)\binaries
!ENDIF

!IF ( "$(TARGET_CPU)" == "x86" )
PERLDIR=$(PERL_X86)
PYTHON2DIR=$(PYTHON2_X86)
PYTHON3DIR=$(PYTHON3_X86)
TCLDIR=$(TCL_X86)
!ELSE IF ( "$(TARGET_CPU)" == "x64" )
PERLDIR=$(PERL_X64)
PYTHON2DIR=$(PYTHON2_X64)
PYTHON3DIR=$(PYTHON3_X64)
TCLDIR=$(TCL_X64)
!ELSE
!ERROR "Unrecognised target cpu $(TARGET_CPU)
!ENDIF

default: postgresql

phony:

!INCLUDE zlib.mak
!INCLUDE configpl.mak
!INCLUDE postgresql.mak
!include install.mak

clean: zlib-clean postgresql-clean
	IF EXIST $(LIBBUILDDIR) rd /s /q $(LIBBUILDDIR)
	
really-clean: clean zlib-really-clean
	IF EXIST $(LIBDIR) rd /s /q $(LIBDIR)
	IF EXIST $(PGDIR) rd /s /q $(PGDIR)
	
