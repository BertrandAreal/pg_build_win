#!perl -w
#
# This script is a wrapper around the makefiles
# used to do most of the work of building PostgreSQL and its
# dependencies. The it works around some of the
# limitations of nmake, like the lack of any way to define
# a macro based on the output of invoking a command.
#
# A file named 'settings.pl' must be present in the same
# directory as buildall.pl. 
#

our $VERSION = 1.00;
our @ISA = qw(Exporter);
# Always export:
our @EXPORT = ();
# Export only on request
our @EXPORT_OK = qw(build);

use strict;
use Data::Dumper;
use Cwd;
use File::Spec::Win32 qw(canonpath);

use PgBuildWin::Config qw(cfg_read);
use PgBuildWin::DetectSDK;

sub build($) {
	my ($use_git) = @_;
	
	my $verstring = PgBuildWin::DetectSDK->ver_string();
	my $cfg = cfg_read($use_git);
	print "Effective configuration:\n";
	print Dumper($cfg) . "\n\n";

	my @makeargs = (
		'/F', "\"$cfg->{'makefile'}\"",
		"SDKVERSION=\"$verstring\""
	);
	if ($use_git) {
		push(@makeargs, 'USE_GIT=1');
	} else {
		push(@makeargs, 'PGBUILDDIR="' . File::Spec::Win32->canonpath(getcwd()) . '"');
	}
	# Add config make arguments
	while (my ($k,$v) = each %$cfg->{'makeargs'}) {
		if (defined($v)) {
			push(@makeargs, "$k=\"$v\"");
		}
	}
	# Add command line args. Should really clean this up.
	foreach my $arg (@ARGV) {
		print("ARG: $arg\n");
		push(@makeargs, '"'.$arg.'"');
	}
	my $cmd = "nmake ".join(' ',@makeargs);
	print "Make command:\n";
	print $cmd . "\n";
	my $ret = system($cmd);
	if ($ret != 0) {
		print("Build failed, return code from nmake was $ret\n");
	} else {
		print("Build successful");
	}
	return $ret == 0;
}