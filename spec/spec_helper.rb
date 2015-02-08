# By default if you have the FakeWeb gem installed when the specs are
# run they will hit recorded responses.  However, if you don't have
# the FakeWeb gem installed or you set the environment variable
# LIVE_TEST then the tests will hit the live site gares-en-mouvement.com.
#
# Having both methods available for testing allows you to quickly
# refactor and add features, while also being able to make sure that
# no changes to the gares-en-mouvement.com interface have affected the parser.
###

require 'rspec'

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'gares'

def read_fixture(path)
  File.read(File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', path)))
end

GARES_SAMPLES = {
  'http://www.gares-en-mouvement.com/fr/frabt/services-en-gare/vente/' => 'frabt',
  'http://www.gares-en-mouvement.com/fr/frlpd/votre-gare' => 'frlpd',
  'http://www.gares-en-mouvement.com/fr/frhco/vore-gare/' => 'frhco',
  'https://www.kimonolabs.com/api/7jys32dy?apikey=lsOO4tNm78cH9JxqWg9gAk9l4nYaou9j&kimmodify=1' => 'search'
}

unless ENV['LIVE_TEST']
  begin
    require 'rubygems'
    require 'fakeweb'

    FakeWeb.allow_net_connect = false
    GARES_SAMPLES.each do |url, response|
      FakeWeb.register_uri(:get, url, response: read_fixture(response))
    end
  rescue LoadError
    puts 'Could not load FakeWeb, these tests will hit gares-en-mouvement.com'
    puts 'You can run `gem install fakeweb` to stub out the responses.'
  end
end
