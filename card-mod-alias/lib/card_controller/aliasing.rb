class CardController < ApplicationController
  # overrides REST methods to handle alias redirects and card reloads
  module Aliasing
    def read
      return super unless redirect_to_aliased?

      hard_redirect card_url(card.first_name.url_key)
    end

    %i[create update delete].each do |action|
      define_method action do
        @card = card.first_card if card&.type_id == Card::AliasID
        super()
      end
    end

    private

    def redirect_to_aliased?
      return false unless card&.alias?

      card.compound? || params[:view].blank?
    end
  end
end
