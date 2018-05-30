# -*- encoding : utf-8 -*-

class Card
  class Content
    module Chunk
      class Reference < Abstract
        attr_accessor :referee_name, :name

        def referee_name
          return if name.nil?
          @referee_name ||= referee_name_from_rendered(render_obj(name))
          @referee_name = @referee_name.absolute(card.name).to_name
        rescue Card::Error::NotFound
          # do not break on missing id/codename references.
        end

        def referee_name_from_rendered rendered_name
          ref_card = fetch_referee_card rendered_name
          ref_card ? ref_card.name : rendered_name.to_name
        end

        def referee_card
          @referee_card ||= referee_name && Card.fetch(referee_name)
        end

        def replace_name_reference old_name, new_name
          @referee_card = nil
          @referee_name = nil
          if name.is_a? Card::Content
            name.find_chunks(Chunk::Reference).each do |chunk|
              chunk.replace_reference old_name, new_name
            end
          else
            @name = name.to_name.swap old_name, new_name
          end
        end

        def render_obj raw
          if format && raw.is_a?(Card::Content)
            format.process_content raw
          else
            raw
          end
        end

        private

        def fetch_referee_card rendered_name
          case rendered_name # FIXME: this should be standard fetch option.
          when /^\~(\d+)$/ # get by id
            Card.fetch Regexp.last_match(1).to_i
          when /^\:(\w+)$/ # get by codename
            Card.fetch Regexp.last_match(1).to_sym
          end
        end
      end
    end
  end
end
