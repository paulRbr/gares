require 'cgi'

module Gares #:nordoc:
  module StringExtensions
    # Unescape HTML
    def unescape_html
      CGI.unescapeHTML(encode('UTF-8'))
    end

    # Strip tags
    def strip_tags
      gsub(/<\/?[^>]*>/, '')
    end

    # Strips out whitespace then tests if the string is empty.
    def blank?
      strip.empty?
    end unless method_defined?(:blank?)
  end
end

String.send :include, Gares::StringExtensions
