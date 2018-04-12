class Cardname
  module Contextual
    RELATIVE_REGEXP = /\b_(left|right|whole|self|user|main|\d+|L*R?)\b/

    # @return true if name is left or right of context
    def child_of? context
      return false unless junction?
      context_key = context.to_name.key
      absolute_name(context).parent_keys.include? context_key
    end

    def relative?
      starts_with_joint? || (s =~ RELATIVE_REGEXP).present?
    end

    def simple_relative?
      starts_with_joint? && (s =~ RELATIVE_REGEXP).nil?
    end

    def absolute?
      !relative?
    end

    def stripped
      s.gsub RELATIVE_REGEXP, ""
    end

    def starts_with_joint?
      junction? && parts.first.empty?
    end

    def from *from
      name_from(*from).s
    end

    # if possible, relativize name into one beginning with a "+".  The new name must absolutize back to the correct
    # original name in the context of "from"
    def name_from *from
      return self unless (remaining = remove_context *from)
      compressed = remaining.compact.unshift(nil).to_name  # exactly one nil at beginning
      key == compressed.absolute_name(from).key ? compressed : self
    end

    def remove_context *from
      return false unless from.compact.present?
      remaining = parts_excluding *from
      return false if remaining.compact.empty? || # all name parts in context
                      remaining == parts          # no name parts in context
      remaining
    end

    def parts_excluding *string
      exclude_name = string.to_name
      exclude_keys = exclude_name ? exclude_name.part_names.map(&:key) : []
      parts_minus exclude_keys
    end

    def parts_minus keys_to_ignore
      parts.map do |part|
        next if part.empty?
        next if part =~ /^_/ # this removes relative parts.  why?
        next if keys_to_ignore.member? part.to_name.key
        part
      end
    end

    def absolute context, args={}
      context = (context || "").to_name
      new_parts = absolutize_contextual_parts context
      return "" if new_parts.empty?
      absolutize_extremes new_parts, context.s
      new_parts.join self.class.joint
    end

    def absolute_name *args
      absolute(*args).to_name
    end

    def nth_left n
      # 1 = left; 2= left of left; 3 = left of left of left....
      (n >= length ? parts[0] : parts[0..-n - 1]).to_name
    end

    private

    def absolutize_contextual_parts context
      parts.map do |part|
        case part
        when /^_user$/i            then user_part part
        when /^_main$/i            then self.class.params[:main_name]
        when /^(_self|_whole|_)$/i then context.s
        when /^_left$/i            then context.trunk
        # note - inconsistent use of left v. trunk
        when /^_right$/i           then context.tag
        when /^_(\d+)$/i           then ordinal_part $~[1].to_i, context
        when /^_(L*)(R?)$/i        then partmap_part $~, context
        else                            part
        end.to_s.strip
      end
    end

    def user_part part
      name_proc = self.class.session
      name_proc ? name_proc.call : part
    end

    def ordinal_part pos, context
      pos = context.length if pos > context.length
      context.parts[pos - 1]
    end

    def partmap_part match, context
      l_s, r_s = match[1].size, !match[2].empty?
      l_part = context.nth_left l_s
      r_s ? l_part.tag : l_part.s
    end

    def absolutize_extremes new_parts, context
      [0, -1].each do |i|
        next if new_parts[i].present?
        # following avoids recontextualizing with relative contexts.
        # Eg, `+A+B+.absolute('+A')` should be +A+B, not +A+A+B.
        next if new_parts.to_name.send "#{[ :start, :end ][i]}s_with_parts?", context
        new_parts[i] = context
      end
    end

  end
end
