RSpec.describe Card::Set::Abstract::Attachment::Web do
  let :file_card do
    with_storage_config :web do
      create_file_card :web, nil, content: web_url
    end
  end

  let(:web_url) { "http://web.de/web_file.txt" }

  specify "view: core" do
    expect(file_card.format.render_core)
      .to have_tag("a[href=\"#{web_url}\"]") do
        with_text "Download file card"
      end
  end

  specify "view: :source" do
    expect(file_card.format.render_source).to eq(web_url)
  end

  it "saves url as identifier" do
    expect(file_card.db_content).to eq(web_url)
  end

  it "has correct original filename" do
    expect(file_card.original_filename).to eq("web_file.txt")
  end

  it "has correct url" do
    expect(file_card.attachment.url).to eq(web_url)
  end

  it "accepts url as file argument" do
    expect(create_file_card(:web, web_url).db_content).to eq(web_url)
  end

  it "accepts url as remote url argument" do
    expect(create_file_card(:web, nil, remote_file_url: web_url).db_content)
      .to eq(web_url)
  end
end
