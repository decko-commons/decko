RSpec.describe Card::Format::Content do
  example "single bracket line break double bracket bug" do
    processed = Card["A"].format.process_content "before[keyword]after\n[[C]]"

    expect(processed).to include "before[keyword]after"
  end
end
