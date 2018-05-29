
def self.included host_class
  host_class.include_set Abstract::CodeFile
  host_class.include OverrideCodeFile
  host_class.mattr_accessor :stylesheets_dir, :bootstrap_path, :mod_path
  host_class.mod_path = File.join Cardio.gem_root, "mod", host_class.file_content_mod_name
  host_class.stylesheets_dir = File.join host_class.mod_path, "lib", "stylesheets"
  host_class.bootstrap_path = File.join host_class.mod_path, "vendor", "bootstrap", "scss"
end

module OverrideCodeFile
  def content
    stylesheets.join "\n"
  end

  def stylesheets
    load_stylesheets unless @stylesheets
    @stylesheets
  end

  def add_bs_subdir sub_dir
    Dir.glob("#{bootstrap_path}/#{sub_dir}/*.scss").each do |path|
      load_from_path path
    end
  end

  def add_stylesheet filename, type: :scss
    load_from_path File.join(stylesheets_dir, "#{filename}.#{type}")
  end

  def add_stylesheet_file path
    load_from_path File.join(mod_path, path)
  end

  def add_bs_stylesheet filename, type: :scss, subdir: nil
    path = File.join(*[bootstrap_path, subdir, "_#{filename}.#{type}"].compact)
    load_from_path path
  end

  def load_from_path path
    @stylesheets ||= []
    Rails.logger.info "reading file: #{path}"
    @stylesheets << File.read(path)
  end

  def source_changed _since:
    false
  end

  def existing_source_paths
    []
  end
end
