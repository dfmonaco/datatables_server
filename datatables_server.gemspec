# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datatables_server/version'

Gem::Specification.new do |spec|
  spec.name          = "datatables_server"
  spec.version       = DatatablesServer::VERSION
  spec.authors       = ["Diego Mónaco"]
  spec.email         = ["dfmonaco@gmail.com"]
  spec.summary       = %q{Server-side processing for DataTables in Ruby}
  spec.description   = %q{DatatablesServer will receive a number of variables from a Datatables client and
  it will perform all the required processing (i.e. when paging, sorting, filtering etc),
  and then return the data in the format required by DataTables}
  spec.homepage      = "https://github.com/dfmonaco/datatables_server"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.2'
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry-debugger"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "coveralls"
end
