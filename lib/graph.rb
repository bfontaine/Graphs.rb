# -*- coding: UTF-8 -*-

require 'yaml'

# A graph with nodes and edges
# @!attribute [rw] nodes
#   @return [NodeArray] array of current Graph's nodes
# @!attribute [rw] edges
#   @return [EdgeArray] array of current Graph's edges
# @!attribute [rw] attrs
#   @return [Hash] attributes of the current Graph (e.g. author, description, …).
#   By default, the graph is directed, i.e. the :directed attribute is set to `true`.
class Graph

    # Return a new Graph which is the intersection of every given graph.
    # Each node of the intersection is in every given graph (idem for edges).
    # The last argument may be a hash of options.
    # @option options [Boolean] :same_fields use only fields which are in every
    # graph to compare nodes/edges to perform the intersection
    # @see Graph#&
    # @see Graph::union
    # @see Graph::xor
    def Graph::intersection(*graphs)
         perform_graphs_group_op(*graphs, &:&)
    end

    # Return a new Graph which is the union of every given graph.
    # Each node of the union is in one or more given graph(s) (idem for edges).
    # The last argument may be a hash of options.
    # @option options [Boolean] :same_fields use only fields which are in every
    # graph to compare nodes/edges to perform the union
    # @see Graph#|
    # @see Graph::intersection
    # @see Graph::xor
    def Graph::union(*graphs)
        perform_graphs_group_op(*graphs, &:|)
    end

    # Perform a XOR operation on all given graphs, and returns the result.
    # The last argument may be a hash of options.
    # @option options [Boolean] :same_fields use only fields which are in every
    # graph to compare nodes/edges to perform the XOR operation
    # @see Graph#^
    # @see Graph::union
    # @see Graph::intersection
    def Graph::xor(*graphs)
        perform_graphs_group_op(*graphs, &:^)
    end

    # A node. This class is just a wrapper around a hash of
    # attributes since in version <= 0.1.5 nodes were simple hashes
    class Node

        attr_accessor :attrs

        def initialize(attrs=nil)
            @attrs = attrs || {}
        end

        # compare two nodes
        # @param other [Node]
        def ==(other)
            return false if !other.is_a?(Node)

            @attrs == other.attrs
        end

        def method_missing(method, *args, &block)
            @attrs.send(method, *args, &block)
        end

    end

    # An edge. This class is just a wrapper around a hash of
    # attributes since in version <= 0.1.5 edges were simple hashes
    class Edge

        attr_accessor :attrs

        def initialize(attrs=nil)
            @attrs = attrs || {}
        end

        # compare two edges
        # @param other [Edge]
        def ==(other)
            return false if !other.is_a?(Edge)

            @attrs == other.attrs
        end

        def method_missing(method, *args, &block)
            @attrs.send(method, *args, &block)
        end

    end

    # An array of Node objects
    class NodeArray < Array

        def initialize(li)
            nodes = li.map { |n| n.is_a?(Node) ? n : Node.new(n) }
            super(nodes)
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
        # @param n [Node]
        def push(n)
            if (!n.is_a?(Hash) && !n.is_a?(Node))
                raise TypeError.new "#{n.inspect} is not an Hash or a Node!"
            end

            super(n.clone.update(@defaults))
        end
    end

    # An array of Edge objects
    class EdgeArray < Array
        def initialize(li)
            edges = li.map { |n| n.is_a?(Edge) ? n : Edge.new(n) }
            super(edges)
            @defaults = {}
        end

        # Set some default values for current elements.
        # @note This method can be called multiple times.
        # @example Set all edges's 'created-at' value to '2012-05-03'
        #   myEdgeList.set_default({'created-at'=>'2012-05-03'})
        # @param dict [Hash]
        def set_default(dict)
            @defaults.update(dict)
            self.map! { |e| e.update(@defaults) }
        end

        # Add the given edge at the end of the list
        # @param e [Edge]
        def push(e)
            if (!e.is_a?(Hash) && !e.is_a?(Edge))
                raise TypeError.new "#{e.inspect} is not an Hash or an Edge!"
            end

            super(e.clone.update(@defaults))
        end
    end

    attr_accessor :nodes, :edges, :attrs

    # @param nodes [Array] Nodes of the graph
    # @param edges [Array] Edges of the graph
    def initialize(nodes=nil, edges=nil)
        @nodes = NodeArray.new(nodes || [])
        @edges = EdgeArray.new(edges || [])
        @attrs = { :directed => true }
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
    # @param other [Graph]
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

    # Return true if the Graph is directed.
    # @see Graph.attrs
    def directed?()
        self.attrs[:directed]
    end

    # Clone the current graph. All nodes and edges are also cloned. A new Graph
    # is returned.
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

    # Return the degree of the node n in the current graph, i.e. the number
    # of edges which are connected to this node. Note that this is useful
    # only for a undirected graph, for a directed one, you should use
    # Graph#in_degree_of and/or Graph#out_degree_of.
    #
    # Edges must have the 'node1' and 'node2' attributes, which must contain
    # the 'label' attributes of nodes.
    #
    # @param n [Node,String] A node or a label of one
    # @see Graph#in_degree_of
    # @see Graph#out_degree_of
    def degree_of(n)
        label = Graph::get_label_from_node(n)

        degree = 0

        # This is more efficient than in_degree_of(n)+out_degree_of(n)
        # since it goes only once through the edges array
        self.edges.each do |e|
            degree += 1 if (e['node1'] || e[:node1]).to_s == label
            degree += 1 if (e['node2'] || e[:node2]).to_s == label
        end

        degree
    end

    # Return the “in degree” of the node n in the current graph, i.e. the number
    # of edges which are directed to this node. Note that the graph must be oriented.
    #
    # Edges must have the 'node1' and 'node2' attributes, which must contain
    # the 'label' attributes of nodes.
    #
    # @param n [Node,String] A node or a label of one
    # @see Graph#degree_of
    # @see Graph#out_degree_of
    def in_degree_of(n)
        label = Graph::get_label_from_node(n)

        degree = 0

        self.edges.each do |e|
            degree += 1 if (e['node2'] || e[:node2]).to_s == label
        end

        degree
    end

    # Return the “out degree” of the node n in the current graph, i.e. the number
    # of edges which are directed from this node. Note that the graph must be oriented.
    #
    # Edges must have the 'node1' and 'node2' attributes, which must contain
    # the 'label' attributes of nodes.
    #
    # @param n [Node,String] A node or a label of one
    # @see Graph#degree_of
    # @see Graph#out_degree_of
    def out_degree_of(n)
        label = Graph::get_label_from_node(n)

        degree = 0

        self.edges.each do |e|
            degree += 1 if (e['node1'] || e[:node1]).to_s == label
        end

        degree
    end

    # Return the “in degree” of the node n in the current graph, i.e. the number
    # of edges which are directed to this node. Note that the graph must be oriented.
    #
    # Edges must have the 'node1' and 'node2' attributes, which must contain
    # the 'label' attributes of nodes.
    #
    # @param n [Node,String] A node or a label of one
    # @see Graph#degree_of
    # @see Graph#out_degree_of
    def in_degree_of(n)
        label = Graph::get_label_from_node(n)

        degree = 0

        # This is more efficient than in_degree_of(n)+out_degree_of(n)
        # since it goes only once through the edges array
        self.edges.each do |e|
            degree += 1 if (e['node2'] || e[:node2]).to_s == label
        end

        degree
    end


    # return the label of a node. Raise a TypeError exception if the argument
    # is not a Node nor a String object.
    # @param n [Node,String] A node with a 'label' or :label attribute, or a string
    def Graph::get_label_from_node(n)
        label = n.is_a?(Node) \
                      ? (n['label'] || n[:label]).to_s \
                      : n.is_a?(String) ? n : nil

        raise TypeError.new("#{n.inspect} must be a Node or String object.") if label.nil?

        label
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
            
            opts = graphs.pop
        end

        # return nil if one argument is not a graph
        graphs.each do |g|
                return nil if !g.is_a?(Graph)
        end

        # if :same_fields option is set, call `keep_only_same_fields` function
        graphs = keep_only_same_fields(*graphs) if opts[:same_fields]

        # perform an and operation on all graph list
        graphs.inject(&block)
    end

    private_class_method :keep_only_same_fields, :perform_graphs_group_op
end
