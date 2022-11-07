# frozen_string_literal: true

require_relative 'lib/rulers/version'

Gem::Specification.new do |spec|
  spec.name = 'rulers'
  spec.version = Rulers::VERSION
  spec.authors = ['Yuri Bocharov']
  spec.email = ['quesadillaman@gmail.com']

  spec.summary = 'I an having a good time.'
  spec.description = 'A real blast.'
  spec.homepage = ''
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_runtime_dependency 'erubis'
  spec.add_runtime_dependency 'multi_json'
  spec.add_runtime_dependency 'rack', '~> 2.2.4'
  spec.add_runtime_dependency 'sqlite3'

  spec.add_development_dependency 'minitest', '~> 5.16'
  spec.add_development_dependency 'rack-test', '~> 2.0'
  spec.add_development_dependency 'rspec', '~> 3.11'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
