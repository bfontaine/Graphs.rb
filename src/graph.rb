#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

class Graph

    class NodeArray < Array

        def initialize(*args)
            super(*args)
            @defaults = {}
        end

        def set_default(dict)
            @defaults.update(dict)
            self.map! { |e| e.update(@defaults) }
        end

        def push(o)
            if (!o.is_a?(Hash))
                raise TypeError.new "#{o.inspect} is not an Hash!"
            end
            o2 = o.clone
            o2.update(@defaults)
            super
        end
    end

    class EdgeArray < NodeArray
    end

    attr_accessor :nodes, :edges

    def initialize(nodes=nil, edges=nil)
        @nodes = NodeArray.new(nodes || [])
        @edges = EdgeArray.new(edges || [])
    end

    def ==(other)
        if (!other.is_a?(GDF::Graph))
            return false
        end
        (self.nodes === other.nodes) && (self.edges == other.edges)
    end

    def &(other)
        if (!other.is_a?(GDF::Graph))
            return nil
        end

        nodes = @nodes & other.nodes
        edges = @edges & other.edges

        GDF::Graph.new(nodes, edges)
    end
end
