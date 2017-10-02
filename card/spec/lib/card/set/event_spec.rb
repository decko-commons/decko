describe Card::Set::Event do
  it "params are deserialized in intergrate_with_delay events" do
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
      Card["A"].update_attributes! content: "new content"

      expect(@called).to eq true
    end
  end
end
