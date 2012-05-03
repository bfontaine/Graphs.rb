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
        opts = {}

        _graphs = []

        graphs.each {|g|
            if (g.is_a?(Graph))
                _graphs << g
            elsif (g.is_a?(Hash))
                opts.update(g)
            end
        }

        return nil if (_graphs.length == 0)

        if opts[:same_fields]
            _graphs.map! {|g| g.clone}
        end

        

        return Graph.new
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

    attr_accessor :nodes, :edges

    # @param nodes [Array] Nodes of the graph
    # @param edges [Array] Edges of the graph
    def initialize(nodes=nil, edges=nil)
        @nodes = NodeArray.new(nodes || [])
        @edges = EdgeArray.new(edges || [])
    end

    # Test if current graph has same nodes and edges as the other
    # graph.
    # @param other [Graph]
    def ==(other)
        if (!other.is_a?(Graph))
            return false
        end
        (self.nodes === other.nodes) && (self.edges == other.edges)
    end

    # Perform an intersection between the current graph and the other.
    # Returns a new Graph which nodes are both in the current graph and
    # the other (idem for edges).
    # @param other [Graph]
    def &(other)
        if (!other.is_a?(Graph))
            return nil
        end

        nodes = @nodes & other.nodes
        edges = @edges & other.edges

        Graph.new(nodes, edges)
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
end
