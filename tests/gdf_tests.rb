#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

module Utils
    def self.get_sample_graph
        @@sample_graph_1
    end

    @@sample_graph_1  = "nodedef>label VARCHAR,num INT,biglabel VARCHAR\n"
    @@sample_graph_1 += "toto,14,TOTO\nlala,5,LALA\ntiti,988,TITI\n"
    @@sample_graph_1 += "edgedef>node1 VARCHAR,node2 VARCHAR,directed BOOLEAN\n"
    @@sample_graph_1 += "toto,lala,true\nlala,titi,true\n"
    @@sample_graph_1 += "titi,lala,false\ntiti,toto,true\n"
end

class GDF_Graph_test < Test::Unit::TestCase

    # == Graph#to_gdf == #

    def test_empty_graph_to_gdf
        g = Graph.new
        empty_gdf = "nodedef>"

        assert_equal(empty_gdf, g.to_gdf)
    end

    def test_sample_graph_to_gdf
        gdf = Utils::get_sample_graph
        g = GDF::parse(gdf)
        assert_equal(gdf, g.to_gdf)
    end

    # == Graph#write('….gdf') == #

    def test_empty_graph_write_gdf
        g = Graph.new

        f = Tempfile.new([ 'foo', '.gdf' ])
        f.close

        g.write(f.path)
        g2 = GDF.load(f.path)

        assert_equal(g, g2)
        f.unlink
    end
end

class GDF_test < Test::Unit::TestCase

    # == GDF::parse == #

    def test_parse_empty_graph
        g = GDF::parse('')

        assert_equal([], g.nodes)
        assert_equal([], g.edges)
    end

    def test_parse_empty_graph_with_nodedef

        s = "nodedef>label VARCHAR\n" 

        g = GDF::parse(s)

        assert_equal([], g.nodes)
        assert_equal([], g.edges)
    end

    def test_parse_empty_graph_with_nodedef_and_edgedef
        s = "nodedef>label VARCHAR\nedgedef>node1 VARCHAR,node2 VARCHAR\n"
        g = GDF::parse(s)

        assert_equal([], g.nodes)
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge_string_field
        s = "nodedef>label VARCHAR\nfoo\n"
        g = GDF::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal('foo', g.nodes[0]['label'])
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge_tinyint_field
        s = "nodedef>num TINYINT\n3\n"
        g = GDF::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal(3, g.nodes[0]['num'])
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge_smallint_field
        s = "nodedef>num SMALLINT\n3\n"
        g = GDF::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal(3, g.nodes[0]['num'])
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge_int_field
        s = "nodedef>num INT\n3\n"
        g = GDF::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal(3, g.nodes[0]['num'])
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge_negative_int_field
        s = "nodedef>num INT\n-1337\n"
        g = GDF::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal(-1337, g.nodes[0]['num'])
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge_bigint_field
        s = "nodedef>num BIGINT\n3\n"
        g = GDF::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal(3, g.nodes[0]['num'])
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge_float_field
        s = "nodedef>num FLOAT\n3\n"
        g = GDF::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal(3.0, g.nodes[0]['num'])
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge_double_field
        s = "nodedef>num FLOAT\n3\n"
        g = GDF::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal(3.0, g.nodes[0]['num'])
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge_real_field
        s = "nodedef>num FLOAT\n3\n"
        g = GDF::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal(3.0, g.nodes[0]['num'])
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge_negative_real_field
        s = "nodedef>num FLOAT\n-42.14\n"
        g = GDF::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal(-42.14, g.nodes[0]['num'])
        assert_equal([], g.edges)
    end

    def test_parse_one_node_no_edge_unknow_field_type
        s = "nodedef>foo BAR\nfoobar"
        g = GDF::parse(s)

        assert_equal(1, g.nodes.length)
        assert_equal('foobar', g.nodes[0]['foo'])
        assert_equal([], g.edges)
    end

    def test_parse_sample_graph
        g = GDF::parse(Utils::get_sample_graph)

        assert_equal(3, g.nodes.length)
        assert_equal(4, g.edges.length)

        assert_equal('toto', g.nodes[0]['label'])
        assert_equal('TOTO', g.nodes[0]['biglabel'])
        assert_equal(988, g.nodes[2]['num'])

        assert_equal('toto', g.edges[0]['node1'])
        assert_equal('lala', g.edges[0]['node2'])
        assert_equal(false, g.edges[2]['directed'])

    end

    # == GDF::unparse == #

    def test_unparse_empty_graph
        g = Graph.new

        s = GDF::unparse(g)

        assert_equal("nodedef>", s)
    end

    def test_unparse_sample_graph
        g1 = GDF::parse(Utils::get_sample_graph)
        g2 = GDF::parse(GDF::unparse(g1))

        assert_equal(g1, g2)
    end

    def test_unparse_big_int_gephi
        g = Graph.new([{'n'=>9999999999999999}])
        gdf = GDF::unparse(g, {:gephi=>true})

        assert_equal("nodedef>n INT\n9999999999999999\nedgedef>", gdf)

    end
end
