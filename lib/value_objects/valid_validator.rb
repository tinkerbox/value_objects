# frozen_string_literal: true
module ValueObjects

  class ValidValidator < ActiveModel::EachValidator

    def validate_each(record, attribute, value)
      record.errors.add(attribute, :invalid) unless value && (value.is_a?(Array) ? value.count(&:invalid?) == 0 : value.valid?)
    end

  end

end
