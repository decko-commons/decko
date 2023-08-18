shared_examples "view without errors" do |view_name, format=:html|
  if format == :html
    # require "nokogumbo"
    include RSpecHtmlMatchers::SyntaxHighlighting
  end

  it "view #{view_name} has #{'valid HTML and ' if format == :html}no errors" do
    next unless (rendered = format_subject(format).render view_name)

    expect(rendered).to lack_errors

    next unless format == :html

    doc = Nokogiri::HTML5.fragment rendered
    expect(doc.errors).to be_empty, [doc.errors, highlight_syntax(rendered)].join("\n")
  end
end
