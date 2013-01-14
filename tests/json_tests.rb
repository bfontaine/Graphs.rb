#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require_relative '../lib/graphs/json'

module JSONUtils
    def self.get_sample_graph
        @@json
    end

    @@json = <<EOJSON
{
    "nodes" : [
        { "label": "foo" }, { "label": "bar" }
    ],
    "edges" : [
        { "node1": "bar", "node2": "foo" }
    ]
}
EOJSON

    @@json.gsub!(/\s+/, '')
end

class JSON_Graph_test < Test::Unit::TestCase

    # == Graph#to_json == #

    def test_empty_graph_to_json
        g = Graph.new
        empty_json = '{"nodes":[],"edges":[]}'
        assert_equal(empty_json, g.to_json)
    end

    def test_sample_graph_to_json
        json = JSONUtils::get_sample_graph
        g = JSONGraph::parse(json)
        assert_equal(json, g.to_json)
    end

    # == Graph#write('….json') == #

    def test_empty_graph_write_json
        g = Graph.new
        
        f = Tempfile.new([ 'foo', '.json' ])
        f.close

        g.write(f.path)
        g2 = JSONGraph.load(f.path)

        assert_equal(g, g2)
        f.unlink
    end

    def setup
        if File.exists? '/tmp/_graph_test.json'
            File.delete '/tmp/_graph_test.json'
        end
    end

end
