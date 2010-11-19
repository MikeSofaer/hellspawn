class Hellspawn
  def self.legion(options)
    Legion.new(options)
  end
  class Legion < Array
    def initialize(options)
      @options = options
    end
    def march!
      FileUtils.rm_rf(@options[:base])
      each {|daemon| daemon.march!(@options[:base])}
    end

    def summon(options)
      by_flag = options.delete :by_flag
      if by_flag
        by_flag[1].each do |value|
          new_options = options.dup
          new_options[:flags] = options[:flags].dup || {}
          new_options[:flags][by_flag[0]] = value
          new_options[:name] = options[:name] +  "_" + value.to_s
          self << Daemon.new(new_options)
        end
      else
        self << Daemon.new(options)
      end
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
        "exec #{self[:executable]} " + flag_snippet
      end
      def flag_snippet
        self[:flags].map{|k,v| k + " " + v.to_s}.join(" ")
      end
      def run_prep
        "exec 2&>1"
      end
    end
  end
end
