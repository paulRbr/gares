require 'spec_helper'

describe Gares::Search do
  describe "search by station name" do
    context 'with multiple search results' do
      subject do
        Gares::Search.new('saint étienne')
      end

      it 'should remember the query' do
        expect(subject.query).to eql('saint étienne')
      end

      it 'should find 11 results' do
        expect(subject.stations.size).to eql(11)
      end

      it 'should return Gares::Station objects only' do
        expect(subject.stations).to all(be_an(Gares::Station))
      end

      it 'should not return gares with no name' do
        subject.stations.each { |gare| expect(gare.name).to_not be_blank }
      end

      it 'should return only the name of the result' do
        expect(subject.stations.first.name).to eql('St-Étienne-du-Rouvray')
      end
    end

    describe 'with name that has utf-8 characters' do
      subject { Gares::Station.search('Saone').first }

      it 'should give the proper name' do
        expect(subject.name).to eql('Saône')
      end
    end

    context 'with an exact match' do
      subject { Gares::Search.new('Paris Austerlitz') }

      it 'should not raise an exception' do
        expect do
          subject.stations
        end.not_to raise_error
      end

      it 'should return the gare sncf_id.downcase correctly' do
        expect(subject.stations.first.sncf_id.downcase).to eql('frpaz')
      end
    end

    context 'with a fuzzy match' do
      subject { Gares::Search.new('CULMONT CHALINDREY') }
      it 'should not raise an exception' do
        expect do
          subject.stations
        end.not_to raise_error
      end

      it 'should return the gare sncf_id.downcase correctly' do
        expect(subject.stations.first.sncf_id.downcase).to eql('frccy')
      end

      context 'with a "st" searching for "saint"' do
        it 'should return the gare sncf_id.downcase correctly' do
          subject = Gares::Search.new('ST ETIENNE CHATEAUCREUX')
          expect(subject.stations.first.sncf_id.downcase).to eql('frhhd')
        end
      end

      context 'with a multi-terms search' do
        it 'should return the gare sncf_id.downcase correctly' do
          subject = Gares::Search.new('BAR SUR AUBE')
          expect(subject.stations.first.sncf_id.downcase).to eql('frapx')
        end

        it 'should return the gare sncf_id.downcase correctly' do
          subject = Gares::Search.new('NOGENT SUR SEINE')
          expect(subject.stations.first.sncf_id.downcase).to eql('frapm')
        end

        it 'should return the gare sncf_id.downcase correctly' do
          subject = Gares::Station.search('MONTELIMAR GARE SNCF')
          expect(subject.first.sncf_id.downcase).to eql('frmtl')
        end

        it 'should return the gare sncf_id.downcase correctly' do
          subject = Gares::Station.search('MONTPELLIER SAINT-ROCH')
          expect(subject.first.sncf_id.downcase).to eql('frmpl')
        end

        it 'should return the gare sncf_id.downcase correctly' do
          subject = Gares::Station.search('CHALON SUR SAONE')
          expect(subject.first.sncf_id.downcase).to eql('frxcd')
        end

      end
    end
  end

  describe "search by sncf_id" do
    context 'with an exact match' do
      subject { Gares::Search.new('frlpd', :sncf_id) }

      it 'should not raise an exception' do
        expect do
          subject.stations
        end.not_to raise_error
      end

      it 'returns the good station' do
        expect(subject.stations.first.sncf_id.downcase).to eql('frlpd')
        expect(subject.stations.first.name).to eql('Lyon Part-Dieu')
      end
    end
  end

  describe "search by unsupported field" do
    it 'raises an exception' do
      expect do
        Gares::Search.new('Paris Austerlitz', :foo)
      end.to raise_error
    end
  end

end
