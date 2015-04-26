# encoding: utf-8

require 'spec_helper'

# This test uses "Lyon Part-Dieu" as a testing sample:
#
#     http://www.gares-en-mouvement.com/fr/frlpd/votre-gare/
#
describe Gares::Station do

  describe 'valid gare' do

    before(:each) do
      # Get gare de Lyon Part-Dieu
      @gare = Gares::Station.search_by_sncf_id('frlpd').first
    end

    it 'should find the name' do
      name = @gare.name

      expect(name).to eql('Lyon Part-Dieu')
    end

    it 'should find the geolocation coordinates' do
      lat = @gare.latitude
      long = @gare.longitude

      expect(lat).to eql(45.760568)
      expect(long).to eql(4.859991)
    end

    it 'should have opening hours' do
      horaires = @gare.horaires

      expect(horaires.first).to eql('du lundi au dimanche de 04:50 à 00:45')
    end

    it 'should have a list of services' do
      services = @gare.services

      expect(services).to be_an(Array)
      expect(services.first).to_not be_blank
    end

    it 'should have a list of sales services' do
      sales = @gare.sales

      expect(sales).to be_an(Array)
      expect(sales.first).to_not be_blank
    end

    context 'Station of Agde' do
      before(:each) do
        # Get gare de Agde
        @gare = Gares::Station.search_by_sncf_id('frxag').first
      end

      describe 'a gare without wifi nor defibrillator' do
        it { expect(@gare.wifi?).to be(false) }
        it { expect(@gare.defibrillator?).to be(false) }
      end

      describe 'a gare with no sales services' do
        it { expect(@gare.has_borne?).to be(false) }
      end
    end
  end

  describe 'with name that has utf-8 characters' do
    # Belleville sur Sâone
    before(:each) do
      @gare = Gares::Station.search('Saone').first
    end

    it 'should give the proper name' do
      expect(@gare.name).to eql('Port-sur-Saône')
    end
  end
end
