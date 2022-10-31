RSpec.describe Card::Set::Type::User do
  before { Card::Auth.signin :anonymous }

  specify "view: :setup" do
    expect { Card.new(type: :user).format._render_setup }.not_to raise_error
  end
end
