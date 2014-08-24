#! /usr/bin/env ruby
# -*- coding: UTF-8 -*-

require 'csv'
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
# see http://guess.wikispot.org/The_GUESS_.gdf_format
module GDF

    NODEDEF = 'nodedef>'
    EDGEDEF = 'edgedef>'

    # non-string predefined properties
    PREDEFINED_NODE_PROPS = {
      'x' => 'float',
      'y' => 'float',
      'visible' => 'boolean',
      'fixed' => 'boolean',
      'style' => 'int',
      'width' => 'float',
      'height' => 'float'
    }
    PREDEFINED_EDGE_PROPS = {
      'visible' => 'boolean',
      'weight' => 'float',
      'width' => 'float',
      'directed' => 'boolean',
      'labelvisible' => 'boolean'
    }

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

        fields_split = /[\t ]*,[\t ]*/

        nodedef_len, edgedef_len = NODEDEF.length, EDGEDEF.length

        current_def = nil

        nodes, edges = [], []
        current_set = nil

        content.each_line do |line|
          line.strip!
          is_nodedef = line.start_with? NODEDEF
          is_edgedef = !is_nodedef && line.start_with?(EDGEDEF)

          if is_nodedef || is_edgedef
            line.slice!(0, is_nodedef ? nodedef_len : edgedef_len)
            line.strip!
            defaults = is_nodedef ? PREDEFINED_NODE_PROPS : PREDEFINED_EDGE_PROPS
            current_def = line.split(fields_split).map do |l|
              read_def(l, defaults)
            end

            current_set = is_nodedef ? nodes : edges
          else
            el = {}
            fields = line.parse_csv || [nil]
            fields.zip(current_def).each do |val,label_type|
              label, type, default = label_type
              el[label] = parse_field(val, type, default)
            end
            current_set << el
          end
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
        gdf_s = NODEDEF

        if (graph.nodes.length == 0)
            return gdf_s
        end

        keys = graph.nodes[0].keys
        nodedef = keys.map { |k| [k, self.get_type(graph.nodes[0][k], opts)] }

        gdf_s += (nodedef.map {|nd| nd.join(' ')}).join(',') + "\n"

        graph.nodes.each do |n|
            gdf_s += n.values.to_csv
        end

        # edges
        gdf_s += EDGEDEF

        return gdf_s if graph.edges.empty?

        keys = graph.edges[0].keys
        edgedef = keys.map { |k| [k, self.get_type(graph.edges[0][k], opts)] }

        gdf_s += (edgedef.map {|ed| ed.join(' ')}).join(',') + "\n"

        graph.edges.each do |e|
            gdf_s += e.values.to_csv
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

        if v.is_a?(Fixnum) || v.is_a?(Bignum)
            if opts[:gephi] || v <= 2147483647
              return 'INT'
            else
              return 'BIGINT'
            end
        elsif v.is_a?(TrueClass) || v.is_a?(FalseClass)
            return 'BOOLEAN'
        elsif v.is_a?(Float)
            return 'FLOAT'
        else
            return 'VARCHAR'
        end
    end

    # read a node/edge def, and return a list where the first element is the
    # label of the field, the second its type, and the third and last one its
    # default value
    # @param s
    # @param defaults
    def self.read_def(s, defaults={})
        label, *params = s.split(/\s+/)
        default = nil

        if params.empty?
          value_type = defaults[label.downcase] || 'VARCHAR'
        else
          value_type = params.shift

          if params.shift == 'default'
            default = parse_field(params.shift, value_type.downcase)
          end

          if /((tiny|small|medium|big)?int|integer)/i.match(value_type)
              value_type = 'int'
          elsif /(float|real|double)/i.match(value_type)
              value_type = 'float'
          elsif (value_type.downcase === 'boolean')
              value_type = 'boolean'
          end
        end

        [label, value_type, default]
    end

    # read a field and return its value
    # @param f
    # @param value_type [String]
    # @param default
    def self.parse_field(f, value_type, default=nil)
        case value_type
        when 'int'     then (f || default).to_i
        when 'float'   then (f || default).to_f
        when 'boolean' then
          if f.nil?
            default.nil? ? false : default
          else
            /^(?:null|false|)$/i !~ f
          end
        else f || default
        end
    end

end
