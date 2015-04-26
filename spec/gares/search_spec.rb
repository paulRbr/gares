require 'spec_helper'

describe Gares::Search do
  context 'with multiple search results' do
    before(:each) do
      @search = Gares::Search.new('Aix')
    end

    it 'should remember the query' do
      expect(@search.query).to eql('Aix')
    end

    it 'should find 28 results' do
      expect(@search.stations.size).to eql(28)
    end

    it 'should return Gares::Station objects only' do
      expect(@search.stations).to all(be_an(Gares::Station))
    end

    it 'should not return gares with no name' do
      @search.stations.each { |gare| expect(gare.name).to_not be_blank }
    end

    it 'should return only the name of the result' do
      expect(@search.stations.first.name).to eql('Roubaix')
    end
  end

  context 'with an exact match' do
    it 'should not raise an exception' do
      expect do
        @search = Gares::Search.new('Paris Austerlitz').stations
      end.not_to raise_error
    end

    it 'should return the gare sncf_id.downcase correctly' do
      @search = Gares::Search.new('Paris Austerlitz')
      expect(@search.stations.first.sncf_id.downcase).to eql('frpaz')
    end
  end

  context 'with a fuzzy match' do
    it 'should not raise an exception' do
      expect do
        @search = Gares::Search.new('CULMONT CHALINDREY').stations
      end.not_to raise_error
    end

    it 'should return the gare sncf_id.downcase correctly' do
      @search = Gares::Search.new('CULMONT CHALINDREY')
      expect(@search.stations.first.sncf_id.downcase).to eql('frccy')
    end

    context 'with a "st" searching for "saint"' do
      it 'should return the gare sncf_id.downcase correctly' do
        @search = Gares::Search.new('ST ETIENNE CHATEAUCREUX')
        expect(@search.stations.first.sncf_id.downcase).to eql('frhhd')
      end
    end

    context 'with a multi-terms search' do
      it 'should return the gare sncf_id.downcase correctly' do
        @search = Gares::Search.new('BAR SUR AUBE')
        expect(@search.stations.first.sncf_id.downcase).to eql('frapx')
      end

      it 'should return the gare sncf_id.downcase correctly' do
        @search = Gares::Search.new('NOGENT SUR SEINE')
        expect(@search.stations.first.sncf_id.downcase).to eql('frapm')
      end

      it 'should return the gare sncf_id.downcase correctly' do
        @stations = Gares::Station.search('MONTELIMAR GARE SNCF')
        expect(@stations.first.sncf_id.downcase).to eql('frmtl')
      end

      it 'should return the gare sncf_id.downcase correctly' do
        @stations = Gares::Station.search('MONTPELLIER SAINT-ROCH')
        expect(@stations.first.sncf_id.downcase).to eql('frmpl')
      end
    end
  end
end
