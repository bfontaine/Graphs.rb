The goal of this project is to provide some useful Ruby functions to manipulate
graph files.

GDF Module
==========

The GDF module is used to parse
[GDF](http://guess.wikispot.org/The_GUESS_.gdf_format) files using the unique method
`GDF::load(filename)`. It returns a `GDF::Graph` object which provide two
read-write attributes: `nodes` and `edges`. It can also write graph objects in files
using `GDF::Graph#write(filename)` method.

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
     irb> require './gdf'
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

Note that the `set_default` method is defined for `edges` **and** `nodes`. It
accepts multiple arguments, and you only need to call it once, it will work for
every new node or edge.

then, we can save our new graph in a new file

    irb> g.write('new_trips.gdf')


Documentation
-------------

- `GDF::Graph`: a graph object, with `nodes` and `edges` attributes
- `GDF::Graph.new(nodes[, edges])`: create a new `GDF::Graph` object
- `GDF::Graph#write(filename)`: write the current graph object into a file
- `GDF::Graph::NodeArray`: sort of `Array`, with a `set_default` method
- `GDF::Graph::EdgeArray`: same as `GDF::Graph::NodeArray`
- `GDF::Graph::NodeArray#set_default({ k=>v[,…] })`: set some defaults values
  for each node of the current graph object.
- `GDF::Graph::EdgeArray#set_default({ k=>v[,…] })`: set some defaults values
  for each edge of the current graph object.
- `GDF::load(filename)`: parse the content of a GDF file, and return a new graph object

