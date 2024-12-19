class Cardname
  # Cards never have more than two "parts" (left and right), but they can have many
  # "pieces".  A card's pieces are all the other cards whose existence its existence
  # implies. For example if A+B+C exists, that implies that A, B, C, and A+B do too.
  module Pieces
    # self and all ancestors (= parts and recursive lefts)
    # @example
    #   "A+B+C+D".to_name.pieces => ["A", "B", "C", "D", "A+B", "A+B+C", "A+B+C+D"]
    # @return [Array <String>]
    def pieces
      simple? ? [self] : (parts + compound_pieces)
    end

    # @see #pieces
    # @return [Array <Cardname>]
    def piece_names
      pieces.map(&:to_name)
    end

    # parents, parents' parents, etc
    # @example
    #   "A+B+C+D".to_name.ancestors => ["A", "B", "C", "D", "A+B", "A+B+C"]
    # @return [Array <String>]
    def ancestors
      pieces.reject { |p| p == self }
    end

    # @see #ancestors
    # @return [Array <Cardname>]
    def ancestor_pieces
      ancestors.map(&:to_name)
    end

    private

    def compound_pieces
      [].tap do |pieces|
        parts[1..].inject parts[0] do |left, right|
          piece = [left, right] * self.class.joint
          pieces << piece
          piece
        end
      end
    end
  end
end
