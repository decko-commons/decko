# -*- encoding : utf-8 -*-

class Card
  module Version
    class << self
      def release
        @@version ||= File.read(File.expand_path("../../VERSION", __dir__)).strip
      end
    end
  end
end
