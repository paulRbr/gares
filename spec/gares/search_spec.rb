require 'spec_helper'

describe Gares::Search do
  context 'with multiple search results' do
    before(:each) do
      @search = Gares::Search.new('Aix')
    end

    it 'should remember the query' do
      expect(@search.query).to eql('Aix')
    end

    it 'should find 5 results' do
      expect(@search.stations.size).to eql(7)
    end

    it 'should return Gares::Station objects only' do
      expect(@search.stations).to all(be_an(Gares::Station))
    end

    it 'should not return gares with no name' do
      @search.stations.each { |gare| expect(gare.name).to_not be_blank }
    end

    it 'should return only the name of the result' do
      expect(@search.stations.first.name).to eql('Aix en Provence')
    end
  end

  context 'with an exact match' do
    it 'should not raise an exception' do
      expect do
        @search = Gares::Search.new('Paris Austerlitz').stations
      end.not_to raise_error
    end

    it 'should return the gare slug correctly' do
      @search = Gares::Search.new('Paris Austerlitz')
      expect(@search.stations.first.slug).to eql('frpaz')
    end
  end

  context 'with a fuzzy match' do
    it 'should not raise an exception' do
      expect do
        @search = Gares::Search.new('CULMONT CHALINDREY').stations
      end.not_to raise_error
    end

    it 'should return the gare slug correctly' do
      @search = Gares::Search.new('CULMONT CHALINDREY')
      expect(@search.stations.first.slug).to eql('frccy')
    end

    context 'with a "st" searching for "saint"' do
      it 'should return the gare slug correctly' do
        @search = Gares::Search.new('ST ETIENNE CHATEAUCREUX')
        expect(@search.stations.first.slug).to eql('frhhd')
      end
    end
  end
end
