require 'spec_helper'

describe String do

  let(:html) { "<p>my paragraph</p>" }
  let(:escaped_html) { CGI::escapeHTML(html) }

  describe '#strip_tags' do
    subject { html.strip_tags }
    it { should eql("my paragraph") }
  end

  describe '#unescape_html' do
    subject { escaped_html.unescape_html }
    it { should eql(html) }
  end
end
