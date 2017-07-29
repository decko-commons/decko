require "pathname"

module Decko
  module ScriptDeckoLoader
    RUBY = File.join(*RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) +
           RbConfig::CONFIG["EXEEXT"]
    SCRIPT_DECKO = File.join("script", "decko")

    def self.exec_script_decko!
      cwd = Dir.pwd
      return unless in_decko_application? || in_decko_application_subdirectory?
      exec RUBY, SCRIPT_DECKO, *ARGV if in_decko_application?
      Dir.chdir("..") do
        # Recurse in a chdir block: if the search fails we want to be sure
        # the application is generated in the original working directory.
        exec_script_decko! unless cwd == Dir.pwd
      end
    rescue SystemCallError
      # could not chdir, no problem just return
    end

    def self.in_decko_application?
      File.exist?(SCRIPT_DECKO)
    end

    def self.in_decko_application_subdirectory? path=Pathname.new(Dir.pwd)
      File.exist?(File.join(path, SCRIPT_DECKO)) ||
        !path.root? && in_decko_application_subdirectory?(path.parent)
    end
  end
end
