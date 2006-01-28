require 'geo_ruby/simple_features/geometry_collection'

module GeoRuby
  module SimpleFeatures
    #Represents a group of points (see Point).
    class MultiPoint < GeometryCollection
      
      def initialize(srid= DEFAULT_SRID)
        super(srid)
      end
      
      def binary_geometry_type
        4
      end
      #Text representation of a MultiPoint
      def text_representation(dimension=2)
        @geometries.collect{|point| point.text_representation(dimension)}.join(",")
      end
      #WKT geoemtry type
      def text_geometry_type
        "MULTIPOINT"
      end

      #Creates a new multi point from an array of points
      def self.from_points(points,srid= DEFAULT_SRID)
        multi_point= MultiPoint::new(srid)
        multi_point.concat(points)
        multi_point
      end

      #Creates a new multi point from a list of point coordinates : ((x,y)...(x,y))
      def self.from_raw_point_sequence(point_sequence,srid= DEFAULT_SRID)
        multi_point= MultiPoint::new(srid)
        multi_point.concat(point_sequence.collect {|point| Point.from_coordinates(point,srid)})
        multi_point
      end
      
    end
  end
end
