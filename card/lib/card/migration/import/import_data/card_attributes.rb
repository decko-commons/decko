class Card
  class Migration
    class Import
      class ImportData
       # handles card attributes for import
       module CardAttributes
         def card_attributes data
           card_attr = ::Set.new [:name, :type, :codename, :file, :image]
           data.select { |k, v| v && card_attr.include?(k) }
         end

         def update_card_attributes card_data
           card_entry = find_card_attributes card_data[:name]
           # we only want strings and not the whole name objects
           # for name and type
           card_data[:name] = card_data[:name].to_s
           card_data[:type] = card_data[:type].to_s
           if card_entry
             card_entry.replace card_data
           else
             cards << card_data
           end
         end

         def update_attribute name, attr_key, attr_value
           card = find_card_attributes name
           return unless card
           card[attr_key] = attr_value
           card
         end

         def write_attributes
           File.write @path, @data.to_yaml
         rescue SystemCallError
           false
           # card.yml not written
         end

         def read_attributes
           ensure_path
           return { cards: [], remotes: {} } unless File.exist? @path
           YAML.load_file(@path).deep_symbolize_keys
         end

         def find_card_attributes name
           key = name.to_name.key
           cards.find do |attr|
             key == (attr[:key].present? ? attr[:key] : attr[:name].to_name.key)
           end
         end

         private

         def ensure_path
           dir = File.dirname(@path)
           FileUtils.mkpath dir unless Dir.exist? dir
         end
       end
      end
    end
  end
end
