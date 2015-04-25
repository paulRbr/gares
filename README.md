# Gares - A gem to interact with French train Stations

[![Build Status](https://travis-ci.org/paulRbr/gares.svg)](https://travis-ci.org/paulRbr/gares) [![Gem Version](https://badge.fury.io/rb/gares.svg)](http://badge.fury.io/rb/gares) [![Coverage Status](https://coveralls.io/repos/paulRbr/gares/badge.svg)](https://coveralls.io/r/paulRbr/gares)

## Description

The Gares gem allows you to easily access publicly available data from gares-en-mouvement.com.

## Features

Gares currently features the following:

* Search for a station
* Retrieve station information

## Examples

### Station:

    g = Gares::Station.new("frlpd")

    g.name
    #=> "Lyon Part Dieu"

    g.wifi?
    #=> true

    g.has_borne?
    #=> true

    g.services.first
    #=> "Services à la clientèle"

    [g.lat, g.long]
    #=> [45.760281, 4.859801]

### Searching:

    g = Gares::Search.new("Aix")

    g.stations.size
    #=> 7

    # or

    stations = Gares::Station.search("lyon")
    station = stations.last

    station.name
    #=> "Paris Gare de Lyon"

## Installation

    gem install gares

Or if you want to use it in a project add this to your `Gemfile`:

    gem "gares"

## Running Tests

As this gem uses external content from gare-en-mouvement.com and sncf.com, the test suite uses a set of
pre-defined fixture files in `spec/fixtures`. These fixtures are
copies of gares-en-mouvement.com and sncf.com pages used in tests.

Run bundle install to install all dependencies, including fakeweb, which
will serve the fixture files instead of doing actual requests to gares-en-mouvement.com or sncf.com.

    $ bundle install

Next, simple run `rake` to run the entire test suite.

### Running against real data

It's possible to run the test suite directly against gares-en-mouvement.com or sncf.com. This has
two disadvantages:

 1. Tests will be slow
 2. Running tests often will probably get you into trouble, see Disclaimer.

    $ LIVE_TEST=true rake

If you want to run against actual data, it's better to just update
the fixture files once with up-to-date content:

    $ rake fixtures:refresh

When you run the test suite now, it will use the updated fixture files.

## Disclaimer

Neither I, nor any developer who contributed to this project, accept any kind of
liability for your use of this library.

gares-en-mouvement.com and sncf.com certainly does not permit use of its data by third parties without their consent.

Using this library for anything other than limited personal use may result
in an IP ban to the gares-en-mouvement.com or sncf.com website.

_This gem is not endorsed or affiliated with gares-en-mouvement.com, nor SNCF, Inc._

## License

See [MIT-LICENSE](https://github.com/paulrbr/gares/blob/master/MIT-LICENSE)
