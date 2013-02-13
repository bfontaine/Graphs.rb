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

    def test_edge_init_with_another_edge

        e = Graph::Edge.new({ :foo => 'bar' })

        assert_equal( e, Graph::Edge.new(e) )

    end

end

class EdgeArray_test < Test::Unit::TestCase

    def test_edgearray_push_edge

        e = Graph::Edge.new({ :foo => 42 })
        ea = Graph::EdgeArray.new([])

        ea.push(e)

        assert_equal(e, ea[0])

    end

    def test_edgearray_push_hash

        e = { :foo => 42 }
        ea = Graph::EdgeArray.new([])

        ea.push(e)

        assert_equal(Graph::Edge.new(e), ea[0])

    end

    def test_edgearray_push_no_edge_nor_hash

        ea = Graph::EdgeArray.new([])

        assert_raise(TypeError) do

            ea.push(42)

        end

    end

end
