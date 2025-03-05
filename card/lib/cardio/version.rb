# -*- encoding : utf-8 -*-

module Cardio
  # handle version numbers for releases
  module Version
    class << self
      CARD_MINOR = { 0 => 90, 1 => 1000 }.freeze # can remove and hardcode after 1.0

      def release
        @release ||= File.read(File.expand_path("../../VERSION", __dir__)).strip
      end

      def card_release
        @card_release ||= [1, minor, point, pre].compact.map(&:to_s).join "."
      end

      private

      def bits
        release.split(".").map do |bit|
          bit.match?(/^\d/) ? bit.to_i : bit
        end
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

      def pre
        bits[3]
      end
    end
  end
end
