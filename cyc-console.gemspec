Gem::Specification.new do |s|
  s.name = "cyc-console"
  s.version = "0.0.2"
  s.date = "2009-07-15"
  s.summary = "Ruby console for the Cyc ontology"
  s.email = "apohllo@o2.pl"
  s.homepage = "http://apohllo.pl"
  s.description = "Ruby console for the Cyc ontology"
  s.authors = ['Aleksander Pohl']
  # the lib path is added to the LOAD_PATH
  s.require_path = "lib"
  # include Rakefile, gemspec, README and all the source files
  s.files = ["Rakefile", "cyc-console.gemspec", "README.txt"] +
    Dir.glob("lib/**/*")
  # include tests and specs
  s.test_files = Dir.glob("{test,spect,features}/**/*")
  # include README while generating rdoc
  s.rdoc_options = ["--main", "README.txt"]
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.txt"]
  s.executables = ['cyc']
  s.add_dependency("apohllo-colors", [">= 0.0.4"])
end

