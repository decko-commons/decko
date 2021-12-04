include_set Abstract::Lock

card_accessor :asset_output, type: :file

def output_filetype
  output_format
end

event :update_asset_output_file, :finalize, on: :save do
  update_asset_output
end

event :validate_asset_inputs, :validate, on: :save, skip: :allowed do
  return unless (invalid_input = find_invalid_input)

  errors.add :content, t(:assets_invalid_input, input_name: invalid_input.name)
end

def find_invalid_input
  item_cards.find { |c| !c.respond_to?(:asset_input_content) }
end

def update_asset_output
  # puts "update_asset_output called: #{name}"
  lock do
    store_output input_from_item_cards
  end
end

def update_asset_output_live
  update_asset_output
  card_path asset_output_url
end

def input_from_item_cards joint="\n"
  input_item_cards.map(&:asset_input_content).compact.join(joint)
end

def store_output output
  handle_file(output) do |file|
    Card::Auth.as_bot do
      # FIXME: this is definitely not how we want to do this.
      # problem is that file object is getting stashed in set_specific attributes,
      # and then reassigned later. This causes problems in cases where a single
      # card (eg *all+*style) is updated by multiple inputters, because the old file arg
      # sticks around in the set specific stash and then reemerges after it's been
      # unlinked. we need a more general solution
      # (error reproducible eg when running card:mod:install on wikirate)
      aoc = asset_output_card
      aoc.update file: file
      aoc.set_specific.delete :file
    end
  end
end

def handle_file output
  file = Tempfile.new [id.to_s, ".#{output_filetype}"]
  file.write output
  file.close
  yield file
  file.unlink
end

view :asset_output_url do
  asset_output_url
end

def make_asset_output_coded mod
  mod ||= :assets
  Card::Auth.as_bot do
    ENV["STORE_CODED_FILES"] = "true"
    asset_output_card.update! storage_type: :coded, mod: mod,
                              codename: asset_output_codename
    ENV["STORE_CODED_FILES"] = nil
  end
end

def asset_output_codename
  asset_output_card.name.parts.map do |part|
    Card[part].codename&.to_s || Card[part].name.safe_key
  end.join "_"
end

def input_item_cards
  item_cards(known_only: true).compact.reject(&:trash)
end

def asset_output_url
  # ensure_asset_output
  asset_output_card.file&.url # (:default, timestamp: false)
  # to get rid of additional number in url
end

def asset_output_path
  # ensure_asset_output
  asset_output_card.file&.path
end
