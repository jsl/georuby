require 'geo_ruby/simple_features/geometry_collection'

module GeoRuby
  module SimpleFeatures
    #Represents a group of line strings (see LineString).
    class MultiLineString < GeometryCollection
      def initialize(srid = DEFAULT_SRID)
        super(srid)
      end
      def binary_geometry_type
        5
      end
      #Text representation of a multi line string
      def text_representation(dimension = 2)
        @geometries.collect{|line_string| "(" + line_string.text_representation + ")" }.join(",")
      end
      #WKT geometry type
      def text_geometry_type
        "MULTILINESTRING"
      end
      #Creates a new multi line string from an array of line strings
      def self.from_line_strings(line_strings,srid=DEFAULT_SRID)
        multi_line_string = MultiLineString::new(srid)
        multi_line_string.concat(line_strings)
        multi_line_string
      end
      #Creates a new multi line string from sequences of points : (((x,y)...(x,y)),((x,y)...(x,y)))
      def self.from_raw_point_sequences(point_sequences,srid=DEFAULT_SRID)
        multi_line_string = MultiLineString::new(srid)
        multi_line_string.concat(point_sequences.collect {|point_sequence| LineString.from_raw_point_sequence(point_sequence,srid) })
        multi_line_string
      end
    end
  end
end
