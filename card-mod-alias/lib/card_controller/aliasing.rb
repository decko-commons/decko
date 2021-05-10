class CardController
  # overrides REST methods to handle alias redirects and card reloads
  module Aliasing
    def read
      return super unless redirect_to_aliased?

      hard_redirect target_url
    end

    %i[create update delete].each do |action|
      define_method action do
        @card = card.target_card if card&.compound? && card&.alias?
        super()
      end
    end

    private

    def target_url
      target_params = params.clone.merge(mark: card.target_name).to_unsafe_h
      target_params.delete :controller
      card.target_card.format(:base).path target_params
    end

    def redirect_to_aliased?
      return false unless card&.alias?

      card.compound? || params[:view].blank?
    end
  end
end
