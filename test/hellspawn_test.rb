require 'test/test_helper'
require 'lib/hellspawn'

class BasicTest < Test::Unit::TestCase
    def setup
      @thin  = {:name => "thin",
              :executable => "/usr/local/bin/thin",
      }
      @legion = Hellspawn.legion(:base => "/tmp/test_services", :name => "test_legion")
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
    run_script = File.read("/tmp/test_services/thin/run")
    assert { run_script.match /exec \/usr\/local\/bin\/thin/ }
  end
  def test_stderr
    @legion.summon @thin
    @legion.march!
    run_script = File.read("/tmp/test_services/thin/run")
    assert { run_script.split("\n").first == "exec 2&>1" }
  end
end
