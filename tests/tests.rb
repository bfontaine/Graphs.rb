#! /usr/bin/env ruby
# -*- coding: UTF-8 -*-

require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'simplecov'
require 'tempfile'

test_dir = File.expand_path( File.dirname(__FILE__) )

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start { add_filter '/tests/' }

require_relative '../lib/graph'
require_relative '../lib/graphs/gdf'
require_relative '../lib/graphs/json'

for t in Dir.glob( File.join( test_dir,  '*_tests.rb' ) )
    require t
end

exit Test::Unit::AutoRunner.run
