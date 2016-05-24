# frozen_string_literal: true
module ValueObjects

  module ActiveRecord

    def self.included(base)
      base.extend self
    end

    def value_object(attribute, value_class, options = {})
      coder =
        case column_for_attribute(attribute).type
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
