module Gares
  # Search Gares-en-mouvement for a gare name
  class Search < GareList
    attr_reader :query

    GARES_LIST_URL = "https://www.kimonolabs.com/api/7jys32dy?apikey=lsOO4tNm78cH9JxqWg9gAk9l4nYaou9j&kimmodify=1"

    # Initialize a new Gares search with the specified query
    #
    #   search = Gares::Search.new("Aix")
    #
    # Gares::Search is lazy loading, meaning that unless you access the +gares+
    # attribute, no query is made to gares-en-mouvement.com.
    #
    def initialize(query)
      @query = query
    end

    # Returns an array of Gares::Gare objects for easy search result yielded.
    # If the +query+ was an exact match, a single element array will be returned.
    def gares
      @gares ||= (exact_match? ? parse_gare : parse_gares)
    end

    private

    def document
      @document ||= Hashie::Mash.new(JSON.load(Gares::Search.query))
    end

    def result
      @result ||= document.results.collection1.map(&:station).select { |gare| gare.name.to_ascii =~ /#{@query.split(" ").join(".*")}/i }
    end

    def self.query
      open(GARES_LIST_URL)
    end

    def parse_gare
      gare = result.first
      [Gares::Gare.new(gare.slug, gare.name)]
    end

    def exact_match?
      result.count == 1
    end
  end # Search
end # Gares
