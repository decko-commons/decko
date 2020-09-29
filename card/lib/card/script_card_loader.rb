require "pathname"
Card

module Card::ScriptCardLoader
    RUBY = File.join(*RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) +
           RbConfig::CONFIG["EXEEXT"]
    SCRIPT_CARD = File.join("script", "card")

    def self.exec_script_card!
      cwd = Dir.pwd
      return unless in_card_application? || in_card_application_subdirectory?
      exec RUBY, SCRIPT_CARD, *ARGV if in_card_application?
      Dir.chdir("..") do
        # Recurse in a chdir block: if the search fails we want to be sure
        # the application is generated in the original working directory.
        exec_script_card! unless cwd == Dir.pwd
      end
    rescue SystemCallError
      # could not chdir, no problem just return
    end

    def self.in_card_application?
      File.exist?(SCRIPT_CARD)
    end

    def self.in_card_application_subdirectory? path=Pathname.new(Dir.pwd)
      File.exist?(File.join(path, SCRIPT_CARD)) ||
        !path.root? && in_card_application_subdirectory?(path.parent)
    end
end
