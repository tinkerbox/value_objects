RSpec.describe ValueObjects::ActiveRecord do

  ActiveRecord::Schema.define(version: 1) do
    self.verbose = false

    create_table :test_records do |t|
      t.string :value, default: ''
      t.string :values, default: ''
    end

  end

  class FooBarValue < ValueObjects::Value

    attr_accessor :foo, :bar
    validates :foo, presence: true

    class Collection < Collection
    end

  end

  class TestRecord < ActiveRecord::Base

    include ValueObjects::ActiveRecord

    value_object :value, FooBarValue, allow_nil: true
    value_object :values, FooBarValue::Collection, allow_nil: true

  end

  describe 'serialization' do

    context 'with non-nil values' do

      let(:value) { FooBarValue.new(foo: '123', bar: 'abc') }
      let(:values) { [FooBarValue.new(foo: 'abc', bar: '123'), FooBarValue.new(foo: 'cba', bar: 321)] }
      let(:record) { TestRecord.create!(value: value, values: values).reload }

      it 'serializes the value object' do
        aggregate_failures do
          expect(record.read_attribute_before_type_cast(:value)).to eq('{"foo":"123","bar":"abc"}')
          expect(record.read_attribute_before_type_cast(:values)).to eq('[{"foo":"abc","bar":"123"},{"foo":"cba","bar":321}]')
        end
      end

      it 'deserializes the value object' do
        aggregate_failures do
          expect(record.read_attribute(:value)).to eq(value)
          expect(record.read_attribute(:values)).to eq(values)
        end
      end

    end

    context 'with nil values' do

      let(:value) { nil }
      let(:values) { nil }
      let(:record) { TestRecord.create!(value: value, values: values).reload }

      it 'serializes the value object' do
        aggregate_failures do
          expect(record.read_attribute_before_type_cast(:value)).to eq(nil)
          expect(record.read_attribute_before_type_cast(:values)).to eq(nil)
        end
      end

      it 'deserializes the value object' do
        aggregate_failures do
          expect(record.read_attribute(:value)).to eq(value)
          expect(record.read_attribute(:values)).to eq(values)
        end
      end

    end

    context 'with blank values' do

      let(:value) { FooBarValue.new }
      let(:values) { [] }
      let(:record) { TestRecord.new.tap { |r| r.save!(validate: false) }.reload }

      it 'deserializes the value object' do
        aggregate_failures do
          expect(record.read_attribute_before_type_cast(:value)).to eq('')
          expect(record.read_attribute_before_type_cast(:values)).to eq('')
          expect(record.read_attribute(:value)).to eq(value)
          expect(record.read_attribute(:values)).to eq(values)
        end
      end

    end

  end

  describe 'validation' do

    let(:record) { TestRecord.new(value: value, values: values).tap(&:valid?) }

    context 'with valid values' do

      let(:value) { FooBarValue.new(foo: '123', bar: 'abc') }
      let(:values) { [FooBarValue.new(foo: 'abc', bar: '123'), FooBarValue.new(foo: 'cba', bar: 321)] }

      it { expect(record.errors).to be_empty }

    end

    context 'with invalid values' do

      let(:value) { FooBarValue.new(foo: '', bar: 'abc') }
      let(:values) { [FooBarValue.new(foo: '', bar: '123'), FooBarValue.new(foo: '', bar: 321)] }

      it { expect(record.errors.keys).to contain_exactly(:value, :values) }

    end

  end

  describe '#value_attributes=' do

    let(:record) { TestRecord.new(value_attributes: value_attributes) }
    let(:value_attributes) { { 'foo': '123', 'bar': 'abc' } }

    it { expect(record.value).to eq(FooBarValue.new(value_attributes)) }

  end

  describe '#values_attributes=' do

    let(:record) { TestRecord.new(values_attributes: values_attributes) }
    let(:values_attributes) { { '0' => { 'foo' => 321, 'bar' => 'cba' }, '1' => { 'foo' => 'abc', 'bar' => 123 } } }

    it { expect(record.values).to eq(FooBarValue::Collection.new(values_attributes)) }

  end

end
