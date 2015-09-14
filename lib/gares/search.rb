require 'trie'

module Gares
  # Search Gares-en-mouvement for a station name
  class Search < StationList
    @@trie = nil
    mattr_reader :trie

    attr_reader :query

    # This is the stations database from capitainetrain.com
    GARES_LIST_URL = "https://raw.githubusercontent.com/paulrbr/stations/stations-with-bls/stations.csv"

    # Initialize a new Station search with the specified query
    #
    #   search = Gares::Search.new("Aix")
    #
    # Gares::Search is lazy loaded, meaning that unless you access the +stations+
    # attribute, no remomte query is made.
    #
    # Search can by done via the :name or :sncf_id field given in parameter.
    # Defaults to the :name field.
    def initialize(query, field = :name)
      fail UnsupportedIndex unless %w(name sncf_id).include?(field.to_s)
      @query = query
      @by = field
    end

    # Returns an array of Gares::Station objects in order to easily search result yielded.
    # If the +query+ was an exact match, a single element array will be returned.
    def stations
      @stations ||= (exact_match? ? parse_station : parse_stations)
    end

    def self.find(str)
      trie.find_prefix(str)
    end

    private

    def result
      query = self.class.simplify(@query)
      if @raw_results.nil?
        @raw_results = self.class.find(query).values
        # try removing keywords one by one if nothing found
        while @raw_results.empty? && !query.split(" ").empty?
          query = query.split(" ")[0..-2].join(" ")
          @raw_results = @raw_results.empty? ? self.class.find(query).values : @raw_results
        end
      end
      @result ||= @raw_results.map do |raw_station|
        Gares::Station.new(raw_station.select { |key| Gares::Station.properties.include?(key) })
      end
    end

    def self.simplify(str)
      str.to_ascii.downcase
        .gsub(/\bgare\ssncf\b/, "")
        .gsub(/\bsaint\b/, "st")
        .gsub(/[^a-z]/, " ")
        .gsub(/\s+/, " ")
        .strip
    end

    # Read stations.csv file into memory into a Trie data structure
    def self.load_data
      if @@trie.nil?
        raw_data ||= SmarterCSV.process(open(GARES_LIST_URL), col_sep: ";")
        trie = Trie.new

        raw_data.each do |raw_station|
          next if raw_station[:name].nil? || raw_station[:sncf_id].nil? || raw_station[:uic].nil?
          trie.insert(simplify(raw_station[:name]), raw_station)
          trie.insert(simplify(raw_station[:sncf_id]), raw_station)
        end

        @@trie = trie
      end
    end
    load_data

    def parse_station
      [result.first]
    end

    def exact_match?
      result.count == 1
    end
  end # Search
end # Gares
