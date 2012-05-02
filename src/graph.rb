#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require 'yaml'

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
        if (!other.is_a?(Graph))
            return false
        end
        (self.nodes === other.nodes) && (self.edges == other.edges)
    end

    def &(other)
        if (!other.is_a?(Graph))
            return nil
        end

        nodes = @nodes & other.nodes
        edges = @edges & other.edges

        Graph.new(nodes, edges)
    end

    def write(filename, opts=nil)

        has_ext = filename.split('.')

        if ((has_ext.length == 1) || (has_ext[-1] == 'yml'))
            # YAML (default)
            nodes = self.nodes.to_a
            edges = self.edges.to_a

            data = {'nodes'=>nodes, 'edges'=>edges}.to_yaml
            f = open(filename+'.yml', 'w')
            f.write(data)
            f.close
        else
            ext = has_ext[-1]

            m = (self.methods - Object.methods).map {|e| e.to_s}

            if (m.include? '_write_'+ext.downcase)
                self.send('_write_'+ext.downcase, filename, opts)
            end
        end

    end
end
