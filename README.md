# Gares (en-mouvement)

[![Build Status](https://travis-ci.org/paulRbr/gares.svg)](https://travis-ci.org/paulRbr/gares) [![Gem Version](https://badge.fury.io/rb/gares.svg)](http://badge.fury.io/rb/gares) [![Coverage Status](https://coveralls.io/repos/paulRbr/gares/badge.svg)](https://coveralls.io/r/paulRbr/gares)

## Description

The Gares gem allows you to easy access publicly available data from gares-en-mouvement.com.

## Features

Gares currently features the following:

* Search for a gare
* Retrieve gare information

## Examples

### Gare:

    g = Gares::Gare.new("frlpd")

    g.name
    #=> "Lyon Part Dieu"

    g.wifi?
    #=> true

    g.has_borne?
    #=> true
    
    g.services.first
    #=> "Services à la clientèle"

### Searching:

    g = Gares::Search.new("Aix")

    g.gares.size
    #=> 7
    
    # or
    
    gares = Gares::Gare.search("lyon")
    
    gares.last.name
    #=> "Paris Gare de Lyon"

## Installation

    gem install gares

Or, if you're using this in a project with Bundler:

    gem gares

## Running Tests

As this gem uses content from gare-en-mouvement.com, the test suite uses a set of
pre-defined fixute files in `spec/fixtures`. These fixtures are
copies of gares-en-mouvement page used in tests.

Run bundle install to install all dependencies, including fakeweb, which
will serve the fixture files instead of doing actual requests to gares-en-mouvement.com.

    $ bundle install

Next, simple run `rake` to run the entire test suite.

### Running against actual gare-en-mouvement data

It's possible to run the test suite directly against gares-en-mouvement.com. This has
two disadvantages:

 1. Tests will be slow
 2. Running tests often will probably get you into trouble, see Disclaimer.

    $ LIVE_TEST=true rake

If you want to run against actual gares-en-mouvement data, it's better to just update
the fixture files once with up-to-date content:

    $ rake fixtures:refresh

When you run the test suite now, it will use the updated fixture files.

## Disclaimer

Neither I, nor any developer who contributed to this project, accept any kind of
liability for your use of this library.

gares-en-mouvement does not permit use of its data by third parties without their consent.

Using this library for anything other than limited personal use may result
in an IP ban to the gares-en-mouvement website.

_This gem is not endorsed or affiliated with gares-en-mouvement.com, or SNCF, Inc._

## License

See [MIT-LICENSE](https://github.com/paulrbr/gares/blob/master/MIT-LICENSE)
