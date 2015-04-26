module Gares
  # Represents something on gare-en-mouvement.com
  class Base < Hashie::Dash
    property :id
    property :name
    property :slug
    property :sncf_id
    property :longitude
    property :latitude
    property :uic
    property :uic8_sncf
    property :parent_station_id
    property :is_city
    property :country
    property :is_main_station
    property :time_zone
    property :is_suggestable
    property :sncf_is_enabled
    property :idtgv_id
    property :idtgv_is_enabled
    property :db_id
    property :db_is_enabled
    property :idbus_id
    property :idbus_is_enabled
    property :ouigo_id
    property :ouigo_is_enabled
    property :trenitalia_id
    property :trenitalia_is_enabled
    property :ntv_id
    property :ntv_is_enabled
    property :'info:fr'
    property :'info:en'
    property :'info:de'
    property :'info:it'
    property :same_as


    NAME = 'En direct de '

    def services
      @services ||= Services.new(sncf_id: sncf_id)
      @services.all
    end

    def sales
      @sales ||= Sales.new(sncf_id: sncf_id)
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

    # deprecated
    def slug
      sncf_id.downcase
    end

    # deprecated
    def lat
      latitude
    end

    # deprecated
    def long
      longitude
    end

    private

    # Returns a new Nokogiri document for parsing.
    def document
      @document ||= Nokogiri::HTML(self.class.external_data(sncf_id))
    end

    # Use HTTParty to fetch the raw HTML for this gare.
    def self.external_data(sncf_id, page = :"votre-gare")
      open("http://www.gares-en-mouvement.com/fr/#{sncf_id.downcase}/#{page}")
    end

    # Convenience method for search (by name)
    def self.search(query)
      Gares::Search.new(query).stations
    end

    # Convenience method for search_by_sncf_id
    def self.search_by_sncf_id(query)
      Gares::Search.new(query, :sncf_id).stations
    end
  end # Base
end # Gares
