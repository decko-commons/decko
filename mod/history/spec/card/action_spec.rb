RSpec.describe Card::Action do
  specify "#delete_old" do
    expect { described_class.delete_old }.not_to raise_error
  end

  specify "#make_current_state_the_initial_state" do
    expect { described_class.make_current_state_the_initial_state }.not_to raise_error
  end
end
