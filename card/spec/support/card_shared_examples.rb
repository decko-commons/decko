shared_examples "view without errors" do |view_name, format=:html|
  # let(:view) { Card.fetch name }
  it "view #{view_name} has no errors" do
    expect(format_subject(format).render(view_name)).to lack_errors
  end
end

shared_examples "view with valid html" do |view_name|
  require 'nokogumbo'
  include RSpecHtmlMatchers::SyntaxHighlighting
  # let(:view) { Card.fetch name }
  it "view #{view_name} has valid html" do
    rendered = format_subject.render(view_name)
    doc = Nokogiri::HTML5.fragment rendered
    expect(doc.errors).to be_empty, [doc.errors, highlight_syntax(rendered)].join("\n")
  end
end

