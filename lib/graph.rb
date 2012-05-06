# -*- coding: UTF-8 -*-

require 'yaml'

# A graph with nodes and edges
class Graph

    # Return a new Graph which is the intersection of every given graphs.
    # Each node of the intersection is in every given graph (idem for edges).
    # The last argument may be a hash of options.
    # @option options [Boolean] :same_fields use only fields which are in every
    # graph to perform the intersection
    # @see Graph#&
    def Graph::intersection(*graphs)
         perform_graphs_group_op(*graphs, &:&)
    end

    def Graph::union(*graphs)
        perform_graphs_group_op(*graphs, &:|)
    end

    # An array of nodes, each node is an hash of label/value paires
    class NodeArray < Array

        def initialize(*args)
            super(*args)
            @defaults = {}
        end

        # Set some default values for current elements.
        # @note This method can be called multiple times.
        # @example Set all nodes's 'created-at' value to '2012-05-03'
        #   myNodeList.set_default({'created-at'=>'2012-05-03'})
        def set_default(dict)
            @defaults.update(dict)
            self.map! { |e| e.update(@defaults) }
        end

        # Add the given node at the end of the list
        # @param o [Node]
        def push(o)
            if (!o.is_a?(Hash))
                raise TypeError.new "#{o.inspect} is not an Hash!"
            end
            o2 = o.clone
            o2.update(@defaults)
            super(o2)
        end
    end

    # An array of edges, each edge is an hash of label/value paires
    class EdgeArray < NodeArray
    end

    attr_accessor :nodes, :edges, :attrs

    # @param nodes [Array] Nodes of the graph
    # @param edges [Array] Edges of the graph
    def initialize(nodes=nil, edges=nil)
        @nodes = NodeArray.new(nodes || [])
        @edges = EdgeArray.new(edges || [])
        @attrs = {}
    end

    # Test if current graph has same nodes and edges as the other
    # graph.
    # @param other [Graph]
    def ==(other)
        if (!other.is_a?(Graph))
            return false
        end
        (self.nodes === other.nodes) && (self.edges === other.edges)
    end

    # Perform an intersection between the current graph and the other.
    # Returns a new Graph which nodes are both in the current graph and
    # the other (idem for edges).
    # @param other [Graph]
    # @see Graph#^
    # @see Graph::intersection
    def &(other)
        if (!other.is_a?(Graph))
            return nil
        end

        nodes = @nodes & other.nodes
        edges = @edges & other.edges

        Graph.new(nodes, edges)
    end

    # Perform a XOR operation between the current graph and the other. Returns a
    # new Graph which nodes are in the current graph or in the other, but not in
    # both (idem for edges).
    # @param other [Graph]
    # @see Graph#&
    def ^(other)
        if (!other.is_a?(Graph))
            return nil
        end

        nodes = (@nodes + other.nodes) - (@nodes & other.nodes)
        edges = (@edges + other.edges) - (@edges & other.edges)

        Graph.new(nodes, edges)
    end

    # Add two graphs, keeping duplicate nodes and edges
    # @param other [Graph]
    def +(other)
        if (!other.is_a?(Graph))
            return nil
        end

        nodes = @nodes + other.nodes
        edges = @edges + other.edges

        Graph.new(nodes, edges)
    end

    # Perform an OR operation on the current Graph and the given one. Returns a
    # new graph which every node is in the current Graph and/or the other
    # (idem for edges).
    def |(other)
        if (!other.is_a?(Graph))
            return nil
        end
            
        nodes = @nodes | other.nodes
        edges = @edges | other.edges

        Graph.new(nodes, edges)
    end

    # Returns a new Graph, which is a copy of the current graph without nodes
    # and edges which are in the given Graph.
    # @param other [Graph]
    def -(other)
        if (!other.is_a?(Graph))
            return nil
        end

        nodes = @nodes - other.nodes
        edges = @edges - other.edges

        Graph.new(nodes, edges)
    end

    # @see Graph#-
    def not(other)
        self - other
    end

    # Clone the current graph. All nodes and edges are also cloned.
    def clone()
        g = Graph.new
        g.nodes = self.nodes.clone
        g.edges = self.edges.clone

        g.nodes.map! {|h| h.clone}
        g.edges.map! {|h| h.clone}

        g
    end

    # Write the current Graph into a file.
    # @param filename [String] A valid filename
    # @param opts [Hash] A customizable set of options
    # @option opts [Boolean] :gephi Should be <tt>true</tt> if the file will be used with Gephi.
    def write(filename, opts=nil)

        has_ext = filename.split('.')
        ext = (has_ext.length>1) ? has_ext[-1] : 'unknow'

        m = (self.methods - Object.methods).map {|e| e.to_s}

        if (m.include? 'write_'+ext.downcase)
            self.send('write_'+ext.downcase, filename, opts)

        elsif (ext == 'unknow' || ext == 'yml')
            # YAML (default)
            nodes = self.nodes.to_a
            edges = self.edges.to_a

            data = {'nodes'=>nodes, 'edges'=>edges}.to_yaml
            f = open(filename, 'w')
            f.write(data)
            f.close
        else
            raise NoMethodError.new("No method to handle #{ext} file extension.")
        end

    end

    # return the provided set of graphs, from which every node/edge label which
    # is not in all graphs has been removed. So every returned graph has same
    # node/edge labels than each other
    def Graph::keep_only_same_fields(*graphs)
            graphs.map! {|g| g.clone}

            # every first node of every graphs
            nodes_ref = graphs.map {|g| g.nodes[0] || {}}
            # every first edge of every graphs
            edges_ref = graphs.map {|g| g.edges[0] || {}}

            nodes_keys_ref = nodes_ref.map {|n| n.keys}
            edges_keys_ref = edges_ref.map {|e| e.keys}

            # keep only same keys
            nodes_keys_uniq = nodes_keys_ref.inject {|i,e| i &= e}
            edges_keys_uniq = edges_keys_ref.inject {|i,e| i &= e}

            graphs.map {|g|
                g.nodes.map! { |n|
                    
                    newnode = {}

                    n.each_key { |k|
                        newnode[k] = n[k] if nodes_keys_uniq.include?(k)
                    }

                    newnode
                }
                g.edges.map! { |n|
                    
                    newedge = {}

                    n.each_key { |k|
                        newedge[k] = n[k] if edges_keys_uniq.include?(k)
                    }

                    newedge
                }
                g
            }
    end

    # Perform an operation on a graphs group
    # @param block [Block] operation
    def Graph::perform_graphs_group_op(*graphs, &block)
        return nil if graphs.length == 0

        # options
        opts = {}

        # if the last arg is an hash, use it as a set of options and remove it
        # from the arguments
        if graphs[-1].is_a?(Hash)
            return nil if graphs.length == 1
            opts.update(graphs.pop)
        end

        # return nil if one argument is not a graph
        graphs.each {|g|
                return nil if (!g.is_a?(Graph))
        }

        # if :same_fields option is set, call `keep_only_same_fields` function
        *graphs = keep_only_same_fields(*graphs) if opts[:same_fields]

        # perform an and operation on all graph list
        graphs.inject(&block)
    end

    private_class_method :keep_only_same_fields, :perform_graphs_group_op
end
