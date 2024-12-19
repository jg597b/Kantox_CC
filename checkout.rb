# frozen_string_literal: true

class Checkout

  PRODUCT_PRICES = {
    'GR1' => 3.11,
    'SR1' => 5.00,
    'CF1' => 11.23
  }

  DISCOUNTS={
    'GR1' => {
      type: 'buy x get one discount',
      threshold: 2,
      value: 0
    },
    'SR1' => {
      type: 'price',
      threshold: 3,
      value: 4.50
    },
    'CF1' => {
      type: 'percentage',
      threshold: 3,
      value: 0.666
    }
  }


  def initialize
    @items = []
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
      price = PRODUCT_PRICES[item]
      count = type.count
      discount = apply_discount(item,price,count)
      total+=discount
      puts "#{item}: #{count} price: #{price}  Subtotal for #{item}: #{discount.round(2)} "
    end
    puts "Total: #{total.round(2)}"
  end

  def apply_discount(item,price,count)
    discount = DISCOUNTS[item]
    return count * price if count < discount[:threshold]
    case discount[:type]
    when 'percentage'
      count * (price * (1 - discount[:value]))
    when 'price'
      count * discount[:value]
    when 'buy x get one discount'
      (count - (count/discount[:threshold]).ceil) * price
    else
      count * price
    end
  end
end
