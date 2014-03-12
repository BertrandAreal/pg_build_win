#
# This file configures the build. Copy it to
# "settings.pl" and edit it to reflect your needs and
# environment.
# 

$cfg = {

	'makeargs' => {
		'LIBDIR' => 'c:\pg\libs',
		'TOOLPREFIX' => 'c:',

		#################################### 
		# Manual PostgreSQL source trees   #
		####################################
		#
		# If you want to install the resulting build, set PGINSTALLDIR
		# to the location you want to install to. If unset, the default 
		# will be to install to "binaries\" under the build directory.
		'PGINSTALLDIR' => undef,
		
		##############################################
		# PostgreSQL automatically managed from git  #
		##############################################
		# These settings apply only to buildgit.pl
		'PGDIR' => 'c:\pg\postgresql',
        # Where to fetch changes from
        'PG_GIT_URL' => 'git://git.postgresql.org/git/postgresql.git',
        # If you want clones to use a --reference, specify the repo here.
        #
        # I strongly recommend using a local cache of the PostgreSQL git repo
        # e.g. C:\pg\postgresql-git and using Task Scheduler to pull a mirror
        # of PostgreSQL's master repo on a regular basis. See the README.
        #
        #'PG_GIT_REFERENCE' => 'c:\pg\postgresql-git',
		'PG_BRANCH' => 'master',
		# The location of git will usually be autodetected, and it'll be found on
		# the PATH if present. Set it if the scripts don't find it.
		#'GIT' => undef
		# if you GIT_PULL to any value in USE_GIT mode then the
		# working directory will be updated before each build. 
		'GIT_PULL' => 1
	} # end of @makeargs
};
