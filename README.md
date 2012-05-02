The goal of this project is to provide some useful Ruby functions to manipulate
graph files.

Install
-------

The best way is to use the `graphs` gem:

    gem install graphs

Graph Class
===========

The `Graph` class is a simple graph with nodes and edges.

Example
-------

    irb> require 'graph'
    => true
    irb> nodes = [{'name'=>'me'}, {'name'=>'you'}]
    => [{'name'=>'me'}, {'name'=>'you'}]
    irb> edges = [{'node1'=>'you', 'node2'=>'me', 'directed'=>true},
                  {'node1'=>'you', 'node2'=>'me', 'directed'=>true}]
    => [{'node1'=>'you', 'node2'=>'me', 'directed'=>true}, {'node1'=>'you', 'node2'=>'me', 'directed'=>true}] 
    irb> g = Graph.new(nodes, edges)
    => #<Graph:0x9e08e3c @nodes=[{"name"=>"me"}, {"name"=>"you"}], @edges=[{"node1"=>"you", "node2"=>"me", "directed"=>true}, {"node1"=>"you", "node2"=>"me", "directed"=>true}]>

You can use the `&` method to make the intersection of two graphes.

GDF Module
==========

The GDF module is used to parse
[GDF](http://guess.wikispot.org/The_GUESS_.gdf_format) files using the unique method
`GDF::load(filename)`. It returns a `Graph` object which provide two
read-write attributes: `nodes` and `edges`. It can also write graph objects in files
using `Graph#write(filename)` method.

Example
-------

Imagine we have a file as below:

     $ cat trips.gdf
     nodedef> name VARCHAR,country VARCHAR
     Foo,England
     Bar,India
     edgedef> node1,node2,day INT,duration INT
     Bar,Foo,62,14
     Foo,Bar,154,7

Then, using `irb`, we use the `GDF` module:

     $ irb
     irb> require 'graphs/gdf'
     => true
     irb> g = GDF::load 'trips.gdf'

We can now access nodes

     irb> g.nodes
     => [{'name'=>'Foo', 'country'=>'England'}, {'name'=>'Bar', 'country'=>'India'}]
     
and edges

     irb> g.edges
     => [{'node1'=>'Bar', 'node2'=>'Foo', 'day'=>62, 'duration'=>14},
         {'node1'=>'Foo', 'node2'=>'Bar', 'day'=>154, 'duration'=>7}]

now, we can add a node and an edge

    irb> g.nodes.push {'name'=>'John', country=>'USA'}
    irb> g.edges.push {'node1'=>'John', 'node2'=>'Foo', 'day'=>42, 'duration'=>12}

but we forgot that all edges are directed ones. That's ok, just use
the `set_default` method:

    irb> g.edges.set_default 'directed' => true
    irb> g.edges
    => [{'node1'=>'Bar', 'node2'=>'Foo', …, 'directed'=>true},
        {'node1'=>'Foo', 'node2'=>'Bar', …, 'directed'=>true},
        {'node1'=>'John', 'node2'=>'Foo', …, 'directed'=>true}]

Note that the `set_default` method is defined for `edges` and `nodes`. It
accepts multiple arguments, and you only need to call it once, it will work for
every new node or edge (just use `.push` method to add new ones).

then, we can save our new graph in a new file

    irb> g.write('new_trips.gdf')

Note to [Gephi](https://github.com/gephi/gephi) users: You can add the `:gephi`
option to `g.write(…)` if you have big numbers. `Graph#write` method use
`BIGINT` type for big numbers, but Gephi does not support it and parses it as a
string field. So using the following:
    
    irb> g.write('new_trips.gdf', {:gephi=>true})

make sure that `INT` is used for all `BIGINT` fields.

GEXF Module
===========

*soon…*

Short Documentation
===================

(more documentation coming soon…)

- `Graph`: a graph object, with `nodes` and `edges` attributes
- `Graph.new(nodes[, edges])`: create a new `Graph` object
- `Graph#write(filename)`: write the current graph object into a file. The
  filetype is based on `filename`'s extension (Yaml is used as default)
- `Graph::NodeArray`: kind of `Array`, with a `set_default` method
- `Graph::EdgeArray`: same as `Graph::NodeArray`
- `Graph::NodeArray#set_default({ k=>v[,…] })`: set some defaults values
  for each node of the current graph object.
- `Graph::EdgeArray#set_default({ k=>v[,…] })`: set some defaults values
  for each edge of the current graph object.
- `GDF::load(filename)`: parse the content of a GDF file, and return a new graph object
