shared_examples "view without errors" do |view_name, format=:html|
  let(:view) { Card.fetch name }
  it "view #{view_name} has no errors" do
    expect(card_subject.format(format).render(view_name)).to lack_errors
  end
end

shared_examples "view with valid html" do |view_name|
  let(:view) { Card.fetch name }
  it "view #{view_name} has valid html" do
    doc = Nokogiri::HTML.fragment card_subject.format.render(view_name)
    expect(doc.errors).to be_empty
  end
end

