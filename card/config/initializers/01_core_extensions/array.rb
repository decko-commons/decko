module CoreExtensions
  module Array
    def to_pointer_content
      map do |item|
        item = item.to_s.strip
        item =~ /^\[\[.+\]\]$/ ? item : "[[#{item}]]"
      end.join "\n"
    end

    def to_name
      Card::Name.compose self
    end
  end
end
