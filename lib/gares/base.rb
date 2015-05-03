module Gares
  # Represents a station on gares-sncf.com
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

    # Whether this station has a "borne" (yellow self-service ticket machine)
    # @return [Boolean]
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

    # List of the next departing trains from this station.
    # @param refresh [Boolean] whether to fetch fresh data from gares-sncf.com or not.
    # @return [Array<Train>]
    def departures(refresh = false)
      if tvs
        trains(:departure, refresh)
      end
    end
    alias departing_trains departures

    # List of the next arriving trains in this station.
    # @param refresh [Boolean] whether to fetch fresh data from gares-sncf.com or not.
    # @return [Array<Train>]
    def arrivals(refresh = false)
      if tvs
        trains(:arrival, refresh)
      end
    end
    alias arriving_trains arrivals

    private

    def tvs
      if uic8_sncf
        @tvs ||= self.class.open_data_sncf(uic8_sncf, :tvs)
      end
    end

    def trains(direction = :departure, refresh = false)
      variable = "@#{direction}".to_sym
      if tvs && (refresh || instance_variable_get(variable).nil?)
        raw_trains = self.class.external_gares_sncf(tvs, direction, refresh)
        all_trains = raw_trains.map do |raw_train|
          raw_train[:num] = raw_train[:num].to_i
          raw_train[:date] = Time.now
          Gares::Train.new(raw_train)
        end
        instance_variable_set(variable, all_trains)
      end
      instance_variable_get(variable)
    end

    def self.open_data_sncf(uic8_sncf, field)
      @open_data ||= {}
      @open_data[uic8_sncf] ||= JSON.parse(open(OPEN_DATA_SNCF % ("%010d" % uic8_sncf).to_s).read, :symbolize_names => true)[:records]
      unless @open_data[uic8_sncf].empty?
        @open_data[uic8_sncf].first[:fields][field]
      end
    end

    def self.external_gares_sncf(tvs, direction = :departure, refresh = false)
      @gares_sncf ||= {}
      @gares_sncf[tvs] ||= {}
      if refresh || @gares_sncf.nil? || @gares_sncf[direction].nil?
        @gares_sncf[tvs][direction] = JSON.parse(open(GARES_SNCF % [direction, tvs]).read, :symbolize_names => true)[:trains]
      end
      @gares_sncf[tvs][direction]
    end

    # Convenience method for search (by name)
    def self.search(query)
      Gares::Search.new(query).stations
    end

    # Convenience method for search_by_sncf_id
    def self.find_by_sncf_id(query)
      Gares::Search.new(query, :sncf_id).stations.first
    end
  end # Base
end # Gares
