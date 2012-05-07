#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require 'test/unit'
require 'graphs/gexf'

class GEXF_Graph_test < Test::Unit::TestCase

    def setup
        @@sample_gexf  = '<?xml version="1.0" encoding="UTF-8"?>'
        @@sample_gexf += '<gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">'
        @@sample_gexf += '<graph mode="static" defaultedgetype="directed">'
        @@sample_gexf += '<nodes>'
        @@sample_gexf += '<node id="0" label="Hello" />'
        @@sample_gexf += '<node id="1" label="Word" />'
        @@sample_gexf += '</nodes>'
        @@sample_gexf += '<edges>'
        @@sample_gexf += '<edge id="0" source="0" target="1" />'
        @@sample_gexf += '</edges>'
        @@sample_gexf += '</graph>'
        @@sample_gexf += '</gexf>'
    end
end
