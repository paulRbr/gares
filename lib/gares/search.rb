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

    private

    def result
      @raw_result ||= case @by
      when :name
        keywords = @query.to_ascii.split(/[ -]/).select { |keyword| !IGNORE_KEYWORDS.include?(keyword.upcase) }
        regexp_query = keywords.join(".*")
        self.class.data(@by).select do |index, v|
          index && index =~ /#{regexp_query}/i
        end
      when :sncf_id
        { @query.downcase => self.class.data(@by)[@query.downcase] }
      end

      @result ||= @raw_result.map { |_, raw_station| Gares::Station.new(raw_station) }
    end

    # Read stations.csv file into memory
    # @param index either :name or :sncf_id
    # @return [Hash<String, Hash>] list of stations indexed in a Hash
    def self.data(index)
      @@raw_data ||= SmarterCSV.process(open(GARES_LIST_URL), col_sep: ";")
      case index
      when :name
        @@data_by_name ||= index_data(@@raw_data, index)
      when :sncf_id
        @@data_by_sncf_id ||= index_data(@@raw_data, index)
      end
    end

    def self.index_data(data, by)
      data.map do |raw_station|
        [raw_station[by].to_ascii.downcase, raw_station] if raw_station[by] && raw_station[:uic]
      end.compact.to_h
    end

    def parse_station
      [result.first]
    end

    def exact_match?
      result.count == 1
    end
  end # Search
end # Gares
