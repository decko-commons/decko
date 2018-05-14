# -*- encoding : utf-8 -*-

class Card
  # module to be included in cards used as options for follow rules
  module FollowOption
    @test = {}
    @follower_candidate_ids = {}
    @options = { all: [], main: [], restrictive: [] }

    class << self
      attr_reader :test, :follower_candidate_ids, :options

      def codenames type=:all
        options[type]
      end

      def cards
        codenames.map { |codename| Card[codename] }
      end

      def restrictive_options
        codenames :restrictive
      end

      def main_options
        codenames :main
      end
    end
  end
end
