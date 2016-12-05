lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_hal/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_hal'
  spec.version       = ActiveHal::VERSION
  spec.authors       = ['Greg Beech']
  spec.email         = ['greg@gregbeech.com']

  spec.summary       = %q{An ActiveModel-like client for HAL APIs}
  spec.description   = %q{An ActiveModel-like client for HAL APIs}
  spec.homepage      = 'https://github.org/gregbeech/active_hal'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '>= 4.0'
  spec.add_dependency 'activesupport', '>= 4.0'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'typhoeus'
  spec.add_dependency 'hashie'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
end
