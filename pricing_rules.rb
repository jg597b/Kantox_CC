# frozen_string_literal: true

class PricingRules
  TYPES_OF_DISCOUNT = %w[BOGO price percentage].freeze
  PRODUCT_PRICES = {
    'GR1' => 3.11,
    'SR1' => 5.00,
    'CF1' => 11.23
  }.freeze
  def initialize(pricing_rules)
    @pricing_rules = validate(pricing_rules)
  end

  def price_for(item)
    PRODUCT_PRICES[item] || raise(ArgumentError, "Unknown product: #{item}")
  end

  def apply_discount(item, count)
    discount = @pricing_rules[item]
    price = price_for(item)

    return count * price if !discount || count < discount[:threshold]

    case discount[:type]
    when 'percentage'
      count * price * discount[:value]
    when 'price'
      count * discount[:value]
    when 'BOGO'
      (count - (count / discount[:threshold]).ceil) * price
    else
      count * price
    end
  end

  private

  def validate(pricing_rules)
    raise ArgumentError, 'Pricing rules must be a Hash.' unless pricing_rules.is_a?(Hash)

    pricing_rules.each do |product, rule|
      validate_product_format(product)
      validate_rule_format(rule)
    end

    pricing_rules
  end

  def validate_product_format(product)
    return if product.is_a?(String) && !product.empty?

    raise ArgumentError, "Product keys must be non-empty strings. Invalid key: #{product.inspect}"
  end

  def validate_rule_format(rule)
    raise ArgumentError, "Each rule must be a Hash. Invalid rule: #{rule.inspect}" unless rule.is_a?(Hash)

    unless TYPES_OF_DISCOUNT.include?(rule[:type])
      raise ArgumentError, "Invalid type: #{rule[:type]}. Must be one of: #{TYPES_OF_DISCOUNT.join(', ')}"
    end

    unless rule[:threshold].is_a?(Integer) && (rule[:threshold]).positive?
      raise ArgumentError, "Threshold must be a positive integer. Invalid threshold: #{rule[:threshold]}"
    end

    return if rule[:value].is_a?(Numeric) && rule[:value] >= 0

    raise ArgumentError, "Value must be a non-negative number. Invalid value: #{rule[:value]}"
  end
end
