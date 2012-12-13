#
# Build PostgreSQL
#


$(PGBUILDDIR)\$(PG_BRANCH): phony
	@IF NOT EXIST "$(PGBUILDDIR)" md "$(PGBUILDDIR)
	IF NOT EXIST "$(PGBUILDDIR)\$(PG_BRANCH)" "$(GIT)" clone -b "$(PG_BRANCH)" "$(PG_GIT_URL)" "$(PGBUILDDIR)\$(PG_BRANCH)"
	cd $(PGBUILDDIR)\$(PG_BRANCH)
	"$(GIT)" pull --force
	
postgresql: $(FLEX) $(BISON) zlib $(PGBUILDDIR)\$(PG_BRANCH) $(CONFIG_PL) $(BUILDENV_PL)
	cd $(PGBUILDDIR)\$(PG_BRANCH)\src\tools\msvc
	"$(PERL_CMD)" build.pl
	
postgresql-clean:
	IF EXIST $(PGBUILDDIR)\$(PG_BRANCH)\.git\HEAD ( cd $(PGBUILDDIR)\$(PG_BRANCH) &&  "$(GIT)" clean -fdx )

postgresql-check: postgresql
	cd $(PGBUILDDIR)\$(PG_BRANCH)\src\tools\msvc
	"$(PERL_CMD)" vcregress.pl check