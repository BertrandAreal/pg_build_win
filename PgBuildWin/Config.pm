package PgBuildWin::Config;

use strict;
use warnings;
use Exporter;
use File::Spec::Functions qw/catfile catdir devnull/;
use IPC::Open3 qw( open3 );
use FindBin qw($Bin);
use File::Basename qw/dirname/;

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

sub set_ind_path($$$) {
	# Same as set_ind, but only sets default if the path actually exists
	my ($h, $k, $v) = @_;
	if (-e $k) {
		set_ind($h,$k,$v);
	}
}

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
	return undef;
}

sub find_7zip($) {
	my $ma = $_[0];
	my $sevenz;
	foreach $sevenz (
		'7z',
		'7za',
		catfile($ENV{'ProgramFiles'}, '7-Zip','7z.exe'),
		catfile($ENV{'ProgramFiles(x86)'}, '7-Zip','7z.exe')
	) {
		if (test_cmd('"' . $sevenz . '"')) {
			$ma->{'7ZIP'} = $sevenz;
			return 1;
		}
	}
}

sub add_util_to_path($) {
	my $cmd = $_[0];
	my $cmddir = dirname($cmd);
	if ( ($cmddir ne '.') && (index($ENV{'PATH'}, $cmddir) == -1) ) {
		$ENV{PATH} .= ';' . $cmddir;
		print("Added " . $cmddir . " to PATH\n");
	}
}

# Pass a reference to the config hash to merge_defaults
# and it'll be extended with default settings.
sub merge_defaults($$) {
	my ($cfg, $use_git) = ($_[0], $_[1]);
	
	die("makeargs key missing from cfg dict") 
		unless defined($cfg->{'makeargs'});
	my $ma = $cfg->{'makeargs'};
	
	set_ind($ma, 'TARGET_CPU', defined($ENV{'TARGET_CPU'}) ? $ENV{'TARGET_CPU'} : '');
	my $cpu = lc($ma->{'TARGET_CPU'});
	if (!defined($cpu) || $cpu eq '') {
		die("TARGET_CPU isn't defined in settings.pl or the environment. See README.");
	}

	set_ind($ma, 'CONFIGURATION', defined($ENV{'CONFIGURATION'}) ? $ENV{'CONFIGURATION'} : '');
	if ($ma->{'CONFIGURATION'} eq '') {
		die("CONFIGURATION isn't defined in settings.pl or the environment. See README.");
	}
	
	die("Don't set USE_GIT in settings.pl; use buildgit.pl instead.") if exists($ma->{'USE_GIT'});
	
	set_ind($ma, 'LIBDIR', '\pg\libs');
	set_ind($ma, 'PKGDIR', catdir($ma->{'LIBDIR'}, 'pkgs'));
	if (defined($ma->{'USE_GIT'})) {
		die("Don't set USE_GIT in settings.pl; use buildgit.pl instead");
	}
	if (!defined($ma->{'GIT'})) {
		# Git location not specified. Try to find it. If we can't it
		# is only fatal if USE_GIT is set, but we use it for flex/bison/
		# etc otherwise, so we still want it.
		$ma->{'GIT'} = find_git();
	}
	if ($use_git) {
		if (!defined($ma->{'GIT'})) {
			die ("If USE_GIT is set you must set GIT to the location of the git executable or add git to the PATH");
		}
	} else {
		# Unset git-related params if USE_GIT is not set
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
	
	# Tools the scripts can download and install
	# for you.
	set_ind($ma, 'ZLIB_URL', 'http://zlib.net/zlib128.zip');
	set_ind($ma, 'ZLIB_VERSION', '1.2.8');

	# Override this to specify a particular perl executable
	set_ind($ma, 'PERL_CMD', 'perl');

	set_ind_path($ma, 'MINGW', catdir($ma->{'TOOLPREFIX'}, 'MinGW'));
	set_ind_path($ma, 'MSYS', catdir($ma->{'MINGW'}, 'msys', '1.0'));
	
	# Look for flex, curl, bison and touch in msysgit, then if not found in
	# mingw.
	my $cmd;
	foreach $cmd ('flex', 'bison', 'touch','curl', 'tee') {
		if (!defined($ma->{uc($cmd)})) {
			if (test_cmd("\"$cmd\" --version")) {
				print("Detected $cmd on PATH\n");
				$ma->{uc($cmd)} = $cmd;
				next;
			}
			if (defined($ma->{'GIT'})) {
				# Why shortpaths? Bison may misbehave if the path has spaces in it.
				my $cmdpath = Win32::GetShortPathName(catfile(dirname($ma->{'GIT'}),$cmd . '.exe'));
				if (test_cmd("\"$cmdpath\" --version")) {
					print("Detected $cmd at $cmdpath\n");
					$ma->{uc($cmd)} = $cmdpath;
					next;
				}
			}
			if (defined($ma->{'MINGW'})) {
				my $cmdpath = Win32::GetShortPathName(catfile($ma->{'MINGW'}, $cmd . '.exe'));
				if (test_cmd("\"$cmdpath\" --version")) {
					print("Detected $cmd at $cmdpath\n");
					$ma->{uc($cmd)} = $cmdpath;
					next;
				}
			}
		}
	}
	
	foreach $cmd ('flex', 'bison', 'touch','curl') {
		if (!defined($ma->{uc($cmd)})) {
			die('Could not find usable ' . uc($cmd) . '. Looked in MAKEARGS, git install, mingw. See README.');
		}
		if (!test_cmd("\"$ma->{uc($cmd)}\" --version")) {
			die("Expected usable $cmd at $ma->{uc($cmd)}, cannot proceed with build. See README.\n");
		}
	}
	
	if ($ma->{'BISON'} =~ / /) {
		my $shortbison = Win32::GetShortPathName($ma->{'BISON'});
		if ($shortbison =~ / /) {			
			print("---------------------------------------------\n");
			print("WARNING: Path to bison has spaces in the name, malfunction is highly likely\n");
			print("Press control-C to abort the build; it will continue in 2 seconds\n");
			print("---------------------------------------------\n");
			sleep(2);
		} else {
			print("WARNING: bison path has spaces in it. Converting to shortname form $shortbison\n");
			$ma->{'BISON'} = $shortbison;
		}
		sleep(5);
	}
	
	# The PostgreSQL build expects flex and bison to be on the PATH; it can't take their locations
	# via an env var, because pgflex.pl and pgbison.pl just assume a bare command. Extract the paths
	# and inject them into the environment.
	add_util_to_path($ma->{'FLEX'});
	add_util_to_path($ma->{'BISON'});
	
	# you can also use 7za, the standalone 7zip, here.
	if (!defined($ma->{'7ZIP'})) {
		find_7zip($ma) or die ("7ZIP not in MAKEARGS and not found in well known locations. See README.\n");
	} elsif (!test_cmd('"' . $ma->{'7ZIP'} . '"')) {
		die("7ZIP was set in MAKEARGS but could not be executed. See README.");
	}
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
