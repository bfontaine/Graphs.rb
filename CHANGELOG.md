v0.1.5
======

Release date: *soon*.

- `Node` and `Edge` classes added, to replace hashes previously used for nodes
  and edges. Note: this is retro-compatible, since `Node` and `Edges` classes
  work as wrappers around a hash.


New methods
-----------

- `Graph#degree_of(node)` (get the degree of a node)
- `Graph#directed?` (alias of `Graph#attrs[:directed]`)
