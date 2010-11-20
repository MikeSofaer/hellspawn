require 'test/test_helper'
require 'lib/hellspawn'

class BasicTest < Test::Unit::TestCase
    def setup
      @thin  = {:name => "thin",
              :executable => "/usr/local/bin/thin",
              :flags => {"-e" => "production",
                         "-c" => "/usr/local/app/my_app",
                        },
      }
      @base = "/tmp/test_services"
      @legion = Hellspawn.legion(:base => @base,
                                 :log_dir => "/tmp/test_services_log")
    end
    def teardown
      FileUtils.rm_rf @base
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
    assert { run_script.split("\n").first == "exec multilog #{@legion.log_dir}/thin.log" }
  end
  def test_flags
    @legion.summon @thin
    @legion.march!
    run_script_lines = File.read("#{@base}/thin/run").split("\n")
    assert { run_script_lines.include?("exec /usr/local/bin/thin -c /usr/local/app/my_app -e production") }
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
end
