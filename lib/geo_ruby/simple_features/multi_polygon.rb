require 'geo_ruby/simple_features/geometry_collection'


module GeoRuby
  module SimpleFeatures
    #Represents a group of polygons (see Polygon).
   class MultiPolygon < GeometryCollection
      def initialize(srid = DEFAULT_SRID)
        super(srid)
      end
      def binary_geometry_type
        6
      end
      #Text representation of a MultiPolygon
      def text_representation(dimension=2)
        @geometries.collect{|polygon| "(" + polygon.text_representation(dimension) + ")"}.join(",")
      end
      #WKT geometry type
      def text_geometry_type
        "MULTIPOLYGON"
      end
      
      #Creates a multi polygon from an array of polygons
      def self.from_polygons(polygons,srid=DEFAULT_SRID)
        multi_polygon = MultiPolygon::new(srid)
        multi_polygon.concat(polygons)
        multi_polygon
      end
      #Creates a multi polygon from sequences of points : ((((x,y)...(x,y)),((x,y)...(x,y)),((x,y)...(x,y))) 
      def self.from_raw_point_sequences(point_sequences, srid= DEFAULT_SRID)
        multi_polygon = MultiPolygon::new(srid)
        multi_polygon.concat( point_sequences.collect {|point_sequence| Polygon.from_raw_point_sequences(point_sequence,srid) } )
        multi_polygon
      end
      
    end
  end
end
