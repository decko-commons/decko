module CoreExtensions
  module MatchData
    def capture index
      case index
      when Symbol, String
        named_captures[index.to_s]
      else
        captures[index]
      end
    end
  end
end
