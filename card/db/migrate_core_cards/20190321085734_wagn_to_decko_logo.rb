# -*- encoding : utf-8 -*-

class WagnToDeckoLogo < Card::Migration::Core
  def up
    logo = Card[:logo]
    return unless logo&.pristine?

    logo.update! content: ":logo/standard.svg",
                 empty_ok: true
  end
end
