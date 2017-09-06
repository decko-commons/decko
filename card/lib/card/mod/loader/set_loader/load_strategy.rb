class Card
  module Mod
    module Loader
      class SetLoader
        class LoadStategy < Card::Mod::LoadStrategy
          private
          # yields for every set file with arguments the absolute path, the relative path
          # and the set pattern
          # def each_file &block
          #   @mod_dirs.each :set do |mod_set_path|
          #     Card::Set::Pattern.in_load_order.each do |pattern|
          #       each_file_in_dir "#{mod_set_path}/#{pattern}", &block
          #     end
          #   end
          # end
        end
      end
    end
  end
end
