*Hellspawn* is for spawning.  It spawns processes using daemontools.
It makes sure that you are running the processes you claim you want to be running.

    legion = Hellspawn.legion :base => "/directory/for/services"
    legion.summon :name => "daemon_name", :executable => "daemon executable path"
    legion.march!

Now you have daemons.
