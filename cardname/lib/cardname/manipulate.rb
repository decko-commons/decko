class Cardname
  # methods for altering name
  module Manipulate
    # alter cardname based on card index
    # @return [Cardname]
    def []= index, val
      p = parts
      p[index] = val
      replace self.class.new(p)
    end

    # append part to cardname
    # @return [Cardname]
    def << val
      replace self.class.new(parts << val)
    end

    # swap one name for another (keys are used for comparison)
    # @return [Cardname]
    def swap old, new
      old_name = old.to_name
      new_name = new.to_name

      if old_name.num_parts > num_parts
        self
      elsif old_name.simple?
        swap_part old_name, new_name
      elsif include? old_name
        swap_all_subsequences(old_name, new_name).to_name
      else
        self
      end
    end

    # add a joint to name's beginning (if it doesn't already start with one)
    # @return [String]
    def prepend_joint
      joint = self.class.joint
      self =~ /^#{Regexp.escape joint}/ ? self : (joint + self)
    end
    alias_method :to_field, :prepend_joint

    # substitute name, where it appears in str, with new string
    # @return [String]
    def sub_in str, with:
      %i[capitalize downcase].product(%i[pluralize singularize])
                             .inject(str) do |s, (m1, m2)|
        s.gsub(/\b#{send(m1).send(m2)}\b/, with.send(m1).send(m2))
      end
    end

    private

    def swap_part oldpart, newpart
      parts.map { |p| oldpart == p ? newpart : p }.to_name
    end

    def swap_all_subsequences oldseq, newseq
      res = []
      i = 0
      while i <= num_parts - oldseq.num_parts
        # for performance reasons: check first character first then the rest
        if oldseq.part_keys.first == part_keys[i] &&
           oldseq.part_keys == part_keys[i, oldseq.num_parts]
          res += newseq.parts
          i += oldseq.num_parts
        else
          res << parts[i]
          i += 1
        end
      end
      res += parts[i..-1] if i < num_parts
      res
    end
  end
end
