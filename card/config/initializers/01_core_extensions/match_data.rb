module CoreExtensions
  module MatchData
    # named_captures was introduced in Ruby 2.4.0
    if RUBY_VERSION =~ /^2.3/
      def named_captures
        names.zip(captures).to_h
      end
    end

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
