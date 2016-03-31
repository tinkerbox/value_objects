# frozen_string_literal: true
module ValueObjects

  module ActionView

    module Cocoon
    end

  end

end

ActionView::Base.send(:include, ValueObjects::ActionView::Cocoon)
