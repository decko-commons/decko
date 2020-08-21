class Card
  class Format
    # Contextual names make titles less noisy by not rendering redundant name parts
    #
    # For example, in the context of "Ball", "Ball+size" is rendered as just "+size"
    module ContextNames
      def naming name=nil
        result = yield
        add_name_context name
        result
      end

      # TODO: stop this lazy loading
      # the combo of lazy loading + format ancestry navigation + caching is dangerous
      # Long term, it would probably be smarter to handle this in the voo.
      def context_names
        @context_names ||= initial_context_names
      end

      def initial_context_names
        @initial_context_names ||= relevant_context_names do
          parent ? parent.context_names : context_names_from_params
        end
      end

      def relevant_context_names
        part_keys = @card.name.part_names.map(&:key)
        yield.select { |n| part_keys.include? n.key }
      end

      # "slot[name_context]" param is a string; @context_names is an array
      def context_names_from_params
        return [] unless (name_list = Card::Env.slot_opts.delete(:name_context))

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
        newtitle = title.from(*context_names)
        keep_safe ? newtitle.html_safe : newtitle
      end
    end
  end
end
