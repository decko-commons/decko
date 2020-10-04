require "pathname"

module Cardio
  module ScriptLoader
    RUBY = File.join(*RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) +
           RbConfig::CONFIG["EXEEXT"]

    class <<self
      def script_file name
        File.join("script", name.to_s)
      end

      def exec_script! name
        cwd = Dir.pwd
        return unless in_application?(name) || in_application_subdirectory?(name)
        exec RUBY, script_file(name), *ARGV if in_application?(name)
        Dir.chdir("..") do
          # Recurse in a chdir block: if the search fails we want to be sure
          # the application is generated in the original working directory.
          exec_script!(name) unless cwd == Dir.pwd
        end
      rescue SystemCallError
        # could not chdir, no problem just return
      end

      def in_application? name
        File.exist?(script_file name)
      end

      def in_application_subdirectory? name, path=Pathname.new(Dir.pwd)
        File.exist?(File.join(path, script_file(name))) ||
          !path.root? && in_application_subdirectory?(name, path.parent)
      end
    end
  end
end
