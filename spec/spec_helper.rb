# By default if you have the FakeWeb gem installed when the specs are
# run they will hit recorded responses.  However, if you don't have
# the FakeWeb gem installed or you set the environment variable
# LIVE_TEST then the tests will hit the live site gares-sncf.com and sncf.com.
#
# Having both methods available for testing allows you to quickly
# refactor and add features, while also being able to make sure that
# no changes to the gares-sncf.com interface have affected the parser.
###

require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

def read_fixture(path)
  File.read(File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', path)))
end

# Fixtures for Gares
GARES_SAMPLES = {
  'https://raw.githubusercontent.com/captaintrain/stations/master/stations.csv' => 'stations.csv',
  'https://ressources.data.sncf.com/api/records/1.0/search?dataset=referentiel-gares-voyageurs&q=0087723197' => '87723197.json', # Lyon Part-Dieu
  'https://ressources.data.sncf.com/api/records/1.0/search?dataset=referentiel-gares-voyageurs&q=0087271007' => '87271007.json', # Paris Gare-du-Nord
  'https://ressources.data.sncf.com/api/records/1.0/search?dataset=referentiel-gares-voyageurs&q=0088140010' => '88140010.json', # Bruxelles Midi
  'http://www.gares-sncf.com/fr/train-times/arrival/LYD/gl' => 'LYD-arrivals.json',
  'http://www.gares-sncf.com/fr/train-times/departure/LYD/gl' => 'LYD-departures.json'
}

# Sample fixtures for Trains
TRAINS_SAMPLES = [
  { 17709 => 'train-17709' },
  { 11641 => 'train-11641' },
  { 17495 => 'train-17495' },
  { 12345 => 'train-12345' },
  { 6815  => 'train-6815'  }, # Multi-itinerary see MULTI_TRAINS_SAMPLES
]

MULTI_TRAINS_SAMPLES = [
  { 6815  => ['train-6815-0', 'train-6815-1'] },
]

unless ENV['LIVE_TEST']
  begin
    require 'rubygems'
    require 'fakeweb'

    FakeWeb.allow_net_connect = %r[^https?://coveralls.io]
    GARES_SAMPLES.each do |url, response|
      FakeWeb.register_uri(:get, url, response: read_fixture(response))
    end
  rescue LoadError
    puts 'Could not load FakeWeb, these tests will hit gares-sncf.com and sncf.com'
    puts 'You can run `gem install fakeweb` to stub out the responses.'
  end
end

def fake_response_for_train(number)
  unless ENV['LIVE_TEST']
    begin
      response = TRAINS_SAMPLES.find { |sample| sample.keys.first == number }.values.first
      multi_responses = MULTI_TRAINS_SAMPLES.find { |sample| sample.keys.first == number }
      multi_responses = multi_responses.nil? ? [] : multi_responses.values.first
      sncf_result_url = 'http://www.sncf.com/en/horaires-info-trafic/train/resultats'
      FakeWeb.register_uri(:get, sncf_result_url, response: read_fixture("get-#{response}"))
      sncf_post_url = 'http://www.sncf.com/sncf/train'
      FakeWeb.register_uri(:post, sncf_post_url, response: read_fixture("post-#{response}"))
      multi_responses.each_with_index do |multi_response, idx|
        sncf_get_multi_url = "http://www.sncf.com/sncf/train/displayDetailTrain?idItineraire=#{idx}"
        FakeWeb.register_uri(:get, sncf_get_multi_url, response: read_fixture("get-#{multi_response}"))
        sncf_get_data_url = "http://www.sncf.com/en/horaires-info-trafic/train/resultats?#{idx}"
        FakeWeb.register_uri(:get, sncf_get_data_url, response: read_fixture("get-#{multi_response}-data"))
      end
    rescue LoadError
      puts 'Could not load FakeWeb, these tests will hit gares-sncf.com and sncf.com'
      puts 'You can run `gem install fakeweb` to stub out the responses.'
    end
  end
end

# Now that we mocked http requests, load the gem
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'gares'
