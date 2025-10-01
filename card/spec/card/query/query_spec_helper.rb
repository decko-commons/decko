# helper methods for specs testing CQL queries
module QuerySpecHelper
  # CARDS_MATCHING_TWO = ["42", "Joe User", "One+Two", "One+Two+Three", "Two"].freeze
  CARDS_MATCHING_TWO = ["42", "Joe User", "Two"].freeze

  # extra helper for specs testing CQL fasteners
  module Fasten
    def each_fasten(&)
      %i[join exist in].each(&)
    end
  end

  def self.included base
    base.extend Fasten
  end

  def run_query statement={}
    statement.reverse_merge! return: :name, sort_by: :name
    statement[:fasten] = fasten if try(:fasten)
    Card::Query.run statement
  end

  def cards_matching_two
    CARDS_MATCHING_TWO
  end
end
