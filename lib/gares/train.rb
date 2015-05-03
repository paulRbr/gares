require "net/http"
require "uri"

module Gares
  # Represents a train from http://www.sncf.com/fr/horaires-info-trafic/train
  class Train < Hashie::Dash
    property :origdest
    property :num, required: true
    property :date, required: true
    property :type
    property :picto
    property :voie
    property :voie_attr
    property :heure
    property :etat
    property :retard
    property :infos

    # Initialize a new Train object with at least it's number and departure date
    #
    #   train = Gares::Train.new(num: 6704, date: Time.parse('2015-04-15'))
    #
    # Gares::Train objects are lazy loaded, meaning that no HTTP request
    # will be performed when a new object is created. An HTTP request is made
    # Only when you use an accessor that needs remote data.
    def initialize(*arguments)
      fail "Please provide a train number" unless arguments.first[:num].is_a?(Integer)
      fail "Please provide a departure date" unless arguments.first[:date].is_a?(Time)

      if arguments.first[:origdest]
        arguments.first[:origdest] = Gares::Station.search(arguments.first[:origdest]).first
      end

      super(*arguments)
    end

    # @return [Integer] The train number
    def number
      num
    end

    # @return [TrainStop] The departure point of the train
    def departure
      @departure ||= TrainStop.new(document.at('tr.itinerary-start'), date)
    end

    # @return [Array<TrainStop>] A list of all stops between departure and arrival stations.
    def stops
      @stops ||= document.css('tr.itinerary-stop').map { |stop| TrainStop.new(stop, date) }
    end

    # @return [TrainStop] The arrival point of the train
    def arrival
      @arrival ||= TrainStop.new(document.at('tr.itinerary-end'), date)
    end

    def delayed?
      (retard && !retard.blank?) || ([departure] + stops + [arrival]).any?(&:delayed?)
    end

    def platform
      voie
    end

    private

    def itinerary_available?
      document.css('ul.itinerary-details').size > 0
    end

    # Returns a new Nokogiri document for parsing.
    def document
      if !@document
        @document = Nokogiri::HTML(self.class.request_sncf(number, date))
        if !itinerary_available?
          @document = Nokogiri::HTML(self.class.request_sncf_itinerary(0))
        end
      end
      if @document.at('#no_results')
        fail TrainNotFound, @document.at('#no_results b').inner_html
      end
      @document
    end

    def self.request_sncf(number, date)
      uri = URI.parse("http://www.sncf.com/sncf/train")
      response = Net::HTTP.post_form(uri, {"numeroTrain" => number, "date" => date.strftime("%d/%m/%Y")})
      @cookies = response.get_fields('Set-Cookie').map { |cookie| cookie.split(";").first }.join(";")

      uri = URI.parse("http://www.sncf.com/en/horaires-info-trafic/train/resultats")
      req = Net::HTTP::Get.new(uri.path)
      req.add_field("Cookie", @cookies)
      Net::HTTP.new(uri.host, uri.port).start { |http| http.request(req) }.body
    end

    def self.request_sncf_itinerary(index)
      uri = URI.parse("http://www.sncf.com/sncf/train/displayDetailTrain?idItineraire=#{index}")
      req = Net::HTTP::Get.new(uri)
      req.add_field("Cookie", @cookies) if @cookies
      Net::HTTP.new(uri.host, uri.port).start { |http| http.request(req) }.body

      uri = URI.parse("http://www.sncf.com/en/horaires-info-trafic/train/resultats?#{index}")
      req = Net::HTTP::Get.new(uri)
      req.add_field("Cookie", @cookies) if @cookies
      Net::HTTP.new(uri.host, uri.port).start { |http| http.request(req) }.body
    end

  end # Train
end # Gares
