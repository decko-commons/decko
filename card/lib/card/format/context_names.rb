class Card
  class Format
    module ContextNames

      def context_names
        @context_names ||= initial_context_names
      end

      def initial_context_names
        @initial_context_names ||=
          parent ? context_names_from_parent : context_names_from_params
      end

      def context_names_from_parent
        part_keys = @card.name.part_names.map(&:key)
        parent.context_names.reject { |n| !part_keys.include? n.key }
      end

      def context_names_from_params
        return [] unless (name_list = Card::Env.slot_opts[:name_context])
        name_list.to_s.split(",").map(&:to_name)
      end

      def context_names_to_params
        return if context_names.empty?
        context_names.join(",")
      end

      def add_name_context name=nil
        name ||= card.name
        @context_names = (context_names + name.to_name.part_names).uniq
      end

      def title_in_context title=nil
        keep_safe = title&.html_safe?
        title = title ? title.to_name.absolute_name(card.name) : card.name
        newtitle = title.from *context_names
        keep_safe ? newtitle.html_safe : newtitle
      end
    end
  end
end
