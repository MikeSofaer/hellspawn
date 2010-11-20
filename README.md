*Hellspawn* is for spawning.  It spawns processes using daemontools.
It makes sure that you are running the processes you claim you want to be running.

    legion = Hellspawn.legion :base => "/directory/for/services"
    legion.summon :name => "daemon_name", :executable => "daemon executable path"
    legion.march!

Now you have daemons.

Some other options:
    legion.summon :name => "thin", :by_flag => ["-p", [3000, 3001, 3002]], :executable => "/usr/local/bin/thin"
    legion.summon :name => "thin", :memory_limit_mb => 500, :executable => "/usr/local/bin/thin"

To log:
    legion = Hellspawn.legion :base => "/directory/for/services", :log_dir => "/directory_for_logs"

If you march a legion to a directory that already exists, it deletes everything from it first
but it doesn't yet know how to stop currently running services in those directories

You can also use Hellspawn.summon and Hellspawn.march! to access your first legion.
This is useful when writing chef scripts, so you can summon from anywhere without passing the legion around
