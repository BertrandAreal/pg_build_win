# To run you must first:
#
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
#
# You may also want to run Update-Help
#
# Then:
#
#     .\SetupBuildEnv.ps1

$installers = "c:\pg\installers\";

# Block for all the generic MSI installers
$msiinstall = {
	param($f)
	Start-Process "msiexec" -ArgumentList ('/i', $f, '/qb', '/passive') -Wait
}

$installsdk = {
	param($f);
	$7z = "$((Get-ItemProperty -Path "hkcu:\Software\7-Zip" -Name Path).Path)\7z.exe"
	Start-Process $7z -ArgumentList ('x', $f, '-y') -Wait
	Start-Process "setup.exe" -ArgumentList ('-q', '-params:ADDLOCAL=ALL') -Wait
}

$urls = @{
	'git'    = (
		[System.URI]'https://msysgit.googlecode.com/files/Git-1.9.0-preview20140217.exe',
		{ param($f); Start-Process $f -ArgumentList ('/silent') -Wait }
	)
	'perl32' = (
		[System.URI]'http://downloads.activestate.com/ActivePerl/releases/5.20.2.2001/ActivePerl-5.20.2.2001-MSWin32-x86-64int-298913.msi  ',
		{ param($f); Start-Process "msiexec" -ArgumentList ('/i', "$f", '/qb', '/passive', "PERL_PATH=$perlonpath", "PERL_EXT=$perlonpath") -Wait }
	)
	'perl64' = (
		[System.URI]'http://downloads.activestate.com/ActivePerl/releases/5.20.2.2001/ActivePerl-5.20.2.2001-MSWin32-x64-298913.msi',
		{ param($f); Start-Process "msiexec" -ArgumentList ('/i', "$f", '/qb', '/passive', "PERL_PATH=$perlonpath", "PERL_EXT=$perlonpath") -Wait }
	)
	# Argh, the new mingw installer doesn't have a silent mode
	#   https://sourceforge.net/p/mingw/bugs/2176/
	# It's not worth working around this. We'll just let the user click "next" for now.
	'mingw'  = (
		[System.URI]'http://downloads.sourceforge.net/project/mingw/Installer/mingw-get-setup.exe?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fmingw%2Ffiles%2FInstaller%2F&ts=1394502508&use_mirror=heanet',
		{ 
			param($f);
			Start-Process $f -ArgumentList ('/silent') -Wait;
			Start-Process 'c:\MinGW\bin\mingw-get.exe' -ArgumentList ('install', 'msys-flex', 'msys-bison', 'g++', 'gdb', 'mingw32-make', 'msys-base') -Wait;
		}
	)
	'7zip'   = (
		[System.URI]'http://downloads.sourceforge.net/sevenzip/7z920.msi',
		{
			param($f)
			Start-Process "msiexec" -ArgumentList ('/i', $f, '/qb', '/passive') -Wait
		}
	)
	'python27_32' = (
		[System.URI]'http://www.python.org/ftp/python/2.7.6/python-2.7.6.msi',
		{
			param($f)
			Start-Process "msiexec" -ArgumentList ('/i', $f, '/qb', '/passive', "TARGETDIR=${env:SystemDrive}\Python27_x86", 'ALLUSERS=1') -Wait
		}

	)
	'python27_64' = (
		[System.URI]'http://www.python.org/ftp/python/2.7.6/python-2.7.6.amd64.msi',
		{
			param($f)
			Start-Process "msiexec" -ArgumentList ('/i', $f, '/qb', '/passive', "TARGETDIR=${env:SystemDrive}\Python27_x64", 'ALLUSERS=1') -Wait
		}

	)
	'python33_32' = (
		[System.URI]'http://www.python.org/ftp/python/3.3.5/python-3.3.5.msi',
		{
			param($f)
			Start-Process "msiexec" -ArgumentList ('/i', $f, '/qb', '/passive', "TARGETDIR=${env:SystemDrive}\Python33_x86", 'ALLUSERS=1') -Wait
		}

	)
	'python33_64' = (
		[System.URI]'http://www.python.org/ftp/python/3.3.5/python-3.3.5.amd64.msi',
		{
			param($f)
			Start-Process "msiexec" -ArgumentList ('/i', $f, '/qb', '/passive', "TARGETDIR=${env:SystemDrive}\Python33_x64", 'ALLUSERS=1') -Wait
		}

	)
	
	'dotnet4' = (
		[System.URI]'http://download.microsoft.com/download/5/6/2/562A10F9-C9F4-4313-A044-9C94E0A8FAC8/dotNetFx40_Client_x86_x64.exe',
		{
			param($f);
			Start-Process $f -ArgumentList ('/passive', 'norestart') -Wait
		}
	)
	
	'vs2012ex' = (
		[System.URI]'http://download.microsoft.com/download/1/F/5/1F519CC5-0B90-4EA3-8159-33BFB97EF4D9/wdexpress_full.exe',
		{ 
			param($f);
			Start-Process $f -ArgumentList ('/Passive', '/NoRestart') -Wait;
		}
	)
	'vs2010ex'  = (
		[System.URI]'http://download.microsoft.com/download/1/D/9/1D9A6C0E-FC89-43EE-9658-B9F0E3A76983/vc_web.exe',
		{ 
			param($f);
			# Not sure if this works...
			Start-Process $f -ArgumentList ('/q') -Wait;
		}
	)
	'vs2010sp1' = (
		[System.URI]'http://download.microsoft.com/download/2/3/0/230C4F4A-2D3C-4D3B-B991-2A9133904E35/VS10sp1-KB983509.exe',
		{
			param($f);
			Start-Process $f -ArgumentList ('/q', '/norestart') -Wait;
		}
	)
	'vs2010_64bit_compiler_update' = (
		[System.URI]'http://download.microsoft.com/download/7/5/0/75040801-126C-4591-BCE4-4CD1FD1499AA/VC-Compiler-KB2519277.exe',
		{
			param($f);
			Start-Process $f -ArgumentList ('/passive', '/norestart') -Wait;
		}
	)
	
	'winsdk71_x86' = (
		[System.URI]'http://download.microsoft.com/download/F/1/0/F10113F5-B750-4969-A255-274341AC6BCE/GRMSDK_EN_DVD.iso',
		$installsdk
	)
	'winsdk71_x64' = (
		[System.URI]'http://download.microsoft.com/download/F/1/0/F10113F5-B750-4969-A255-274341AC6BCE/GRMSDKX_EN_DVD.iso',
		$installsdk
	)
}

