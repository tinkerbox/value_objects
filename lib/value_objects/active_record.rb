# frozen_string_literal: true
module ValueObjects

  module ActiveRecord

    def self.included(base)
      base.extend self
    end

    def value_object(attribute, value_class)
      serialize(attribute, value_class)
      validates_with(::ValueObjects::ValidValidator, attributes: [attribute])
      setter = :"#{attribute}="
      define_method("#{attribute}_attributes=") do |attributes|
        send(setter, value_class.new(attributes))
      end
    end

  end

end
