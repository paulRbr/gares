module Gares
  class StationList

    private

    def parse_stations
      result.compact.uniq.map do |station|
        Gares::Station.new(station.slug, station.name)
      end
    end
  end # StationList
end # Gares
