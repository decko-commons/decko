class CardController
  # overrides REST methods to handle alias redirects and card reloads
  module Aliasing
    def read
      return super unless redirect_to_aliased?

      hard_redirect target_url
    end

    # create, read, and update requests take effect on the target card
    # when aliases are compound (but on the alias card itself when simple).
    %i[create update delete].each do |action|
      define_method action do
        @card = card.target_card if card&.compound? && card&.alias?
        super()
      end
    end

    private

    # url to which aliased requests should be redirected
    def target_url
      target_params = params.clone.merge(mark: card.target_name).to_unsafe_h
      target_params.delete :controller
      card.target_card.format(:base).path target_params
    end

    # aliased names are not redirected when a view is specified for a simple alias card
    def redirect_to_aliased?
      return false unless card&.alias?

      card.compound? || params[:view].blank?
    end
  end
end
