# -*- encoding : utf-8 -*-

class WagnToDeckoLogo < Cardio::Migration::Core
  def up
    logo = Card[:logo]
    return unless logo&.pristine?

    logo.update_column :db_content, ":logo/standard.svg"
    Card::Cache.reset_all
  end
end
