To set up a Jenkins instance to build PostgreSQL, you should:

Run the agent as an unprivileged user other than "local system":
--------

* Create C:\jenkins
* Add a Windows jenkins node by launching the slave agent over JNLP, using C:\jenkins as the workspace
* Use the slave agent GUI to install Jenkins as a service
* Create a "jenkins" user account using Computer Management. This user should NOT be an administrator. Its password should never expire.
* Stop the service
* Open `services.msc` and edit the Jenkins service
* Change the user account to ".\jenkins" and enter the jenkins user password.
* Change the ownership on C:\jenkins recursively to the "jenkins" user
* Start the Jenkins service

(see `slow_bison_flex.md` for why we jump through these hoops)

Give the node the labels:

  x86 x64 windows

Create the project
==================

Create a new matrix project.

Restrict build
-------

Check "Restrict where this project can run", setting it to run only on nodes labeled "windows".

Setup SCM
-------

Configure it to get changes from git, either github triggers, or using polling.
Specify branch(es) that should be built when they change.

Check the "clean after checkout" option in the Advanced section of the git configuration.

Setup Axes
-------

Create a Slaves axis "SL_OS". In this axis, check only the "windows" slave.
That restricts the build jobs to running only on nodes running Windows.

Create a User-defined axis "BT" with options "debug release".

Create a User-defined axis "SDK" with options "winsdk71 vs2010ex vs2012ex
vs2013ex" (or whatever subset of SDKs you have installed). These are the labels
recognised by `setupsdk.cmd`.

To limit the number of builds, set a combination filter, something like:

    (BT=="release") && (TA=="x86").implies(SDK=="winsdk71") && (TA=="x64").implies(SDK=="vs2012ex")

which will produce an x86 build with winsdk 7.1 suitable for XP and above, and
an x64 build with VS 2012 Express suitable for Vista and above.

Build name
-------

Set the build name to something like:

    #${BUILD_NUMBER}-#${ENV,var="NODE_LABELS"}#${GIT_BRANCH}

if you have the build name plugin installed.

Build command
--------

In the Build section, add "Execute a Windows batch command", and enter:

    @echo off
    SET PGBW=C:\pg\pg_build_win
    call %PGBW%\jenkins.cmd

(adjusting the path to reflect where your Windows host has `pg_build_win` checked out)

I also recommend adding a post-build action to archive the artifacts:

    **/src/test/regress/regression.diffs

so you capture regression test failures. Under advanced, check "Do not fail build if archiving returns nothing".

Email notification
--------

I recommend a post-build action to send email notifications of build status.
