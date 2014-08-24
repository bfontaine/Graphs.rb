#! /usr/bin/env ruby
# -*- coding: UTF-8 -*-

require 'yaml'

# A graph with nodes and edges
class Graph

    # Return a new Graph which is the intersection of every given graph.
    # Each node of the intersection is in every given graph (idem for edges).
    # The last argument may be a hash of options.
    # @option options [Boolean] +:same_fields+ use only fields which are in
    #                           every graph to compare nodes/edges to perform
    #                           the intersection
    # @see Graph#&
    # @see Graph.union
    # @see Graph.xor
    # @return [Graph]
    def Graph::intersection(*graphs)
         perform_graphs_group_op(*graphs, &:&)
    end

    # Return a new {Graph} which is the union of every given graph.
    # Each node of the union is in one or more given graph(s) (idem for edges).
    # The last argument may be a hash of options.
    # @option options [Boolean] +:same_fields+ use only fields which are in
    #                           every graph to compare nodes/edges to perform
    #                           the union
    # @see Graph#|
    # @see Graph.intersection
    # @see Graph.xor
    # @return [Graph]
    def Graph::union(*graphs)
        perform_graphs_group_op(*graphs, &:|)
    end

    # Perform a XOR operation on all given graphs, and returns the result.
    # The last argument may be a hash of options.
    # @option options [Boolean] :same_fields use only fields which are in every
    # graph to compare nodes/edges to perform the XOR operation
    # @see Graph#^
    # @see Graph.union
    # @see Graph.intersection
    # @return [Graph]
    def Graph::xor(*graphs)
        perform_graphs_group_op(*graphs, &:^)
    end

    # A node. This class is just a wrapper around a hash of attributes. Before
    # 0.1.6, nodes were simple hashs
    # @since 0.1.6
    class Node

        # @return Node's attributes
        attr_accessor :attrs

        # Create a new Node
        # @param attrs [Node, Hash]
        def initialize(attrs=nil)
            @attrs = attrs.is_a?(Node) ? attrs.attrs : attrs || {}
        end

        # compare two nodes
        # @param other [Node]
        # @return [Boolean]
        def ==(other)
            return false if !other.is_a?(Node)

            @attrs == other.attrs
        end

        # Update the current node, like the +Hash#update+ method.
        # @param h [Hash]
        # @return [Node]
        def update(h)
            Node.new super(h)
        end

        # Tries to resolve the method as an hash key, and forward the method
        # resolution to the underlying hash if the key doesn't exist
        def method_missing(method, *args, &block)
            return @attrs[method.to_sym] if @attrs.has_key? method.to_sym
            return @attrs[method.to_s] if @attrs.has_key? method.to_s

            @attrs.send(method, *args, &block)
        end

    end

    # An edge. This class is just a wrapper around a hash of
    # attributes since before version 0.1.5 edges were simple hashes
    # @since 0.1.6
    class Edge

        # @return Edge's attributes
        attr_accessor :attrs

        # Create a new edge
        # @param attrs [Edge, Hash]
        def initialize(attrs=nil)
            @attrs = attrs.is_a?(Edge) ? attrs.attrs : attrs || {}
        end

        # Compare two edges
        # @param other [Edge]
        # @return [Boolean]
        def ==(other)
            return false if !other.is_a?(Edge)

            @attrs == other.attrs
        end

        # Update the current edge, like the +Hash#update+ method.
        # @param h [Hash]
        # @return [Edge]
        def update(h)
            Edge.new super(h)
        end

        # Tries to resolve the method as an hash key, and forward the method
        # resolution to the underlying hash if the key doesn't exist
        def method_missing(method, *args, &block)
            return @attrs[method.to_sym] if @attrs.has_key? method.to_sym
            return @attrs[method.to_s] if @attrs.has_key? method.to_s

            @attrs.send(method, *args, &block)
        end

    end

    # An array of Node objects
    class NodeArray < Array

        # Create a new +NodeArray+ from an existing +Array+.
        # @param li [Array]
        def initialize(li)
            nodes = li.map { |n| n.is_a?(Node) ? n : Node.new(n) }
            super(nodes)
            @defaults = {}
        end

        # Set some default values for current elements.
        # @note This method can be called multiple times.
        # @param dict [Hash]
        # @return [NodeArray]
        # @example Set all nodes's 'created-at' value to '2012-05-03'
        #   myNodeList.set_default({'created-at'=>'2012-05-03'})
        def set_default(dict)
            @defaults.update(dict)
            self.map! { |e| e.update(@defaults) }
        end

        # Add the given node at the end of the list
        # @param n [Node]
        # @return [NodeArray]
        def push(n)
            if (!n.is_a?(Hash) && !n.is_a?(Node))
                raise TypeError.new "#{n.inspect} is not an Hash nor a Node!"
            end

            n = Node.new(n) if (n.is_a?(Hash))

            super(n.clone.update(@defaults))
        end

    end

    # An array of Edge objects
    class EdgeArray < Array

        # Create a new +EdgeArray+ from an existing +Array+.
        # @param li [Array<Edge, Hash>]
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
        # @return [EdgeArray]
        def push(e)
            if (!e.is_a?(Hash) && !e.is_a?(Edge))
                raise TypeError.new "#{e.inspect} is not an Hash nor an Edge!"
            end

            e = Edge.new(e) if (e.is_a?(Hash))

            super(e.clone.update(@defaults))
        end

    end

    # @return [NodeArray] the graph's nodes
    attr_accessor :nodes

    # @return [EdgeArray] the graph's edges
    attr_accessor :edges

    # @return [Hash] the graph's attributes
    attr_accessor :attrs

    # Create a new +Graph+ from one set of nodes and one set of edges
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
    # @return [Boolean]
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
    # @return [Graph]
    # @see Graph#^
    # @see Graph.intersection
    def &(other)
        return unless other.is_a?(Graph)

        nodes = @nodes & other.nodes
        edges = @edges & other.edges

        Graph.new(nodes, edges)
    end

    # Perform a XOR operation between the current graph and the other. Returns
    # a new Graph which nodes are in the current graph or in the other, but not
    # in both (idem for edges).
    # @param other [Graph]
    # @return [Graph]
    # @see Graph#&
    def ^(other)
        return unless other.is_a?(Graph)

        nodes = (@nodes - other.nodes) + (other.nodes - @nodes)
        edges = (@edges - other.edges) + (other.edges - @edges)

        Graph.new(nodes, edges)
    end

    # Add two graphs, keeping duplicate nodes and edges
    # @param other [Graph]
    # @return [Graph]
    def +(other)
        return unless other.is_a?(Graph)

        nodes = @nodes + other.nodes
        edges = @edges + other.edges

        Graph.new(nodes, edges)
    end

    # Perform an OR operation on the current Graph and the given one. Returns a
    # new graph which every node is in the current Graph and/or the other
    # (idem for edges).
    # @param other [Graph]
    # @return [Graph]
    def |(other)
        return unless other.is_a?(Graph)

        nodes = @nodes | other.nodes
        edges = @edges | other.edges

        Graph.new(nodes, edges)
    end

    # Returns a new Graph, which is a copy of the current graph without nodes
    # and edges which are in the given Graph.
    # @param other [Graph]
    # @return [Graph]
    def -(other)
        return unless other.is_a?(Graph)

        nodes = @nodes - other.nodes
        edges = @edges - other.edges

        Graph.new(nodes, edges)
    end

    # (see Graph#-)
    def not(other)
        self - other
    end

    # Return true if the Graph is directed.
    # @return [Boolean]
    # @see Graph.attrs
    def directed?()
        !!self.attrs[:directed]
    end

    # Clone the current graph. All nodes and edges are also cloned. A new Graph
    # is returned.
    # @return [Graph] a new graph
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
    # @return []
    # @option opts [Boolean] :gephi Should be <tt>true</tt> if the file will be
    #                        used with Gephi.
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
    # Edges must have the +node1+ and +node2+ attributes, which must contain
    # the +label+ attributes of nodes.
    #
    # @param n [Node,String] A node or a label of one
    # @return [Integer]
    # @see Graph#in_degree_of
    # @see Graph#out_degree_of
    def degree_of(n)
        label = Graph::get_label(n)

        degree = 0

        # This is more efficient than in_degree_of(n)+out_degree_of(n)
        # since it goes only once through the edges array
        self.edges.each do |e|
            degree += 1 if (e['node1'] || e[:node1]).to_s == label
            degree += 1 if (e['node2'] || e[:node2]).to_s == label
        end

        degree
    end

    # Return the “in degree” of the node n in the current graph, i.e. the
    # number of edges which are directed to this node. Note that the graph must
    # be oriented.
    #
    # Edges must have the +node1+ and +node2+ attributes, which must contain
    # the +label+ attributes of nodes.
    #
    # @param n [Node,String] A node or a label of one
    # @return [Integer]
    # @see Graph#degree_of
    # @see Graph#out_degree_of
    def in_degree_of(n)
        label = Graph::get_label(n)

        degree = 0

        self.edges.each do |e|
            degree += 1 if (e['node2'] || e[:node2]).to_s == label
        end

        degree
    end

    # Return the “out degree” of the node n in the current graph, i.e. the
    # number of edges which are directed from this node. Note that the graph
    # must be oriented.
    #
    # Edges must have the +node1+ and +node2+ attributes, which must contain
    # the +label+ attributes of nodes.
    #
    # @param n [Node,String] A node or a node's label
    # @return [Integer]
    # @see Graph#degree_of
    # @see Graph#out_degree_of
    def out_degree_of(n)
        label = Graph::get_label(n)

        degree = 0

        self.edges.each do |e|
            degree += 1 if (e['node1'] || e[:node1]).to_s == label
        end

        degree
    end

    # return the first node which mach the given label in the current graph
    # @param label [String] A node's label
    # @return [Node]
    def get_node(label)
        label = Graph::get_label(label)

        self.nodes.find { |n| n.label == label }
    end

    # return an array of the neighbours of a node in the current graph.
    # @param n [Node,String] A node with a 'label' or :label attribute, or a
    #                        string
    # @return [Array<Node>]
    def get_neighbours(n)

        label = Graph::get_label n
        neighbours = NodeArray.new []

        self.edges.each do |e|

            l1 = e[:node1] || e['node1']
            l2 = e[:node2] || e['node2']

            if l2 && l1 == label

                n2 = self.get_node l2

                unless n2.nil? || neighbours.include?(n2)

                    neighbours.push(n2)

                end

            end

            if l1 && l2 == label && !self.directed?

                n1 = self.get_node l1

                unless n1.nil? || neighbours.include?(n1)

                    neighbours.push(n1)

                end

            end

        end

        neighbours

    end

    # return the label of a node. Raise a TypeError exception if the argument
    # is not a Node nor a String object.
    # @param n [Node,String] A node with a 'label' or :label attribute, or a
    #                        string
    # @return [String]
    def Graph::get_label(n)
        label = n.is_a?(Node) \
                      ? n.label.to_s \
                      : n.is_a?(String) ? n : nil

         if label.nil?
            raise TypeError.new("#{n.inspect} must be a Node or String object.")
         end

        label
    end

    private

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

            graphs.map do |g|
                g.nodes.map! do |n|

                    newnode = {}

                    n.each_key do |k|
                        newnode[k] = n[k] if nodes_keys_uniq.include?(k)
                    end

                    newnode
                end
                g.edges.map! do |n|

                    newedge = {}

                    n.each_key do |k|
                        newedge[k] = n[k] if edges_keys_uniq.include?(k)
                    end

                    newedge
                end
                g
            end
    end

    # Perform an operation on a graphs group
    # @param graphs [Array<Graph>]
    # @param block [Block] operation
    # @return [Graph]
    def Graph::perform_graphs_group_op(*graphs, &block)
        return if graphs.length == 0

        # options
        opts = {}

        # if the last arg is an hash, use it as a set of options and remove it
        # from the arguments
        if graphs[-1].is_a?(Hash)
            return if graphs.length == 1
            opts = graphs.pop
        end

        # return nil if one argument is not a graph
        graphs.each do |g|
            return if !g.is_a?(Graph)
        end

        # if :same_fields option is set, call `keep_only_same_fields` function
        graphs = keep_only_same_fields(*graphs) if opts[:same_fields]

        # perform an and operation on all graph list
        graphs.inject(&block)
    end
end
