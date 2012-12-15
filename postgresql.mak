#
# Build PostgreSQL
#

!IFDEF USE_GIT
$(PGBUILDDIR): phony
	@IF NOT EXIST "$(PGBUILDDIR)" md "$(PGBUILDDIR)
	IF NOT EXIST "$(PGBUILDDIR)\.git" "$(GIT)" clone -b "$(PG_BRANCH)" "$(PG_GIT_URL)" "$(PGBUILDDIR)"
	cd $(PGBUILDDIR)
	"$(GIT)" pull --force
!ELSE
# This is a dummy target because we expect a valid Pg tree to be 
# at $(PGBUILDDIR) already. If there isn't one, protest.
$(PGBUILDDIR): phony
	@IF NOT EXIST "$(PGBUILDDIR)"\GNUmakefile.in (echo "No PostgreSQL source tree at $(PGBUILDDIR) and USE_GIT not set" && EXIT 1)
!ENDIF

postgresql: $(FLEX) $(BISON) zlib $(PGBUILDDIR) $(CONFIG_PL) $(BUILDENV_PL)
	cd $(PGBUILDDIR)\src\tools\msvc
	"$(PERL_CMD)" build.pl

!IFDEF USE_GIT	
postgresql-clean: phony
	IF EXIST $(PGBUILDDIR)\.git\HEAD ( cd $(PGBUILDDIR) &&  "$(GIT)" clean -fdx )
!ELSE
postgresql-clean: phony
	IF EXIST $(PGBUILDDIR)\src\tools\msvc ( cd $(PGBUILDDIR)\src\tools\msvc && clean dist)
!ENDIF

postgresql-check: postgresql
	cd $(PGBUILDDIR)\src\tools\msvc
	"$(PERL_CMD)" vcregress.pl check