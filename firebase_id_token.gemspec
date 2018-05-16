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
  spec.description   = "A Ruby gem to verify the signature of Firebase ID "\
    "Tokens. It uses Redis to store Google's x509 certificates and manage "\
    "their expiration time, so you don't need to request Google's API in "\
    "every execution and can access it as fast as reading from memory."
  spec.homepage      = 'https://github.com/fschuindt/firebase_id_token'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'redcarpet', '~> 3.4', '>= 3.4.0'
  spec.add_development_dependency 'simplecov', '~> 0.14.1'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 1.0', '>= 1.0.0'

  spec.add_runtime_dependency 'redis', '>= 3.3.3'
  spec.add_runtime_dependency 'redis-namespace', '~> 1.5', '>= 1.5.3'
  spec.add_dependency 'httparty', '~> 0.14.0'
  spec.add_runtime_dependency 'jwt', '~> 1.5', '>= 1.5.6'
end
