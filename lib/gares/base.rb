module Gares
  # Represents something on gare-en-mouvement.com
  class Base
    attr_accessor :slug, :name

    GPS_COORD = 'Coordonnées GPS : '
    NAME = 'En direct de '

    # Initialize a new Station object with it's gare-en-mouvemnt id (as a String)
    #
    #   station = Gares::Station.new("frabt")
    #
    # Gares::Station objects are lazy loaded, meaning that no HTTP request
    # will be performed when a new object is created. An HTTP request is made (once)
    # Only when you use an accessor that needs the remote data.
    #
    def initialize(slug, name = nil)
      @slug = slug
      @name = name if name
    end

    def lat
      coordinates.first.to_f
    end

    def long
      coordinates.last.to_f
    end

    def services
      @services ||= Services.new(@slug)
      @services.all
    end

    def sales
      @sales ||= Sales.new(@slug)
      @sales.all
    end

    def horaires
      document.search('ul.ouverture_heure li').
          map { |horaire| horaire.inner_html } rescue []
    end
    alias opening_hours horaires

    # Whether the gare has a defibrillator or not
    def defibrillateur?
      !document.at('div.defibrillateur').nil?
    end
    alias defibrillator? defibrillateur?

    # Whether the gare is equipped with wifi or not
    def wifi?
      !document.at('div.wifi').nil?
    end

    def has_borne?
      sales.any? { |sales_service| sales_service =~ /bornes?.libre.service/i }
    end

    # Returns a string containing the name
    def name(force_refresh = false)
      if @name && !force_refresh
        @name
      else
        @name = document.at('h1').inner_html.gsub(NAME, '') rescue nil
      end
    end

    private

    def coordinates
      @coordinates ||= document.xpath("//p/strong[contains(text(), '#{GPS_COORD}')]").first.parent.text
        .gsub(GPS_COORD, '').split(',')
    end

    # Returns a new Nokogiri document for parsing.
    def document
      @document ||= Nokogiri::HTML(Gares::Station.find_by_slug(@slug))
    end

    # Use HTTParty to fetch the raw HTML for this gare.
    def self.find_by_slug(slug, page = :"votre-gare")
      open("http://www.gares-en-mouvement.com/fr/#{slug}/#{page}")
    end

    # Convenience method for search
    def self.search(query)
      Gares::Search.new(query).stations
    end
  end # Base
end # Gares
