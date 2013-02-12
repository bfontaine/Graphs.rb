#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

class Edge_test < Test::Unit::TestCase
    
    def setup
        @@empty = Graph::Node.new
        @@alice = Graph::Node.new('label' => 'Alice')
    
        # Alice ----> Bob
        #   ↑          ↑
        #   |          |
        # Oscar -------'
        @@sample_graph = Graph.new(
            [
                { 'label' => 'Alice' },
                { 'label' => 'Bob'   },
                { 'label' => 'Oscar' }
            ],
            [
                { 'node1' => 'Alice', 'node2' => 'Bob' },
                { :node1  => 'Oscar', 'node2' => 'Alice'},
                { 'node1' => 'Oscar', :node2  => 'Bob'}
            ]
        )
    
    end

    def test_edge_node1_attr
        assert_equal('Alice', @@sample_graph.edges[0].node1)
        assert_equal('Oscar', @@sample_graph.edges[1].node1)
    end

    def test_edge_node2_attr
        assert_equal('Alice', @@sample_graph.edges[1].node2)
        assert_equal('Bob', @@sample_graph.edges[2].node2)
    end

    def test_edge_update

        e = Graph::Edge.new

        assert_equal(true, e.update({}).is_a?(Graph::Edge))
    end

end
