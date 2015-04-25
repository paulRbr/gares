describe Gares::Sales do

  context 'with a valid station' do

    subject(:sales) { Gares::Sales.new('frqxb') }

    it { expect(sales.has_borne?).to be(true) }

  end

end
