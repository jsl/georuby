# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{GeoRuby}
  s.version = "1.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Guilhem Vellut", "Andrew Turner", "Kashif Rasul", "Shoaib Burq"]
  s.date = %q{2009-03-19}
  s.description = %q{GeoRuby is a holder for data returned from PostGIS and the Spatial Extensions of MySql which supports various input and output formats}
  s.email = %q{guilhem.vellut@gmail.com}
  s.files = [
    "tools/shp2sql.rb", "tools/db.yml", "test/test_simple_features.rb", "test/test_shp_write.rb", "test/test_shp.rb", "test/test_georss_kml.rb", 
    "test/test_ewkt_parser.rb", "test/test_ewkb_parser.rb", "test/data/polyline.shx", "test/data/polyline.shp", "test/data/polyline.dbf", 
    "test/data/polygon.shx", "test/data/polygon.shp", "test/data/polygon.dbf", "test/data/point.shx", "test/data/point.shp", "test/data/point.dbf", 
    "test/data/multipoint.shx", "test/data/multipoint.shp", "test/data/multipoint.dbf", "README", "rakefile.rb", "MIT-LICENSE", "lib/geo_ruby.rb", 
    "lib/geo_ruby/simple_features/polygon.rb", "lib/geo_ruby/simple_features/point.rb", "lib/geo_ruby/simple_features/multi_polygon.rb", 
    "lib/geo_ruby/simple_features/multi_point.rb", "lib/geo_ruby/simple_features/multi_line_string.rb", "lib/geo_ruby/simple_features/linear_ring.rb", 
    "lib/geo_ruby/simple_features/line_string.rb", "lib/geo_ruby/simple_features/helper.rb", "lib/geo_ruby/simple_features/georss_parser.rb", 
    "lib/geo_ruby/simple_features/geometry_factory.rb", "lib/geo_ruby/simple_features/geometry_collection.rb", "lib/geo_ruby/simple_features/geometry.rb", 
    "lib/geo_ruby/simple_features/ewkt_parser.rb", "lib/geo_ruby/simple_features/ewkb_parser.rb", "lib/geo_ruby/simple_features/envelope.rb", 
    "lib/geo_ruby/shp4r/shp.rb", "lib/geo_ruby/shp4r/dbf.rb", "georuby.gemspec"
  ]  
  
  s.has_rdoc = true
  s.homepage = %q{http://georuby.rubyforge.org/}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{georuby}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{GeoRuby is a holder for data returned from PostGIS and the Spatial Extensions of MySql which supports various input and output formats}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mime-types>, [">= 1.15"])
      s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
    else
      s.add_dependency(%q<mime-types>, [">= 1.15"])
      s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
    end
  else
    s.add_dependency(%q<mime-types>, [">= 1.15"])
    s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
  end
end
