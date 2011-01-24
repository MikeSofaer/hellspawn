require '/vagrant/lib/hellspawn'


package "git-core" do
  action :install
end

ruby_block "install daemontools" do
  block { Hellspawn.install_daemontools! }
end

execute "make sure daemontools is installed" do
  command "ls /command/svscanboot"
end
