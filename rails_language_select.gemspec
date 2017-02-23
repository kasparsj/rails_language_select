# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rails_language_select/version'

Gem::Specification.new do |s|
  s.name = "rails_language_select"
  s.version = LanguageSelect::VERSION
  s.licenses = ["MIT"]
  s.authors = ["Kaspars Jaudzems"]
  s.email = ["kasparsj@gmail.com"]
  s.homepage = "https://github.com/kasparsj/rails_language_select"
  s.summary = "Helper for displaying a localised <select> of languages"
  s.description = "Helper for displaying a localised <select> of languages using the ISO 369 standard."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2'

  s.add_development_dependency 'actionpack', '~> 3'
  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'wwtd'

  s.add_dependency 'i18n_data', '~> 0.7.0'
  s.add_dependency 'sort_alphabetical', '~> 1.0'
end
