require 'rubygems'
require 'bundler'

require 'sinatra/base'
require 'haml'
require 'coffee-script'
require 'sass'
require 'json'
require 'thin'

require './lib/application/sass_engine'
require './lib/application/coffee_engine'
require './lib/application/visualisation'
require './lib/application/application'
