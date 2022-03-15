# -*- encoding : utf-8 -*-

module Cardio
  module Version
    class << self
      CARD_MINOR = { 0 => 90, 1 => 1000 }.freeze # can remove and hardcode after 1.0

      def release
        @version ||= File.read(File.expand_path("../../VERSION", __dir__)).strip
      end

      def card_release
        @card_release ||= [1, minor, point].compact.map(&:to_s).join "."
      end

      private

      def bits
        release.split(".").map(&:to_i)
      end

      def major
        bits[0]
      end

      def minor
        CARD_MINOR[major] + bits[1]
      end

      def point
        bits[2]
      end
    end
  end
end
