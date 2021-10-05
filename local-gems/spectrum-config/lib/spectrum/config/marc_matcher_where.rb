module Spectrum
  module Config
    class MarcMatcherWhere
      attr_accessor :clauses

      def initialize(clauses)
        self.clauses = (clauses || []).map do |clause|
          MarcMatcherWhereClause.new(clause)
        end
      end

      def match?(field)
        return true if clauses.empty?
        clauses.all? { |clause| clause.match?(field) }
      end
    end
  end
end
