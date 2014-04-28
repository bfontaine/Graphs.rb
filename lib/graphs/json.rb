#! /usr/bin/env ruby
# -*- coding: UTF-8 -*-

require 'json'
require_relative '../graph'

class Graph
    # Returns a JSON version of the current graph
    # @param opts [Hash] A customizable set of options
    # @return [String]
    # @see JSONGraph.unparse
    def to_json(opts=nil)
        JSONGraph::unparse(self, opts)
    end

    # Write the current graph into a JSON file. This method is used internally,
    # use Graph#write instead.
    # @param filename [String] a valid filename
    # @return []
    # @see JSON.unparse
    def write_json(filename, opts=nil)
        json = JSONGraph::unparse(self, opts)
        f = File.open(filename, 'w')
        f.write(json)
        f.close
    end
end

# JSON-related functions
module JSONGraph

    # Loads a JSON file and return a new Graph object
    # @param filename [String] a valid filename
    # @return [Graph]
    # @see JSONGraph.parse
    def self.load(filename)
        self.parse(File.read(filename))
    end

    # Parse some JSON text and return a new Graph object
    # @param content [String] a valid GDF String
    # @return [Graph]
    # @see JSONGraph.load
    # @see JSONGraph.unparse
    def self.parse(content)

        if (content.nil? || content.length == 0)
            return Graph.new([],[])
        end

        content = JSON.parse content

        nodes = content['nodes']
        edges = content['edges']

        Graph.new(nodes, edges)
    end

    # Return a JSON String which describe the given Graph
    # @param graph [Graph]
    # @param opts [Hash] A customizable set of options
    # @return [String]
    # @see Graph#write
    def self.unparse(graph, opts=nil)

        nodes = graph.nodes.map { |n| n.to_hash }
        edges = graph.edges.map { |e| e.to_hash }

        JSON.dump({ 'nodes' => nodes, 'edges' => edges })
    end
end
