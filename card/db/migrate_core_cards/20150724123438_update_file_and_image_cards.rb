# -*- encoding : utf-8 -*-

class UpdateFileAndImageCards < Card::Migration::Core
  def up
    # use codenames for the filecards not for the left parts
    if (credit = Card[:credit]) && (card = credit.fetch(:image))
      card.update_column :codename, "credit_image"
    end
    add_skin_thumbnails
    Card::Cache.reset_all
    update_cards_with_attachment
  end

  def update_cards_with_attachment
    Card.search(type: [:in, "file", "image"]).each do |card|
      update_history card
      next unless card.db_content.present?
      update_db_content card
      update_filenames card
    end
  end

  def update_db_content card
    attach_array = card.db_content.split "\n"
    attach_array[0].match(/\.(?<ext>.+)$/) do |match|
      basename =
        if attach_array.size > 3 # mod file
          mod_name = attach_array[3].sub(/^0\d_/, "")
          ":#{card.codename}/#{mod_name}"
        else
          "~#{card.id}/#{card.last_action_id}"
        end
      card.update_column :db_content, "#{basename}.#{match[:ext]}"
    end
  end

  # swap variant and action_id/type_code in file name
  def update_filenames card
    return unless Dir.exist? card.store_dir
    symlink_target_hash =
      Dir.entries(card.store_dir).each_with_object({}) do |file, symlink_target|
        next unless (new_filename = get_new_file_name(file))
        file_path = File.join(card.store_dir, file)
        if File.symlink?(file_path)
          symlink_target[new_filename] = File.readlink(file_path)
          File.unlink file_path
        else
          FileUtils.mv file_path, File.join(card.store_dir, new_filename)
        end
      end
    update_symlinks symlink_target_hash
  end

  def update_symlinks symlink_targets
    symlink_targets.each do |symlink, target|
      new_target_name = get_new_file_name target
      File.symlink File.join(card.store_dir, new_target_name),
                   File.join(card.store_dir, symlink)
    end
  end

  def update_history card
    card.actions.each do |action|
      if (content_change = action.change :db_content)
        original_filename = content_change.value.split("\n").first
        action.update! comment: original_filename
      end
    end
  end

  def add_skin_thumbnails
    %w(cerulean_skin cosmo_skin cyborg_skin darkly_skin flatly_skin
       journal_skin lumen_skin paper_skin readable_skin sandstone_skin
       simplex_skin slate_skin spacelab_skin superhero_skin united_skin
       yeti_skin).each do |name|
      next unless (card = Card[name.to_sym])
      card.update! codename: nil
      if (card = Card.fetch name, :image)
        card.update_column :codename, "#{name}_image"
      end
    end
  end

  def get_new_file_name filename
    original_filename = filename
    if filename =~ /^(icon|small|medium|large|original)-([^.]+).(.+)$/
      filename = "#{Regexp.last_match(2)}-#{Regexp.last_match(1)}."\
                 "#{Regexp.last_match(3)}"
    end
    filename = filename.downcase
    filename if filename != original_filename
  end
end
