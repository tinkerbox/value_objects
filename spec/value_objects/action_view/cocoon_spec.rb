load 'value_objects/action_view/cocoon.rb' # this module is dynamically loaded

RSpec.describe ValueObjects::ActionView::Cocoon do

  class TestView < ActionView::Base
  end

  let(:test_view) { TestView.new }
  let(:body) { Nokogiri::HTML(html).at('body') }
  let(:link) { body.at('a') }
  let(:link_text) { link.text }
  let(:link_href) { link.attribute('href')&.value }
  let(:link_class) { link.attribute('class')&.value }
  let(:link_wrapper_class) { link.attribute('data-wrapper-class')&.value }

  describe '#link_to_remove_nested_value' do

    shared_examples_for 'link_to_remove' do |options|

      it 'renders the link correctly' do
        aggregate_failures do
          expect(body.children).to contain_exactly(link)
          expect(link_text).to eq(options[:text])
          expect(link_class).to eq(options[:class])
          expect(link_wrapper_class).to eq(options[:wrapper_class])
          expect(link_href).to eq(nil)
        end
      end

    end

    let(:html) { test_view.link_to_remove_nested_value(*args, &block) }
    let(:args) { [name] + [options].compact }
    let(:name) { nil }
    let(:options) { nil }
    let(:block) { nil }

    include_examples 'link_to_remove', text: '', class: 'remove_fields dynamic'

    context 'with name' do

      let(:name) { 'Some text ...' }

      include_examples 'link_to_remove', text: 'Some text ...', class: 'remove_fields dynamic'

      context 'and block' do

        let(:block) { -> { 'Block text' } }

        include_examples 'link_to_remove', text: 'Block text', class: 'remove_fields dynamic'

      end

    end

    context 'with class' do

      let(:options) { { class: classes } }
      let(:classes) { 'foo bar' }

      include_examples 'link_to_remove', text: '', class: 'foo bar remove_fields dynamic'

      context 'as an array' do

        let(:classes) { %w( foo bar ) }

        include_examples 'link_to_remove', text: '', class: 'foo bar remove_fields dynamic'

      end

    end

    context 'with wrapper_class' do

      let(:options) { { wrapper_class: 'sub-fields' } }

      include_examples 'link_to_remove', text: '', class: 'remove_fields dynamic', wrapper_class: 'sub-fields'

    end

    context 'with all args' do

      let(:name) { 'text' }
      let(:options) { { class: 'bar foo', wrapper_class: 'fields' } }

      include_examples 'link_to_remove', text: 'text', class: 'bar foo remove_fields dynamic', wrapper_class: 'fields'

    end

  end

end

# cleanup to avoid interfering with other specs
ValueObjects::ActionView.send(:remove_const, :Cocoon)