# Store map of download items to filenames
$filenames = @{}

new-item -path $installers -itemtype "directory" -force >NIL

# Fetch installers
$wc = New-Object System.Net.WebClient
$wc.Headers.add("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2;)")
foreach ($u in $urls.GetEnumerator()) {
	$basefn = [System.IO.Path]::GetFileName($u.Value[0].AbsolutePath)
	$fn =  Join-Path $installers $basefn
	if (Test-Path $fn) {
		Write-Host "$fn already exists, skipping"
	} else {
		Write-Host "Downloading $($u.Name) from $($u.Value[0]) to $fn"
		$wc.DownloadFile($u.Value[0], $fn)
	}
	# Add an element to the download info with the filename
	$filenames.($u.Name) = $fn
}

# Decide what to install
$installlist = (
	'git',
	'mingw',
	'7zip',
	'dotnet4',
	'python27_32',
	'python33_32',
	'vs2010ex'
)

# Install Perl. For 64-bit, put the 64-bit version
# on the PATH but still install the 64-bit version.
# For 32-bit, put the 32-bit version on the path.
#
# Also make decisions about 32-bit vs 64-bit tools
# to install.
$arch = (Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture).OSArchitecture
if ( $arch -eq "64-bit" ) 
{
	($url, $b) = $urls.perl64
	$fn = $filenames.perl64
	$perlonpath = "Yes"
	Write-Host "Installing $fn ..."
	&$b($filenames.perl64)
	
	($url, $b) = $urls.perl32
	$fn = $filenames.perl32
	$perlonpath = "No"
	Write-Host "Installing $fn ..."
	&$b($fn)
	
	$installlist += @('python27_64', 'python33_64', 'winsdk71_x64')
}
elseif ( $arch -eq "32-bit" )
{
	($url, $b) = $urls.perl32
	$fn = $filenames.perl32
	$perlonpath = "Yes"
	Write-Host "Installing $fn ..."
	&$b($fn)
	
	$installlist += @('winsdk71_x86')
}
else
{
  Throw "Unknown architecture $arch"
}

# Tools to be installed last:
$installlist += @(
	'vs2012ex',
	'vs2010sp1',
	'vs2010_64bit_compiler_update'
);

# Install the rest of the tools
foreach ($x in $installlist) {
	($url, $installblock) = $urls.$x
	$fn = $filenames.$x
	Write-Host "Installing $x from  $fn ..."
	&$installblock($fn)
}
