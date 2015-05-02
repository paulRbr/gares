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
    property :has_bls

    OPEN_DATA_SNCF = "https://ressources.data.sncf.com/api/records/1.0/search?dataset=referentiel-gares-voyageurs&q=%s"

    GARES_SNCF = "http://www.gares-sncf.com/fr/train-times/%s/%s/gl"

    def initialize(*args)
      super(*args)
    end

    # @deprecated
    def services
      warn "[DEPRECATION] since gares-en-mouvement.com does not exist anymore."
    end

    # @deprecated
    def sales
      warn "[DEPRECATION] since gares-en-mouvement.com does not exist anymore."
    end

    # @deprecated
    def horaires
      warn "[DEPRECATION] since gares-en-mouvement.com does not exist anymore."
    end
    alias opening_hours horaires

    # Whether the gare has a defibrillator or not
    # @deprecated
    def defibrillateur?
      warn "[DEPRECATION] since gares-en-mouvement.com does not exist anymore."
    end
    alias defibrillator? defibrillateur?

    # Whether the gare is equipped with wifi or not
    # @deprecated
    def wifi?
      warn "[DEPRECATION] since gares-en-mouvement.com does not exist anymore."
    end

    # @deprecated
    def has_borne?
      has_bls == "t"
    end

    # @deprecated
    def slug
      warn "[DEPRECATION] favor the 'sncf_id' method instead of 'slug'."
      sncf_id.downcase
    end

    # @deprecated
    def lat
      warn "[DEPRECATION] favor the 'latitude' method instead of 'lat'."
      latitude
    end

    # @deprecated
    def long
      warn "[DEPRECATION] favor the 'longitude' method instead of 'long'."
      longitude
    end

    def departures
      if tvs
        @departures ||= self.class.external_gares_sncf(tvs)
      end
    end

    def arrivals
      if tvs
        @arrivals ||= self.class.external_gares_sncf(tvs, :arrival)
      end
    end

    def tvs
      if uic8_sncf
        @tvs ||= self.class.open_data_sncf(uic8_sncf, 'tvs')
      end
    end

    private

    def self.open_data_sncf(uic8_sncf, field)
      @open_data ||= JSON.parse(open(OPEN_DATA_SNCF % ("%010d" % uic8_sncf).to_s).read)['records']
      unless @open_data.empty?
        @open_data.first['fields'][field]
      end
    end

    def self.external_gares_sncf(tvs, direction = :departure)
      @gares_sncf ||= {}
      @gares_sncf[direction] ||= JSON.parse(open(GARES_SNCF % [direction, tvs]).read)['trains']
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
