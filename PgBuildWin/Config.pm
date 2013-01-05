package PgBuildWin::Config;

use strict;
use warnings;
use Exporter;
use File::Spec::Functions qw/catfile catdir devnull/;
use IPC::Open3 qw( open3 );
use FindBin qw($Bin);

our $VERSION = 1.00;
our @ISA = qw(Exporter);
# Always export:
our @EXPORT = ();
# Export only on request
our @EXPORT_OK = qw(cfg_read);


sub set_ind($$$) {
	# Set key $k in hash of hash-ref $h to $v if $k is not already set
	# to a non-undef value.
	my ($h, $k, $v) = @_;
	if (!defined($h->{$k})) {
		$h->{$k} = $v;
	}
};

sub test_cmd($) {
	my $cmd = $_[0];
	open(local *NUL, '>', devnull()) or die;
	my $pid = open3('<STDIN', '>&NUL', '>&NUL', $cmd);
	waitpid($pid, 0);
	return $? == 0;
}

sub test_lang($$$$) {
	# Common code from test_perl, test_python, etc
	my ($ma, $k, $default, $testcmd) = ($_[0], $_[1], $_[2], $_[3]);
	my $cmddir = exists $ma->{$k} ? $ma->{$k} : $default;
	if (!defined($cmddir)) {
		# cmd explicitly set to `undef`; return
		return 0;
	}
	$testcmd =~ s/\{COMMANDDIR\}/$cmddir/;
	my $cmdok = test_cmd($testcmd);
	if ($cmdok) {
		print("Found $k at $cmddir\n");
		$ma->{$k} = $cmddir;
	} else {
		print("config.pl makeargs $k: $testcmd failed\n");
		print("Disabling $k. To suppress this message set $k=undef in settings.pl.\n");
		delete($ma->{$k});
	}
	return $cmdok;
}

sub test_perl($$$) {
	return test_lang($_[0], $_[1], $_[2], catdir('"{COMMANDDIR}"','bin','perl.exe') . ' --version');
}

sub test_python($$$) {
	return test_lang($_[0], $_[1], $_[2], catdir('"{COMMANDDIR}"','python.exe') . ' --version');
}

sub test_tcl($$$) {
	# TCL is weird. It doesn't have any sane way to just pass an argument to see if it
	# exists and works. You have to use 'echo exit 0 | d:\Tcl_x64\bin\tclsh.exe' or similar.
	#
	return test_lang($_[0], $_[1], $_[2], 'echo exit 0 | "{COMMANDDIR}"\bin\tclsh.exe');
	exit(0);
}

sub find_git() {
	my $git;
	foreach $git (
		"git", 
		"$ENV{'ProgramFiles'}\\Git\\bin\\git",
		"$ENV{'ProgramFiles(x86)'}\\Git\\bin\\git"
	) {
		return $git if test_cmd('"' . $git . '" --version');
	}
	return;
}

