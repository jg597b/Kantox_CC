# frozen_string_literal: true

require_relative '../checkout'

RSpec.describe Checkout do
  let(:checkout) { described_class.new }

  describe '#initialize' do
    it 'creates a new instance with empty items' do
      expect(checkout.instance_variable_get(:@items)).to be_empty
    end
  end

  describe '#scan' do
    it 'adds an item to the cart' do
      checkout.scan('GR1')
      expect(checkout.instance_variable_get(:@items)).to eq(['GR1'])
    end

    it 'returns self for method chaining' do
      expect(checkout.scan('GR1')).to be_instance_of(Checkout)
    end

    it 'allows multiple items to be scanned' do
      checkout.scan('GR1').scan('SR1').scan('CF1')
      expect(checkout.instance_variable_get(:@items)).to eq(['GR1', 'SR1', 'CF1'])
    end
  end

  describe '#total' do
    context 'with an empty cart' do
      it 'returns 0' do
        expect(checkout.total).to eq(0)
      end
    end

    context 'with single items (no discounts)' do
      it 'calculates total for one Green Tea' do
        checkout.scan('GR1')
        expect { checkout.total }.to output(/.*Total: 3\.11.*/).to_stdout
      end

      it 'calculates total for one Strawberries' do
        checkout.scan('SR1')
        expect { checkout.total }.to output(/.*Total: 5\.0.*/).to_stdout
      end

      it 'calculates total for one Coffee' do
        checkout.scan('CF1')
        expect { checkout.total }.to output(/.*Total: 11\.23.*/).to_stdout
      end
    end

    context 'with Green Tea buy-one-get-one discount' do
      it 'applies discount for two Green Teas' do
        checkout.scan('GR1').scan('GR1')
        expect { checkout.total }.to output(/.*Total: 3\.11.*/).to_stdout
      end

      it 'applies discount for three Green Teas' do
        checkout.scan('GR1').scan('GR1').scan('GR1')
        expect { checkout.total }.to output(/.*Total: 6\.22.*/).to_stdout
      end
    end

    context 'with Strawberries bulk price discount' do
      it 'applies no discount for two Strawberries' do
        checkout.scan('SR1').scan('SR1')
        expect { checkout.total }.to output(/.*Total: 10\.0.*/).to_stdout
      end

      it 'applies discount for three Strawberries' do
        checkout.scan('SR1').scan('SR1').scan('SR1')
        expect { checkout.total }.to output(/.*Total: 13\.5.*/).to_stdout
      end
    end

    context 'with Coffee percentage discount' do
      it 'applies no discount for two Coffees' do
        checkout.scan('CF1').scan('CF1')
        expect { checkout.total }.to output(/.*Total: 22\.46.*/).to_stdout
      end

      it 'applies discount for three Coffees' do
        checkout.scan('CF1').scan('CF1').scan('CF1')
        expected_price = (11.23 * (1 - 0.666) * 3).round(2)
        expect { checkout.total }.to output(/.*Total: #{expected_price}.*/).to_stdout
      end
    end

    context 'with mixed items' do
      it 'calculates correct total for basket with multiple types of items' do
        checkout.scan('GR1').scan('SR1').scan('GR1').scan('CF1').scan('CF1')
        expect { checkout.total }.to output(/.*Total: 30\.57.*/).to_stdout
      end

      it 'calculates correct total for basket with multiple discounts' do
        checkout.scan('GR1').scan('GR1').scan('SR1').scan('SR1').scan('SR1').scan('CF1').scan('CF1').scan('CF1')
        expect { checkout.total }.to output(/.*Total: 27\.86.*/).to_stdout
      end
    end
  end
end