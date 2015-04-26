module Gares
  # Search Gares-en-mouvement for a station name
  class Search < StationList
    attr_reader :query

    # This is the stations database from capitainetrain.com
    GARES_LIST_URL = "https://raw.githubusercontent.com/capitainetrain/stations/master/stations.csv"

    # List of keywords to ignore while searching
    IGNORE_KEYWORDS = ["ST", "SAINT", "GARE", "SNCF"]
    # Initialize a new Station search with the specified query
    #
    #   search = Gares::Search.new("Aix")
    #
    # Gares::Search is lazy loaded, meaning that unless you access the +stations+
    # attribute, no remomte query is made.
    #
    def initialize(query, field = :name)
      @query = query
      @by = field
    end

    # Returns an array of Gares::Station objects in order to easily search result yielded.
    # If the +query+ was an exact match, a single element array will be returned.
    def stations
      @stations ||= (exact_match? ? parse_station : parse_stations)
    end

    private

    def data
      @data ||= self.class.query.map { |raw_station| Gares::Station.new(raw_station) }
    end

    def result
      keywords = @query.split(/[ -]/).select { |keyword| !IGNORE_KEYWORDS.include?(keyword.upcase) }
      @result ||= data.select do |station|
        station.send(@by) && station.send(@by).to_ascii =~ /#{keywords.join(".*")}/i
      end
    end

    def self.query
      @data ||= SmarterCSV.process(open(GARES_LIST_URL), col_sep: ";")
    end

    def parse_station
      [result.first]
    end

    def exact_match?
      result.count == 1
    end
  end # Search
end # Gares
