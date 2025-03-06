# extend core module from carrierwave gem
module CarrierWave
  def self.tmp_path
    @tmp_path ||= Card.paths["tmp"].existent.first
  end

  # custom uploader class for cards
  class FileCardUploader
    # path-related methods for uploader
    module Path
      def local_url opts={}
        "%s/%s/%s" % [local_url_base(opts), file_dir, full_filename(url_filename)]
      end

      def local_url_base opts={}
        web_path = Card.config.files_web_path
        opts.delete(:absolute) ? card_url(web_path) : card_path(web_path)
      end

      def public_path
        File.join Cardio.paths["public"].existent.first, url
      end

      def cache_dir
        "#{@model.files_base_dir 'tmp'}/cache"
      end

      # Carrierwave calls store_path without argument when it stores the file
      # and with the identifier from the db when it retrieves the file.
      # In our case the first part of our identifier is not part of the path
      # but we can construct the filename from db data. So we don't need the
      # identifier.
      def store_path for_file=nil
        if for_file
          retrieve_path
        else
          File.join([store_dir, full_filename(filename)].compact)
        end
      end

      def retrieve_path
        File.join([retrieve_dir, full_filename(filename)].compact)
      end

      def tmp_path
        Dir.mkdir_p model.tmp_upload_dir
        File.join model.tmp_upload_dir, filename
      end

      # paperclip compatibility used in type/file.rb#core (base format)
      def path version=nil
        version ? versions[version].path : super()
      end
    end
  end
end
