# -*- coding: UTF-8 -*-

require 'yaml'
require_relative '../graph'

class Graph
    # Returns a Dot version of the current graph
    # @param opts [Hash] A customizable set of options
    # @see Dot::unparse
    def to_dot(opts=nil)
        Dot::unparse(self, opts)
    end

    # Write the current graph into a Dot file. This method is used internally,
    # use Graph#write instead.
    # @param filename [String] a valid filename
    # @see Dot::unparse
    def write_dot(filename, opts=nil)
        dot = Dot::unparse(self, opts)
        f = File.open(filename, 'w')
        f.write(dot)
        f.close
    end

    # @see Graph#write_dot
    def write_gv(filename, opts=nil)
        self.write_dot(filename, opts)
    end
end

# Dot Language-related functions. Note that Dot extension is `.gv`
module Dot

    # default graph name = @@default_name + @@default_name_cursor
    @@default_name = 'graph'
    @@default_name_cursor = 0

    # Loads a Dot file and return a new Graph object
    # @param filename [String] a valid filename
    # @see Dot::parse
    def self.load(filename)
        self.parse(File.read(filename))
    end

    # Parse some Dot text and return a new Graph object
    # @param content [String] a valid Dot String
    # @see Dot::load
    # @see Dot::unparse
    def self.parse(content)

        if (content.nil? || content.length == 0)
            return Graph.new([],[])
        end

        #TODO
    end

    # Return a Dot String which describe the given Graph
    # @param graph [Graph]
    # @param opts [Hash] A customizable set of options
    # @see Graph#write
    def self.unparse(graph, opts=nil)
        directed = graph.attrs[:directed] || graphs.attrs['directed']

        dot = (directed ? 'di' : '') + 'graph '

        name = graph.attrs[:name] || graphs.attrs['name'] || next_name

        dot += name + "{\n"
        #TODO
        

        dot + "}\n"
    end

    private

    # Return the next default graph name. It is a string followed by a
    # incremented number.
    def next_name
        "#{@@default_name}#{@@default_name_cursor+=1}"
    end
end
