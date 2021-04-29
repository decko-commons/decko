module CarrierWave
  module Uploader
    # Implements a different name pattern for versions than CarrierWave's
    # default: we expect the version name at the end of the filename separated
    # by a dash
    module CardVersions
      private

      # put version at the end of the filename
      def full_filename for_file
        name = super(for_file)
        parts = name.split "."
        basename = [parts.shift, version_name].compact.join("-")
        "#{basename}.#{parts.join('.')}"
      end
    end
  end
end