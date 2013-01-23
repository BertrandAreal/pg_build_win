package PgBuildWin::Config;

use strict;
use warnings;
use Exporter;
use LWP::Simple qw( getstore is_success );
use File::Spec::Functions qw/catfile catdir devnull/;
#use IPC::Open3 qw( open3 );
#use FindBin qw($Bin);

our $VERSION = 1.00;
our @ISA = qw(Exporter);
# Always export:
our @EXPORT = ();
# Export only on request
our @EXPORT_OK = qw();

my $resources = {
	'GIT' => ('http://msysgit.github.com/', 'http://msysgit.googlecode.com/files/Git-1.8.0-preview20121022.exe', 'Git-1.8.0-preview20121022.exe')
};

sub install_git($) {
	my $cfg = $_[0];
	my ($home,$dl,$localfilename) = $resources->{'GIT'};
	my $localfilepath = catfile($cfg->{'PKGDIR'}, $localfilename);
	my $dl_result = getstore($dl);
	if (is_success($dl_result)) {
		print("Successfully downloaded git");
	} else {
		print("Download of git failed with HTTP $dl_result\n");
	}
}

