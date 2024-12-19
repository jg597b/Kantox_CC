# Kantox Code Challenge
You are the lead programmer for a small chain of supermarkets. You are required to make a simple cashier function that adds products to a cart and displays the total price.
You have the following test products registered:

| Product Code | Name | Price |
|---|---|---|
| GR1 | Green tea | £3.11 |
| SR1 | Strawberries | £5.00 |
| CF1 | Coffee | £11.23 |

## Special conditions:
* The CEO is a big fan of buy-one-get-one-free offers and of green tea. He wants us to add a rule to do this.
* The COO, though, likes low prices and wants people buying strawberries to get a price discount for bulk purchases. If you buy 3 or more strawberries, the price should drop to £4.50
* The CTO is a coffee addict. If you buy 3 or more coffees, the price of all coffees should drop to two thirds of the original price.

Our check-out can scan items in any order, and because the CEO and COO change their minds often, it needs to be flexible regarding our pricing rules.

The interface to our checkout looks like this (shown in ruby):
```
co = Checkout.new(pricing_rules) co.scan(item)
co.scan(item)
price = co.total
``` 

Implement a checkout system that fulfills these requirements.

Test data:
Basket: GR1,SR1,GR1,GR1,CF1
Total price expected: ​£22.45

Basket: GR1,GR1
Total price expected: ​£3.11

Basket: SR1,SR1,GR1,SR1
Total price expected:​ £16.61

Basket: GR1,CF1,SR1,CF1,CF1
Total price expected:​ £30.57

# Version 1 Assumptions 

We assume that the pricing rules follow the below structure

```
PRICING_RULES={
'GR1' => {
type: 'BOGO',
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
```

# Setup and Installation

## Prerequisites

* Ruby 3.0+
* Bundler gem

### Installation Steps

1. Clone this repository 
```
https://github.com/jg597b/Kantox_CC.git
```

2. Install dependencies:
```
bundle install
```

### Running the Tests
We use RSpec for testing

1. Run all tests
```
bundle exec rspec
```
2. Run specific test file
```
bundle exec rspec spec/checkout_spec.rb 
```

### Adding these classes to your interface

```
irb
```

Once in irb you can add it to your interface
```
load 'checkout.rb'
```

Define the Pricing rules
```
PRICING_RULES={
'GR1' => {
type: 'BOGO',
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
```

Create a new checkout object
```
co=Checkout.new(PRICING_RULES)

```

add items to your basket
```
co.scan('CF1').scan('CF1').scan('CF1')
```
See the total
```
co.total
```