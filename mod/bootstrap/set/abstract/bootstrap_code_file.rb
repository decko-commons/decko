include_set Abstract::Scss

def self.included host_class
  host_class.include_set Abstract::CodeFile
  host_class.include OverrideCodeFile
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

  def mod_root
    mod_path :bootstrap
  end

  def bootstrap_path
    "#{mod_root}/vendor/bootstrap/scss"
  end

  def add_stylesheet filename, type: :scss
    load_from_path "#{mod_root}/lib/stylesheets/#{filename}.#{type}"
  end

  def add_stylesheet_file path
    load_from_path File.join(mod_root, path)
  end

  def add_bs_stylesheet filename, type: :scss, subdir: nil
    path = File.join(*[bootstrap_path, subdir, "_#{filename}.#{type}"].compact)
    load_from_path path
  end

  def load_from_path path
    @stylesheets ||= []
    Rails.logger.debug "reading file: #{path}"
    @stylesheets << File.read(path)
  end

  def source_changed _since:
    false
  end

  def existing_source_paths
    []
  end
end
