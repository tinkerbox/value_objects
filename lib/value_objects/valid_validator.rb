# frozen_string_literal: true
module ValueObjects

  class ValidValidator < ActiveModel::EachValidator

    def validate_each(record, attribute, value)
      record.errors.add(attribute, :invalid) unless value && [*value].all?(&:valid?)
    end

  end

end
