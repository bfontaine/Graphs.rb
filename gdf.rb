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

    def self.parse(filename)
        ct = File.read(filename).split("\n")

        # lines index of 'nodedef>' and 'edgedef>'
        nodes_def_index = -1
        edges_def_index = -1

        ct.each_with_index {|l,i|
            if /^nodedef>/ =~ l
                nodes_def_index = i
            elsif /^edgedef>/ =~ l
                edges_def_index = i
            end

            if ((nodes_def_index >= 0) && (edges_def_index >= 0))
                break
            end
        }

        # no edges
        if (edges_def_index == -1)
            edges = []
            edges_def_index = ct.length
        else
            edges = ct[edges_def_index+1..ct.length]
        end

        # only nodes lines
        nodes = ct[nodes_def_index+1..[edges_def_index-1, ct.length].min] || []

        nodes_def = ct[nodes_def_index]
        nodes_def = nodes_def["nodedef>".length..nodes_def.length].strip.split(",")
        nodes_def.each_index {|i|
            nodes_def[i] = (/^\w+/.match nodes_def[i].strip).to_s
        }

        nodes.each_with_index {|n,i|
            n2 = {}
            n = n.split(",")
            n.zip(nodes_def).each {|val,label|
                n2[label] = val
            }
            nodes[i] = n2
        }

        if (edges === [])
            return GDF::Graph.new(nodes)
        end

        # only edges lines
        edges_def = ct[edges_def_index]
        edges_def = edges_def["edgedef>".length..edges_def.length].strip.split(",")
        edges_def.each_index {|i|
            edges_def[i] = (/^\w+/.match edges_def[i].strip).to_s
        }

        edges.each_with_index {|e,i|
            e2 = {}
            e = e.split(",")
            e.zip(edges_def).each {|val,label|
                e2[label] = val
            }
            edges[i] = e2
        }

        GDF::Graph.new(nodes, edges)
    end
end
