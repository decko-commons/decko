shared_examples "view without errors" do |view_name, format=:html|
  let(:view) { Card.fetch name }
  it "view #{view_name} has no errors" do
    expect(card_subject.format(format).render(view_name)).to lack_errors
  end
end

