require 'rubygems'
require 'sinatra'
require 'haml'
require 'beats'
require 'uuid'
require './beatblox'

set :environment, :production
set :run, false

run Sinatra::Application