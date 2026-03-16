# frozen_string_literal: true

require_relative 'lib/legion/extensions/memory/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-memory'
  spec.version       = Legion::Extensions::Memory::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Memory'
  spec.description   = 'Memory trace system for brain-modeled agentic AI — consolidation, reinforcement, and decay'
  spec.homepage      = 'https://github.com/LegionIO/lex-memory'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/LegionIO/lex-memory'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-memory'
  spec.metadata['changelog_uri'] = 'https://github.com/LegionIO/lex-memory'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/LegionIO/lex-memory/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
end
