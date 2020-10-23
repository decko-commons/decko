describe Card::Set::Abstract::Paging do
  describe "offset" do
    it "doesn't allow anonymous users to use extremely high limits" do
      Card::Auth.signin Card::AnonymousID
      Card::Env.with_params limit: 10_000 do
        expect { Card[:all].format(:json).limit }
          .to raise_error(Card::Error::PermissionDenied,
                          /limit parameter exceeds maximum/)
      end
    end
  end
end
