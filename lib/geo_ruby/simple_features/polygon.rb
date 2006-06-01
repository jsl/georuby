require 'geo_ruby/simple_features/geometry'

module GeoRuby
  module SimpleFeatures
    #Represents a polygon as an array of linear rings (see LinearRing). No check is performed regarding the validity of the geometries forming the polygon.
    class Polygon < Geometry
      #the list of rings forming the polygon
      attr_reader :rings
      
      def initialize(srid = DEFAULT_SRID,with_z=false,with_m=false)
        super(srid,with_z,with_m)
        @rings = []
      end
      
      #Delegate the unknown methods to the rings array
      def method_missing(method_name,*args,&b)
        @rings.send(method_name,*args,&b)
      end
      
      #Bounding box in 2D. Returns an array of 2 points
      def bounding_box
        @rings[0].bounding_box
      end
      
      #tests for other equality. The SRID is not taken into account.
      def ==(other_polygon)
        if other_polygon.class != self.class or
            length != other_polygon.length
          false
        else
          index=0
          while index<length
            return false if self[index] != other_polygon[index]
            index+=1
          end
          true
        end
      end
      #binary representation of a polygon, without the headers neccessary for a valid WKB string
      def binary_representation(allow_z=true,allow_m=true)
        rep = [length].pack("V")
        each {|linear_ring| rep << linear_ring.binary_representation(allow_z,allow_m)}
        rep
      end
      #WKB geometry type
      def binary_geometry_type
        3
      end
      
      #Text representation of a polygon 
      def text_representation(allow_z=true,allow_m=true)
        @rings.collect{|line_string| "(" + line_string.text_representation(allow_z,allow_m) + ")" }.join(",")
      end
      #WKT geometry type
      def text_geometry_type
        "POLYGON"
      end

      #creates a new polygon. Accepts an array of linear strings as argument
      def self.from_linear_rings(linear_rings,srid = DEFAULT_SRID,with_z=false,with_m=false)
        polygon = Polygon::new(srid,with_z,with_m)
        polygon.concat(linear_rings)
        polygon
      end
      
      #creates a new polygon. Accepts a sequence of points as argument : ((x,y)....(x,y)),((x,y).....(x,y))
      def self.from_coordinates(point_sequences,srid=DEFAULT_SRID,with_z=false,with_m=false)
        polygon = Polygon::new(srid,with_z,with_m)
        polygon.concat( point_sequences.collect {|points| LinearRing.from_coordinates(points,srid,with_z,with_m) } )
        polygon
      end


    end
  end
end
