#! /usr/bin/ruby1.9.1

module GDF

    class GDF::Graph

        @nodes = []
        @edges = []

        attr_accessor :nodes, :edges

        def initialize(nodes, edges=nil)
            @nodes = nodes || []
            @edges = edges || []
        end
    end

    def self.load(filename)
        self.parse(File.read(filename))
    end

    def self.parse(content)

        if (content.nil? || content.length == 0)
            return GDF::Graph.new([],[])
        end

        content = content.split("\n")

        # lines index of 'nodedef>' and 'edgedef>'
        nodes_def_index = -1
        edges_def_index = -1

        content.each_with_index {|l,i|
            if l.start_with? 'nodedef>'
                nodes_def_index = i
            elsif l.start_with? 'edgedef>'
                edges_def_index = i
            end

            if ((nodes_def_index >= 0) && (edges_def_index >= 0))
                break
            end
        }

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
        nodes_def.each_index {|i|
            nodes_def[i] = read_def(nodes_def[i])
        }

        nodes.each_with_index {|n,i|
            n2 = {}
            n = n.split(fields_split)
            n.zip(nodes_def).each {|val,label_type|
                label, type = label_type
                n2[label] = parse_field(val, type)
            }
            nodes[i] = n2
        }

        if (edges === [])
            return GDF::Graph.new(nodes)
        end

        # only edges lines
        edges_def = content[edges_def_index]
        edges_def = edges_def['edgedef>'.length..edges_def.length].strip.split(fields_split)
        edges_def.each_index {|i|
            edges_def[i] = read_def(edges_def[i])
        }

        edges.each_with_index {|e,i|
            e2 = {}
            e = e.split(fields_split)

            e.zip(edges_def).each {|val,label_type|
                label, type = label_type
                e2[label] = parse_field(val, type)
            }
            edges[i] = e2
        }

        GDF::Graph.new(nodes, edges)
    end

    def self.unparse(graph)

        # nodes
        gdf_s = 'nodedef>'

        if (graph.nodes.length == 0)
            return gdf_s
        end

        keys = graph.nodes[0].keys
        nodedef = keys.map { |k| [k, self.get_type(graph.nodes[0][k])] }

        gdf_s += (nodedef.map {|nd| nd.join(' ')}).join(',') + "\n"

        graph.nodes.each { |n|
            gdf_s += n.values.join(',') + "\n"
        }

        # edges
        gdf_s += 'edgedef>'

        if (graph.edges.length == 0)
            return gdf_s
        end

        keys = graph.edges[0].keys
        edgedef = keys.map { |k| [k, self.get_type(graph.edges[0][k])] }

        gdf_s += (edgedef.map {|ed| ed.join(' ')}).join(',') + "\n"

        graph.edges.each { |e|
            gdf_s += e.values.join(',') + "\n"
        }

        gdf_s
    end

    private

    # read the value of a node|edge field, and return the value's type (String)
    def self.get_type(v)
        if v.is_a?(Fixnum)
            return 'INT'
        elsif v.is_a?(Bignum)
            return 'BIGINT'
        elsif v.is_a?(TrueClass) || v.is_a?(FalseClass)
            return 'BOOLEAN'
        elsif v.is_a?(Float)
            return 'FLOAT'
        else
            return 'VARCHAR'
        end
    end

    # read a (node|edge)def, and return ['label', 'type of value']
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
    def self.parse_field(f, value_type)
        case value_type
        when 'int'     then f.to_i
        when 'float'   then f.to_f
        when 'boolean' then !(/(null|false)/i =~ f)
        else f
        end
    end

end
