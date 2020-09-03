RSpec.describe Card::Set::Abstract::PagingParams do
  describe "offset_param" do
    it "doesn't allow anonymous users to use extremely high values" do
      Card::Auth.signin Card::AnonymousID
      Card::Env.with_params offset: 10_000 do
        expect { Card[:all].format(:json).offset_param }
          .to raise_error(Card::Error::PermissionDenied,
                          "offset parameter exceeds maximum")
      end
    end
  end
end
