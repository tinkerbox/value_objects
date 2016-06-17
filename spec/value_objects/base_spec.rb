RSpec.describe ValueObjects::Base do

  class TestValue < ValueObjects::Base

    attr_accessor :foo, :bar
    validates :foo, presence: true

    class Collection < Collection
    end

  end

  class OtherTestValue < ValueObjects::Base

    attr_accessor :foo, :bar
    validates :foo, presence: true

    class Collection < Collection
    end

  end

  describe '#==' do

    it { expect(TestValue.new(foo: 'abc', bar: 123)).to eq(TestValue.new(foo: 'abc', bar: 123)) }
    it { expect(TestValue.new(foo: 'abc', bar: 123)).not_to eq(OtherTestValue.new(foo: 'abc', bar: 123)) }
    it { expect(TestValue.new(foo: 'abc', bar: '123')).not_to eq(TestValue.new(foo: 'abc', bar: 123)) }
    it { expect(TestValue.new(foo: 'abc', bar: '123')).not_to eq(nil) }

  end

  describe '#to_hash' do

    it { expect(TestValue.new.to_hash).to eq(foo: nil, bar: nil) }
    it { expect(TestValue.new(foo: 'abc', bar: 123).to_hash).to eq(foo: 'abc', bar: 123) }

  end

  describe 'validation' do

    let(:value) { TestValue.new.tap(&:valid?) }

    it { expect(value.errors.keys).to contain_exactly(:foo) }

  end

  describe '::load' do

    context 'with nil value' do

      let(:value) { TestValue.load(nil) }

      it { expect(value).to eq(nil) }

    end

    context 'with empty value' do

      let(:value) { TestValue.load({}) }

      it { expect(value).to eq(TestValue.new) }

    end

    context 'with non-empty value' do

      let(:value) { TestValue.load('foo' => 321, 'bar' => 'cba') }

      it { expect(value).to eq(TestValue.new(foo: 321, bar: 'cba')) }

    end

  end

  describe '::dump' do

    context 'with nil value' do

      let(:value) { TestValue.dump(nil) }

      it { expect(value).to eq(nil) }

    end

    context 'with empty value' do

      let(:value) { TestValue.dump(TestValue.new) }

      it { expect(value).to eq(foo: nil, bar: nil) }

    end

    context 'with non-empty value' do

      let(:value) { TestValue.dump(TestValue.new(foo: 321, bar: 'cba')) }

      it { expect(value).to eq(foo: 321, bar: 'cba') }

    end

  end

  describe '::i18n_scope' do

    it { expect(TestValue.i18n_scope).to be_a(Symbol) }

  end

  describe 'Collection::new' do

    context 'with empty value' do

      let(:value) { TestValue::Collection.new({}) }

      it { expect(value).to eq([]) }

    end

    context 'with non-empty value' do

      let(:value) { TestValue::Collection.new('0' => { 'foo' => 321, 'bar' => 'cba' }, '1' => { 'foo' => 'abc', 'bar' => 123 }) }

      it { expect(value).to eq([TestValue.new(foo: 321, bar: 'cba'), TestValue.new(foo: 'abc', bar: 123)]) }

    end

    context 'with non-empty value containing dummy item' do

      let(:value) { TestValue::Collection.new('0' => { 'foo' => 321, 'bar' => 'cba' }, '-1' => { 'foo' => 'abc', 'bar' => 123 }) }

      it { expect(value).to eq([TestValue.new(foo: 321, bar: 'cba')]) }

    end

  end

  describe 'Collection::load' do

    context 'with nil value' do

      let(:value) { TestValue::Collection.load(nil) }

      it { expect(value).to eq(nil) }

    end

    context 'with empty value' do

      let(:value) { TestValue::Collection.load([]) }

      it { expect(value).to eq([]) }

    end

    context 'with non-empty value' do

      let(:value) { TestValue::Collection.load([{ 'foo' => 321, 'bar' => 'cba' }, { 'foo' => 'abc', 'bar' => 123 }]) }

      it { expect(value).to eq([TestValue.new(foo: 321, bar: 'cba'), TestValue.new(foo: 'abc', bar: 123)]) }

    end

  end

  describe 'Collection::dump' do

    context 'with nil value' do

      let(:values) { TestValue::Collection.dump(nil) }

      it { expect(values).to eq(nil) }

    end

    context 'with empty array' do

      let(:values) { TestValue::Collection.dump([]) }

      it { expect(values).to eq([]) }

    end

    context 'with non-empty array' do

      let(:values) { TestValue::Collection.dump([TestValue.new(foo: 123, bar: 'abc'), TestValue.new(foo: 'cba', bar: 321)]) }

      it { expect(values).to eq([{ foo: 123, bar: 'abc' }, { foo: 'cba', bar: 321 }]) }

    end

  end

end
