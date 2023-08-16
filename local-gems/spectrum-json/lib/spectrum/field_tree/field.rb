# frozen_string_literal: true

module Spectrum
  module FieldTree
    class Field < Base
      TYPES = {
        'tag'           => Spectrum::FieldTree::Tag,
        'field'         => Spectrum::FieldTree::Field,
        'literal'       => Spectrum::FieldTree::Literal,
        'special'       => Spectrum::FieldTree::Special,
        'value_boolean' => Spectrum::FieldTree::ValueBoolean
      }.freeze

      PHRASE_ONLY_FIELDS = %w[
          search_call_number_starts_with
          search_lc_subject_starts_with
          search_title_starts_with
      ]

      def params(field_map)
        ret = super
        unless @value.empty? || field_map.by_uid(@value).nil?
          ret.merge!(field_map.by_uid(@value).query_params)
        end
        ret
      end


      # Note the special cases for the "starts with" fields
      # TODO: Figure out in which ways call number and title starts-with fields are different
      def query(field_map)
        val = @children.map {|item| item.query(field_map)}.join(' ')
        if @value.empty? || field_map.by_uid(@value).nil? || field_map.by_uid(@value).query_field.empty?
          val
        else
          field = field_map.by_uid(@value).query_field

          quoteless = val.delete('"')
          if field.respond_to?(:map)
            "(#{field.map {|f| "#{f}:(#{val})"}.join(' OR ')})"
          elsif PHRASE_ONLY_FIELDS.include? field
            %Q[#{field}:"#{quoteless}"]
          else
            "#{field}:(#{val})"
          end
        end
      end
    end
  end
end
