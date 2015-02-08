# encoding: utf-8

require 'spec_helper'

# This test uses "Lyon Part-Dieu" as a testing sample:
#
#     http://www.gares-en-mouvement.com/fr/frlpd/votre-gare/
#

describe Gares::Gare do

  describe 'valid gare' do

    before(:each) do
      # Get gare de Lyon Part-Dieu
      @gare = Gares::Gare.new('frlpd')
    end

    it 'should find the name' do
      name = @gare.name

      expect(name).to eql('Lyon Part Dieu')
    end
  end

  describe 'with name that has utf-8 characters' do
    # Belleville sur Sâone
    before(:each) do
      @gare = Gares::Gare.search('Saone').first
    end

    it 'should give the proper name' do
      expect(@gare.name).to eql('Belleville sur Sâone')
    end
  end
end
