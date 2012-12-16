# You can override any settings in settings-defaults.mak here

#LIBDIR=d:\libs
#TOOLPREFIX=d:

#################################### 
# Manual PostgreSQL source trees   #
####################################
#
# If USE_GIT is not set, PGBUILDDIR must be set to point to the path of a PostgreSQL
# source tree - an unpacked tarball or a git working directory. You can use:
#
#    nmake /f \path\to\pg_build_win\Makefile PGBUILDDIR=%CD%
#
# ... to use the current directory.
#
# If you want to install the resulting build, set PGINSTALLDIR to the location
# you want to install to. If unset, the default will be to install to "binaries\"
# under the build directory.
# 
##############################################
# PostgreSQL automatically managed from git  #
##############################################
#
#
# If you define USE_GIT (to anything; it's not a boolean) then these build
# scripts will perform git checkouts of the Pg source tree into a tree based
# at PGDIR.
#
#USE_GIT=1
#PGDIR=d:\postgresql
#PG_GIT_URL=D:\postgresql-git
#PG_BRANCH=REL9_2_STABLE
#GIT=c:\Program Files (x86)\Git\bin\git.exe
#
# If you set:
#GIT_PULL=1
# in USE_GIT mode then the working directory will be updated before each build.
