require "pathname"


module Cardio
  # help card executable find ./script/card when called from anywhere within deck
  module ScriptLoader
    # modularize for reusing in decko
    module ClassMethods
      RUBY = File.join(*RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) +
             RbConfig::CONFIG["EXEEXT"]

      attr_accessor :script_name

      def script
        File.join "script", script_name
      end

      def exec!
        cwd = Dir.pwd
        return unless continue?

        exec_script
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

      def exec_script
        exec RUBY, script, *ARGV if in_application?
      end

      def continue?
        in_application? || in_application_subdirectory?
      end

      def in_application?
        File.exist?(script)
      end

      def in_application_subdirectory? path=Pathname.new(Dir.pwd)
        File.exist?(File.join(path, script)) ||
          !path.root? && in_application_subdirectory?(path.parent)
      end
    end

    extend ClassMethods
  end
end
