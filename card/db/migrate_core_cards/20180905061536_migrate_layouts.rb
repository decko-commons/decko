# -*- encoding : utf-8 -*-

class MigrateLayouts < Card::Migration::Core
  def up
    Card.search referred_to_by: { right: :layout } do |card|
      create_head_rules card
      update_layout_card card
    end
  end

  # strip layout content down to body tag
  def update_layout_card card
    body = body_tag card
    missing "body", card unless body.present?

    puts "updating layout '#{card.name}'"
    card.update! content: body.to_s
  end

  def body_tag card
    card.content[/<body[^>]+>.*<\/body>/mi]
  end

  def create_head_rules layout_card
    head = find_head_content layout_card
    return missing "head", layout_card unless head

    each_layout_set layout_card do |set_name|
      puts "creating head rule for '#{set_name}'"
      ensure_card [set_name, :head], content: head, type_id: Card::HtmlID
    end
  end

  def find_head_content card
    head_tag(card) || find_nested_head(card)
  end

  def head_tag card
    if (match = card.content.match(/<head>(.*)<\/head>/mi))
      match[1].strip
    end
  end

  def missing obj, card
    puts "warning: couldn't find #{obj} in layout '#{card.name}'"
  end

  def each_layout_set layout_card
    Card.search(link_to: layout_card.name) do |rule|
      rule.name.left
    end
  end

  private

  def find_nested_head card
    # we go only one level deep
    Card::Content.new(card.content, card, chunk_list: :nest_only).each_chunk do |chunk|
      nested = chunk.referee_card
      return head_tag(nested) if nested&.content&.match?(/<head>/i)
    end
    nil
  end
end
