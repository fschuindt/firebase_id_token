# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'firebase_id_token/version'

Gem::Specification.new do |spec|
  spec.name          = 'firebase_id_token'
  spec.version       = FirebaseIdToken::VERSION
  spec.authors       = ['Fernando Schuindt']
  spec.email         = ['f.schuindtcs@gmail.com']

  spec.summary       = 'A Firebase ID Token verifier.'
  spec.description   = "Verifies signatures in Firebase ID Tokens. It uses "\
    "Redis to share x509 certificates between multiple instances, just "\
    "request the keys once and you will have it until it's expiration time."
  spec.homepage      = 'https://github.com/fschuindt/firebase_id_token'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against ' \
  #     'public gem pushes.'
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'redcarpet', '~> 3.4.0'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'redis', '~> 3.3.3'
  spec.add_dependency 'redis-namespace', '~> 1.5.3'
  spec.add_dependency 'httparty', '~> 0.14.0'
  spec.add_dependency 'jwt', '~> 1.5.6'
end
