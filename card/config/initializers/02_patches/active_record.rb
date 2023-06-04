# pluck_in_batches:
#   yields an array of *columns that is at least size
#   batch_size to a block.
#
#   Special case: if there is only one column selected than each batch
#                 will yield an array of columns like [:column, :column, ...]
#                 rather than [[:column], [:column], ...]
# Arguments
#   columns      ->  an arbitrary selection of columns found on the table.
#   batch_size   ->  How many items to pluck at a time
#   &block       ->  A block that processes an array of returned columns.
#                    Array is, at most, size batch_size
#
# Returns
#   nothing is returned from the function

module Patches
  module ActiveRecord
    module Relation
      def pluck_in_batches *columns, batch_size: 1000
        batch_start = nil
        select_columns, id_index, remove_id = prepare_batch_pluck columns

        loop do
          items = pluck_in_batches_items batch_size, batch_start, select_columns
          break if items.empty?

          batch_start = pluck_in_batches_batch_start items, id_index
          cleaned_batch_items items, remove_id
          yield items

          break if items.size < batch_size
        end
      end

      private

      # Remove :id column if not in *columns
      def cleaned_batch_items items, remove_id
        items.map! { |row| row[1..-1] } if remove_id
      end

      def prepare_batch_pluck columns
        raise "There must be at least one column to pluck" if columns.empty?

        # It's cool. We're only taking in symbols
        # no deep clone needed
        select_columns = columns.dup

        # Find index of :id in the array
        remove_id_from_results = false
        id_index = columns.index primary_key.to_sym

        # :id is still needed to calculate offsets
        # add it to the front of the array and remove it when yielding
        if id_index.nil?
          id_index = 0
          select_columns.unshift primary_key

          remove_id_from_results = true
        end

        [select_columns, id_index, remove_id_from_results]
      end

      def pluck_in_batches_batch_start items, id_index
        # Use the last id to calculate where to offset queries
        last_item = items.last
        last_item.is_a?(Array) ? last_item[id_index] : last_item
      end

      def pluck_in_batches_items batch_size, batch_start, select_columns
        relation = reorder(table[primary_key].asc).limit(batch_size)
        relation = relation.where(table[primary_key].gt(batch_start)) if batch_start
        relation.pluck(*select_columns)
      end
    end

    module ConnectionAdapters
      module AbstractAdapter
        def match _string
          raise ::I18n.t(:lib_exception_not_implemented)
        end

        def cast_types
          native_database_types.merge custom_cast_types
        end

        def custom_cast_types
          {}
        end
      end

      module PostgreSQLAdapter
        def match string
          "~* #{string}"
        end
      end

      module Mysql2Adapter
        def match string
          "REGEXP #{string}"
        end

        def custom_cast_types
          { string: { name: "char" },
            integer: { name: "signed" },
            text: { name: "char" },
            float: { name: "decimal" },
            binary: { name: "binary" } }
        end
      end

      module SQLiteAdapter
        def match string
          "REGEXP #{string}"
        end
      end
    end

    module Migration
      module ClassMethods
        def check_pending! connection=::ActiveRecord::Base.connection
          binding.pry
          %i[structure transform].each do |migration_type|
            Cardio::Schema.mode(migration_type) do |paths|
              ::ActiveRecord::Migrator.migrations_paths = paths
              super
            end
          end
        end
      end
    end
  end
end
