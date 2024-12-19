# frozen_string_literal: true

require './pricing_rules'

RSpec.describe PricingRules do
  include_context 'checkout system'

  describe '#initialize' do
    context 'with valid rules' do
      it 'creates a new instance' do
        expect { described_class.new(valid_pricing_rules) }.not_to raise_error
      end
    end

    context 'with invalid rules' do
      it 'raises error when rules is not a hash' do
        expect { described_class.new([]) }
          .to raise_error(ArgumentError, 'Pricing rules must be a Hash.')
      end

      it 'raises error for invalid product key type' do
        invalid_rules = { 123 => { type: 'BOGO', threshold: 2, value: 0 } }
        expect { described_class.new(invalid_rules) }
          .to raise_error(ArgumentError, /Product keys must be non-empty strings/)
      end

      it 'raises error for empty product key' do
        invalid_rules = { '' => { type: 'BOGO', threshold: 2, value: 0 } }
        expect { described_class.new(invalid_rules) }
          .to raise_error(ArgumentError, /Product keys must be non-empty strings/)
      end

      it 'raises error when rule is not a hash' do
        invalid_rules = { 'GR1' => 'invalid' }
        expect { described_class.new(invalid_rules) }
          .to raise_error(ArgumentError, /Each rule must be a Hash/)
      end

      it 'raises error for invalid discount type' do
        invalid_rules = { 'GR1' => { type: 'invalid', threshold: 2, value: 0 } }
        expect { described_class.new(invalid_rules) }
          .to raise_error(ArgumentError, /Invalid type: invalid/)
      end

      it 'raises error for invalid threshold type' do
        invalid_rules = { 'GR1' => { type: 'BOGO', threshold: 'invalid', value: 0 } }
        expect { described_class.new(invalid_rules) }
          .to raise_error(ArgumentError, /Threshold must be a positive integer/)
      end

      it 'raises error for negative threshold' do
        invalid_rules = { 'GR1' => { type: 'BOGO', threshold: -1, value: 0 } }
        expect { described_class.new(invalid_rules) }
          .to raise_error(ArgumentError, /Threshold must be a positive integer/)
      end

      it 'raises error for invalid value type' do
        invalid_rules = { 'GR1' => { type: 'BOGO', threshold: 2, value: 'invalid' } }
        expect { described_class.new(invalid_rules) }
          .to raise_error(ArgumentError, /Value must be a non-negative number/)
      end

      it 'raises error for negative value' do
        invalid_rules = { 'GR1' => { type: 'BOGO', threshold: 2, value: -1 } }
        expect { described_class.new(invalid_rules) }
          .to raise_error(ArgumentError, /Value must be a non-negative number/)
      end
    end
  end

  describe '#price_for' do
    let(:pricing_rules) { described_class.new(valid_pricing_rules) }

    it 'returns correct price for GR1' do
      expect(pricing_rules.price_for('GR1')).to eq(3.11)
    end

    it 'returns correct price for SR1' do
      expect(pricing_rules.price_for('SR1')).to eq(5.00)
    end

    it 'returns correct price for CF1' do
      expect(pricing_rules.price_for('CF1')).to eq(11.23)
    end

    it 'raises error for unknown product' do
      expect { pricing_rules.price_for('XXX') }
        .to raise_error(ArgumentError, 'Unknown product: XXX')
    end
  end

  describe '#apply_discount' do
    let(:pricing_rules) { described_class.new(valid_pricing_rules) }
    it_behaves_like 'discount application' do
      let(:pricing_rules) { described_class.new(valid_pricing_rules) }
    end
    context 'with no discount rule' do
      let(:no_discount_rules) do
        {
          'GR1' => { type: 'BOGO', threshold: 2, value: 0 } # Only GR1 has a rule
        }
      end
      let(:pricing_rules) { described_class.new(no_discount_rules) }

      it 'applies regular price when no discount rule exists' do
        expect(pricing_rules.apply_discount('SR1', 3)).to eq(15.00)
      end
    end
  end
end
