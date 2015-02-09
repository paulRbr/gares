module Gares
  class Services < Base

    def all
      document.search('#page_content_resize_true h2').
        map { |title| title.inner_html } rescue []
    end

    private

    def document
      @document ||= Nokogiri::HTML(Gares::Gare.find_by_slug(
        @slug, :"services-en-gare/service/"))
    end
  end
end
