The goal of this project is to provide some useful Ruby functions to manipulate
graph files.

Note: some of the examples below are outdated, since before the 0.1.5 version,
nodes & edges were represented as hashes, and now they are `Node` & `Edge`
objects, respectively. However, the principles stay the sames.

Install
-------

The best way is to use the `graphs` gem:

    gem install graphs

If you want to have the latest version, clone this repo, build the gem, and
install it:
    
    git clone git://github.com/bfontaine/Graphs.rb.git
    cd Graphs.rb
    gem build graphs.gemspec
    gem install ./graphs-*.gem # you may want to use sudo

Tests
-----

To perform the tests, clone this repo, then go into `tests` repertory, and
execute `tests.rb`:

    git clone git://github.com/bfontaine/Graphs.rb.git
    cd Graphs.rb/tests
    ruby tests.rb

Make sure you have the latest version.

Graph Class
===========

The `Graph` class is a simple graph with nodes and edges. It provides three
read-write attributes: `nodes`, `edges`, and `attr` (attributes of the graph,
like author or description). It can be written in a file using `Graph#write`
method.

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

You can perform some operations on graphes using the `|`, `&`, `^`, `+` or `-`
operators. See the [documentation](http://rubydoc.info/gems/graphs/frames) for
more informations.

GDF Module
==========

The GDF module is used to parse
[GDF](http://guess.wikispot.org/The_GUESS_.gdf_format) files using the unique method
`GDF::load(filename)` which returns a Graph object.

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

