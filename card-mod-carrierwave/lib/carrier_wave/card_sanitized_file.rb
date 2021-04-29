module CarrierWave
  module CardSanitizedFile
    def content_type
      # the original content_type method doesn't seem to be very reliable
      # It uses mime_magic_content_type  - which returns invalid/invalid for css files
      # that start with a comment - as the second option.  (we switch the order and
      # use it as the third option)
      @content_type ||=
        existing_content_type ||
        mini_mime_content_type ||
        mime_magic_content_type
    end
  end
end