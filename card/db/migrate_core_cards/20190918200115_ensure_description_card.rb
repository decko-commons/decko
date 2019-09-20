# -*- encoding : utf-8 -*-

class EnsureDescriptionCard < Card::Migration
  def up
    ensure_card "description", codename: :description

    # Following two appear in other migrations but previously had errors
    # that may persist in some databases.
    ensure_card %i[all content_option_view], content: "smart_label"
    ensure_card "*account settings",
                codename: "account_settings", type_id: Card::BasicID
  end
end
