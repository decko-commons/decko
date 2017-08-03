describe "bootstrap builder" do
  class BuilderTest < Card::Format::HtmlFormat::Bootstrap::Component
    add_tag_method :test_tag, "test-class" do |opts, _extra_args|
      prepend { tag :prepend, "prepend-class" }
      append { tag :append, "append-class" }
      insert { tag :insert, "insert-class" }
      # wrap { |content| tag :wrap, "wrap-class" { content } }
      opts
    end
  end

  describe "tag create helper methods" do
    subject do
      fo = Card["A"].format(:html)
      tag = BuilderTest.render(fo) { test_tag }
      "<buildertest>#{tag}<buildertest/>"
    end

    it "appends work" do
      is_expected.to have_tag "buildertest" do
        with_tag 'prepend.prepend-class'
        with_tag 'test_tag.test-class' do
          with_tag 'insert.insert-class'
        end
        with_tag 'append.append-class'
      end
    end
  end
end
