$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'geo_ruby'
require 'test/unit'

include GeoRuby::SimpleFeatures

class TestSimpleFeatures < Test::Unit::TestCase

  def test_geometry_creation
    geometry = Geometry::new
    assert_equal(DEFAULT_SRID,geometry.srid)
        
    geometry = Geometry::new(225)
    assert_equal(225,geometry.srid)

    point = Geometry.from_hex_ewkb("01010000207B000000CDCCCCCCCCCC28406666666666A64640")
    assert_equal(Point,point.class)
    assert_equal(12.4,point.x)
        
  end
  def test_point_creation
    point= Point::new(456)
    assert_equal(456,point.srid)
    assert(!point.with_z)
    assert(!point.with_m)
    assert_equal(0.0,point.x)
    assert_equal(0.0,point.y)
    assert_equal(0.0,point.z)
    assert_equal(0.0,point.m)

    point.set_x_y_z(2.6,56.6,12)
    assert_equal(2.6,point.x)
    assert_equal(56.6,point.y)
    assert_equal(12.0,point.z)

    point= Point.from_coordinates([1.6,2.8],123)
    assert_equal(1.6,point.x)
    assert_equal(2.8,point.y)
    assert(!point.with_z)
    assert_equal(0.0,point.z)
    assert_equal(123,point.srid)
    
    point=Point.from_coordinates([1.6,2.8,3.4],123,true)
    assert_equal(1.6,point.x)
    assert_equal(2.8,point.y)
    assert(point.with_z)
    assert_equal(3.4,point.z)
    assert_equal(123,point.srid)
    
    point=Point.from_coordinates([1.6,2.8,3.4,15],DEFAULT_SRID,true,true)
    assert_equal(1.6,point.x)
    assert_equal(2.8,point.y)
    assert(point.with_z)
    assert_equal(3.4,point.z)
    assert(point.with_m)
    assert_equal(15,point.m)
    assert_equal(DEFAULT_SRID,point.srid)
    
    point= Point.from_x_y(1.6,2.8,123)
    assert_equal(1.6,point.x)
    assert_equal(2.8,point.y)
    assert(!point.with_z)
    assert_equal(0,point.z)
    assert_equal(123,point.srid)
    
    point= Point.from_x_y_z(-1.6,2.8,-3.4,123)
    assert_equal(-1.6,point.x)
    assert_equal(2.8,point.y)
    assert_equal(-3.4,point.z)
    assert_equal(123,point.srid)

    point= Point.from_x_y_m(-1.6,2.8,-3.4,123)
    assert_equal(-1.6,point.x)
    assert_equal(2.8,point.y)
    assert_equal(-3.4,point.m)
    assert_equal(123,point.srid)

    point= Point.from_x_y_z_m(-1.6,2.8,-3.4,15,123)
    assert_equal(-1.6,point.x)
    assert_equal(2.8,point.y)
    assert_equal(-3.4,point.z)
    assert_equal(15,point.m)
    assert_equal(123,point.srid)
  end

  def test_point_equal
    point1= Point::new
    point1.set_x_y(1.5,45.4)
    point2= Point::new
    point2.set_x_y(1.5,45.4)
    point3= Point::new
    point3.set_x_y(4.5,12.3)
    point4= Point::new
    point4.set_x_y_z(1.5,45.4,423)
    point5= Point::new
    point5.set_x_y(1.5,45.4)
    point5.m=15
    geometry= Geometry::new

    assert(point1==point2)
    assert(point1!=point3)
    assert(point1!=point4)
    assert(point1==point5) #only compare the geometry
    assert(point1!=geometry)
  end
  
  def test_point_binary
    point = Point.from_x_y(12.4,45.3,123)
    assert_equal("01010000207B000000CDCCCCCCCCCC28406666666666A64640", point.as_hex_ewkb)
    
    point = Point.from_x_y_z(12.4,45.3,-3.5,123)
    assert_equal("01010000A07B000000CDCCCCCCCCCC28406666666666A646400000000000000CC0", point.as_hex_ewkb)

    point = Point.from_x_y_z_m(12.4,45.3,-3.5,15,123)
    assert_equal("01010000E07B000000CDCCCCCCCCCC28406666666666A646400000000000000CC00000000000002E40", point.as_hex_ewkb)

    assert_equal("0101000000CDCCCCCCCCCC28406666666666A64640", point.as_hex_wkb)
  end

  def test_point_text
    point = Point.from_x_y(12.4,45.3,123)
    assert_equal("SRID=123;POINT(12.4 45.3)", point.as_ewkt)
    
    point = Point.from_x_y_z(12.4,45.3,-3.5,123)
    assert_equal("SRID=123;POINT(12.4 45.3 -3.5)", point.as_ewkt)
    assert_equal("POINT(12.4 45.3)", point.as_wkt)
    assert_equal("POINT(12.4 45.3 -3.5)", point.as_ewkt(false,true))

    point = Point.from_x_y_m(12.4,45.3,-3.5,123)
    assert_equal("SRID=123;POINTM(12.4 45.3 -3.5)", point.as_ewkt)
    assert_equal("SRID=123;POINT(12.4 45.3)", point.as_ewkt(true,true,false))
  end

  def test_line_string_creation
    line_string = LineString::new
    line_string.concat([Point.from_x_y(12.4,45.3),Point.from_x_y(45.4,41.6)])
    
    assert_equal(2,line_string.length)
    assert_equal(Point.from_x_y(12.4,45.3),line_string[0])

    point=Point.from_x_y(123,45.8777)
    line_string[0]=point
    assert_equal(point,line_string[0])

    points=[Point.from_x_y(123,45.8777),Point.from_x_y(45.4,41.6)]
    line_string.each_index {|i| assert_equal(points[i],line_string[i]) }

    point=Point.from_x_y(22.4,13.56)
    line_string << point
    assert_equal(3,line_string.length)
    assert_equal(point,line_string[2])

    line_string = LineString.from_points([Point.from_x_y(12.4,-45.3),Point.from_x_y(45.4,41.6)],123)
    assert_equal(LineString,line_string.class)
    assert_equal(2,line_string.length)
    assert_equal(Point.from_x_y(12.4,-45.3),line_string[0])
    assert_equal(Point.from_x_y(45.4,41.6),line_string[1])
    
    line_string = LineString.from_coordinates([[12.4,-45.3],[45.4,41.6],[4.456,1.0698]],123)
    assert_equal(LineString,line_string.class)
    assert_equal(3,line_string.length)
    assert_equal(Point.from_x_y(12.4,-45.3),line_string[0])
    assert_equal(Point.from_x_y(45.4,41.6),line_string[1])

  end
  
  def test_line_string_equal
    line_string1 = LineString.from_coordinates([[12.4,-45.3],[45.4,41.6],[4.456,1.0698]],123)
    line_string2 = LineString.from_coordinates([[12.4,-45.3],[45.4,41.6]],123)
    point = Point.from_x_y(12.4,-45.3,123)
    
    assert(LineString.from_coordinates([[12.4,-45.3],[45.4,41.6],[4.456,1.0698]],123) == line_string1)
    assert(line_string1 != line_string2)
    assert(line_string1 != point)
  end

  def test_line_string_binary
    line_string = LineString.from_coordinates([[12.4,-45.3],[45.4,41.6]],256)
    assert_equal("01020000200001000002000000CDCCCCCCCCCC28406666666666A646C03333333333B34640CDCCCCCCCCCC4440",line_string.as_hex_ewkb)

    line_string = LineString.from_coordinates([[12.4,-45.3,35.3],[45.4,41.6,12.3]],256,true)
    assert_equal("01020000A00001000002000000CDCCCCCCCCCC28406666666666A646C06666666666A641403333333333B34640CDCCCCCCCCCC44409A99999999992840",line_string.as_hex_ewkb)

    line_string = LineString.from_coordinates([[12.4,-45.3,35.3,45.1],[45.4,41.6,12.3,40.23]],256,true,true)
    assert_equal("01020000E00001000002000000CDCCCCCCCCCC28406666666666A646C06666666666A64140CDCCCCCCCC8C46403333333333B34640CDCCCCCCCCCC44409A999999999928403D0AD7A3701D4440",line_string.as_hex_ewkb)
  end
  
  def test_line_string_text
    line_string = LineString.from_coordinates([[12.4,-45.3],[45.4,41.6]],256)
    assert_equal("SRID=256;LINESTRING(12.4 -45.3,45.4 41.6)",line_string.as_ewkt)

    line_string = LineString.from_coordinates([[12.4,-45.3,35.3],[45.4,41.6,12.3]],256,true)
    assert_equal("SRID=256;LINESTRING(12.4 -45.3 35.3,45.4 41.6 12.3)",line_string.as_ewkt)
  end
  
  def test_linear_ring_creation
    #testing just the constructor helpers since the rest is the same as for line_string
    linear_ring = LinearRing.from_coordinates([[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],345)
    assert_equal(LinearRing,linear_ring.class)
    assert_equal(4,linear_ring.length)
    assert(linear_ring.is_closed)
    assert_equal(Point.from_x_y(45.4,41.6,345),linear_ring[1])
  end
  #no test of the binary representation for linear_rings : always with polygons and like line_string
  def test_polygon_creation
    linear_ring1 = LinearRing.from_coordinates([[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],256) 
    linear_ring2 = LinearRing.from_coordinates([[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]],256) 
    
    polygon = Polygon::new(256)
    assert_equal(0,polygon.length)
    
    polygon << linear_ring1
    assert_equal(1,polygon.length)
    assert_equal(linear_ring1,polygon[0])
    
    #the validity of the hole is not checked : just for the sake of example
    polygon << linear_ring2
    assert_equal(2,polygon.length)
    assert_equal(linear_ring2,polygon[1])
    
    polygon = Polygon.from_linear_rings([linear_ring1,linear_ring2],256)
    assert_equal(Polygon,polygon.class)
    assert_equal(2,polygon.length)
    assert_equal(linear_ring1,polygon[0])
    assert_equal(linear_ring2,polygon[1])
    
    polygon = Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256)
    assert_equal(Polygon,polygon.class)
    assert_equal(2,polygon.length)
    assert_equal(linear_ring1,polygon[0])
    assert_equal(linear_ring2,polygon[1])
  end
  def test_polygon_equal
    polygon1 = Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256)
    polygon2 = Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06]]])
    point = Point.from_x_y(12.4,-45.3,123)

    assert(polygon1 == Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256))
    assert(polygon1 != polygon2)
    assert(polygon1 != point)
  end
  def test_polygon_binary
    polygon = Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)
    #taken from PostGIS answer
    assert_equal("0103000020000100000200000005000000000000000000000000000000000000000000000000001040000000000000000000000000000010400000000000001040000000000000000000000000000010400000000000000000000000000000000005000000000000000000F03F000000000000F03F0000000000000840000000000000F03F00000000000008400000000000000840000000000000F03F0000000000000840000000000000F03F000000000000F03F",polygon.as_hex_ewkb)
    
    polygon = Polygon.from_coordinates([[[0,0,2],[4,0,2],[4,4,2],[0,4,2],[0,0,2]],[[1,1,2],[3,1,2],[3,3,2],[1,3,2],[1,1,2]]],256,true)
    #taken from PostGIS answer
    assert_equal("01030000A000010000020000000500000000000000000000000000000000000000000000000000004000000000000010400000000000000000000000000000004000000000000010400000000000001040000000000000004000000000000000000000000000001040000000000000004000000000000000000000000000000000000000000000004005000000000000000000F03F000000000000F03F00000000000000400000000000000840000000000000F03F0000000000000040000000000000084000000000000008400000000000000040000000000000F03F00000000000008400000000000000040000000000000F03F000000000000F03F0000000000000040",polygon.as_hex_ewkb);
  end
  def test_polygon_text
    polygon = Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)
    assert_equal("SRID=256;POLYGON((0 0,4 0,4 4,0 4,0 0),(1 1,3 1,3 3,1 3,1 1))",polygon.as_ewkt)
    
    polygon = Polygon.from_coordinates([[[0,0,2],[4,0,2],[4,4,2],[0,4,2],[0,0,2]],[[1,1,2],[3,1,2],[3,3,2],[1,3,2],[1,1,2]]],256,true)
    assert_equal("SRID=256;POLYGON((0 0 2,4 0 2,4 4 2,0 4 2,0 0 2),(1 1 2,3 1 2,3 3 2,1 3 2,1 1 2))",polygon.as_ewkt);
  end
  def test_geometry_collection_creation
    geometry_collection = GeometryCollection::new(256)
    geometry_collection << Point.from_x_y(4.67,45.4,256)

    assert_equal(1,geometry_collection.length)
    assert_equal(Point.from_x_y(4.67,45.4,256),geometry_collection[0])
    
    geometry_collection[0]=LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)
    geometry_collection << Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)
    assert_equal(2,geometry_collection.length)
    assert_equal(LineString.from_coordinates([[5.7,12.45],[67.55,54]],256),geometry_collection[0])
    
    geometry_collection = GeometryCollection.from_geometries([Point.from_x_y(4.67,45.4,256),LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)],256)
    assert_equal(GeometryCollection,geometry_collection.class)
    assert_equal(256,geometry_collection.srid)
    assert_equal(2,geometry_collection.length)
    assert_equal(LineString.from_coordinates([[5.7,12.45],[67.55,54]],256),geometry_collection[1])
  end
  def test_geometry_collection_equal
    geometry_collection1 = GeometryCollection.from_geometries([Point.from_x_y(4.67,45.4,256),LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)],256)
    geometry_collection2 = GeometryCollection.from_geometries([Point.from_x_y(4.67,45.4,256),LineString.from_coordinates([[5.7,12.45],[67.55,54]],256),Polygon.from_coordinates([[[0,0,2],[4,0,2],[4,4,2],[0,4,2],[0,0,2]],[[1,1,2],[3,1,2],[3,3,2],[1,3,2],[1,1,2]]],256)],256,true)
    line_string=LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)

    assert(GeometryCollection.from_geometries([Point.from_x_y(4.67,45.4,256),LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)],256) == geometry_collection1)
    assert(geometry_collection1 != geometry_collection2)
    assert(geometry_collection1 != line_string)
  end
  def test_geometry_collection_binary
    geometry_collection = GeometryCollection.from_geometries([Point.from_x_y(4.67,45.4,256),LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)],256)
    assert_equal("010700002000010000020000000101000000AE47E17A14AE12403333333333B34640010200000002000000CDCCCCCCCCCC16406666666666E628403333333333E350400000000000004B40",geometry_collection.as_hex_ewkb)
  end
  def test_geometry_collection_text
    geometry_collection = GeometryCollection.from_geometries([Point.from_x_y(4.67,45.4,256),LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)],256)
    assert_equal("SRID=256;GEOMETRYCOLLECTION(POINT(4.67 45.4),LINESTRING(5.7 12.45,67.55 54))",geometry_collection.as_ewkt)
  end
  def test_multi_point_creation
    multi_point = MultiPoint.from_coordinates([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444)
    assert(multi_point.instance_of?(MultiPoint))
    assert_equal(3,multi_point.length)
    assert_equal(Point.from_x_y(12.4,-123.3,444),multi_point[0])
    assert_equal(Point.from_x_y(123.55555555,123,444),multi_point[2])
  end
  def test_multi_point_binary
    multi_point = MultiPoint.from_coordinates([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444)
    assert_equal("0104000020BC010000030000000101000000CDCCCCCCCCCC28403333333333D35EC0010100000066666666664650C09A99999999D95E4001010000001F97DD388EE35E400000000000C05E40",multi_point.as_hex_ewkb)
  end
  def test_multi_point_text
    multi_point = MultiPoint.from_coordinates([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444)
    assert_equal("SRID=444;MULTIPOINT(12.4 -123.3,-65.1 123.4,123.55555555 123)",multi_point.as_ewkt)
  end
  def test_multi_line_string_creation
    multi_line_string1 = MultiLineString.from_line_strings([LineString.from_coordinates([[1.5,45.2],[-54.12312,-0.012]],256),LineString.from_coordinates([[1.5,45.2],[-54.12312,-0.012],[45.123,123.3]],256)],256)
    assert(multi_line_string1.instance_of?(MultiLineString))
    assert_equal(2,multi_line_string1.length)
    assert_equal(LineString.from_coordinates([[1.5,45.2],[-54.12312,-0.012]],256),multi_line_string1[0])
  
    multi_line_string2= MultiLineString.from_coordinates([[[1.5,45.2],[-54.12312,-0.012]],[[1.5,45.2],[-54.12312,-0.012],[45.123,123.3]]],256);
    assert(multi_line_string2.instance_of?(MultiLineString))
    assert_equal(2,multi_line_string2.length)
    assert_equal(LineString.from_coordinates([[1.5,45.2],[-54.12312,-0.012]],256),multi_line_string2[0])
    assert(multi_line_string2 == multi_line_string2)
  end
  
  def test_multi_line_string_binary
    multi_line_string = MultiLineString.from_line_strings([LineString.from_coordinates([[1.5,45.2],[-54.12312,-0.012]],256),LineString.from_coordinates([[1.5,45.2],[-54.12312,-0.012],[45.123,123.3]],256)],256)
    assert_equal("01050000200001000002000000010200000002000000000000000000F83F9A99999999994640E4BD6A65C20F4BC0FA7E6ABC749388BF010200000003000000000000000000F83F9A99999999994640E4BD6A65C20F4BC0FA7E6ABC749388BF39B4C876BE8F46403333333333D35E40",multi_line_string.as_hex_ewkb)
  end
  
  def test_multi_line_string_text
    multi_line_string = MultiLineString.from_line_strings([LineString.from_coordinates([[1.5,45.2],[-54.12312,-0.012]],256),LineString.from_coordinates([[1.5,45.2],[-54.12312,-0.012],[45.123,123.3]],256)],256)
    assert_equal("SRID=256;MULTILINESTRING((1.5 45.2,-54.12312 -0.012),(1.5 45.2,-54.12312 -0.012,45.123 123.3))",multi_line_string.as_ewkt)
  end

  def test_multi_polygon_creation
    multi_polygon1 = MultiPolygon.from_polygons([Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256),Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)],256)
    assert(multi_polygon1.instance_of?(MultiPolygon))
    assert_equal(2,multi_polygon1.length)
    assert_equal(Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256),multi_polygon1[0])

    multi_polygon2 = MultiPolygon.from_coordinates([[[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],[[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]]],256)
    assert(multi_polygon2.instance_of?(MultiPolygon))
    assert_equal(2,multi_polygon2.length)
    assert_equal(Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256),multi_polygon2[0])
    assert(multi_polygon1 == multi_polygon2)
  end
  def test_multi_polygon_binary
    multi_polygon = MultiPolygon.from_polygons([Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256),Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)],256)
    assert_equal("0106000020000100000200000001030000000200000004000000CDCCCCCCCCCC28406666666666A646C03333333333B34640CDCCCCCCCCCC44406DE7FBA9F1D211403D2CD49AE61DF13FCDCCCCCCCCCC28406666666666A646C004000000333333333333034033333333333315409A999999999915408A8EE4F21FD2F63FEC51B81E85EB2C40F6285C8FC2F5F03F3333333333330340333333333333154001030000000200000005000000000000000000000000000000000000000000000000001040000000000000000000000000000010400000000000001040000000000000000000000000000010400000000000000000000000000000000005000000000000000000F03F000000000000F03F0000000000000840000000000000F03F00000000000008400000000000000840000000000000F03F0000000000000840000000000000F03F000000000000F03F",multi_polygon.as_hex_ewkb)
  end
  def test_multi_polygon_text
    multi_polygon = MultiPolygon.from_polygons([Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256),Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)],256)
    assert_equal("SRID=256;MULTIPOLYGON(((12.4 -45.3,45.4 41.6,4.456 1.0698,12.4 -45.3),(2.4 5.3,5.4 1.4263,14.46 1.06,2.4 5.3)),((0 0,4 0,4 4,0 4,0 0),(1 1,3 1,3 3,1 3,1 1)))",multi_polygon.as_ewkt)
  end
  
end
