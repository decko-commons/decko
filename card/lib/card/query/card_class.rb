class Card
  module Query
    module CardClass
      def search spec, comment=nil, &block
        results = ::Card::Query.run(spec, comment)
        results.each(&block) if block_given? && results.is_a?(Array)
        results
      end

      def count_by_cql spec
        spec = spec.clone
        spec.delete(:offset)
        search spec.merge(return: "count")
      end

      def find_each **options, &block
        # this is a copy from rails (3.2.16) and is needed because this
        # is performed by a relation (ActiveRecord::Relation)
        find_in_batches(**options) do |records|
          records.each(&block)
        end
      end

      def find_in_batches **options
        if block_given?
          super do |records|
            yield(records)
            Card::Cache.reset_soft
          end
        else
          super
        end
      end
    end
  end
end
