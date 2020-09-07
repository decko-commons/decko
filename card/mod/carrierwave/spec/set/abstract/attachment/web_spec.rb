RSpec.describe Card::Set::Abstract::Attachment::Web do
  subject do
    with_storage_config :web do
      create_file_card :web, nil, content: web_url
    end
  end

  let(:web_url) { "http://web.de/web_file.txt" }

  specify "view: core" do
    expect(subject.format.render_core)
      .to have_tag("a[href=\"#{web_url}\"]") do
        with_text "Download file card"
      end
  end

  specify "view: :source" do
    expect(subject.format.render_source).to eq(web_url)
  end

  it "saves url as identifier" do
    expect(subject.db_content).to eq web_url
  end

  it "has correct original filename" do
    expect(subject.original_filename).to eq "web_file.txt"
  end

  it "has correct url" do
    expect(subject.attachment.url).to eq web_url
  end

  it "accepts url as file argument" do
    Card::Auth.as_bot do
      card = Card.create! name: "file card", type_id: Card::FileID,
                          file: web_url, storage_type: :web
      expect(card.db_content).to eq web_url
    end
  end

  it "accepts url as remote url argument" do
    Card::Auth.as_bot do
      card = Card.create! name: "file card", type_id: Card::FileID,
                          remote_file_url: web_url, storage_type: :web
      expect(card.db_content).to eq web_url
    end
  end
end
