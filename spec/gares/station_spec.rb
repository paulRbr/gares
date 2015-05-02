require 'spec_helper'

# This test uses "Lyon Part-Dieu" as a testing sample:
#
#     http://www.gares-en-mouvement.com/fr/frlpd/votre-gare/
#
describe Gares::Station do

  describe 'valid gare' do

    subject do
      # Get gare de Lyon Part-Dieu
      Gares::Station.search_by_sncf_id('frlpd').first
    end

    it 'should find the name' do
      expect(subject.name).to eql('Lyon Part-Dieu')
    end

    it 'should find the sncf_id' do
      expect(subject.sncf_id).to eql('FRLPD')
      # Still supports deprecated fields
      expect(subject.slug).to eql(subject.sncf_id.downcase)
    end

    it 'should find the geolocation coordinates' do
      expect(subject.latitude).to eql(45.760568)
      expect(subject.longitude).to eql(4.859991)
      # Still supports deprecated fields
      expect(subject.lat).to eql(subject.latitude)
      expect(subject.long).to eql(subject.longitude)
    end

    it 'should have opening hours' do
      expect(subject.horaires.first).to eql('du lundi au dimanche de 04:50 à 00:45')
    end

    it 'should have a list of services' do
      expect(subject.services).to be_an(Array)
      expect(subject.services.first).to_not be_blank
    end

    it 'should have a list of sales services' do
      expect(subject.sales).to be_an(Array)
      expect(subject.sales.first).to_not be_blank
    end

    context 'Station of Agde' do
      subject do
        # Get gare de Agde
        Gares::Station.search_by_sncf_id('frxag').first
      end

      describe 'a gare without wifi nor defibrillator' do
        it { expect(subject.wifi?).to be(false) }
        it { expect(subject.defibrillator?).to be(false) }
      end

      describe 'a gare with no sales services' do
        it { expect(subject.has_borne?).to be(true) }
      end
    end
  end
end
