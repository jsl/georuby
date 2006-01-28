$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'geo_ruby'
require 'test/unit'

include GeoRuby::SimpleFeatures

class TestEWKBParser < Test::Unit::TestCase
  
  def setup
    @factory = GeometryFactory::new
    @hex_ewkb_parser = HexEWKBParser::new(@factory)
  end
  
  def test_point2d
    @hex_ewkb_parser.parse("01010000207B000000CDCCCCCCCCCC28406666666666A64640")
    point = @factory.geometry
    assert(point.instance_of?(Point))
    assert_equal(Point.from_x_y(12.4,45.3,123),point)
  end
  
  def test_point3d
    @hex_ewkb_parser.parse("01010000A07B000000CDCCCCCCCCCC28406666666666A646400000000000000CC0")
    point = @factory.geometry
    assert(point.instance_of?(Point))
    assert_equal(Point.from_x_y_z(12.4,45.3,-3.5,123),point)
  end
  
  def test_line_string
    @hex_ewkb_parser.parse("01020000200001000002000000CDCCCCCCCCCC28406666666666A646C03333333333B34640CDCCCCCCCCCC4440")
    line_string = @factory.geometry
    assert(line_string.instance_of?(LineString))
    assert_equal(LineString.from_raw_point_sequence([[12.4,-45.3],[45.4,41.6]],256),line_string)
  end

  def test_polygon
    @hex_ewkb_parser.parse("0103000020000100000200000005000000000000000000000000000000000000000000000000001040000000000000000000000000000010400000000000001040000000000000000000000000000010400000000000000000000000000000000005000000000000000000F03F000000000000F03F0000000000000840000000000000F03F00000000000008400000000000000840000000000000F03F0000000000000840000000000000F03F000000000000F03F")
    polygon = @factory.geometry
    assert(polygon.instance_of?(Polygon))
    assert_equal(Polygon.from_raw_point_sequences([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256),polygon)
  end

  def test_geometry_collection
    @hex_ewkb_parser.parse("010700002000010000020000000101000000AE47E17A14AE12403333333333B34640010200000002000000CDCCCCCCCCCC16406666666666E628403333333333E350400000000000004B40")
    geometry_collection = @factory.geometry
    assert(geometry_collection.instance_of?(GeometryCollection))
    assert_equal(GeometryCollection.from_geometries([Point.from_x_y(4.67,45.4,256),LineString.from_raw_point_sequence([[5.7,12.45],[67.55,54]],256)],256),geometry_collection)
    assert_equal(256,geometry_collection[0].srid)
  end
  
  def test_multi_point
    @hex_ewkb_parser.parse("0104000020BC010000030000000101000000CDCCCCCCCCCC28403333333333D35EC0010100000066666666664650C09A99999999D95E4001010000001F97DD388EE35E400000000000C05E40")
    multi_point = @factory.geometry
    assert(multi_point.instance_of?(MultiPoint))
    assert_equal(MultiPoint.from_raw_point_sequence([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444),multi_point)
    assert_equal(444,multi_point.srid)
    assert_equal(444,multi_point[0].srid)
  end
  
  def test_multi_line_string
    @hex_ewkb_parser.parse("01050000200001000002000000010200000002000000000000000000F83F9A99999999994640E4BD6A65C20F4BC0FA7E6ABC749388BF010200000003000000000000000000F83F9A99999999994640E4BD6A65C20F4BC0FA7E6ABC749388BF39B4C876BE8F46403333333333D35E40")
    multi_line_string = @factory.geometry
    assert(multi_line_string.instance_of?(MultiLineString))
    assert_equal(MultiLineString.from_line_strings([LineString.from_raw_point_sequence([[1.5,45.2],[-54.12312,-0.012]],256),LineString.from_raw_point_sequence([[1.5,45.2],[-54.12312,-0.012],[45.123,123.3]],256)],256),multi_line_string)
    assert_equal(256,multi_line_string.srid)
    assert_equal(256,multi_line_string[0].srid)
  end
  
  def test_multi_polygon
    @hex_ewkb_parser.parse("0106000020000100000200000001030000000200000004000000CDCCCCCCCCCC28406666666666A646C03333333333B34640CDCCCCCCCCCC44406DE7FBA9F1D211403D2CD49AE61DF13FCDCCCCCCCCCC28406666666666A646C004000000333333333333034033333333333315409A999999999915408A8EE4F21FD2F63FEC51B81E85EB2C40F6285C8FC2F5F03F3333333333330340333333333333154001030000000200000005000000000000000000000000000000000000000000000000001040000000000000000000000000000010400000000000001040000000000000000000000000000010400000000000000000000000000000000005000000000000000000F03F000000000000F03F0000000000000840000000000000F03F00000000000008400000000000000840000000000000F03F0000000000000840000000000000F03F000000000000F03F")
    multi_polygon = @factory.geometry
    assert(multi_polygon.instance_of?(MultiPolygon))
    assert_equal(MultiPolygon.from_polygons([Polygon.from_raw_point_sequences([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256),Polygon.from_raw_point_sequences([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)],256),multi_polygon)
    assert_equal(256,multi_polygon.srid)
    assert_equal(256,multi_polygon[0].srid)
  end
  def test_failure_trailing_data
    #added A345 at the end
    assert_raise(StandardError){@hex_ewkb_parser.parse("01010000207B000000CDCCCCCCCCCC28406666666666A64640A345")}
  end
  def test_failure_unknown_geometry_type
    assert_raise(StandardError){@hex_ewkb_parser.parse("01090000207B000000CDCCCCCCCCCC28406666666666A64640")}
  end
  def test_failure_m
    assert_raise(StandardError){@hex_ewkb_parser.parse("01010000607B000000CDCCCCCCCCCC28406666666666A64640")}
  end
  def test_failure_truncated_data
    assert_raise(StandardError){@hex_ewkb_parser.parse("01010000207B000000CDCCCCCCCCCC2840666666")}
  end
  
end
