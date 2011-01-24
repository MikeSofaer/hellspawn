class Hellspawn
  @@legions = []
  def self.legion(options)
    legion = Legion.new(options)
    @@legions << legion
    legion
  end
  def self.legions; @@legions; end
  def self.legions=(value); @@legions = value; end  #for_test
  def self.summon(*args); @@legions.first.summon(*args); end
  def self.march!; @@legions.first.march!; end
  class Legion < Array
    def initialize(options)
      @options = options
    end
    def log_dir
      @options[:log_dir]
    end
    def march!
      FileUtils.rm_rf(@options[:base])
      FileUtils.mkdir_p(log_dir) if log_dir
      each {|daemon| daemon.march!(@options[:base], log_dir)}
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
      def march!(base, log_dir = nil)
        FileUtils.mkdir_p File.join(base, name)
        File.open(File.join(base, name, "run"), "w+") do |f|
          f.puts run_prep
          f.puts run_script
        end
        if log_dir
          FileUtils.mkdir_p File.join(base, name, 'log')
          File.open(File.join(base, name,'log', "run"), "w+") do |f|
            f.puts log_script(log_dir)
          end
        end
      end
      def run_script
        "exec #{dt_options}#{self[:executable]} " + flag_snippet
      end
      def flag_snippet
        self[:flags].map{|k,v| k + " " + v.to_s}.join(" ")
      end
      def log_script log_dir
        "exec multilog #{log_dir}/#{self[:name]}.log"
      end
      def run_prep
        "exec 2&>1"
      end
      def dt_options
        parts = []
        parts << "softlimit #{self[:memory_limit_mb] * 1024} " if self[:memory_limit_mb]
        parts.join("")
      end
    end
  end

  def self.install_daemontools!
    directory = "/package/admin"
    repo = "git://github.com/MikeSofaer/daemontools.git"
    dir_name = "daemontools-0.76"
    FileUtils.mkdir_p directory
    system("cd #{directory} && git clone #{repo} #{dir_name}")
    system("cd #{File.join(directory, dir_name)} && ./package/install")
  end

end
