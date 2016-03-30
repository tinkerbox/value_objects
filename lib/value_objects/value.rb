# frozen_string_literal: true
module ValueObjects

  class Value

    include ::ActiveModel::Model
    include ::ActiveModel::Validations

    def ==(other)
      self.class == other.class && self.class.attrs.all? { |key| send(key) == other.send(key) }
    end

    def to_hash
      self.class.attrs.each_with_object({}) { |key, hash| hash[key] = send(key) }
    end

    class << self

      def load(value)
        new(JSON.load(value)) if value
      end

      def dump(value)
        value.to_json if value
      end

      def i18n_scope
        :value_objects
      end

      attr_reader :attrs

      private

      def attr_accessor(*args)
        (@attrs ||= []).concat(args)
        super(*args)
      end

    end

    class Collection

      class << self

        def inherited(subclass)
          subclass.instance_variable_set(:@value_class, subclass.parent)
        end

        def new(attributes)
          # Data encoded with the 'application/x-www-form-urlencoded' media type cannot represent empty collections.
          # As a workaround, a dummy item can be added to the collection with it's key set to '-1'.
          # This dummy item will be ignored when initializing the value collection.
          values = []
          attributes.each { |k, v| values << @value_class.new(v) if k != '-1' }
          values
        end

        def load(values)
          values.blank? ? [] : JSON.load(values).map { |value| @value_class.new(value) } if values
        end

        def dump(values)
          values.to_json if values
        end

      end

    end

  end

end
