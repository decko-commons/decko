# -*- encoding : utf-8 -*-

class MigrateLayouts < Card::Migration::Core
  def up
    Card.search referred_to_by: { right: :layout } do |card|
      update_layout_card card
      create_head_rules card
    end
  end

  # strip layout content down to body tag
  def update_layout_card card
    body = html_tag card, "body"
    missing "body", card  unless body.present?

    puts "updating layout '#{card.name}'"
    card.update_attributes! content: body.to_s
  end

  def create_head_rules layout_card
    head = find_head_content layout_card
    return missing "head", layout_card unless head
    each_layout_set layout_card do |set_name|
      puts "creating head rule for '#{set_name}'"
      ensure_card [set_name, :head], content: head,
                  type_id: Card::HtmlID
    end
  end

  def find_head_content card
    head = Nokogiri::XML(card.content).css("head")
    return head.first.text if head.present?

    # try to find head in nests
    # we go only one level deep
    Card::Content.new(card.content, card, chunk_list: :nest_only).each_chunk do |chunk|
      if chunk.referee_card&.content&.include? "<head>"
        return Nokogiri::XML(chunk.referee_card.content).css("head").first.text
      end
    end
  end

  def html_tag card, tag_name
    Nokogiri::XML(card.content).css(tag_name).first
  end

  def missing obj, card
    puts "warning: couldn't find #{obj} in layout '#{card.name}'"
  end

  def each_layout_set layout_card
    Card.search(link_to: layout_card.name) do |rule|
      rule.name.left
    end
  end
end
