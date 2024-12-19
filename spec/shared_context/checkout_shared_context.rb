# frozen_string_literal: true

RSpec.shared_context 'checkout system' do
  let(:valid_pricing_rules) do
    {
      'GR1' => { type: 'BOGO', threshold: 2, value: 0 },      # Buy one get one free
      'SR1' => { type: 'price', threshold: 3, value: 4.50 },  # Bulk purchase discount price
      'CF1' => { type: 'percentage', threshold: 3, value: 2 / 3.0 } # Bulk purchase percentage discount
    }
  end

  # Common product prices
  let(:product_prices) do
    {
      'GR1' => 3.11,
      'SR1' => 5.00,
      'CF1' => 11.23
    }
  end

  # Helper method to calculate expected totals
  def calculate_expected_total(items)
    items.group_by(&:itself).sum do |item, occurrences|
      count = occurrences.length
      rule = valid_pricing_rules[item]
      price = product_prices[item]

      if !rule || count < rule[:threshold]
        count * price
      else
        case rule[:type]
        when 'BOGO'
          (count - (count / rule[:threshold]).ceil) * price
        when 'price'
          count * rule[:value]
        when 'percentage'
          count * price * rule[:value]
        end
      end
    end
  end
end
