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
if (! -e 'src\tools\msvc\build.pl') {
	die('src\tools\msvc\build.pl not found - did you run buildcwd.pl from a PostgreSQL source tree? See the README.');
}
build(0) or die("Build failed.");