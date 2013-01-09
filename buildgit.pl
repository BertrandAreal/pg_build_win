#!perl -w
#
use FindBin qw($Bin);
use lib "$Bin";
use PgBuildWin::PgBuildWin qw(build);

my $val;
foreach $val (@ARGV) {
	if ($val =~ /^"?USE_GIT/) {
		die("Don't pass USE_GIT on the command line. Use buildgit.pl instead.");
	}
}
build(1) or die("Build failed.");