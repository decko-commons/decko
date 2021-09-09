include_set Abstract::Lock

card_accessor :asset_output, type: FileID

def output_filetype
  output_format
end

event :update_asset_output_file, :finalize, on: :save do
  update_asset_output
end

event :validate_asset_inputs, :validate, on: :save do
  return unless (invalid_input = item_cards.find { |c| !c.respond_to?(:ensure_asset_input) })
  errors.add :content, t(:assets_invalid_input, input_name: invalid_input.name)
end

def update_asset_output
  lock do
    store_output file_output
  end
end

def update_asset_output_live
  update_asset_output
  card_path asset_output_url
end

def file_output joint="\n"
  input_item_cards.map(&:ensure_asset_input).compact.join(joint)
end

def store_output output
  handle_file(output) do |file|
    Card::Auth.as_bot do
      asset_output_card.update! file: file
    end
  end
end

def handle_file output
  file = Tempfile.new [id.to_s, ".#{output_filetype}"]
  file.write output
  file.rewind
  yield file
  file.close
  file.unlink
end

view :asset_output_url do
  asset_output_url
end

def make_machine_output_coded mod=:machines
  update_machine_output
  Card::Auth.as_bot do
    ENV["STORE_CODED_FILES"] = "true"
    asset_output_card.update! storage_type: :coded, mod: mod,
                                codename: asset_output_codename_codename
    ENV["STORE_CODED_FILES"] = nil
  end
end

def asset_output_codename
  asset_output_card.name.parts.map do |part|
    Card[part].codename&.to_s || Card[part].name.safe_key
  end.join "_"
end

def input_item_cards
  item_cards(known_only: true).reject(&:trash)
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
