module Gares
  # Represents something on gare-en-mouvement.com
  class Base
    attr_accessor :slug, :name

    # Initialize a new Gare object with it's gare-en-mouvemnt id (as a String)
    #
    #   gare = Gares::Gare.new("frabt")
    #
    # Gares::Gare objects are lazy loading, meaning that no HTTP request
    # will be performed when a new object is created. Only when you use an
    # accessor that needs the remote data, a HTTP request is made (once).
    #
    def initialize(slug, name = nil)
      @slug = slug
      @name = name if name
    end

    def services
      @services ||= Services.new(@slug).all
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

    # Returns a string containing the name
    def name(force_refresh = false)
      if @name && !force_refresh
        @name
      else
        @name = document.at('h1').inner_html.gsub(/En direct de /, '') rescue nil
      end
    end

    private

    # Returns a new Nokogiri document for parsing.
    def document
      @document ||= Nokogiri::HTML(Gares::Gare.find_by_slug(@slug))
    end

    # Use HTTParty to fetch the raw HTML for this gare.
    def self.find_by_slug(slug, page = :"votre-gare")
      open("http://www.gares-en-mouvement.com/fr/#{slug}/#{page}")
    end

    # Convenience method for search
    def self.search(query)
      Gares::Search.new(query).gares
    end
  end # Gare
end # Gares
