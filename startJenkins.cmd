
SET PGBW=%~sdp0
SET PGBW=%PGBW:~0,-1%
SET TA=x64
SET BT=release
SET SDK=vs2013ex
call "%PGBW%\jenkins.cmd"
::cmd  /c start "" /d"%PGBW%\" "jenkins.cmd" 