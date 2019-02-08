shared_examples "view without errors" do |view_name, format=:html|
  # let(:view) { Card.fetch name }
  it "view #{view_name} has no errors" do
    expect(card_subject.format(format).render(view_name)).to lack_errors
  end
end

shared_examples "view with valid html" do |view_name|
  require 'nokogumbo'
  include RSpecHtmlMatchers::SyntaxHighlighting
  # let(:view) { Card.fetch name }
  it "view #{view_name} has valid html" do
    rendered = card_subject.format.render(view_name)
    doc = Nokogiri::HTML5.fragment rendered
    expect(doc.errors).to be_empty, [doc.errors, highlight_syntax(rendered)].join("\n")
  end
end

