$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'geo_ruby'
require 'test/unit'

include GeoRuby::SimpleFeatures

class TestGeorssKml < Test::Unit::TestCase

  def test_geometry_creation
    point = Point.from_x_y(3,4)
    
    assert_equal("<georss:point featuretypetag=\"hoyoyo\" elev=\"45.7\">4 3</georss:point>", point.as_georss(:dialect => :simple, :elev => 45.7, :featuretypetag => "hoyoyo").gsub("\n",""))
    assert_equal("<geo:lat>4</geo:lat><geo:long>3</geo:long>",point.as_georss(:dialect => :w3cgeo).gsub("\n",""))
    assert_equal("<georss:where><gml:Point><gml:pos>4 3</gml:pos></gml:Point></georss:where>",point.as_georss(:dialect => :gml).gsub("\n",""))

    assert_equal("<Point id=\"HOYOYO-42\"><coordinates>3,4</coordinates></Point>",point.as_kml(:id => "HOYOYO-42").gsub("\n",""))
  end

  def test_line_string
    ls = LineString.from_points([Point.from_lon_lat_z(12.4,-45.3,56),Point.from_lon_lat_z(45.4,41.6,45)],123,true)

    assert_equal("<georss:line>-45.3 12.4 41.6 45.4</georss:line>",ls.as_georss.gsub("\n",""))
    assert_equal("<geo:lat>-45.3</geo:lat><geo:long>12.4</geo:long>",ls.as_georss(:dialect => :w3cgeo).gsub("\n",""))
    assert_equal("<georss:where><gml:LineString><gml:posList>-45.3 12.4 41.6 45.4</gml:posList></gml:LineString></georss:where>",ls.as_georss(:dialect => :gml).gsub("\n",""))

    assert_equal("<LineString><extrude>1</extrude><altitudeMode>absolute</altitudeMode><coordinates>12.4,-45.3,56 45.4,41.6,45</coordinates></LineString>",ls.as_kml(:extrude => 1, :altitude_mode => "absolute").gsub("\n",""))
  end 

  def test_polygon
     linear_ring1 = LinearRing.from_coordinates([[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],256) 
    linear_ring2 = LinearRing.from_coordinates([[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]],256) 
    polygon = Polygon.from_linear_rings([linear_ring1,linear_ring2],256)

    assert_equal("<hoyoyo:polygon>-45.3 12.4 41.6 45.4 1.0698 4.456 -45.3 12.4</hoyoyo:polygon>",polygon.as_georss(:georss_ns => "hoyoyo").gsub("\n",""))
    assert_equal("<bouyoul:lat>-45.3</bouyoul:lat><bouyoul:long>12.4</bouyoul:long>",polygon.as_georss(:dialect => :w3cgeo, :w3cgeo_ns => "bouyoul").gsub("\n",""))
    assert_equal("<georss:where><gml:Polygon><gml:exterior><gml:LinearRing><gml:posList>-45.3 12.4 41.6 45.4 1.0698 4.456 -45.3 12.4</gml:posList></gml:LinearRing></gml:exterior></gml:Polygon></georss:where>",polygon.as_georss(:dialect => :gml).gsub("\n",""))

    assert_equal("<Polygon><outerBoundaryIs><LinearRing><coordinates>12.4,-45.3 45.4,41.6 4.456,1.0698 12.4,-45.3</coordinates></LinearRing></outerBoundaryIs><innerBoundaryIs><LinearRing><coordinates>2.4,5.3 5.4,1.4263 14.46,1.06 2.4,5.3</coordinates></LinearRing></innerBoundaryIs></Polygon>",polygon.as_kml.gsub("\n",""))
  end

  def test_geometry_collection
    gc = GeometryCollection.from_geometries([Point.from_x_y(4.67,45.4,256),LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)],256)
    
    #only the first geometry is output
    assert_equal("<georss:point floor=\"4\">45.4 4.67</georss:point>",gc.as_georss(:dialect => :simple,:floor => 4).gsub("\n",""))
    assert_equal("<geo:lat>45.4</geo:lat><geo:long>4.67</geo:long>",gc.as_georss(:dialect => :w3cgeo).gsub("\n",""))
    assert_equal("<georss:where><gml:Point><gml:pos>45.4 4.67</gml:pos></gml:Point></georss:where>",gc.as_georss(:dialect => :gml).gsub("\n",""))
    
    assert_equal("<MultiGeometry id=\"HOYOYO-42\"><Point><coordinates>4.67,45.4</coordinates></Point><LineString><coordinates>5.7,12.45 67.55,54</coordinates></LineString></MultiGeometry>",gc.as_kml(:id => "HOYOYO-42").gsub("\n",""))
  end

  def test_envelope
    linear_ring1 = LinearRing.from_coordinates([[12.4,-45.3,5],[45.4,41.6,6],[4.456,1.0698,8],[12.4,-45.3,3.5]],256,true) 
    linear_ring2 = LinearRing.from_coordinates([[2.4,5.3,9.0],[5.4,1.4263,-5.4],[14.46,1.06,34],[2.4,5.3,3.14]],256,true) 
    polygon = Polygon.from_linear_rings([linear_ring1,linear_ring2],256,true)
    
    e = polygon.envelope
    
    assert_equal("<georss:box>-45.3 4.456 41.6 45.4</georss:box>",e.as_georss(:dialect => :simple).gsub("\n",""))
    #center
    assert_equal("<geo:lat>-1.85</geo:lat><geo:long>24.928</geo:long>",e.as_georss(:dialect => :w3cgeo).gsub("\n",""))
    assert_equal("<georss:where><gml:Envelope><gml:LowerCorner>-45.3 4.456</gml:LowerCorner><gml:UpperCorner>41.6 45.4</gml:UpperCorner></gml:Envelope></georss:where>",e.as_georss(:dialect => :gml).gsub("\n",""))
    
    assert_equal("<LatLonAltBox><north>41.6</north><south>-45.3</south><east>45.4</east><west>4.456</west><minAltitude>-5.4</minAltitude><maxAltitude>34</maxAltitude></LatLonAltBox>",e.as_kml.gsub("\n",""))
  end

end
