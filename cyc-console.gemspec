Gem::Specification.new do |s|
  s.name = "cyc-console"
  s.version = "0.0.6"
  s.date = "#{Time.now.strftime("%Y-%m-%d")}"
  s.summary = "Ruby console for the Cyc ontology"
  s.email = "apohllo@o2.pl"
  s.homepage = "http://github.com/apohllo/cyc-console"
  s.description = "Ruby console for the Cyc ontology with " +
    "support for readline, colorful output, history, etc."
  s.authors = ['Aleksander Pohl']
  # the lib path is added to the LOAD_PATH
  s.require_path = "lib"
  # include Rakefile, gemspec, README and all the source files
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  # include README while generating rdoc
  s.rdoc_options = ["--main", "README.txt"]
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.txt"]
  s.executables = ['cyc']
  s.add_dependency("colors", [">= 0.0.4"])
  s.add_dependency("cycr", ["~> 0.1.0"])
end

