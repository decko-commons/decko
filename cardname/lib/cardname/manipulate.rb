class Cardname
  module Manipulate
    # swap a subname
    # keys are used for comparison
    def swap old, new
      old_name = old.to_name
      new_name = new.to_name
      return self if old_name.num_parts > num_parts
      return swap_part(old_name, new_name) if old_name.simple?
      return self unless include? old_name

      swap_all_subsequences(old_name, new_name).to_name
    end

    def swap_part oldpart, newpart
      ensure_simpleness oldpart, "Use 'swap' to swap junctions"

      oldpart = oldpart.to_name
      newpart = newpart.to_name

      parts.map do |p|
        oldpart == p ? newpart : p
      end.to_name
    end

    def swap_piece oldpiece, newpiece
      oldpiece = oldpiece.to_name
      newpiece = newpiece.to_name

      return swap_part oldpiece, newpiece if oldpiece.simple?
      return self unless starts_with_parts?(oldpiece)
      return newpiece if oldpiece.num_parts == num_parts

      self.class.new [newpiece, self[oldpiece.num_parts..-1]].flatten
    end

    def num_parts
      parts.length
    end

    def [] *args
      self.class.new part_names[*args]
    end

    def prepend_joint
      joint = self.class.joint
      self =~ /^#{Regexp.escape joint}/ ? self : (joint + self)
    end

    def sub_in str, with:
      %i[capitalize downcase].product(%i[pluralize singularize])
                             .inject(str) do |s, (m1, m2)|
        s.gsub(/\b#{send(m1).send(m2)}\b/, with.send(m1).send(m2))
      end
    end

    alias_method :to_field, :prepend_joint

    private

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

    def ensure_simpleness part, msg=nil
      return if part.to_name.simple?

      raise StandardError, "'#{part}' has to be simple. #{msg}"
    end
  end
end
