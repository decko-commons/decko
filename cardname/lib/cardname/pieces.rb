class Cardname
  module Pieces
    # self and all ancestors (= parts and recursive lefts)
    # @example
    #   "A+B+C+D".to_name.pieces
    #   # => ["A", "B", "C", "D", "A+B", "A+B+C", "A+B+C+D"]
    def pieces
      @pieces ||= simple? ? [self] : (parts + junction_pieces)
    end

    private

    def junction_pieces
      [].tap do |pieces|
        parts[1..-1].inject parts[0] do |left, right|
          piece = [left, right] * self.class.joint
          pieces << piece
          piece
        end
      end
    end
  end
end
