require 'test/test_helper'
require 'lib/hellspawn'

class BasicTest < Test::Unit::TestCase
  def setup
    @thin  = {:name => "thin",
      :executable => "/usr/local/bin/thin",
      :flags => {"-e" => "production",
                 "-c" => "/usr/local/app/my_app",
    },
      :directory => "/usr/local/app/my_app",
    }
    @base = "/tmp/test_services"
    @log_dir = "/tmp/test_services_log"
    @legion = Hellspawn.legion(:base => @base, :log_dir => @log_dir)
  end
  def teardown
    FileUtils.rm_rf @base
    Hellspawn.legions = []
  end
  def test_legion
    assert {@legion.size == 0}
  end
  def test_summon
    @legion.summon @thin
    assert {@legion.first.name == "thin"}
  end
  def test_march
    @legion.summon @thin
    @legion.march!
    run_script = File.read("#{@base}/thin/run")
    assert { run_script.match /exec \/usr\/local\/bin\/thin/ }
  end
  def test_legion_dir
    @legion.summon @thin
    @legion.march!
    run_script = File.read("#{@base}/thin/run")
    assert { run_script.match /^cd #{@thin[:directory]}$/ }
  end
  def test_executable
    @legion.summon @thin
    @legion.march!
    assert { `ls -l #{@base}/thin/run | awk '{print $1}'`.match /x/ }
    assert { `ls -l #{@base}/thin/log/run | awk '{print $1}'`.match /x/ }
  end
  def test_legion_log_dir
    @legion.summon @thin
    @legion.march!
    assert { Dir.glob(@legion.log_dir) == [ @legion.log_dir]}
  end
  def test_daemon_log_dir
    @legion.summon @thin
    @legion.march!
    assert { Dir.glob("#{@base}/thin/log/run") == ["#{@base}/thin/log/run"]}
  end
  def test_daemon_log_script
    @legion.summon @thin
    @legion.march!
    run_script = File.read("#{@base}/thin/log/run")
    assert { run_script.split("\n").first == "exec multilog #{@log_dir}/thin.log" }
  end
  def test_flags
    @legion.summon @thin
    @legion.march!
    run_script_lines = File.read("#{@base}/thin/run").split("\n")
    assert { run_script_lines.include?("exec /usr/local/bin/thin -c /usr/local/app/my_app -e production") }
  end
  def test_memory_limit
    @legion.summon @thin.merge(:memory_limit_mb => 500)
    @legion.march!
    assert {File.read("#{@base}/thin/run").match /softlimit -m 512000/ }
  end
  def test_stderr
    @legion.summon @thin
    @legion.march!
    run_script = File.read("#{@base}/thin/run")
    assert { run_script.split("\n").first == "exec 2&>1" }
  end
  def test_removal
    @legion.summon @thin
    @legion.march!
    Hellspawn.legion(:base => @base).march!
    assert {Dir.glob("#{@base}/*") == [] }
  end
  def test_squad_by_flag
    @legion.summon @thin.merge(:by_flag => ["-p", [8004, 8005, 8006, 8007]])
    @legion.march!
    assert {File.read("#{@base}/thin_8004/run").match /thin .* -p 8004/ }
    assert {File.read("#{@base}/thin_8005/run").match /thin .* -p 8005/ }
    assert {File.read("#{@base}/thin_8006/run").match /thin .* -p 8006/ }
    assert {File.read("#{@base}/thin_8007/run").match /thin .* -p 8007/ }
  end
  def test_get_legion
    assert { Hellspawn.legions == [@legion] }
  end
  def test_shorctuts
    Hellspawn.summon @thin
    Hellspawn.march!
    assert {Dir.glob(File.join(@base, "thin", "run")).size == 1}
  end
end
