RSpec.describe ValueObjects::ValidValidator do

  class NilAllowedRecord

    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :foo

    validates :foo, 'value_objects/valid': true, allow_nil: true

  end

  class NilForbiddenRecord

    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :foo

    validates :foo, 'value_objects/valid': true

  end

  let(:valid_value) { instance_double('ValidValue', invalid?: false) }
  let(:invalid_value) { instance_double('InvalidValue', invalid?: true) }

  context 'with allow_nil' do

    let(:record) { NilAllowedRecord.new(foo: value) }

    context 'and nil value' do

      let(:value) { nil }

      it 'passes validation' do
        aggregate_failures do
          expect(record.valid?).to eq(true)
          expect(record.errors).not_to include(:foo)
        end
      end

    end

    context 'and invalid value' do

      let(:value) { invalid_value }

      it 'fails validation' do
        aggregate_failures do
          expect(record.valid?).to eq(false)
          expect(record.errors).to include(:foo)
        end
      end

    end

    context 'and valid value' do

      let(:value) { valid_value }

      it 'passes validation' do
        aggregate_failures do
          expect(record.valid?).to eq(true)
          expect(record.errors).to be_empty
        end
      end

    end

  end

  context 'without allow_nil' do

    let(:validation_options) { { valid: true } }
    let(:record) { NilForbiddenRecord.new(foo: value) }

    context 'and nil value' do

      let(:value) { nil }

      it 'fails validation' do
        aggregate_failures do
          expect(record.valid?).to eq(false)
          expect(record.errors).to include(:foo)
        end
      end

    end

    context 'and invalid value' do

      let(:value) { invalid_value }

      it 'fails validation' do
        aggregate_failures do
          expect(record.valid?).to eq(false)
          expect(record.errors).to include(:foo)
        end
      end

    end

    context 'and valid value' do

      let(:value) { valid_value }

      it 'passes validation' do
        aggregate_failures do
          expect(record.valid?).to eq(true)
          expect(record.errors).to be_empty
        end
      end

    end

  end

  context 'with collection' do

    let(:record) { NilForbiddenRecord.new(foo: values) }

    context 'and no values' do

      let(:values) { [] }

      it 'passes validation' do
        aggregate_failures do
          expect(record.valid?).to eq(true)
          expect(record.errors).to be_empty
        end
      end

    end

    context 'and no invalid values' do

      let(:values) { [value1, value2] }
      let(:value1) { valid_value }
      let(:value2) { valid_value }

      it 'passes validation' do
        expect(value1).to receive(:invalid?).and_return(false).once
        expect(value2).to receive(:invalid?).and_return(false).once
        aggregate_failures do
          expect(record.valid?).to eq(true)
          expect(record.errors).to be_empty
        end
      end

    end

    context 'and some invalid values' do

      let(:values) { [value1, value2, value3] }
      let(:value1) { invalid_value }
      let(:value2) { valid_value }
      let(:value3) { invalid_value }

      it 'fails validation' do
        expect(value1).to receive(:invalid?).and_return(true).once
        expect(value2).to receive(:invalid?).and_return(false).once
        expect(value3).to receive(:invalid?).and_return(true).once
        aggregate_failures do
          expect(record.valid?).to eq(false)
          expect(record.errors).to include(:foo)
        end
      end

    end

  end

end
