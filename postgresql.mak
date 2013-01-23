#
# Build PostgreSQL
#

!IFDEF USE_GIT
# The horrific FOR construct is the command-shell equivalent of
#  IF ! test "`$(GIT) ls-remote origin $(GIT_BRANCH) | cut -f 1`" == "`$(GIT) rev-parse HEAD`" THEN
# What it's doing is testing to see if the remote has changed and updating if it has.
#
$(PGBUILDDIR): phony
	@IF NOT EXIST "$(PGBUILDDIR)" md "$(PGBUILDDIR)
	IF NOT EXIST "$(PGBUILDDIR)\.git" "$(GIT)" clone -b "$(PG_BRANCH)" "$(PG_GIT_URL)" "$(PGBUILDDIR)"
	cd $(PGBUILDDIR)
	IF "$(GIT_PULL)" == "1" FOR /f "tokens=1" %G IN ('"$(GIT)" ls-remote origin $(PG_BRANCH)') DO FOR /f %H IN ('"$(GIT)" rev-parse HEAD') DO IF NOT "%G" == "%H" "$(GIT)" checkout --force $(PG_BRANCH) && "$(GIT)" pull --force
!ELSE
# This is a dummy target because we expect a valid Pg tree to be 
# at $(PGBUILDDIR) already. If there isn't one, protest.
$(PGBUILDDIR): phony
	@IF NOT EXIST "$(PGBUILDDIR)"\GNUmakefile.in (echo "No PostgreSQL source tree at $(PGBUILDDIR) and USE_GIT not set" && EXIT 1)
!ENDIF

#
# This target will always build, because NMake will always see "$(PGBUILDDIR) as dirty;
# it doesn't test directory timestamps. That's OK, since there's no reliable way for
# us to find out if the tree is dirty, so we have to re-run the build and let it decide
# anyway.
#
# The weird hack with tee works around an odd stdio issue that seems to occur
# on some machines with some consoles and some SDK versions with some Perl versions.
# Which ones? Never did work it out.
#
postgresql: zlib $(PGBUILDDIR) $(CONFIG_PL) $(BUILDENV_PL)
	cd $(PGBUILDDIR)\src\tools\msvc
!IFDEF TEE
	"$(PERL_CMD)" build.pl 2>&1 | tee build-log.log
!ELSE
	"$(PERL_CMD)" build.pl
!ENDIF
	
!IFDEF USE_GIT	
postgresql-clean: phony
	IF EXIST $(PGBUILDDIR)\.git\HEAD ( cd $(PGBUILDDIR) &&  "$(GIT)" clean -fdx )
	IF EXIST $(PGINSTALLDIR) rd /s /q $(PGINSTALLDIR)
!ELSE
postgresql-clean: phony
	IF EXIST $(PGBUILDDIR)\src\tools\msvc ( cd $(PGBUILDDIR)\src\tools\msvc && clean dist)
	IF EXIST $(PGINSTALLDIR) rd /s /q $(PGINSTALLDIR)
!ENDIF

postgresql-check: postgresql
	cd $(PGBUILDDIR)\src\tools\msvc
	"$(PERL_CMD)" vcregress.pl check

postgresql-install: postgresql
	cd $(PGBUILDDIR)\src\tools\msvc
	install.bat $(PGINSTALLDIR)