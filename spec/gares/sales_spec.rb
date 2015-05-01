require 'spec_helper'

describe Gares::Sales do

  context 'with a valid station' do

    subject(:sales) { Gares::Sales.new(sncf_id: 'frqxb') }

    it { expect(sales.has_borne?).to be(true) }

  end

end
