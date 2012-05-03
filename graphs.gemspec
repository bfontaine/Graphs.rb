Gem::Specification.new do |s|
    s.name          = 'graphs'
    s.version       = '0.1.3'
    s.date          = Time.now

    s.summary       = 'Utilities to manipulate graph files'
    s.description   = 'Provide functions to (un)parse GDF files and generate graphs'
    s.license       = 'MIT'

    s.author        = 'Baptiste Fontaine'
    s.email         = 'batifon@yahoo.fr'
    s.homepage      = 'https://github.com/bfontaine/Graphs.rb'

    s.files         = ['lib/graph.rb', 'lib/graphs/gdf.rb']
    s.test_files    = Dir.glob('tests/tests_*.rb')
    s.require_path  = 'lib'
    s.platform      = Gem::Platform::CURRENT
end