# Pass a reference to the config hash to merge_defaults
# and it'll be extended with default settings.
sub merge_defaults($$) {
	my ($cfg, $use_git) = ($_[0], $_[1]);
	
	die("makeargs key missing from cfg dict") 
		unless defined($cfg->{'makeargs'});
	my $ma = $cfg->{'makeargs'};
	
	set_ind($ma, 'TARGET_CPU', $ENV{'TARGET_CPU'});
	my $cpu = lc($ma->{'TARGET_CPU'});
	if (!defined($cpu)) {
		die("TARGET_CPU isn't defined in settings.pl or the environment. Did you run vcvars or setenv.cmd?");
	}
	
	die("Don't set USE_GIT in settings.pl; use buildgit.pl instead.") if exists($ma->{'USE_GIT'});

	set_ind($ma, 'CONFIGURATION', $ENV{'CONFIGURATION'});
	
	set_ind($ma, 'LIBDIR', '\pg\libs');
	set_ind($ma, 'PKGDIR', catdir($ma->{'LIBDIR'}, 'pkgs'));
	if (defined($ma->{'USE_GIT'})) {
		die("Don't set USE_GIT in settings.pl; use buildgit.pl instead");
	}
	if ($use_git) {
		if (!defined($ma->{'GIT'})) {
			# Git location not specified. Try to find it; if we can't,
			# fail.
			$ma->{'GIT'} = find_git()
				or die ("If USE_GIT is set you must set GIT to the location of the git executable or add git to the PATH");
		}
	} else {
		# Unset git-related params if USE_GIT is not set
		delete $ma->{'GIT'};
		delete $ma->{'GIT_PULL'};
		delete $ma->{'PG_GIT_URL'};
		delete $ma->{'PGDIR'};
		delete $ma->{'PG_BRANCH'};
	}
	set_ind($ma, 'TOOLPREFIX', 'c:');
	# TODO: Be smarter about these, try to find them
	# in the Registry?
	# These will be the paths you get if you installed
	# with the recommended unattended install settings.
	if ($cpu eq "x86") {
		test_perl($ma, 'PERL_X86', catdir($ma->{'TOOLPREFIX'}, 'perl'));
		test_python($ma, 'PYTHON2_X86', catdir($ma->{'TOOLPREFIX'}, 'Python27_x86'));
		test_python($ma, 'PYTHON3_X86', catdir($ma->{'TOOLPREFIX'}, 'Python33_x86'));
		test_tcl($ma, 'TCL_X86', catdir($ma->{'TOOLPREFIX'}, 'Tcl_85_x86'));
	} elsif ($cpu eq "x64") {
		test_perl($ma, 'PERL_X64', catdir($ma->{'TOOLPREFIX'}, 'perl64'));
		test_python($ma, 'PYTHON2_X64', catdir($ma->{'TOOLPREFIX'}, 'Python27_x64'));
		test_python($ma, 'PYTHON3_X64', catdir($ma->{'TOOLPREFIX'}, 'Python33_x64'));
		test_tcl($ma, 'TCL_X64', catdir($ma->{'TOOLPREFIX'}, 'Tcl_85_x64'));
	} else {
		die("Unknown TARGET_CPU $cpu");
	}

	set_ind($ma, 'MINGW', catdir($ma->{'TOOLPREFIX'}, 'MinGW'));
	set_ind($ma, 'MSYS', catdir($ma->{'MINGW'}, 'msys', '1.0'));
	# you can also use 7za, the standalone 7zip, here.
	set_ind($ma, '7ZIP', catfile($ENV{'ProgramFiles'}, '7-Zip','7z.exe'));
	
	# Tools the scripts can download and install
	# for you.
	set_ind($ma, 'ZLIB_URL', 'http://zlib.net/zlib127.zip');
	set_ind($ma, 'ZLIB_VERSION', '1.2.7');

	# Override this to specify a particular perl executable
	set_ind($ma, 'PERL_CMD', 'perl');

	# Where to find wget for downloading sources
	# TODO: Do downloads with Perl instead
	set_ind($ma, 'WGET', catfile($ma->{'MSYS'}, 'bin', 'wget.exe'));

	# FIXME: currently we don't respect $(FLEX) and $(BISON)
	# We assume they're in the msys directory.
	set_ind($ma, 'FLEX', catfile($ma->{'MSYS'}, 'bin', 'flex.exe'));
	set_ind($ma, 'BISON', catfile($ma->{'MSYS'}, 'bin', 'bison.exe'));
	set_ind($ma, 'TOUCH', catfile($ma->{'MSYS'}, 'bin', 'touch.exe'));
};


# Read a filenamed "settings.pl" in the same location
# as the outer script, merge it with the defaults, and
# return it.
#
# Usage: cfg_read_file(path_to_settings_pl, use_git)
#
sub cfg_read_file($$) {
	my ($settingspl, $use_git) = ($_[0], $_[1]);
	{
		package PgBuildWin::CFG;
		my $return;
		our $cfg;
		unless ($return = do $settingspl) {
			die "couldn't parse $settingspl: $@" if $@;
			die "couldn't do $settingspl: $!"    unless defined $return;
			die "$settingspl ran with errors"    unless $return;
		}
	}
	if (!defined($PgBuildWin::CFG::cfg)) {
		die("settings.pl must assign a hash to \$cfg, but did not");
	}
	merge_defaults($PgBuildWin::CFG::cfg, $use_git);
	return $PgBuildWin::CFG::cfg;
};

# Usage: cfg_read(use_git)
#
sub cfg_read($) {
	my $use_git = $_[0];
	my $pg_build_win_dir = $Bin;
	my $settingspl = catfile( ($pg_build_win_dir), 'settings.pl');
	if (! -e $settingspl) {
		print "Expected to find settings.pl at $settingspl.\n";
		print "Copy settings_template.pl to $settingspl and edit to fit your environment.\n";
		die("Exiting: settings.pl missing");
	}
	my $cfg = cfg_read_file($settingspl, $use_git);
	$cfg->{'makefile'} = catfile($pg_build_win_dir, 'Makefile');
	return $cfg;
}

1;




