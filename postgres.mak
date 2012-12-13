#
# Build PostgreSQL
#

$(PGBUILDDIR)\$(PG_BRANCH)\GNUmakefile.in:
	IF NOT EXIST "$(PGBUILDDIR)" md "$(PGBUILDDIR)"
	"$(GIT)" clone "$(PG_GIT_URL)" "$(PGBUILDDIR)\$(PG_BRANCH)"
	
postgresql: $(PGBUILDDIR)\$(PG_BRANCH)\GNUmakefile.in $(CONFIG_PL) $(BUILDENV_PL)
	cd $(PGBUILDDIR)\$(PG_BRANCH)\src\tools\msvc
	"$(PERL_CMD)" build.pl