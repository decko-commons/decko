class Card
  module Query
    # superclass for CardQuery, ReferenceQuery, ActQuery, and ActionQuery
    # handles query hierarchy
    class AbstractQuery
      include QueryHelper
      include Tie

      DEFAULT_FASTEN = :join

      attr_reader :statement, :mods, :conditions, :vars,
                  :subqueries, :superquery, :comment
      attr_accessor :joins, :conditions_on_join, :table_seq, :fasten

      def initialize statement, _comment=nil
        @subqueries = []
        @conditions = []
        @joins = []
        @mods = {}

        @statement = statement.clone
        @context = @statement.delete(:context) || nil
        @superquery = @statement.delete(:superquery) || nil

        @fasten = @statement.delete(:fasten) || DEFAULT_FASTEN
        table_alias

        @vars = initialize_vars
      end

      def initialize_vars
        if (v = @statement.delete :vars) then v.symbolize_keys
        elsif @superquery                then @superquery.vars
        else                                  {}
        end
      end

      def interpret hash
        hash.each do |action, card|
          send action, card
        end
      end

      def full?
        false
      end

      def sql
        @sql ||= Query::SqlStatement.new(self).build.to_s
      end

      def root
        @root ||= @superquery ? @superquery.root : self
      end

      def root?
        root == self
      end

      def subquery opts={}
        klass = opts.delete(:class) || Query
        subquery = klass.new opts.merge(superquery: self)
        @subqueries << subquery
        subquery
      end

      def context
        if !@context.nil?
          @context
        else
          @context = superquery ? superquery.context : ""
        end
      end

      def depth
        @depth ||= case
                   when !superquery       then 0
                   when fasten == :direct then superquery.depth
                   else                        superquery.depth + 1
                   end
      end
    end
  end
end
