# Graphs.rb

[![Build Status](https://travis-ci.org/bfontaine/Graphs.rb.svg?branch=master)](https://travis-ci.org/bfontaine/Graphs.rb)
[![Gem Version](https://img.shields.io/gem/v/graphs.svg)](http://badge.fury.io/rb/graphs)
[![Coverage Status](https://img.shields.io/coveralls/bfontaine/Graphs.rb.svg)](https://coveralls.io/r/bfontaine/Graphs.rb)
[![Inline docs](http://inch-ci.org/github/bfontaine/Graphs.rb.png)](http://inch-ci.org/github/bfontaine/Graphs.rb)
[![Dependency Status](https://img.shields.io/gemnasium/bfontaine/Graphs.rb.svg)](https://gemnasium.com/bfontaine/Graphs.rb)

This library allows you to perform some basic operations on graphs, with
import/export from/to JSON and [GDF][gdf-format] files.

Note: Before the 0.1.5 version, nodes & edges were represented as hashes, and
now they are `Node` & `Edge` objects, respectively. They behave like hashes to
preserve the backward compatibility.

See the [changelog][changelog] for more info.

[changelog]: https://github.com/bfontaine/Graphs.rb/wiki/Gem-versions

## Install

The best way is to use the `graphs` gem:

    gem install graphs

If you want to have the latest version, clone this repo, build the gem, and
install it:

    git clone git://github.com/bfontaine/Graphs.rb.git
    cd Graphs.rb
    gem build graphs.gemspec
    gem install ./graphs-*.gem # you may want to use sudo

If you want to use the high security trust policy, you need to add my public key
as a trusted certificate (you only need to do this once. Note: the key changed
on August 24, 2014):

    gem cert --add <(curl -Ls https://gist.github.com/bfontaine/5233818/raw/gem-public-key.pem)

Then, install the gem with the high security trust policy:

    gem install graphs -P HighSecurity


## Tests

To perform the tests, clone this repo, run `bundle install`,
then `rake` (you need Ruby ≥1.9.x):

    git clone git://github.com/bfontaine/Graphs.rb.git
    cd Graphs.rb
    bundle install
    bundle exec rake


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

The library currently support JSON and [GDF][gdf-format]
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
using the file extension. If the file extension is unknown, it uses the YAML
format.

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


[gdf-format]: http://guess.wikispot.org/The_GUESS_.gdf_format
