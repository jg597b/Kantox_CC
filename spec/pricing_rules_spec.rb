# frozen_string_literal: true
require './pricing_rules'

RSpec.describe PricingRules do
  let(:valid_pricing_rules) do
    {
      'GR1' => { type: 'BOGO', threshold: 2, value: 0 },
      'SR1' => { type: 'price', threshold: 3, value: 4.50 },
      'CF1' => { type: 'percentage', threshold: 3, value: 2/3.0 }
    }
  end

  describe '#initialize' do
    context 'with valid rules' do
      it 'creates a new instance' do
        expect { described_class.new(valid_pricing_rules) }.not_to raise_error
      end
    end

    context 'with invalid rules' do
      it 'raises error when rules is not a hash' do
        expect { described_class.new([]) }
          .to raise_error(ArgumentError, "Pricing rules must be a Hash.")
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
        .to raise_error(ArgumentError, "Unknown product: XXX")
    end
  end

  describe '#apply_discount' do
    let(:pricing_rules) { described_class.new(valid_pricing_rules) }

    context 'with BOGO discount' do
      it 'applies no discount for single item' do
        expect(pricing_rules.apply_discount('GR1', 1)).to eq(3.11)
      end

      it 'applies BOGO discount for two items' do
        expect(pricing_rules.apply_discount('GR1', 2)).to eq(3.11)
      end

      it 'applies BOGO discount for three items' do
        expect(pricing_rules.apply_discount('GR1', 3)).to eq(6.22)
      end

      it 'applies BOGO discount for four items' do
        expect(pricing_rules.apply_discount('GR1', 4)).to eq(6.22)
      end
    end

    context 'with price discount' do
      it 'applies no discount below threshold' do
        expect(pricing_rules.apply_discount('SR1', 2)).to eq(10.00)
      end

      it 'applies price discount at threshold' do
        expect(pricing_rules.apply_discount('SR1', 3)).to eq(13.50)
      end

      it 'applies price discount above threshold' do
        expect(pricing_rules.apply_discount('SR1', 4)).to eq(18.00)
      end
    end

    context 'with percentage discount' do
      it 'applies no discount below threshold' do
        expect(pricing_rules.apply_discount('CF1', 2)).to eq(22.46)
      end

      it 'applies percentage discount at threshold' do
        expected = (3 * 11.23 * 2/3.0).round(2)
        expect(pricing_rules.apply_discount('CF1', 3).round(2)).to eq(expected)
      end

      it 'applies percentage discount above threshold' do
        expected = (4 * 11.23 * 2/3.0).round(2)
        expect(pricing_rules.apply_discount('CF1', 4).round(2)).to eq(expected)
      end
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