module Decko
  # hacky first go at swagger generation.
  #
  # In decko, it really just converts yaml to ruby and back again.
  #
  # But it's useful for generating decko swagger docs.
  class Swagger
    attr_accessor :yaml_dir

    def initialize yaml_dir=nil
      @yaml_dir = yaml_dir
    end

    def read_yml filename, dir=nil
      dir ||= yaml_dir || gem_input_dir
      YAML.load_file File.join(dir, "#{filename}.yml")
    end

    def gem_swagger_dir
      File.join Decko.gem_root, "lib/decko/swagger"
    end

    def gem_input_dir
      File.join gem_swagger_dir, "input_yml"
    end

    def gem_swag
      read_yml :layout, gem_input_dir
    end

    def merge_swag filename, dir=nil
      yaml = read_yml filename, dir
      gem_swag.deep_merge yaml
    end

    def output_file filename=nil, dir=nil
      filename ||= "output.yml"
      dir ||= yaml_dir || gem_input_dir
      File.join dir, filename
    end

    def output_to_file hash, filename=nil, dir=nil
      File.write output_file(filename, dir), hash.to_yaml
    end
  end
end
