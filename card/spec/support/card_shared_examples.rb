shared_examples "view without errors" do |view_name|
  let(:view) { Card.fetch name }
  it "#{view_name} has no errors" do
    expect(card_subject.format.render(view_name)).to lack_errors
  end
end

