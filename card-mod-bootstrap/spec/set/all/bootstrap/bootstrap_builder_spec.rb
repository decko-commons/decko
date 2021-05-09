# -*- encoding : utf-8 -*-

RSpec.describe Bootstrap, "bootstrap builder" do
  class BuilderTest < ::Bootstrap::Component
    def_tag_method :test_tag, "test-class" do |_html, opts, _extra_args|
      before { tag :before, "prepend-class" }

      after { tag :after, "after-class" }

      prepend { tag :prepend, "prepend-class" }
      append { tag :append, "append-class" }
      wrap_inner :wrap, "wrap-class"
      wrap :container
      opts
    end

    def_div_method :container, "container-class"
  end

  describe "tag create helper methods" do
    subject do
      fo = Card["A"].format(:html)
      BuilderTest.render(fo) do
        test_tag do
          "content"
        end
      end
    end

    it "appends work" do
      skip "test_tag method needs to be repaired"
      expect(subject).to have_tag "container" do
        with_tag "prepend.prepend-class"
        with_tag "test_tag.test-class" do
          with_tag "insert.insert-class"
          with_tag
          with_tag "wrap.wrap-class", text: "\ncontent"
        end
        with_tag "append.append-class"
      end
    end
  end
end
