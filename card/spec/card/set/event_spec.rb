RSpec.describe Card::Set::Event do
  it "params are deserialized in integrate_with_delay events" do
    @called = false
    def event_called
      @called = true
    end

    with_test_events do
      test_event :integrate_with_delay, on: :update, for: "A" do
        event_called
        expect(Card::Env.params)
          .to include(level1: ActionController::Parameters.new(level2: :a_symbol))
      end

      Card::Env.params[:level1] = ActionController::Parameters.new level2: :a_symbol
      Card["A"].update! content: "new content"

      expect(@called).to eq true
    end
  end

  # This spec can cause other specs to break if they are loaded after
  # it. I don't understand the exact scope, but eg right/api_key_spec.rb
  # was failing because some events didnt run because it wasn't recognizing
  # the described class because the set constant had been redefined.
  #
  # > described_class
  # => Card::Set::Right::ApiKey
  # > described_class == Card::Set::Right::ApiKey
  # => false
  #
  xit "runs events after reloading sets" do
    Cardio::Mod::Loader.reload_sets
    expect(Card.create!(name: "event tester")).to be_a(Card)
    # if events don't load, the above will fail to stamp a creator_id and won't validate
  end
end
