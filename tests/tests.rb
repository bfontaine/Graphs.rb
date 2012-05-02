#! /usr/bin/ruby1.9.1

require '../src/gdf'
require 'test/unit'

class GDF_test < Test::Unit::TestCase

    @@sample_graph_1  = "nodedef>label VARCHAR, num INT, biglabel VARCHAR\n"
    @@sample_graph_1 += "toto, 14, TOTO\nlala, 5, LALA\ntiti, 988, TITI\n"
    @@sample_graph_1 += "edgedef>node1 VARCHAR, node2 VARCHAR, directed BOOLEAN\n"
    @@sample_graph_1 += "toto, lala, true\nlala, titi, true\n"
    @@sample_graph_1 += "titi, lala, false\ntiti, toto, true\n"

    def get_sample_filename
        "/tmp/test_graph_#{rand(9999)}.gdf"
    end

    # == GDF::Graph.new == #

    def test_new_empty_graph
        g = GDF::Graph.new

        assert_equal([], g.nodes)
        assert_equal([], g.edges)
    end

    # == GDF::Graph#== == #

    def test_equal_graphs
        g1 = GDF::parse(@@sample_graph_1)
        g2 = GDF::parse(@@sample_graph_1)

        assert_equal(true, g1==g2)
    end

    # == GDF::Graph#write == #

    def test_write_empty_graph

        f = get_sample_filename

        g = GDF::Graph.new
        g.write(f)

        assert_equal(true, File.exists?(f))
        
        content = File.read(f)

        assert_equal('nodedef>', content)
    end

    def test_write_sample_graph

        f = get_sample_filename

        GDF::parse(@@sample_graph_1).write(f)

        assert_equal(true, File.exists?(f))

        content = File.read(f)

        g0 = GDF::parse(@@sample_graph_1)
        g1 = GDF::parse(content)

        assert_equal(g0, g1)
    end

    # == GDF::Graph::NodeArray#set_default == #

    def test_nodearray_set_default_unexisting_property
        g = GDF::Graph.new([{'name'=>'foo'}, {'name'=>'bar'}])
        g.nodes.set_default 'age' => 21

        assert_equal(21, g.nodes[0]['age'])
        assert_equal(21, g.nodes[1]['age'])
    end

    def test_nodearray_set_default_existing_property
        g = GDF::Graph.new([{'name'=>'foo', 'age'=>42}, {'name'=>'bar'}])
        g.nodes.set_default 'age' => 21

        assert_equal(21, g.nodes[0]['age'])
        assert_equal(21, g.nodes[1]['age'])
    end

    def test_nodearray_set_default_unexisting_property_before_push
        g = GDF::Graph.new([{'name'=>'foo'}])
        g.nodes.set_default 'city' => 'Paris'
        g.nodes.push({'name' => 'bar'})

        assert_equal('Paris', g.nodes[0]['city'])
        assert_equal('Paris', g.nodes[0]['city'])
    end

    def test_nodearray_set_default_existing_property_before_push
        g = GDF::Graph.new([{'name'=>'foo', 'city'=>'London'}])
        g.nodes.set_default 'city' => 'Paris'
        g.nodes.push({'name' => 'bar'})

        assert_equal('Paris', g.nodes[0]['city'])
        assert_equal('Paris', g.nodes[0]['city'])
    end

    # == GDF::Graph::edgeArray#set_default == #

    def test_edgearray_set_default_unexisting_property
        g = GDF::Graph.new([],[{'node1'=>'foo', 'node2'=>'bar'}])
        g.edges.set_default 'directed' => true

        assert_equal(true, g.edges[0]['directed'])
    end

    def test_edgearray_set_default_existing_property
        g = GDF::Graph.new([],
                           [{'node1'=>'foo', 'node2'=>'bar', 'directed'=>true},
                            {'node1'=>'bar', 'node2'=>'foo'}])
        g.edges.set_default 'directed' => false

        assert_equal(false, g.edges[0]['directed'])
        assert_equal(false, g.edges[1]['directed'])
    end

    def test_edgearray_set_default_unexisting_property_before_push
        g = GDF::Graph.new([], [{'node1'=>'foo', 'node2'=>'bar'}])
        g.edges.set_default 'directed' => true
        g.edges.push({'node1' => 'bar', 'node2'=>'foo'})

        assert_equal(true, g.edges[0]['directed'])
        assert_equal(true, g.edges[0]['directed'])
    end

    def test_edgearray_set_default_existing_property_before_push
        g = GDF::Graph.new([],
                           [{'node1'=>'foo', 'node2'=>'bar', 'directed'=>true}])
        g.edges.set_default 'node2' => 'foo'
        g.edges.push({'node1' => 'bar', 'node2' => 'foo'})

        assert_equal('foo', g.edges[0]['node2'])
        assert_equal('foo', g.edges[0]['node2'])
    end

    # == GDF::Graph#& == #

    def test_empty_graph_AND_empty_graph
        g1 = GDF::Graph.new
        g2 = GDF::Graph.new

        assert_equal(g1, g1 & g2)
    end

    def test_one_node_graph_AND_empty_graph
        g = GDF::Graph.new([{'label'=>'foo'}])
        empty = GDF::Graph.new

        assert_equal(empty, g & empty)
    end

    def test_empty_graph_AND_one_node_graph
        g = GDF::Graph.new([{'label'=>'foo'}])
        empty = GDF::Graph.new

        assert_equal(empty, empty & g)
    end

    def test_sample_graph_AND_itself
        g = GDF::parse(@@sample_graph_1)

        assert_equal(g, g & g)
    end

    def test_one_node_graph_AND_one_other_node_graph
        g = GDF::Graph.new([{'label'=>'foo'}])
        h = GDF::Graph.new([{'label'=>'bar'}])
        empty = GDF::Graph.new

        assert_equal(empty, g & h)
    end

    def test_sample_graph_AND_no_graph
        g = GDF::parse(@@sample_graph_1)

        assert_equal(nil, g & 2)
        assert_equal(nil, g & true)
        assert_equal(nil, g & false)
        assert_equal(nil, g & ['foo', 'bar'])
        assert_equal(nil, g & {'foo'=>'bar'})
        assert_equal(nil, g & 'foo')
    end

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
        g = GDF::parse(@@sample_graph_1)

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
        g = GDF::Graph.new

        s = GDF::unparse(g)

        assert_equal("nodedef>", s)
    end

    def test_unparse_sample_graph
        g1 = GDF::parse(@@sample_graph_1)
        g2 = GDF::parse(GDF::unparse(g1))

        assert_equal(g1, g2)
    end

    def test_unparse_big_int_gephi
        g = GDF::Graph.new([{'n'=>9999999999999999}])
        gdf = GDF::unparse(g, {:gephi=>true})

        assert_equal("nodedef>n INT\n9999999999999999\nedgedef>", gdf)

    end

end
