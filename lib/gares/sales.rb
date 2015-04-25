module Gares
  class Sales < Base

    def all
      document.search('#page_content_resize_true h3').
        map { |title| title.inner_html } rescue []
    end

    private

    def document
      @document ||= Nokogiri::HTML(Gares::Station.find_by_slug(
        @slug, :"services-en-gare/vente/"))
    end
  end
end
