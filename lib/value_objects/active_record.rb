# frozen_string_literal: true
module ValueObjects

  module ActiveRecord

    def self.included(base)
      base.extend self
    end

    def value_object(attribute, value_class, options = {})
      type =
        begin
          column_for_attribute(attribute)&.type
        rescue ::ActiveRecord::StatementInvalid
          # This can happen if `column_for_attribute` is called but the database table does not exist
          # as will be the case when migrations are run and the model class is loaded by initializers
          # before the table is created.
          # This is a workaround to prevent such migrations from failing.
          nil
        end
      coder =
        case type
        when :string, :text
          JsonCoder.new(value_class)
        else
          value_class
        end
      serialize(attribute, coder)
      validates_with(::ValueObjects::ValidValidator, options.merge(attributes: [attribute])) unless options[:no_validation]
      setter = :"#{attribute}="
      define_method("#{attribute}_attributes=") do |attributes|
        send(setter, value_class.new(attributes))
      end
    end

    class JsonCoder

      EMPTY_ARRAY = [].freeze

      def initialize(value_class)
        @value_class = value_class
      end

      def load(value)
        @value_class.load(JSON.load(value) || EMPTY_ARRAY) if value
      end

      def dump(value)
        value.to_json if value
      end

    end

  end

end
