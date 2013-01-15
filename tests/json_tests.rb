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

class JSON_test < Test::Unit::TestCase

    # == JSON::parse == #

    def test_parse_empty_graph
        g = JSONGraph::parse('')

        assert_equal([], g.nodes)
        assert_equal([], g.edges)
    end

    def test_parse_empty_graph_with_nodes_list

        s = '{"nodes":[]}' 

        g = JSONGraph::parse(s)

        assert_equal([], g.nodes)
        assert_equal([], g.edges)
    end

    def test_parse_empty_graph_with_nodes_and_edges_lists
        s = '{"nodes":[],"edges":[]}'
        g = JSONGraph::parse(s)

        assert_equal([], g.nodes)
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge
        s = '{"nodes":[{"label":"foo"}]}'
        g = JSONGraph::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal('foo', g.nodes[0]['label'])
        assert_equal([], g.edges)
    end

    def test_parse_sample_graph
        g = JSONGraph::parse(JSONUtils::get_sample_graph)

        assert_equal(2, g.nodes.length)
        assert_equal(1, g.edges.length)

        assert_equal('foo', g.nodes[0]['label'])
        assert_equal('bar', g.nodes[1]['label'])

        assert_equal('bar', g.edges[0]['node1'])
        assert_equal('foo', g.edges[0]['node2'])

    end

    # == JSON::unparse == #

    def test_unparse_empty_graph
        g = Graph.new

        s = JSONGraph::unparse(g)

        assert_equal('{"nodes":[],"edges":[]}', s)
    end

    def test_unparse_sample_graph
        g1 = JSONGraph::parse(JSONUtils::get_sample_graph)
        g2 = JSONGraph::parse(JSONGraph::unparse(g1))

        assert_equal(g1, g2)
    end

end
