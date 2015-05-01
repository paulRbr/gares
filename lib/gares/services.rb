module Gares
  # @deprecated
  class Services < Base

    def all
      document.search('#page_content_resize_true h2').
        map { |title| title.inner_html } rescue []
    end

    private

    def document
      @document ||= Nokogiri::HTML(self.class.external_data(sncf_id, :"services-en-gare/service/"))
    end
  end
end
