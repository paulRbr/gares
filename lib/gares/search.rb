module Gares
  # Search Gares-en-mouvement for a station name
  class Search < StationList
    attr_reader :query

    # This is a file containing minimal information (name and slug) of all stations of gares-en-mouvement.com
    GARES_LIST_URL = "https://www.kimonolabs.com/api/7jys32dy?apikey=lsOO4tNm78cH9JxqWg9gAk9l4nYaou9j&kimmodify=1"

    # List of keywords to ignore while searching
    IGNORE_KEYWORDS = ["ST"]
    # Initialize a new Station search with the specified query
    #
    #   search = Gares::Search.new("Aix")
    #
    # Gares::Search is lazy loaded, meaning that unless you access the +stations+
    # attribute, no remomte query is made.
    #
    def initialize(query)
      @query = query
    end

    # Returns an array of Gares::Station objects in order to easily search result yielded.
    # If the +query+ was an exact match, a single element array will be returned.
    def stations
      @stations ||= (exact_match? ? parse_station : parse_stations)
    end

    private

    def document
      @document ||= Hashie::Mash.new(JSON.load(Gares::Search.query))
    end

    def result
      keywords = @query.split(" ").select { |keyword| !IGNORE_KEYWORDS.include?(keyword) }
      @result ||= document.results.collection1.map(&:station).select do |station|
        station.name.to_ascii =~ /#{keywords.join(".*")}/i
      end
    end

    def self.query
      open(GARES_LIST_URL)
    end

    def parse_station
      station = result.first
      [Gares::Station.new(station.slug, station.name)]
    end

    def exact_match?
      result.count == 1
    end
  end # Search
end # Gares
