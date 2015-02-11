module Gares
  class GareList

    private

    def parse_gares
      result.compact.uniq.map do |gare|
        Gares::Gare.new(gare.slug, gare.name)
      end
    end
  end # GareList
end # Gares
