class Cardname
  module Contextual
    RELATIVE_REGEXP = /\b_(left|right|whole|self|user|main|\d+|L*R?)\b/

    def absolute_name context_name
      to_absolute_name context_name
    end

    # @return true if name is left or right of context
    def child_of? context
      return false unless junction?
      context_key = context.to_name.key
      absolute_name(context).parent_keys.include? context_key
    end

    def relative?
      starts_with_joint? || s =~ RELATIVE_REGEXP
    end

    def simple_relative?
      stripped.to_name.starts_with_joint?
    end

    def absolute?
      !relative?
    end

    def stripped
      s.gsub RELATIVE_REGEXP, ""
    end

    def starts_with_joint?
      length >= 2 && parts.first.empty?
    end

    def pov *from
      pov_name(*from).s
    end

    def pov_name *from
      remaining = pov_remaining *from
      return self if remaining.compact.empty?
      name = remaining.compact.to_name
      return name if remaining[0]
      (self.class.joint + name.s).to_name
    end

    def pov_remaining *from
      from_name = from.to_name
      from_keys = from_name ? from_name.part_names.map(&:key) : []
      parts_minus from_keys
    end

    def parts_minus keys_to_ignore
      parts.map do |part|
        next if part.empty?
        next if part =~ /^_/ # this removes relative parts.  why?
        next if keys_to_ignore.member? part.to_name.key
        part
      end
    end

    def to_absolute context, args={}
      context = context.to_name
      new_parts = absolutize_contextual_parts context
      return "" if new_parts.empty?
      absolutize_extremes new_parts, context.s
      new_parts.join self.class.joint
    end

    def to_absolute_name *args
      self.class.new to_absolute(*args)
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
        # Eg, `+A+B+.to_absolute('+A')` should be +A+B, not +A+A+B.
        next if new_parts.to_name.send "#{[ :start, :end ][i]}s_with?", context
        new_parts[i] = context
      end
    end

  end
end
