# frozen_string_literal: true
module ValueObjects

  module ActionView

    def self.integrate_with(library)
      require "value_objects/action_view/#{library}"
    end

  end

end
