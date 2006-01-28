require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

task :default => :test

desc "Run the tests"
Rake::TestTask::new do |t|
    t.test_files = FileList['test/test*.rb']
    t.verbose = true
end

desc "Generate the documentation"
Rake::RDocTask::new do |rdoc|
  rdoc.rdoc_dir = 'doc/'
  rdoc.title    = "GeoRuby Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

spec = Gem::Specification::new do |s|
  s.platform = Gem::Platform::RUBY

  s.name = 'geo_ruby'
  s.version = "0.0.1"
  s.summary = "Ruby data holder for OGC Simple Features"
  s.description = <<EOF
GeoRuby is intended as a holder for data returned from PostGIS queries. Therefore, the data model roughly follows the OGC "Simple Features for SQL" specification (see www.opengis.org/docs/99-049.pdf), although without any kind of advanced functionalities (such as geometric operators or reprojections)
EOF
  s.author = 'Guilhem Vellut'
  s.email = 'guilhem.vellut+georuby@gmail.com'
  s.homepage = "http://thepochisuperstarmegashow.com"
  
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = FileList["lib/**/*.rb", "test/**/*.rb", "README","MIT-LICENSE","rakefile.rb"]
  s.test_files = FileList['test/test*.rb']

  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.rdoc_options.concat ['--main',  'README']
end

desc "Package the library as a gem"
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end