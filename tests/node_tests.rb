#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require 'test/unit'
require_relative '../lib/graph'

class Node_test < Test::Unit::TestCase
    
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
                { 'node1' => 'Oscar', 'node2' => 'Alice'},
                { 'node1' => 'Oscar', 'node2' => 'Bob'}
            ]
        )
    
    end

    def test_create_graph_with_node_objects
        g1 = Graph.new([
            Graph::Node.new('label' => 'Foo')
        ])

        g2 = Graph.new([
            { 'label' => 'Foo' }
        ])

        assert_equal(g2, g1)
    end

    def test_node_attrs
        a = @@alice

        a['foo'] = 'bar'

        assert_equal('Alice', @@alice['label'])
        assert_equal('bar',   @@alice['foo'])
        assert_equal(nil,     @@alice['fooo'])
    end

end
