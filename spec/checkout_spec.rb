# frozen_string_literal: true
require './checkout'

RSpec.describe Checkout do

  let(:pricing_rules) do
    {
      'GR1' => { type: 'BOGO', threshold: 2, value: 0 },
      'SR1' => { type: 'price', threshold: 3, value: 4.50 },
      'CF1' => { type: 'percentage', threshold: 3, value: 2/3.0 }
    }
  end

  let(:checkout) { described_class.new(pricing_rules) }

  describe '#initialize' do
    it 'creates a new instance with pricing rules' do
      expect(checkout).to be_an_instance_of(Checkout)
    end

    it 'raises an error with invalid pricing rules format' do
      expect { described_class.new([]) }.to raise_error(ArgumentError, "Pricing rules must be a Hash.")
    end
  end

  describe '#scan' do
    it 'adds an item and returns self for method chaining' do
      result = checkout.scan('GR1')
      expect(result).to eq(checkout)
    end

    it 'allows multiple items to be scanned via method chaining' do
      expect { checkout.scan('GR1').scan('SR1').scan('CF1') }.not_to raise_error
    end

    it 'raises an error when scanning an unknown product' do
      expect { checkout.scan('XXX').total }.to raise_error(ArgumentError, "Unknown product: XXX")
    end
  end

  describe '#total' do
    context 'when no items are scanned' do
      it 'returns 0' do
        expect(checkout.total).to eq(0)
      end
    end

    context 'with BOGO discount' do
      it 'applies BOGO discount for even number of items' do
        checkout.scan('GR1').scan('GR1').scan('GR1').scan('GR1')
        expect { checkout.total }.to output(/Total: 6.22/).to_stdout
      end

      it 'applies BOGO discount for odd number of items' do
        checkout.scan('GR1').scan('GR1').scan('GR1')
        expect { checkout.total }.to output(/Total: 6.22/).to_stdout
      end
    end

    context 'with price discount' do
      it 'applies bulk price discount when threshold is met' do
        checkout.scan('SR1').scan('SR1').scan('SR1')
        expect { checkout.total }.to output(/Total: 13.5/).to_stdout
      end

      it 'uses regular price when below threshold' do
        checkout.scan('SR1').scan('SR1')
        expect { checkout.total }.to output(/Total: 10.0/).to_stdout
      end
    end

    context 'with percentage discount' do
      it 'applies percentage discount when threshold is met' do
        checkout.scan('CF1').scan('CF1').scan('CF1')
        expect { checkout.total }.to output(/Total: 22.46/).to_stdout
      end

      it 'uses regular price when below threshold' do
        checkout.scan('CF1').scan('CF1')
        expect { checkout.total }.to output(/Total: 22.46/).to_stdout
      end
    end

    context 'with mixed items' do
      it 'correctly calculates total with different discount types' do
        checkout.scan('GR1').scan('GR1')
                .scan('SR1').scan('SR1').scan('SR1')
                .scan('CF1').scan('CF1').scan('CF1')

        expect { checkout.total }.to output(/Total: 39.07/).to_stdout
      end
    end
  end

  describe 'large quantities' do
    it 'handles very large quantities correctly' do
      10.times { checkout.scan('GR1') }
      expect { checkout.total }.to output(/Total: 15.55/).to_stdout 
    end

    it 'rounds totals to 2 decimal places' do
      checkout.scan('CF1').scan('CF1').scan('CF1')
      expect { checkout.total }.to output(/Total: 22.46/).to_stdout
    end
  end
end