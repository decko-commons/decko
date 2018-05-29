module QuerySpecHelper
  CARDS_MATCHING_TWO = ["Joe User", "One+Two", "One+Two+Three", "Two"].freeze

  module Fasten
    def each_fasten
      %i[join exist in].each do |fastn|
        yield fastn
      end
    end
  end

  def self.included base
    base.extend Fasten
  end

  def run_query statement={}
    statement.reverse_merge! return: :name, sort: :name
    statement[:fasten] = fasten if try(:fasten)
    Card::Query.run statement
  end

  def cards_matching_two
    CARDS_MATCHING_TWO
  end
end
