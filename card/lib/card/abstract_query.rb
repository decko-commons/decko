class Card
  class AbstractQuery
    attr_reader :statement, :mods, :conditions, :vars, :fasten,
                :subqueries, :superquery, :comment
    attr_accessor :joins, :conditions_on_join, :table_seq

    def initialize statement
      @subqueries = []
      @conditions = []
      @joins = []
      @mods = {}

      @statement = statement.clone

      @context    = @statement.delete(:context) || nil
      @fasten     = @statement.delete(:fasten)  || :join
      @superquery = @statement.delete(:superquery) || nil

      @vars       = initialize_vars
    end

    def initialize_vars
      if (v = @statement.delete :vars) then v.symbolize_keys
      elsif @superquery                then @superquery.vars
      else                                  {}
      end
    end

    def full?
      false
    end

    def sql
      Query::SqlStatement.new(self).build.to_s
    end

    def root
      @root ||= @superquery ? @superquery.root : self
    end

    def subquery opts={}
      klass = opts.delete(:class) || Query
      subquery = klass.new opts.merge(superquery: self)
      @subqueries << subquery
      subquery
    end

    def table_alias
      @table_alias ||= begin
        if fasten == :direct
          @superquery.table_alias
        else
          "#{table_prefix}#{table_id}"
        end
      end
    end

    # generates an id used to identify a table variable in the sql statement
    def table_id force=false
      if force
        tick_table_seq!
      else
        @table_id ||= tick_table_seq!
      end
    end

    def tick_table_seq!
      root.table_seq = root.table_seq.to_i + 1
    end

    def fld field_name
      "#{table_alias}.#{field_name}"
    end

    def all_joins
      @all_joins ||=
        (joins + subqueries.select{|s| s.fasten == :direct }.map(&:all_joins)).flatten
    end
  end
end
