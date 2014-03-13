You might find that bison and flex are very slow when running under a service
account (say, Jenkins build service) though they perform normally from the
command prompt. Getting a backtrace from Process Explorer may reveal output
like:

	ntoskrnl.exe!KiSwapContext+0x76
	ntoskrnl.exe!KiSwapThread+0x14e
	ntoskrnl.exe!KiCommitThreadWait+0x127
	ntoskrnl.exe!KeWaitForSingleObject+0x248
	ntoskrnl.exe!FsRtlCancellableWaitForMultipleObjects+0xcb
	ntoskrnl.exe!FsRtlCancellableWaitForSingleObject+0x27
	bowser.sys!BowserSendDatagram+0x337
	bowser.sys!BowserSendSecondClassMailslot+0x147
	bowser.sys!BowserSendElection+0xd9
	bowser.sys!BowserGetBrowserServerList+0x208
	bowser.sys!GetBrowserServerList+0x2b7
	bowser.sys!BowserCommonDeviceIoControlFile+0x936
	bowser.sys!BowserFsdDeviceIoControlFile+0x46
	ntoskrnl.exe!IopXxxControlFile+0x845
	ntoskrnl.exe!NtDeviceIoControlFile+0x56
	ntoskrnl.exe!KiSystemServiceCopyEnd+0x13
	wow64cpu.dll!CpupSyscallStub+0x2
	wow64cpu.dll!DeviceIoctlFileFault+0x31
	wow64.dll!RunCpuSimulation+0xa
	wow64.dll!Wow64LdrpInitialize+0x172
	ntdll.dll!LdrpInitializeProcess+0x157b
	ntdll.dll!_LdrpInitialize+0x851b8
	ntdll.dll!LdrInitializeThunk+0xe
	ntdll.dll!_NtDeviceIoControlFile@40+0xc
	BROWCLI.DLL!_DeviceControlGetInfo@32+0xb0
	BROWCLI.DLL!_GetBrowserServerList@20+0xd6
	BROWCLI.DLL!_EnumServersForTransport@48+0x44
	BROWCLI.DLL!_NetServerEnumEx@36+0x224
	BROWCLI.DLL!_NetServerEnum@36+0x24
	msys-1.0.dll!cygwin_logon_user+0x42b
	msys-1.0.dll!cygwin_logon_user+0x58c
	msys-1.0.dll!ttyslot+0x182a
	msys-1.0.dll!ttyslot+0x1eba
	msys-1.0.dll!__assert+0x36ef
	msys-1.0.dll!_dll_crt0@0+0x133
	msys-1.0.dll!dll_crt0__FP11per_process+0x34
	bison.exe+0x13ccb4
	bison.exe+0x103d
	ntdll.dll!__RtlUserThreadStart+0x20
	ntdll.dll!__RtlUserThreadStart@8+0x1b

Slow regression tests are also a symptom, with Process Explorer showing
diff.exe sitting there for ages.

If so, you will need to reconfigure the Jenkins service so it runs under a user
account other than the default NT service account. Simply setting "Allow this
service to interact with the desktop" is not enough.
