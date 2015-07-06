
SET PGBW=%~sdp0
SET PGBW=%PGBW:~0,-1%
SET TA=x64
SET BT=release
SET SDK=vs2013ex
cd "%PGBW%"
call "%PGBW%\jenkins.cmd"
