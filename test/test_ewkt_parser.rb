$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'geo_ruby'
require 'test/unit'


include GeoRuby::SimpleFeatures

class TestEWKTParser < Test::Unit::TestCase
  
  def setup
    @factory = GeometryFactory::new
    @ewkt_parser = EWKTParser::new(@factory)
  end
  
  def test_point
    ewkt="POINT( 3.456 0.123)"
    @ewkt_parser.parse(ewkt)
    point = @factory.geometry
    assert(point.instance_of?(Point))
    assert_equal(Point.from_x_y(3.456,0.123),point)
  end
  
  def test_point_with_srid
    ewkt="SRID=245;POINT(0.0 2.0)"
    @ewkt_parser.parse(ewkt)
    point = @factory.geometry
    assert(point.instance_of?(Point))
    assert_equal(Point.from_x_y(0,2,245),point)
    assert_equal(245,point.srid)
    assert_equal(point.as_ewkt(true,false),ewkt)
  end
  
  def test_point3dz
    ewkt="POINT(3.456 0.123 123.667)"
    @ewkt_parser.parse(ewkt)
    point = @factory.geometry
    assert(point.instance_of?(Point))
    assert_equal(Point.from_x_y_z(3.456,0.123,123.667),point)
    assert_equal(point.as_ewkt(false),ewkt)
  end

  def test_point3dm
    ewkt="POINTM(3.456 0.123 123.667)"
    @ewkt_parser.parse(ewkt)
    point = @factory.geometry
    assert(point.instance_of?(Point))
    assert_equal(Point.from_x_y_m(3.456,0.123,123.667),point)
    assert_equal(point.as_ewkt(false),ewkt)
  end

  def test_point4d
    ewkt="POINT(3.456 0.123 123.667 15.0)"
    @ewkt_parser.parse(ewkt)
    point = @factory.geometry
    assert(point.instance_of?(Point))
    assert_equal(Point.from_x_y_z_m(3.456,0.123,123.667,15.0),point)
    assert_equal(point.as_ewkt(false),ewkt)
  end

   def test_linestring
    @ewkt_parser.parse("LINESTRING(3.456 0.123,123.44 123.56,54555.22 123.3)")
    linestring = @factory.geometry
    assert(linestring.instance_of?(LineString))
    assert_equal(LineString.from_coordinates([[3.456,0.123],[123.44,123.56],[54555.22,123.3]]),linestring)
  end

   def test_polygon
    @ewkt_parser.parse("POLYGON((0 0,4 0,4 4,0 4,0 0),(1 1,3 1,3 3,1 3,1 1))")
    polygon = @factory.geometry
    assert(polygon.instance_of?(Polygon))
    assert_equal(Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256),polygon)
   end

   def test_multi_point
    @ewkt_parser.parse("SRID=444;MULTIPOINT(12.4 -123.3,-65.1 123.4,123.55555555 123)")
    multi_point = @factory.geometry
    assert(multi_point.instance_of?(MultiPoint))
    assert_equal(MultiPoint.from_coordinates([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444),multi_point)
    assert_equal(444,multi_point.srid)
    assert_equal(444,multi_point[0].srid)
  end

   def test_multi_line_string
    @ewkt_parser.parse("SRID=256;MULTILINESTRING((1.5 45.2,-54.12312 -0.012),(1.5 45.2,-54.12312 -0.012,45.123 123.3))")
    multi_line_string = @factory.geometry
    assert(multi_line_string.instance_of?(MultiLineString))
    assert_equal(MultiLineString.from_line_strings([LineString.from_coordinates([[1.5,45.2],[-54.12312,-0.012]],256),LineString.from_coordinates([[1.5,45.2],[-54.12312,-0.012],[45.123,123.3]],256)],256),multi_line_string)
    assert_equal(256,multi_line_string.srid)
    assert_equal(256,multi_line_string[0].srid)
  end

   def test_multi_polygon
     ewkt="SRID=256;MULTIPOLYGON(((12.4 -45.3,45.4 41.6,4.456 1.0698,12.4 -45.3),(2.4 5.3,5.4 1.4263,14.46 1.06,2.4 5.3)),((0.0 0.0,4.0 0.0,4.0 4.0,0.0 4.0,0.0 0.0),(1.0 1.0,3.0 1.0,3.0 3.0,1.0 3.0,1.0 1.0)))"
     @ewkt_parser.parse(ewkt)
     multi_polygon = @factory.geometry
     assert(multi_polygon.instance_of?(MultiPolygon))
     assert_equal(MultiPolygon.from_polygons([Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256),Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)],256),multi_polygon)
     assert_equal(256,multi_polygon.srid)
     assert_equal(256,multi_polygon[0].srid)
     assert_equal(multi_polygon.as_ewkt,ewkt)
  end

   def test_geometry_collection
    @ewkt_parser.parse("SRID=256;GEOMETRYCOLLECTION(POINT(4.67 45.4),LINESTRING(5.7 12.45,67.55 54),POLYGON((0 0,4 0,4 4,0 4,0 0),(1 1,3 1,3 3,1 3,1 1)))")
    geometry_collection = @factory.geometry
    assert(geometry_collection.instance_of?(GeometryCollection))
    assert_equal(GeometryCollection.from_geometries([Point.from_x_y(4.67,45.4,256),LineString.from_coordinates([[5.7,12.45],[67.55,54]],256),Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)],256),geometry_collection)
    assert_equal(256,geometry_collection[0].srid)
  end

end
