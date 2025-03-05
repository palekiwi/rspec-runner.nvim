require_relative "./adder.rb"

RSpec.describe Adder do
  describe '#add' do
    context 'when adding two numbers' do
      it 'returns a sum' do
        result = Adder.add(1, 2)

        expect(result).to eq(3)
      end

      it 'makes a mistake' do
        result = Adder.add(1, 2)

        expect(result).to eq(5)
      end

      it 'makes a mistake again' do
        result = Adder.add(1, 3)

        expect(result).to eq(8)
      end
    end
  end
end

