Gem::Specification.new do |s|
    s.name          = 'graphs'
    s.version       = '0.2.0'
    s.date          = Time.now

    s.summary       = 'Utilities to manipulate graph files'
    s.description   = 'Provide functions to (un)parse GDF/JSON files and generate graphs'
    s.license       = 'MIT'

    s.author        = 'Baptiste Fontaine'
    s.email         = 'batifon@yahoo.fr'
    s.homepage      = 'https://github.com/bfontaine/Graphs.rb'

    s.signing_key   = File.expand_path('~/.gem/gem-private_key.pem')
    s.cert_chain    = ['certs/bfontaine.pem']

    s.files         = ['lib/graph.rb', 'lib/graphs/gdf.rb', 'lib/graphs/json.rb']
    s.test_files    = Dir.glob('tests/*tests.rb')
    s.require_path  = 'lib'

    s.add_development_dependency 'simplecov', '~> 0.7'
    s.add_development_dependency 'rake',      '~> 10.1'
    s.add_development_dependency 'test-unit', '~> 2.5'
    s.add_development_dependency 'coveralls', '~> 0.7'
end
