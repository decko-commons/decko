# -*- encoding : utf-8 -*-

RSpec.describe Bootstrap, "bootstrap builder" do
  class BuilderTest < Card::Format::HtmlFormat::Bootstrap::Component
    add_tag_method :test_tag, "test-class" do |opts, _extra_args|
      prepend { tag :prepend, "prepend-class" }
      append { tag :append, "append-class" }
      insert { tag :insert, "insert-class" }
      wrap do |content|
        tag(:wrap, "wrap-class") { content }
      end
      opts
    end
  end

  describe "tag create helper methods" do
    subject do
      fo = Card["A"].format(:html)
      tag = BuilderTest.render(fo) do
        test_tag do
          "content"
        end
      end
      "<buildertest>#{tag}<buildertest/>"
    end

    it "appends work" do
      skip "test_tag method needs to be repaired"
      is_expected.to have_tag "buildertest" do
        with_tag 'prepend.prepend-class'
        with_tag 'test_tag.test-class' do
          with_tag 'insert.insert-class'
          with_tag 'wrap.wrap-class', text: "\ncontent"
        end
        with_tag 'append.append-class'
      end
    end
  end
end
