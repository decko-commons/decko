include_set Abstract::Pointer


def local
    @local = true
end

def minimize
  @minimize = true
end

def add_items paths
  @asset_file_cards ||= []
  paths.each do |path|
  type =
    if path.ends_with "js"
      :asset_java_script
    elsif path.ends_with "coffee.js"
      :asset_coffee_script
    end
  asset_card = Card.new(name: File.basename(path), type: type, content: path)
  asset_card.minimize if @minimize
  asset_card.local if @local
  @asset_file_cards << asset_card
  end
end

def item_cards content=nil
  @asset_file_cards ||= []
end

def content
  (asset_file_cards.map { |c| c.name }).to_pointer_content
end


format :html do
  view :include_tag do
    card.item_cards.map do |icard|
      nest icard, view: :include_tag
    end.join("\n")

  end
end
