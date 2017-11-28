module RSpecHtmlMatchers
  module SyntaxHighlighting
    %i[tag_presents? text_right? count_right?].each do |method_name|
      define_method method_name do
        with_sytnax_highlighting { super() }
      end
    end

    def with_sytnax_highlighting
      doc = @document
      tag = @tag
      @document = hightlight_syntax @document
      @tag = hightlight_syntax @tag, :css
      yield
    ensure
      @document = doc
      @tag = tag
    end

    def hightlight_syntax text, syntax = :html
      text = Nokogiri::XML("<debug>#{text}</debug>", &:noblanks)
               .root.children.to_s if syntax == :html
      CodeRay.scan(text, syntax).term
    end
  end

  class HaveTag
    prepend SyntaxHighlighting
  end
end
