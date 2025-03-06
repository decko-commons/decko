# lib/my_custom_scanner.rb
# require "i18n/tasks/scanners/file_scanner"
# class Card
#   module Set
#     class I18nScanner < ::I18n::Tasks::Scanners::FileScanner
#       include ::I18n::Tasks::Scanners::RelativeKeys
#       include ::I18n::Tasks::Scanners::OccurrenceFromPosition
#
#       # @return [Array<[absolute key, Results::Occurrence]>]
#       def scan_file path
#         text = read_file(path)
#
#         # tr()
#         text.scan(/[^\w._-]tr[( ]\s*["':](\w+)/).map do |_match|
#           occurrence = occurrence_from_position(
#             path, text, Regexp.last_match.offset(0).first
#           )
#           [absolute_key(".#{_match[0]}", path), occurrence]
#         end
#       end
#     end
#     ::I18n::Tasks.add_scanner "Card::Set::I18nScanner"
#   end
# end
