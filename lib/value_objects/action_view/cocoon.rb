# frozen_string_literal: true
module ValueObjects

  module ActionView

    module Cocoon

      def link_to_remove_nested_value(name, html_options = {}, &block)
        wrapper_class = html_options.delete(:wrapper_class)

        html_options[:class] = [html_options[:class], 'remove_fields dynamic'].compact.join(' ')
        html_options[:'data-wrapper-class'] = wrapper_class if wrapper_class

        name = capture(&block) if block_given?
        content_tag(:a, name, html_options)
      end

    end

  end

end

ActionView::Base.send(:include, ValueObjects::ActionView::Cocoon)
