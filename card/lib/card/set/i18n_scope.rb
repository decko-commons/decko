class Card
  module Set
    module I18nScope
      # return scope for I18n
      def scope backtrace
        parts = path_parts backtrace
        index = path_set_index parts
        mod = mod_from_parts parts, index
        set = set_from_parts parts, index
        "mod.#{mod}.set.#{set}"
      end

      # extract the mod name from the path of a set's tmp file
      def mod_name backtrace
        parts = path_parts backtrace
        mod_from_parts parts, path_set_index(parts)
      end

      private

      def set_from_parts parts, index
        start_index = index + (tmp_files? ? 2 : 1)
        parts[start_index..-1].join "."
      end

      def mod_from_parts parts, set_index
        if tmp_files?
          mod_from_tmp_parts parts, set_index
        else
          parts[set_index - 1]
        end
      end

      def mod_from_tmp_parts parts, set_index
        parts[set_index + 1].gsub(/^[^-]*\-/, "")
      end

      def path_parts backtrace
        parts = find_set_path(backtrace).split(File::SEPARATOR)
        parts[-1] = parts.last.split(".").first
        parts
      end

      # extract mod and set from real path
      # @example
      #   if the path looks like ~/mydeck/mod/core/set/all/event.rb/
      #   this method returns ["core", "all", "event"]
      # def set_path_parts backtrace
      #   parts = path_parts backtrace
      #   res = parts[path_mod_index(parts)..-1]
      #   res.delete_at 1
      # end

      # extract mod and set from tmp path
      # @example
      #   a tmp path looks like ~/mydeck/tmp/set/mod002-core/all/event.rb/
      #   this method returns ["core", "all", "event"]
      # def tmp_set_path_parts backtrace
      #   path_parts = find_tmp_set_path(backtrace).split(File::SEPARATOR)
      #   res = path_parts[tmp_path_mod_index(path_parts)..-1]
      #   res[0] = mod_name_from_tmp_dir res.first
      #   res[-1] = res.last.split(".").first
      #   res
      # end
      #
      # def find_tmp_set_path backtrace
      #   path = backtrace.find { |line| line.include? "tmp/set/" }
      #   raise Error, "couldn't find set path in backtrace: #{backtrace}" unless path
      #
      #   path
      # end
      #
      #
      def tmp_files?
        Cardio.config.load_strategy == :tmp_files
      end

      def find_set_path backtrace
        re = %r{(?<!card)/set/}
        path = backtrace.find { |line| line =~ re }
        raise Error, "couldn't find set path in backtrace: #{backtrace}" unless path
        path
      end

      # # index of the mod part in the tmp path
      # def tmp_path_mod_index parts
      #   unless (set_index = parts.index("set")) &&
      #          parts.size >= set_index + 2
      #     raise Error, "not a valid set path: #{path}"
      #   end
      #
      #   set_index + 1
      # end

      def mod_name_from_tmp_dir dir
        match = dir.match(/^mod\d+-(?<mod_name>.+)$/)
        match[:mod_name]
      end

      # index of the mod part in the path
      def path_set_index parts
        unless (set_index = parts.index("set")) &&
               parts.size >= set_index + 2
          raise Error, "not a valid set path: #{path}"
        end

        set_index
      end
    end
  end
end
