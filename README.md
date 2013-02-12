# Graphs.rb

[![Build Status](https://travis-ci.org/bfontaine/Graphs.rb.png)](https://travis-ci.org/bfontaine/Graphs.rb)

The goal of this project is to provide some useful Ruby functions to manipulate
graph files.

Note: some of the examples below are outdated, since before the 0.1.5 version,
nodes & edges were represented as hashes, and now they are `Node` & `Edge`
objects, respectively. However, the principles stay the sames.

## Install

The best way is to use the `graphs` gem:

    gem install graphs

If you want to have the latest version, clone this repo, build the gem, and
install it:
    
    git clone git://github.com/bfontaine/Graphs.rb.git
    cd Graphs.rb
    gem build graphs.gemspec
    gem install ./graphs-*.gem # you may want to use sudo

## Tests

To perform the tests, clone this repo, then go into `tests` repertory, and
execute `tests.rb` (you need Ruby ≥1.9.x):

    git clone git://github.com/bfontaine/Graphs.rb.git
    cd Graphs.rb/tests
    ruby tests.rb

Make sure you have the latest version.

## Docs

The `Graph` class is a simple graph with nodes and edges. It provides three
read-write attributes: `nodes`, `edges`, and `attr` (attributes of the graph,
like author or description). It can be written in a file using `Graph#write`
method.

`Node` and `Edge` are special classes which inherit from `Hash`. A graph object
provide two important attributes:

* `nodes`: A `NodeArray` object (`Array`-like)
* `edges`: An `EdgeArray` object (`Array`-like, too)

For backward compatibility, you can create nodes and edges both with `Node` and
`Edge` objects, and `Hash` ones, e.g.:

```ruby
require 'graph'

nodes = [ {:label => 'foo'}, {:label => 'bar'} ]

g = Graph.new nodes


nodes2 = nodes.map { |n| Graph::Node.new n }
g2 = Graph.new nodes2

g == g2 # true
```

You can perform some operations on graphes using the `|`, `&`, `^`, `+` or `-`
operators. See the [documentation](http://rubydoc.info/gems/graphs/frames) for
more informations.

### Import/Export

The library currently support JSON and [GDF](http://guess.wikispot.org/The_GUESS_.gdf_format)
formats.

You can read from files using the `::load` methods of each module:

```ruby
require 'graph'
require 'graphs/gdf'
require 'graphs/json'

g1 = GDF::load('myGraph.gdf')
g2 = JSONGraph::load('myGraph.json')
```

You can also export a graph using the `.write` method. It guesses the format
using the file extension.

```ruby
require 'graph'
require 'graphs/gdf'
require 'graphs/json'

g = Graph.new

g.write('myGraph.gdf')
g.write('myGraph.json')
```

Note to [Gephi](https://github.com/gephi/gephi) users who want to export in GDF:
You can add the `:gephi` option to `g.write(…)` if you have big numbers.
`Graph#write` method use `BIGINT` type for big numbers, but Gephi does not
support it and parses it as a string field. So using the following:
    
```ruby
g.write('new_trips.gdf', {:gephi=>true})
```

make sure that `INT` is used for all `BIGINT` fields.

