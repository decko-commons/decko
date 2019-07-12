# -*- encoding : utf-8 -*-

require "uri/common"

class Card
  class Content < SimpleDelegator
    # A chunk is a pattern of text that can be protected
    # and interrogated by a format. Each Chunk class has a
    # +pattern+ that states what sort of text it matches.
    # Chunks are initalized by passing in the result of a
    # match by its pattern.
    #
    module Chunk
      mattr_accessor :raw_list, :prefix_regexp_by_list,
                     :prefix_map_by_list, :prefix_map_by_chunkname
      @@raw_list = {}
      @@prefix_regexp_by_list = {}
      @@prefix_map_by_chunkname = {}
      @@prefix_map_by_list = Hash.new { |h, k| h[k] = {} }

      class << self
        def register_class klass, hash
          klass.config = hash.merge class: klass
          prefix_index = hash[:idx_char] || :default
          # ^ this is gross and needs to be moved out.

          klassname = klass.name.split("::").last.to_sym
          prefix_map_by_chunkname[klassname] = { prefix_index => klass.config }
          raw_list.each do |key, list|
            next unless list.include? klassname

            prefix_map_by_list[key].merge! prefix_map_by_chunkname[klassname]
          end
        end

        def register_list key, list
          raw_list[key] = list
          prefix_map_by_list[key] =
            list.each_with_object({}) do |chunkname, h|
              next unless (p_map = prefix_map_by_chunkname[chunkname])

              h.merge! p_map
            end
        end

        def find_class_by_prefix prefix, chunk_list_key=:default
          validate_chunk_list_key chunk_list_key

          prefix_map = prefix_map_by_list[chunk_list_key]
          config = prefix_map[prefix[0, 1]] ||
                   prefix_map[prefix[-1, 1]] ||
                   prefix_map[:default]
          # prefix identified by first character, last character, or default.
          # a little ugly...

          config[:class]
        end

        def prefix_regexp chunk_list_key
          prefix_regexp_by_list[chunk_list_key] ||=
            build_prefix_regexp chunk_list_key
        end

        def build_prefix_regexp chunk_list_key
          validate_chunk_list_key chunk_list_key

          prefix_res =
            raw_list[chunk_list_key].map do |chunkname|
              chunk_class = const_get chunkname
              chunk_class.config[:prefix_re]
            end
          /(?:#{ prefix_res * '|' })/m
        end

        def validate_chunk_list_key chunk_list_key
          unless raw_list.key? chunk_list_key
            raise ArgumentError, "invalid chunk list key: #{chunk_list_key}"
          end
        end
      end

      # not sure whether this is best place.
      # Could really happen almost anywhere
      # (even before chunk classes are loaded).
      register_list :default, %i[
        URI HostURI EmailURI EscapedLiteral Nest Link
      ]
      register_list :references,  %i[EscapedLiteral Nest Link]
      register_list :nest_only, [:Nest]
      register_list :query, [:QueryReference]
      register_list :stub, [:ViewStub]

      class Abstract
        class_attribute :config
        attr_reader :text, :process_chunk

        class << self
          # if the prefix regex matched check that chunk against the full regex
          def full_match content, prefix=nil
            content.match full_re(prefix)
          end

          def full_re _prefix
            config[:full_re]
          end

          def context_ok? _content, _chunk_start
            true
          end
        end

        def reference_code
          "I"
        end

        def initialize match, content
          match = self.class.full_match(match) if match.is_a? String
          @text = match[0]
          @processed = nil
          @content = content
          interpret match, content
          self
        end

        def interpret _match_string, _content
          Rails.logger.info "no #interpret method found for chunk class: " \
                            "#{self.class}"
        end

        def format
          @content.format
        end

        def card
          @content.card
        end

        def to_s
          result
        end

        def result
          burn_read || @process_chunk || @processed || @text
        end

        def burn_read
          return unless @burn_read

          tmp = @burn_read
          @burn_read = nil
          tmp
        end

        # Temporarily overrides the processed nest content for single-use
        # After using the nest's result
        # (for example via `to_s`) the original result is restored
        def burn_after_reading text
          @burn_read = text
        end

        def inspect
          "<##{self.class}##{self}>"
        end

        def as_json _options={}
          burn_read || @process_chunk || @processed ||
            "not rendered #{self.class}, #{card&.name}"
        end
      end
    end
  end
  Card::Mod::Loader.load_chunks
end
