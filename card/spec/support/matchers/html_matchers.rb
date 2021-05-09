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
      @document = highlight_syntax @document
      @tag = highlight_syntax @tag, :css
      yield
    ensure
      @document = doc
      @tag = tag
    end

    def highlight_syntax text, syntax=:html
      text = reformat_html text if syntax == :html
      CodeRay.scan(text, syntax).term
    end

    def reformat_html text
      # needs an additional surrounding tag otherwise it returns only the first tag
      Nokogiri::XML("<debug>#{text}</debug>", &:noblanks).root.children.to_s
    end
  end

  class HaveTag
    prepend SyntaxHighlighting
  end
end
