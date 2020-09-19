module Versioning
  BASE = File.open(File.expand_path("../card/VERSION", __FILE__)).read.chomp
  CARD_MINOR = { 0 => 90, 1 => 1000 } # can remove and hardcode after 1.0

  class << self
    def simple
      BASE
    end

    def card
      [1, minor, point].compact.map(&:to_s).join "."
    end

    private

    def bits
      @bits ||= simple.split('.').map &:to_i
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
