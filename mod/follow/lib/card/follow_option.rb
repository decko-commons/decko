# -*- encoding : utf-8 -*-

class Card
  # module to be included in cards used as options for follow rules
  module FollowOption
    # Hash containing an applicability test for each option (block)
    @test = {}
    # Hash containing an id-list-generating block for each option
    @follower_candidate_ids = {}
    # Hash that registers / groups options
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
