require "pathname"

module Decko
  module ScriptDeckoLoader
    RUBY = File.join(*RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) +
           RbConfig::CONFIG["EXEEXT"]
    SCRIPT_DECKO = File.join("script", "decko")

    class << self
      def exec!
        cwd = Dir.pwd
        return unless continue?
        exec_decko_script
        recurse cwd
      rescue SystemCallError
        # could not chdir, no problem just return
      end

      def recurse cwd
        Dir.chdir("..") do
          # Recurse in a chdir block: if the search fails we want to be sure
          # the application is generated in the original working directory.
          exec! unless cwd == Dir.pwd
        end
      end

      def exec_decko_script
        exec RUBY, SCRIPT_DECKO, *ARGV if in_application?
      end

      def continue?
        in_application? || in_application_subdirectory?
      end

      def in_application?
        File.exist?(SCRIPT_DECKO)
      end

      def in_application_subdirectory? path=Pathname.new(Dir.pwd)
        File.exist?(File.join(path, SCRIPT_DECKO)) ||
          !path.root? && in_decko_application_subdirectory?(path.parent)
      end
    end
  end
end
