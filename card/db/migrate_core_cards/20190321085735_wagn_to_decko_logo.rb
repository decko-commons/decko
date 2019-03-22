# -*- encoding : utf-8 -*-

class WagnToDeckoLogo < Card::Migration::Core
  def up
    logo = Card[:logo]
    binding.pry
    return unless logo&.pristine?

    logo.update_column :db_content, ":logo/standard.svg"
    Card::Cache.reset_all
  end
end
