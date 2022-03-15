module CoreExtensions
  module Array
    def to_pointer_content
      map do |item|
        item = item.to_s.strip
        item.gsub!(/^\[\[/, "")
        item.gsub!(/\]\]$/, "")
        item
        # item =~ /^\[\[.+\]\]$/ ? item : "[[#{item}]]"
      end.join "\n"
    end

    def cardname
      Card::Name.compose self
    end
    alias_method :to_name, :cardname
  end
end
