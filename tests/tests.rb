#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require 'test/unit'
require 'tempfile'
require 'simplecov'

test_dir = File.expand_path( File.dirname(__FILE__) )

SimpleCov.start { add_filter '/tests/' } if ENV['COVERAGE']

require_relative '../lib/graph'
require_relative '../lib/graphs/gdf'
require_relative '../lib/graphs/json'

for t in Dir.glob( File.join( test_dir,  '*_tests.rb' ) )
    require t
end

exit Test::Unit::AutoRunner.run
