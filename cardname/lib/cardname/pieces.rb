class Cardname
  # Cards never have more than two "parts" (left and right), but they can have many
  # "pieces".  A card's pieces are all the other cards whose existence its existence
  # implies. For example if A+B+C exists, that implies that A, B, C, and A+B do too.
  module Pieces
    # self and all ancestors (= parts and recursive lefts)
    # @example
    #   "A+B+C+D".to_name.pieces
    #   # => ["A", "B", "C", "D", "A+B", "A+B+C", "A+B+C+D"]
    def pieces
      simple? ? [self] : (parts + junction_pieces)
    end

    def piece_names
      pieces.map(&:to_name)
    end

    def ancestors
      pieces.reject { |p| p == self }
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
