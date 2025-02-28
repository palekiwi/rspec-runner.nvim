require_relative "./adder.rb"

RSpec.describe Adder do
  describe '#add' do
    context 'when adding two numbers' do
      fit 'returns a sum' do
        result = Adder.add(1, 2)

        expect(result).to eq(3)
      end

      it 'return an error' do
        result = Adder.add(1, 2)

        expect(result).to eq(2)
      end
    end
  end
end

