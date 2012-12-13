# NMakefile to build Pg libs
#
# Useful docs:
#  http://msdn.microsoft.com/en-us/library/cbes8ded(v=vs.80).aspx
#  http://msdn.microsoft.com/en-us/library/y5d8s7f6(v=vs.80).aspx
#  http://msdn.microsoft.com/en-us/library/7y32zxwh(v=vs.80).aspx

!INCLUDE settings.mak

!IFNDEF TARGET_CPU
!ERROR "TARGET_CPU is not set. Did you run vcvars or setenv?"
!ENDIF

!IFNDEF CONFIGURATION
!ERROR "CONFIGURATION is not set. Did you run vcvars or setenv?"
!ENDIF

!IFNDEF PLATFORMTOOLSET
!ERROR "PLATFORMTOOLSET is not set. Did you run vcvars or setenv?"
!ENDIF

# PLATFORMTOOLSET, TARGET_CPU and CONFIGURATION are set by vcvars from visual studio
# or setenv from the winsdk for WinSDK pass /x86 or /x64 to set TARGET_CPU 
# and /Release or /Debug to set CONFIGURATION
#
# You can't set PLATFORMTOOLSET, it's a version param.
#
LIBBUILDDIR=$(LIBDIR)\$(PLATFORMTOOLSET)\$(TARGET_CPU)\$(CONFIGURATION)
PGBUILDDIR=$(PGDIR)\$(PLATFORMTOOLSET)\$(TARGET_CPU)\$(CONFIGURATION)

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

default: all

$(WGET) $(BISON) $(FLEX) $(TOUCH):
	$(MINGW)\bin\mingw-get install msys msys-wget msys-bison msys-flex
	
!INCLUDE zlib.mak
!INCLUDE configpl.mak
!INCLUDE postgres.mak

all: $(ZLIB_OBJS) $(FLEX) $(BISON)

clean:
	@-rd /s /q $(LIBBUILDDIR)
	@-rd /s /q $(PGBUILDDIR)
	@-del $(CONFIG_PL) $(BUILDENV_PL)