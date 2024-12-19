# frozen_string_literal: true
require './pricing_rules'

class Checkout
  def initialize(pricing_rules)
    @items = []
    @pricing_rules = PricingRules.new(pricing_rules)
  end

  def scan(item)
    @items << item
    self
  end

  def total
    calculate_total
  end

  private

  def calculate_total
    return 0 if @items.empty?
    total=0
    grouped_items=@items.group_by { |item| item }
    grouped_items.each do |item, type|
      count = type.count
      discount = @pricing_rules.apply_discount(item,count)
      total+=discount
      puts "#{item}: #{count}   Subtotal for #{item}: #{discount.round(2)} "
    end
    puts "Total: #{total.round(2)}"
  end

end
