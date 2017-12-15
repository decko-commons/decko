# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::FetchHelper do
  let(:retrieve) { test_retrieve_existing }
  let(:retrieve_from_trash) { test_retrieve_existing look_in_trash: true }

  def test_retrieve_existing opts={}
    Card.send :retrieve_existing, "A".to_name, opts
  end

  describe "retrieve_existing" do
    it "looks for non-cached card in database" do
      expect_db_retrieval_with(:key, "a", nil) { retrieve }
    end

    it "doesn't look in db for cached cards(real)" do
      Card.cache.write "a", Card["B"]
      expect_no_db_retrieval { retrieve }
    end

    it "doesn't look in db for cached cards (new)" do
      Card.cache.write "a", Card.new
      expect_no_db_retrieval { retrieve }
    end

    it "doesn't look in db for cached cards (real) if 'look_in_trash' option used" do
      Card.cache.write "a", Card["B"]
      expect_no_db_retrieval { retrieve_from_trash }
    end

    it "looks in db for cached cards (new) if 'look_in_trash' option used" do
      Card.cache.write "a", Card.new
      expect_db_retrieval_with(:key, "a", true) { retrieve_from_trash }
    end

    def expect_no_db_retrieval
      allow(Card).to receive(:retrieve_from_db)
      yield
      expect(Card).not_to have_received(:retrieve_from_db)
    end

    def expect_db_retrieval_with *args
      allow(Card).to receive(:retrieve_from_db)
      yield
      expect(Card).to have_received(:retrieve_from_db).with(*args)
    end
  end
end
