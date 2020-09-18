# shared methods for card collections (Pointers, Searches, Sets, etc.)
module ClassMethods
  def search spec, comment=nil
    results = ::Card::Query.run(spec, comment)
    if block_given? && results.is_a?(Array)
      results.each { |result| yield result }
    end
    results
  end

  def count_by_cql spec
    spec = spec.clone
    spec.delete(:offset)
    search spec.merge(return: "count")
  end

  def find_each options={}
    # this is a copy from rails (3.2.16) and is needed because this
    # is performed by a relation (ActiveRecord::Relation)
    # ARDEP: ::Relation
    find_in_batches(options) do |records|
      records.each { |record| yield record }
    end
  end

  def find_in_batches options={}
    if block_given?
      super(options) do |records|
        yield(records)
        Card::Cache.reset_soft
      end
    else
      super(options)
    end
  end
end

def collection?
  item_cards != [self]
end

format do
  view :count do
    card.item_names.size
  end
end

format :html do
  view :carousel do
    bs_carousel unique_id, 0 do
      nest_item_array.each do |rendered_item|
        item(rendered_item)
      end
    end
  end
end
