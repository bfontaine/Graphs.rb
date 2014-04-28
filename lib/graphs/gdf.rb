#! /usr/bin/env ruby
# -*- coding: UTF-8 -*-

require_relative '../graph'

class Graph
    # Returns a GDF version of the current graph
    # @param opts [Hash] A customizable set of options
    # @return [String]
    # @see GDF.unparse
    def to_gdf(opts=nil)
        GDF::unparse(self, opts)
    end

    # Write the current graph into a GDF file. This method is used internally,
    # use Graph#write instead.
    # @param filename [String] a valid filename
    # @return []
    # @see GDF.unparse
    def write_gdf(filename, opts=nil)
        gdf = GDF::unparse(self, opts)
        f = File.open(filename, 'w')
        f.write(gdf)
        f.close
    end
end

# GDF-related functions
module GDF

    # Loads a GDF file and return a new Graph object
    # @param filename [String] a valid filename
    # @see GDF.parse
    def self.load(filename)
        self.parse(File.read(filename))
    end

    # Parse some GDF text and return a new Graph object
    # @param content [String] a valid GDF String
    # @see GDF.load
    # @see GDF.unparse
    def self.parse(content)

        if (content.nil? || content.length == 0)
            return Graph.new([],[])
        end

        content = content.split("\n")

        # lines index of 'nodedef>' and 'edgedef>'
        nodes_def_index = -1
        edges_def_index = -1

        content.each_with_index do |l,i|
            if l.start_with? 'nodedef>'
                nodes_def_index = i
            elsif l.start_with? 'edgedef>'
                edges_def_index = i
            end

            if ((nodes_def_index >= 0) && (edges_def_index >= 0))
                break
            end
        end

        # no edges
        if (edges_def_index == -1)
            edges = []
            edges_def_index = content.length
        else
            edges = content[edges_def_index+1..content.length]
        end

        fields_split = /[\t ]*,[\t ]*/

        # only nodes lines
        nodes = content[nodes_def_index+1..[edges_def_index-1, content.length].min] || []

        nodes_def = content[nodes_def_index]
        nodes_def = nodes_def['nodedef>'.length..nodes_def.length].strip.split(fields_split)
        nodes_def.each_index do |i|
            nodes_def[i] = read_def(nodes_def[i])
        end

        nodes.each_with_index do |n,i|
            n2 = {}
            n = n.split(fields_split)
            n.zip(nodes_def).each do |val,label_type|
                label, type = label_type
                n2[label] = parse_field(val, type)
            end
            nodes[i] = n2
        end

          return Graph.new(nodes) if edges.empty?

        # only edges lines
        edges_def = content[edges_def_index]
        edges_def = edges_def['edgedef>'.length..edges_def.length].strip.split(fields_split)
        edges_def.each_index do |i|
            edges_def[i] = read_def(edges_def[i])
        end

        edges.each_with_index do |e,i|
            e2 = {}
            e = e.split(fields_split)

            e.zip(edges_def).each do |val,label_type|
                label, type = label_type
                e2[label] = parse_field(val, type)
            end
            edges[i] = e2
        end

        Graph.new(nodes, edges)
    end

    # Return a GDF String which describe the given Graph
    # @param graph [Graph]
    # @param opts [Hash] A customizable set of options
    # @return [String]
    # @see Graph#write
    def self.unparse(graph, opts=nil)
        # nodes
        gdf_s = 'nodedef>'

        if (graph.nodes.length == 0)
            return gdf_s
        end

        keys = graph.nodes[0].keys
        nodedef = keys.map { |k| [k, self.get_type(graph.nodes[0][k], opts)] }

        gdf_s += (nodedef.map {|nd| nd.join(' ')}).join(',') + "\n"

        graph.nodes.each do |n|
            gdf_s += n.values.join(',') + "\n"
        end

        # edges
        gdf_s += 'edgedef>'

        return gdf_s if graph.edges.empty?

        keys = graph.edges[0].keys
        edgedef = keys.map { |k| [k, self.get_type(graph.edges[0][k], opts)] }

        gdf_s += (edgedef.map {|ed| ed.join(' ')}).join(',') + "\n"

        graph.edges.each do |e|
            gdf_s += e.values.join(',') + "\n"
        end

        gdf_s
    end

    private

    # Read the value of a node/edge field, and return the value's
    # type (String)
    # @param v
    # @param opts [Hash]
    # @return [String]
    def self.get_type(v, opts=nil)
        opts = opts || {}

        if v.is_a?(Fixnum)
            return 'INT'
        elsif v.is_a?(Bignum)
            return opts[:gephi] ? 'INT' : 'BIGINT'
        elsif v.is_a?(TrueClass) || v.is_a?(FalseClass)
            return 'BOOLEAN'
        elsif v.is_a?(Float)
            return 'FLOAT'
        else
            return 'VARCHAR'
        end
    end

    # read a node/edge def, and return a list which first element is the
    # label of the field, and the second is its type
    # @param s
    def self.read_def(s)
        *label, value_type = s.split /\s+/
            if /((tiny|small|medium|big)?int|integer)/i.match(value_type)
                value_type = 'int'
            elsif /(float|real|double)/i.match(value_type)
                value_type = 'float'
            elsif (value_type.downcase === 'boolean')
                value_type = 'boolean'
            end

        [label.join(' '), value_type]
    end

    # read a field and return its value
    # @param f
    # @param value_type [String]
    def self.parse_field(f, value_type)
        case value_type
        when 'int'     then f.to_i
        when 'float'   then f.to_f
        when 'boolean' then !(/(null|false)/i =~ f)
        else f
        end
    end

end
