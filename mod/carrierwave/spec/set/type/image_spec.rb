# -*- encoding : utf-8 -*-require 'image_spec'

RSpec.describe Card::Set::Type::Image do
  it "has special editor" do
    assert_view_select render_input("Image"), 'div[class="choose-file"]' do
      assert_select 'input[class~="file-upload slotter"]'
    end
  end

  it "handles size argument in nest syntax" do
    file = File.new CarrierWave::TestFile.path("mao2.jpg")
    image_card = Card.create! name: "TestImage", type: "Image", image: file
    including_card = Card.new name: "Image1",
                              content: "{{TestImage | core; size:small }}"
    rendered = including_card.format._render :core
    assert_view_select(
      rendered, "img[src=?]",
      "/files/~#{image_card.id}/#{image_card.last_content_action_id}-small.jpg"
    )
  end

  context "newly created image card" do
    subject { Card["image card"] }

    before do
      Card::Auth.as_bot do
        Card.create! name: "image card", type: "image",
                     image: File.new(CarrierWave::TestFile.path("mao2.jpg"))
      end
    end

    it "stores correct identifier" do
      expect(subject.content)
        .to eq "~#{subject.id}/#{subject.last_action_id}.jpg"
    end

    it "stores image" do
      expect(subject.image.size).to eq 7202
    end

    it "stores small size" do
      expect(subject.image.small.size).to be < 6000
      expect(subject.image.small.size).to be_positive
    end

    it "stores icon size" do
      expect(subject.image.icon.size).to be < 3000
      expect(subject.image.icon.size).to be_positive
    end

    it "saves original file name as action comment" do
      expect(subject.last_action.comment).to eq "mao2.jpg"
    end

    it "has correct original filename" do
      expect(subject.original_filename).to eq "mao2.jpg"
    end

    it "has correct url" do
      expect(subject.image.url)
        .to eq "/files/~#{subject.id}/#{subject.last_action_id}-original.jpg"
    end

    describe "view: source" do
      it "renders url" do
        expect(subject.format.render!(:source))
          .to eq("/files/~#{subject.id}/#{subject.last_action_id}-medium.jpg")
      end
    end

    describe "view: content changes" do
      it "gets image url" do
        act_summary = subject.format.render_content_changes
        current_url = subject.image.versions[:medium].url
        expect(act_summary).to match(/#{Regexp.quote current_url}/)
      end
    end

    context "updated file card" do
      before do
        subject.update!(
          image: File.new(CarrierWave::TestFile.path("rails.gif"))
        )
      end

      it "updates file" do
        expect(subject.image.size).to eq 8533
      end

      it "updates original file name" do
        expect(subject.image.original_filename).to eq "rails.gif"
      end

      it "updates url" do
        expect(subject.image.url)
          .to eq "/files/~#{subject.id}/#{subject.last_action_id}-original.gif"
      end
    end
  end

  describe "mod image" do
    subject { %i[cerulean_skin image].card }

    it "exists" do
      expect(subject.image.size).to be_positive
    end

    it "has correct url" do
      expect(subject.image.url).to eq "/files/:cerulean_skin_image/bootstrap-original.png"
    end

    it "has correct url as content" do
      expect(subject.content).to eq ":#{subject.codename}/bootstrap.png"
    end

    it "becomes a regular file when changed" do
      Card::Auth.as_bot do
        subject.update! image: File.new(CarrierWave::TestFile.path("rails.gif"))
      end
      is_expected.not_to be_coded
      expect(subject.image.url)
        .to eq "/files/~#{subject.id}/#{subject.last_action_id}-original.gif"
    end

    describe "#coded?" do
      it "returns true" do
        is_expected.to be_coded
      end
    end

    describe "source view" do
      it "renders url with original version" do
        expect(subject.format.render_source)
          .to eq "/files/:#{subject.codename}/bootstrap-medium.png"
      end
    end
  end

  describe "#delete_files_for_action" do
    subject do
      Card::Auth.as_bot do
        Card.create! name: "image card", type: "image",
                     image: File.new(CarrierWave::TestFile.path("mao2.jpg"))
      end
    end

    it "deletes all versions" do
      path = subject.image.path
      small_path = subject.image.small.path
      medium_path = subject.image.medium.path
      subject.delete_files_for_action(subject.last_action)
      expect(File).not_to be_exist(small_path)
      expect(File).not_to be_exist(medium_path)
      expect(File).not_to be_exist(path)
    end
  end
end
