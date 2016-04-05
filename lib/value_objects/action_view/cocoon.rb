# frozen_string_literal: true
module ValueObjects

  module ActionView

    module Cocoon

      def link_to_add_nested_value(name, f, attribute, value_class, html_options = {}, &block)
        render_options = html_options.delete(:render_options) || {}
        partial = html_options.delete(:partial)
        wrap_object = html_options.delete(:wrap_object)
        form_name = html_options.delete(:form_name) || 'f'
        count = html_options.delete(:count).to_i
        new_object = value_class.new
        new_object = wrap_object.call(new_object) if wrap_object

        html_options[:class] = [html_options[:class], 'add_fields'].compact.join(' ')
        html_options[:'data-association'] = attribute
        html_options[:'data-association-insertion-template'] = CGI.escapeHTML(render_association(attribute, f, new_object, form_name, render_options, partial)).html_safe
        html_options[:'data-count'] = count if count > 0

        name = capture(&block) if block_given?
        dummy_input = tag(:input, type: 'hidden', name: "#{f.object_name}[#{attribute}_attributes][-1][_]")
        content_tag(:a, name, html_options) + dummy_input
      end

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
