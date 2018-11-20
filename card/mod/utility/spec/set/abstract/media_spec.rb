describe Card::Set::Abstract::Media do
  describe "#image_with_text" do
    let(:html_format) do
      Card["Samsung"].format_with_set(described_class, :html)
    end

    def text_with_image args={}
      html_format.text_with_image args
    end

    it "uses +image by default" do
      expect(text_with_image)
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='/files/']", with: { alt: "Samsung+image" }
        end
    end

    it "takes image card name as image" do
      expect(text_with_image(image: "*logo"))
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='/files/']", with: { alt: "*logo" }
        end
    end

    it "takes image card object as image" do
      expect(text_with_image(image: Card["*logo"]))
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='/files/']", with: { alt: "*logo" }
        end
    end

    it "handles size argument" do
      expect(text_with_image(size: :small))
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='small']"
        end
    end

    it "doesn't escape a stubbed src argument" do
      stub = "(stub)#{Card::View::Stub.escape '{"mode":"normal"}'}(/stub)"
      allow(html_format).to receive(:nest).and_return stub
      expect(text_with_image).to include %{src='(stub){"mode":"normal"}(/stub)'}
    end
  end
end
