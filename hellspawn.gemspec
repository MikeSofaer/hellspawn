Gem::Specification.new do |s|
  s.name      = "hellspawn"
  s.version   = "0.1.0"
  s.authors   = ["Michael Sofaer"]
  s.email     = "msofaer@pivotallabs.com"
  s.homepage  = "http://github.com/MikeSofaer/hellspawn"
  s.summary   = "Hellspawn runs daemons."
  s.description  = <<-EOS.strip
Since daemontools is the best way to run daemons, we need a gem for it.  This is that gem.
  EOS

  s.files      = Dir['lib/*']
  s.test_files = Dir['test/**/*.rb']

  s.has_rdoc = false

  s.add_development_dependency 'vagrant'
  s.add_development_dependency 'wrong'

end

