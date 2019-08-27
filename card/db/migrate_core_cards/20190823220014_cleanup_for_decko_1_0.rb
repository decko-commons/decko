# -*- encoding : utf-8 -*-

class CleanupForDecko10 < Card::Migration::Core
  def up
    ensure_card "Cards with account", codename: "cards_with_account",
                content: '{"right_plus": "*account"}'

    %i[delete create update comment].each do |perm|
      delete_card [perm, :right, :options]
    end
    delete_card "*missing link"
    delete_card "tags"
    delete_card "*tagged"
    merge_cards "*account"
  end
end
