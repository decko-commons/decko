# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::FetchHelper do
  let(:retrieve) { test_retrieve_existing }
  let(:retrieve_from_trash) { test_retrieve_existing look_in_trash: true }

  def fetch_object opts={}
    if @fetch_object
      @fetch_object.opts.merge! opts
      @fetch_object
    else
      @fetch_object = Card::Fetch.new("A".to_name, opts)
    end
  end

  def test_retrieve_existing opts={}
    fetch_object(opts)&.retrieve_existing
  end

  describe "#controller fetch" do
    it "removes underscores from new card names" do
      expect(Card.controller_fetch(mark: "no_un_der_score").name).to eq("no un der score")
    end
  end

  describe "retrieve_existing" do
    it "looks for non-cached card in database" do
      # expect_db_retrieval_with(:key, "a", nil) { retrieve }
      expect_db_retrieval { retrieve }
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
      # expect_db_retrieval_with(:key, "a", true) { retrieve_from_trash }
      expect_db_retrieval { retrieve_from_trash }
    end

    def expect_no_db_retrieval
      allow(fetch_object).to receive(:retrieve_from_db)
      yield
      expect(fetch_object).not_to have_received(:retrieve_from_db)
    end

    def expect_db_retrieval
      allow(fetch_object).to receive(:retrieve_from_db)
      yield
      expect(fetch_object).to have_received(:retrieve_from_db) # .with(*args)
    end
  end
end
