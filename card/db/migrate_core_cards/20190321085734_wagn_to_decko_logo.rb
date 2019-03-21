# -*- encoding : utf-8 -*-

class WagnToDeckoLogo < Card::Migration::Core
  def up
    logo = Card[:logo]
    return unless logo&.pristine?

    logo.update! type_id: Card::ImageID,
                 storage_type: :coded,
                 mod: :standard,
                 image: File.open(File.join(data_path, "decko_logo.svg"))
  end
end
