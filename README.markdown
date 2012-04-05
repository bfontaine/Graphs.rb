The goal of this project is to provide some useful Ruby functions to manipulate
graph files.

GDF Module
----------

The GDF module is used to parse GDF files using the unique method
`GDF.parse(filename)`. It returns a `GDF::Graph` object, which provide two
attributes: `nodes` and `edges`.
