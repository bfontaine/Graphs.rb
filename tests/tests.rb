#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require 'test/unit'
require 'tempfile'
require 'simplecov'

SimpleCov.start { add_filter '/tests/' } if ENV['COVERAGE']

require_relative '../lib/graph'
require_relative '../lib/graphs/gdf'
require_relative '../lib/graphs/json'

for t in Dir.glob( File.join( File.expand_path( File.dirname(__FILE__) ),  '*_tests.rb' ) )
    require t
end
