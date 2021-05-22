RSpec.describe Card::Set::Abstract::Media do
  describe "#image_with_text" do
    let(:html_format) do
      Card[:yeti_skin].format_with_set(described_class, :html)
    end

    def text_with_image args={}
      html_format.text_with_image args
    end

    it "uses +image by default" do
      expect(text_with_image)
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='/files/']", with: { alt: "yeti skin+Image" }
        end
    end

    it "takes image card name as image" do
      expect(text_with_image(image: "yeti skin+image"))
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='/files/']", with: { alt: "yeti skin+Image" }
        end
    end

    it "takes image card object as image" do
      expect(text_with_image(image: Card[:yeti_skin_image]))
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='/files/']", with: { alt: "yeti skin+Image" }
        end
    end

    it "handles size argument" do
      expect(text_with_image(size: :small))
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='small']"
        end
    end
  end
end
