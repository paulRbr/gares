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
      expect(@search.gares.size).to eql(7)
    end

    it 'should return Gares::Gare objects only' do
      expect(@search.gares).to all(be_an(Gares::Gare))
    end

    it 'should not return gares with no name' do
      @search.gares.each { |gare| expect(gare.name).to_not be_blank }
    end

    it 'should return only the name of the result' do
      expect(@search.gares.first.name).to eql('Aix en Provence')
    end
  end

  context 'with an exact match' do
    it 'should not raise an exception' do
      expect do
        @search = Gares::Search.new('Paris Austerlitz').gares
      end.not_to raise_error
    end

    it 'should return the gare slug correctly' do
      @search = Gares::Search.new('Paris Austerlitz')
      expect(@search.gares.first.slug).to eql('frpaz')
    end
  end

  context 'with a fuzzy match' do
    it 'should not raise an exception' do
      expect do
        @search = Gares::Search.new('CULMONT CHALINDREY').gares
      end.not_to raise_error
    end

    it 'should return the gare slug correctly' do
      @search = Gares::Search.new('CULMONT CHALINDREY')
      expect(@search.gares.first.slug).to eql('frccy')
    end
  end
end
