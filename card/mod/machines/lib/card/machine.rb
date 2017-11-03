class Card
  module Machine
    class << self
      def refresh_script_and_style
        update_if_source_file_changed Card[:all, :script]
        update_if_source_file_changed Card[:all, :style]
      end

      private

      # regenerates the machine output if a source file of a input card
      # has been changed
      def update_if_source_file_changed machine_card
        return unless (mtime_output = machine_card&.machine_output_card&.updated_at)
        regenerate = false
        input_cards_with_source_files(machine_card) do |i_card, files|
          files.each do |path|
            next unless File.mtime(path) > mtime_output
            i_card.expire_machine_cache
            regenerate = true
            break
          end
        end
        return unless regenerate
        machine_card.regenerate_machine_output
      end

      def input_cards_with_source_files card
        card.machine_input_card.extended_item_cards.each do |i_card|
          next unless i_card.codename
          next unless i_card.respond_to?(:existing_source_paths)
          yield i_card, i_card.existing_source_paths
        end
      end

      def source_files card
        files = []
        card.machine_input_card.extended_item_cards.each do |i_card|
          next unless i_card.codename
          next unless i_card.respond_to?(:existing_source_paths)
          files << i_card.existing_source_paths
        end
        files.flatten
      end
    end
  end
end