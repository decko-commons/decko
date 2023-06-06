# -*- encoding : utf-8 -*-

class MigrateLayouts < Cardio::Migration::Transform
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
  rescue Card::Error => e
    card = Card.fetch card.id, skip_modules: true
    card.update! type_id: Card::HtmlID, content: body.to_s
    puts "failed to complete layout upgrade for '#{card.name}': #{e.message}.\n" \
         "To fix, go to /#{card.name.url_key}?view=edit and change type to Layout. \n" \
         "You will need to make sure the layout content includes a main nest ({{_main}})."
  end

  def body_tag card
    card.content[%r{<body[^>]*>.*</body>}mi] || add_body_tag(card)
  end

  def add_body_tag card
    content = card.content.gsub("<!DOCTYPE HTML>", "")
                  .gsub(/\{\{\*head[^}]*\}\}/i, "").strip
    "<body>\n  #{content}\n</body>"
  end

  def create_head_rules layout_card
    head = find_head_content layout_card
    return missing "head", layout_card unless head

    each_layout_set layout_card do |set_name|
      puts "creating head rule for '#{set_name}'"
      Card.ensure name: [set_name, :head], content: head, type_id: Card::HtmlID
    end
  end

  def find_head_content card
    head_tag(card) || find_nested_head(card)
  end

  def head_tag card
    if (match = card.content.match(%r{<head>(.*)</head>}mi))
      match[1].strip
    end
  end

  def missing obj, card
    puts "warning: couldn't find #{obj} in layout '#{card.name}'"
  end

  def each_layout_set layout_card
    Card.search(link_to: layout_card.name) do |rule|
      yield rule.name.left
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
