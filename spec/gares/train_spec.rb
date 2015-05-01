# encoding: utf-8

require 'spec_helper'

describe Gares::Train do

  subject do
    Gares::Train.new(train_number, date)
  end

  describe 'no results' do

    let (:train_number) { 12345 }
    let (:date) { Time.parse("2015-04-25") }

    before do
      # See tasks/fixtures.rake to change dataset
      fake_response_for_train(train_number)
    end

    it "raises an error for any method called on it" do
      expect { subject.departure }.to raise_error
    end

  end

  describe 'a delayed train' do

    let (:train_number) { 17709 }
    let (:date) { Time.parse("2015-04-25") }

    before do
      # See tasks/fixtures.rake to change dataset
      fake_response_for_train(train_number)
    end

    subject do
      Gares::Train.new(train_number, date)
    end

    it "is delayed" do
      expect(subject).to be_delayed
    end

    it "has a departure station" do
      expect(subject.departure.departure_date).to eq(Time.parse('2015-04-25 09:18:00'))
      expect(subject.departure.real_departure_date).to eq(Time.parse('2015-04-25 09:28:00'))
      expect(subject.departure.station.name).to eq('Lyon Part-Dieu')
      expect(subject.departure.station.latitude).to eql(45.760568)
      expect(subject.departure.platform).to eq('--')

      expect(subject.departure.delayed?).to be(true)
    end

    it "has stops" do
      expect(subject.stops.size).to eq(12)
      expect(subject.stops.first.station.name).to eq('Vienne')

      expect(subject.stops[2].station.name).to eq('Tain')
      expect(subject.stops[2].platform).to eq('B')
      expect(subject.stops[2].minutes_of_delay).to eq(10)

      expect(subject.stops.last.station.name).to eq('Vitrolles Aéroport Marseille-Provence TER')
    end

    it "has a arrival station" do
      expect(subject.arrival.arrival_date).to eq(Time.parse('2015-04-25 12:50:00'))
      expect(subject.arrival.real_arrival_date).to eq(Time.parse('2015-04-25 13:00:00'))
      expect(subject.arrival.station.name).to eq('Marseille St-Charles')
      expect(subject.arrival.platform).to eq('--')
    end
  end

  describe 'an on-time train' do

    let (:train_number) { 11641 }
    let (:date) { Time.parse("2015-04-25") }

    before do
      # See tasks/fixtures.rake to change dataset
      fake_response_for_train(train_number)
    end

    subject do
      Gares::Train.new(train_number, date)
    end

    it "is delayed" do
      expect(subject).to_not be_delayed
    end

    it "has a departure station" do
      expect(subject.departure.departure_date).to eq(Time.parse('2015-04-25 06:42:00'))
      expect(subject.departure.real_departure_date).to be_nil
      expect(subject.departure.station.name).to eq('Paris-Gare-de-l’Est')
      expect(subject.departure.platform).to eq('--')

      expect(subject.departure.delayed?).to be(false)
    end

    it "has stops", focus: true do
      expect(subject.stops.size).to eq(7)
      expect(subject.stops.first.station.name).to eq('Nogent-sur-Seine')

      expect(subject.stops[2].station.name).to eq('Troyes')

      expect(subject.stops.last.station.name).to eq('Langres')
    end

    it "has a arrival station" do
      expect(subject.arrival.arrival_date).to eq(Time.parse('2015-04-25 09:45:00'))
      expect(subject.arrival.real_arrival_date).to be_nil
      expect(subject.arrival.station.name).to eq('Culmont-Chalindrey')
      expect(subject.arrival.platform).to eq('--')
    end
  end

  describe 'a multi-itinerary train' do
    let (:train_number) { 6815 }
    let (:date) { Time.parse("2015-04-25") }

    before do
      # See tasks/fixtures.rake to change dataset
      fake_response_for_train(train_number)
    end

    subject do
      Gares::Train.new(train_number, date)
    end

    it "selects always the first itinerary", focus: true do
      expect(subject.departure.station.name).to eq("Dijon Ville")
      expect(subject.stops.first.station.name).to eq("Chalon-sur-Saône")
      expect(subject.arrival.station.name).to eq("Nice Ville")
    end
  end
end
