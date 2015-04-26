require 'time'

module Gares
  # Represents a stop for a train from http://www.sncf.com/fr/horaires-info-trafic/train
  class TrainStop
    # @!attribute departure_date
    #   @return [Time] The scheduled departure date at this stop.

    # @!attribute real_departure_date
    #   @return [Time] The live schedule departure date at this stop.

    # @!attribute arrival_date
    #   @return [Time] The scheduled arrival date at this stop.

    # @!attribute real_arrival_date
    #   @return [Time] The live schedule departure date at this stop.

    # @!attribute station
    #   @return [Station] The station in which this train is stopping.

    # @!attribute platform
    #   @return [String] The platform number/letter if available.

    # @!attribute formatted_info
    #   @return [String] A formatted detailed information in HTML.

    attr_accessor :departure_date, :real_departure_date, :arrival_date, :real_arrival_date,
      :station, :platform, :formatted_info

    # Given the HTML node from sncf.com/fr/horaires-info-trafic/train containing the stop
    # and the +date+ for this train stop.
    # The object gathers all useful information about the stop made by the train.
    def initialize(nokogiri_node, date)
      initialize_dates(nokogiri_node, date)
      initialize_station(nokogiri_node)
      @platform = nokogiri_node.at('td.track').inner_html.strip
      @formatted_info = nokogiri_node.at('td.info').inner_html.strip
    end

    def delayed?
      minutes_of_delay > 0
    end

    # @return [Integer] The amount of minutes of delay at this stop.
    def minutes_of_delay
      if @real_departure_date
        (@real_departure_date - @departure_date) / 60
      else
        0
      end
    end

    private

    def initialize_dates(node, date)
      raw_time = node.at('td.time').inner_html.strip
      raw_real_time = node.at('td.new-schedule').inner_html.strip
      raw_arrival_time = raw_time.split('<br/>').first
      raw_departure_time = raw_time.split('<br/>').last
      raw_real_arrival_time = raw_real_time.split('<br/>').first
      raw_real_departure_time = raw_real_time.split('<br/>').last

      @departure_date = Time.parse(raw_departure_time, date)
      @arrival_date = Time.parse(raw_arrival_time, date)
      if raw_real_departure_time
        @real_departure_date = Time.parse(raw_real_departure_time, date)
      end
      if raw_real_arrival_time
        @real_arrival_date = Time.parse(raw_real_arrival_time, date)
      end
    end

    def initialize_station(node)
      raw_name = node.at('td.stations div.station').inner_html.strip
      stations = Station.search(raw_name)
      @station = if stations.size > 1
        raw_name.gsub!(/[ -]/, '.')
        exact_match  = /^#{raw_name}$/i
        begin_match  = /^#{raw_name}/i
        end_match    = /#{raw_name}$/
        middle_match = /#{raw_name}/i
        stations.find do |station|
          station.name.match(exact_match)
        end ||
        stations.find do |station|
          station.name.match(begin_match)
        end ||
        stations.find do |station|
          station.name.match(end_match)
        end ||
        stations.find do |station|
          station.name.match(middle_match)
        end
      else
        stations.first
      end
    end
  end
end
