#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require 'test/unit'
require_relative '../lib/graph'

for t in Dir.glob(File.dirname(__FILE__)+'/*_tests.rb')
    require t
end

