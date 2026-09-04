source 'https://rubygems.org'

# Specify your gem's dependencies in firebase_id_token.gemspec
gemspec

# Allow CI to resolve the bundle against each supported JWT major release.
gem 'jwt', ENV['JWT_VERSION'] if ENV['JWT_VERSION']

# connection_pool 3.x is incompatible with ActiveSupport 7.x's
# RedisCacheStore (positional options hash vs keyword arguments).
gem 'connection_pool', '< 3.0'

# No longer a default gem in Ruby >= 3.5; needed by pry in the specs.
gem 'ostruct'
