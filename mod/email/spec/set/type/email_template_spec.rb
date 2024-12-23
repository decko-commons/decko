# -*- encoding : utf-8 -*-

describe Card::Set::Type::EmailTemplate do
  describe "#mail" do
    def content_type fields
      card = Card.create! name: "content type test",
                          type: :email_template,
                          subcards: fields
      card.format.mail[:content_type].value
    end

    it "renders text email if text message given", :as_bot do
      expect(content_type("+*text_message" => "text")).to include "text/plain"
    end

    it "renders html email if html message given", :as_bot do
      expect(content_type("+*html_message" => "text")).to include "text/html"
    end

    it "renders multipart email if text and html given", :as_bot do
      expect(content_type("+*text_message" => "text", "+*html_message" => "text"))
        .to include "multipart/alternative"
    end
  end
end
