The goal of this project is to provide some useful Ruby functions to manipulate
graph files.

GDF Module
==========

The GDF module is used to parse
[GDF](http://guess.wikispot.org/The_GUESS_.gdf_format) files using the unique method
`GDF.parse(filename)`. It returns a `GDF::Graph` object, which provide two
attributes: `nodes` and `edges`

Example
-------

Imagine we have a file as below:

     $ cat trips.gdf
     nodedef> name VARCHAR,country VARCHAR
     Foo,england
     Bar,india
     edgedef> node1,node2,day INT,duration INT
     Bar,Foo,62,14
     Foo,Bar,154,7

Then, using `irb`, we use the `GDF` module:

     $ irb
     irb> require './gdf'
     => true
     irb> g = GDF::parse 'trips.gdf'
     […]

We can now access nodes

     irb> g.nodes
     => [{'name'=>'Foo', 'country'=>'england'}, {'name'=>'Bar'}]
     
and edges

     irb> g.edges
     => [{'node1'=>'Bar', 'node2'=>'Foo', 'day'=>'62', 'duration'=>'14'},
         {'node1'=>'Foo', 'node2'=>'Bar', 'day'=>'154', 'duration'=>'7'}]

Note that the GDF module does not yet support value types (all values are strings).
