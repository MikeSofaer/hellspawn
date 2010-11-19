class Hellspawn
  def self.legion(options)
    Legion.new(options)
  end
  class Legion < Array
    def initialize(options)
      @options = options
    end
    def march!
      #slaughter_stragglers!
      each {|daemon| daemon.march!(@options[:base])}
    end

    def summon(options)
      self << Daemon.new(options)
    end
    class Daemon < Hash
      def initialize(options)
        replace options
      end
      def name
        self[:name]
      end
      def march!(base)
        FileUtils.mkdir_p File.join(base, name)
        run_file = File.open(File.join(base, name, "run"), "w+")
        run_file.puts run_prep
        run_file.puts run_script
        run_file.close
      end
      def run_script
        "exec #{self[:executable]}"
      end
      def run_prep
        "exec 2&>1"
      end
    end
  end
end
