class Cardname
  module Manipulate
    # replace a subname
    # keys are used for comparison
    def replace old, new
      old_name = old.to_name
      new_name = new.to_name
      return self if old_name.length > length
      return replace_part(old_name, new_name) if old_name.simple?
      return self unless include? old_name
      replace_all_subsequences(old_name, new_name).to_name
    end

    def replace_part oldpart, newpart
      ensure_simpliness oldpart, "Use 'replace' to replace junctions"

      oldpart = oldpart.to_name
      newpart = newpart.to_name

      parts.map do |p|
        oldpart == p ? newpart : p
      end.to_name
    end

    def replace_piece oldpiece, newpiece
      oldpiece = oldpiece.to_name
      newpiece = newpiece.to_name

      return replace_part oldpiece, newpiece if oldpiece.simple?
      return self unless self.starts_with?(oldpiece)
      return newpiece if oldpiece.length == length
      newpiece + self[oldpiece.length..-1]
    end

    private

    def replace_all_subsequences oldseq, newseq
      res = []
      i = 0
      while i <= length - oldseq.length
        # for performance reasons: check first character first then the rest
        if oldseq.part_keys.first == part_keys[i] &&
           oldseq.part_keys == part_keys[i, oldseq.length]
          res += newseq.parts
          i += oldseq.length
        else
          res << parts[i]
          i += 1
        end
      end
      res += parts[i..-1] if i < length
      res
    end

    def ensure_simpliness part, msg=nil
      return if part.to_name.simple?
      raise StandardError, "'#{part}' has to be simple. #{msg}"
    end
  end

  # ~~~~~~~~~~~~~~~~~~~~ MISC ~~~~~~~~~~~~~~~~~~~~

  # HACK. This doesn't belong here.
  # shouldn't it use inclusions???
  def self.substitute! str, hash
    hash.keys.each do |var|
      str.gsub! var_re do |x|
        hash[var.to_sym]
      end
    end
    str
  end
end
