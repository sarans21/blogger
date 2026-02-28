# frozen_string_literal: true

require_relative "lib/blogger/version"

Gem::Specification.new do |spec|
  spec.name = "blogger"
  spec.version = Blogger::VERSION
  spec.authors = ["Saran Siriphantnon"]
  spec.email = ["sarans@hey.com"]

  spec.summary = "A static blog engine."
  spec.description = "A static blog engine generator and development environment."
  spec.homepage = "https://sarans.co"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sarans21/blogger"
  spec.metadata["changelog_uri"] = "https://github.com/sarans21/blogger/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "rack-livereload", "~> 0.6"
  spec.add_dependency "rack", ">= 3.0", "<3.2"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
