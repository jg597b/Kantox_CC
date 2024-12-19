# frozen_string_literal: true

RSpec.shared_examples 'discount application' do
  context 'when applying BOGO discount' do
    it 'calculates correct price for single item' do
      expect(calculate_expected_total(['GR1'])).to eq(3.11)
    end

    it 'calculates correct price for BOGO threshold' do
      expect(calculate_expected_total(%w[GR1 GR1])).to eq(3.11)
    end
  end

  context 'when applying price discount' do
    it 'calculates correct price for bulk purchase' do
      expect(calculate_expected_total(['SR1'] * 3)).to eq(13.50)
    end
  end

  context 'when applying percentage discount' do
    it 'calculates correct price for bulk purchase' do
      expected = (3 * 11.23 * 2 / 3.0).round(2)
      expect(calculate_expected_total(['CF1'] * 3).round(2)).to eq(expected)
    end
  end
end
