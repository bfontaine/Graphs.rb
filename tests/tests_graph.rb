#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require 'test/unit'
require 'yaml'
require 'graph'

class Graph_test < Test::Unit::TestCase

    @@sample_graph = Graph.new(
        [
            {'label'=>'foo', 'id'=>2},
            {'label'=>'bar', 'id'=>1},
            {'label'=>'chuck', 'id'=>3}
        ],
        [
            {'node1'=>'foo', 'node2'=>'bar'},
            {'node1'=>'bar', 'node2'=>'foo'},
            {'node1'=>'bar', 'node2'=>'chuck'},
            {'node1'=>'foo', 'node2'=>'chuck'}
        ]
    )

    @@sample_graph_1 = Graph.new(
        [
            {'label'=>'bar', 'num'=>3},
            {'label'=>'foo', 'num'=>42},
            {'label'=>'chuck', 'num'=>78}
        ],
        [
            {'node1'=>'foo', 'node2'=>'bar', 'time'=>1.0},
            {'node1'=>'bar', 'node2'=>'foo', 'time'=>2.5},
            {'node1'=>'foo', 'node2'=>'chuck', 'time'=>3.1}
        ]
    )

    def test_new_empty_graph
        g = Graph.new

        assert_equal([], g.nodes)
        assert_equal([], g.edges)
    end

    # == Graph#== == #

    def test_equal_graphs
        g1 = @@sample_graph
        g2 = @@sample_graph.clone()

        assert_equal(true, g1==g2)
    end

    # == Graph::NodeArray#set_default == #

    def test_nodearray_set_default_unexisting_property
        g = Graph.new([{'name'=>'foo'}, {'name'=>'bar'}])
        g.nodes.set_default 'age' => 21

        assert_equal(21, g.nodes[0]['age'])
        assert_equal(21, g.nodes[1]['age'])
    end

    def test_nodearray_set_default_existing_property
        g = Graph.new([{'name'=>'foo', 'age'=>42}, {'name'=>'bar'}])
        g.nodes.set_default 'age' => 21

        assert_equal(21, g.nodes[0]['age'])
        assert_equal(21, g.nodes[1]['age'])
    end

    def test_nodearray_set_default_unexisting_property_before_push
        g = Graph.new([{'name'=>'foo'}])
        g.nodes.set_default 'city' => 'Paris'
        g.nodes.push({'name' => 'bar'})

        assert_equal('Paris', g.nodes[0]['city'])
        assert_equal('Paris', g.nodes[0]['city'])
    end

    def test_nodearray_set_default_existing_property_before_push
        g = Graph.new([{'name'=>'foo', 'city'=>'London'}])
        g.nodes.set_default 'city' => 'Paris'
        g.nodes.push({'name' => 'bar'})

        assert_equal('Paris', g.nodes[0]['city'])
        assert_equal('Paris', g.nodes[0]['city'])
    end

    # == Graph::edgeArray#set_default == #

    def test_edgearray_set_default_unexisting_property
        g = Graph.new([],[{'node1'=>'foo', 'node2'=>'bar'}])
        g.edges.set_default 'directed' => true

        assert_equal(true, g.edges[0]['directed'])
    end

    def test_edgearray_set_default_existing_property
        g = Graph.new([],
                           [{'node1'=>'foo', 'node2'=>'bar', 'directed'=>true},
                            {'node1'=>'bar', 'node2'=>'foo'}])
        g.edges.set_default 'directed' => false

        assert_equal(false, g.edges[0]['directed'])
        assert_equal(false, g.edges[1]['directed'])
    end

    def test_edgearray_set_default_unexisting_property_before_push
        g = Graph.new([], [{'node1'=>'foo', 'node2'=>'bar'}])
        g.edges.set_default 'directed' => true
        g.edges.push({'node1' => 'bar', 'node2'=>'foo'})

        assert_equal(true, g.edges[0]['directed'])
        assert_equal(true, g.edges[0]['directed'])
    end

    def test_edgearray_set_default_existing_property_before_push
        g = Graph.new([], [{'node1'=>'foo', 'node2'=>'bar', 'directed'=>true}])
        g.edges.set_default 'node2' => 'foo'
        g.edges.push({'node1' => 'bar', 'node2' => 'foo'})

        assert_equal('foo', g.edges[0]['node2'])
        assert_equal('foo', g.edges[0]['node2'])
    end

    # == Graph#& == #

    def test_empty_graph_AND_empty_graph
        g1 = Graph.new
        g2 = Graph.new

        assert_equal(g1, g1 & g2)
    end

    def test_one_node_graph_AND_empty_graph
        g = Graph.new([{'label'=>'foo'}])
        empty = Graph.new

        assert_equal(empty, g & empty)
    end

    def test_empty_graph_AND_one_node_graph
        g = Graph.new([{'label'=>'foo'}])
        empty = Graph.new

        assert_equal(empty, empty & g)
    end

    def test_sample_graph_AND_itself
        g = @@sample_graph

        assert_equal(g, g & g)
    end

    def test_one_node_graph_AND_one_other_node_graph
        g = Graph.new([{'label'=>'foo'}])
        h = Graph.new([{'label'=>'bar'}])
        empty = Graph.new

        assert_equal(empty, g & h)
    end

    def test_sample_graph_AND_no_graph
        g = @@sample_graph

        assert_equal(nil, g & 2)
        assert_equal(nil, g & true)
        assert_equal(nil, g & false)
        assert_equal(nil, g & ['foo', 'bar'])
        assert_equal(nil, g & {'foo'=>'bar'})
        assert_equal(nil, g & 'foo')
    end

    def test_AND_2_graphs_same_nodes_different_labels
        g1 = @@sample_graph
        g2 = @@sample_graph_1
        empty = Graph.new

        assert_equal(empty, g1 & g2)
    end

    # == Graph#write == #

    def test_graph_write_no_ext
        g = @@sample_graph
        f = '/tmp/_graph_test'
        g.write(f)
        assert_equal(true, File.exists?(f))
        
        dict = YAML.load(File.open(f))
        assert_equal(g.nodes, dict['nodes'])
        assert_equal(g.edges, dict['edges'])
    end

    def test_graph_write_unknow_ext
        g = @@sample_graph
        f = '/tmp/_graph_test.foo'
        assert_raise(NoMethodError) do
            g.write(f)
        end
        assert_equal(false, File.exists?(f))
    end
end
