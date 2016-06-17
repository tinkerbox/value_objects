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
  let(:link_association) { link.attribute('data-association')&.value }
  let(:link_association_insertion_template) { link.attribute('data-association-insertion-template')&.value }
  let(:link_data_count) { link.attribute('data-count')&.value }
  let(:link_wrapper_class) { link.attribute('data-wrapper-class')&.value }
  let(:input) { body.at('input') }
  let(:input_type) { input.attribute('type')&.value }
  let(:input_name) { input.attribute('name')&.value }

  describe '#link_to_add_nested_value' do

    shared_examples_for 'link_to_add' do |options|

      it 'renders the link correctly' do
        aggregate_failures do
          expect(body.children).to contain_exactly(link, input)
          expect(link_text).to eq(options[:text])
          expect(link_class).to eq(options[:class])
          expect(link_association).to eq(options[:association])
          expect(link_association_insertion_template).to eq(template)
          expect(link_data_count).to eq(options[:count])
          expect(link_href).to eq(nil)
          expect(input_type).to eq('hidden')
          expect(input_name).to eq(input_name)
        end
      end

    end

    before { expect(test_view).to receive(:render_association).and_return(template) }
    let(:template) { '<div class="nested_fields"></div>' }

    let(:html) { test_view.link_to_add_nested_value(*args, &block) }
    let(:args) { [name, form, attribute, value_class] + [options].compact }
    let(:name) { nil }
    let(:form) { double(object_name: 'form[test_record]') }
    let(:attribute) { :test_values }
    let(:value_class) { ValueObjects::Base }
    let(:options) { nil }
    let(:block) { nil }
    let(:input_name) { "#{form.object_name}[#{attribute}_attributes][-1][_]" }

    include_examples 'link_to_add', text: '', class: 'add_fields', association: 'test_values'

    context 'with name' do

      let(:name) { 'Some text ...' }

      include_examples 'link_to_add', text: 'Some text ...', class: 'add_fields', association: 'test_values'

      context 'and block' do

        let(:block) { -> { 'Block text' } }

        include_examples 'link_to_add', text: 'Block text', class: 'add_fields', association: 'test_values'

      end

    end

    context 'with class' do

      let(:options) { { class: classes } }
      let(:classes) { 'foo bar' }

      include_examples 'link_to_add', text: '', class: 'foo bar add_fields', association: 'test_values'

      context 'as an array' do

        let(:classes) { %w( foo bar ) }

        include_examples 'link_to_add', text: '', class: 'foo bar add_fields', association: 'test_values'

      end

    end

    context 'with count' do

      let(:options) { { count: 2 } }

      include_examples 'link_to_add', text: '', class: 'add_fields', association: 'test_values', count: '2'

    end

    context 'with wrap_object' do

      let(:options) { { wrap_object: wrapper } }
      let(:wrapper) do
        double.tap do |d|
          expect(d).to receive(:call) do |obj|
            expect(obj).to be_a(ValueObjects::Base)
          end.once
        end
      end

      include_examples 'link_to_add', text: '', class: 'add_fields', association: 'test_values'

    end

    context 'with other attribute' do

      let(:attribute) { 'foobars' }

      include_examples 'link_to_add', text: '', class: 'add_fields', association: 'foobars'

    end

    context 'with all args' do

      let(:name) { 'text' }
      let(:attribute) { 'value' }
      let(:options) { { class: 'bar foo', count: 3, wrap_object: double(call: nil) } }

      include_examples 'link_to_add', text: 'text', class: 'bar foo add_fields', association: 'value', count: '3'

    end

  end

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
