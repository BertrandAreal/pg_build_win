package PgBuildWin::DetectSDK;

use strict;

our $VERSION = 1.00;
our @ISA = qw(Exporter);
our @EXPORT = ();
our @EXPORT_OK = qw/ver_string/;

sub get_vc_info() {
	# Extract the version from the WindowsSDKDir path; amazingly,
	# there doesn't seem to be an environment variable or standard
	# command to report the SDK version.
	if (!defined($ENV{'WindowsSDKDir'})) {
		die("WindowsSDKDir env var not set. Did you run setenv.cmd or vcvars.bat?");
	}
	my $sdkvers;
	if ($ENV{'WindowsSDKDir'} =~ /Microsoft SDKs\\Windows\\([^\\]+)/) {
		$sdkvers = $1;
	}

	# Try to determine the cl.exe version
	open(CLOUTPUT, "cl 2>&1 |") or die ("Failed to exec cl.exe: $!");
	my $clvers;
	my @cloutput = ();
	while (<CLOUTPUT>) {;
		push(@cloutput, $_);
		if (/.*Version\s(\d{1,3})/) {
			$clvers = $1;
			last;
		}
	}
	close(CLOUTPUT);
	if (!defined($clvers)) {
		die("cl.exe executed, but unable to determine cl.exe version from output. Output was: \n" . join("\n",@cloutput));
	}

	# If we're running under a Visual Studio SDK set up with vcvarsall.bat,
	# VCINSTALLDIR will point to the Visual Studio install. Get its version.
	my $vsvers;
	if (defined($ENV{'VCINSTALLDIR'}) && $ENV{'VCINSTALLDIR'} =~ /Microsoft Visual Studio (\d+\.?\d*)/) {
		$vsvers = $1;
	}
	return ($sdkvers, $clvers, $vsvers);
}

sub detect_sdk() {
	our ($sdkvers, $clvers, $vsvers) = get_vc_info();
	our $verstring = "sdk${sdkvers}_cl${clvers}" . (defined($vsvers)?"_vs${vsvers}":"");
};

sub ver_string() {
	our $verstring;
	if (!defined($verstring)) {
		detect_sdk();
	}
	return $verstring;
}