require 'rubygems'
require 'bundler'

Bundler.require(:default)
# require 'sass/plugin/rack'
require './lib/application/sass_engine'
require './lib/application/coffee_engine'
require './lib/application/visualisation'
require './lib/application/application'
# require './lib/application/coffee_engine'

# use scss for stylesheets
# Sass::Plugin.options[:style] = :compressed
# use Sass::Plugin::Rack

# use coffeescript for javascript
# use Rack::Coffee, root: 'application', urls: '/javascripts'
