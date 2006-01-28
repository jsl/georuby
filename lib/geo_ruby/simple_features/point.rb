require "geo_ruby/simple_features/geometry"

module GeoRuby
  module SimpleFeatures
    #Represents a point. It is in 3D if the Z coordinate is not +nil+.
    class Point < Geometry
      #Coordinates of the point
      attr_accessor :x,:y,:z
      
      def initialize(srid=DEFAULT_SRID)
        super(srid)
        @x=0.0
        @y=0.0
        @z=nil
      end
      #sets all coordinates in one call
      def set_x_y_z(x,y,z)
        @x=x
        @y=y
        @z=z
      end
      #sets all coordinates of a 2D point in one call
      def set_x_y(x,y)
        @x=x
        @y=y
      end
      #tests the equality of points
      def ==(other_point)
        if other_point.class != self.class
          false
        else
          @x == other_point.x and @y == other_point.y and @z == other_point.z
        end
      end
      #binary representation of a point. It lacks some headers to be a valid EWKB representation.
      def binary_representation(dimension=2)
        if dimension == 2
          [@x,@y].pack("EE")
        else
          [@x,@y,@z || 0].pack("EEE")
        end
      end
      #WKB geometry type of a point
      def binary_geometry_type
        1
      end
      
      #text representation of a point
      def text_representation(dimension=2)
        if dimension == 2
          "#{@x} #{@y}"
        else
          "#{@x} #{@y} #{@z || 0}"
        end
      end
      #WKT geometry type of a point
      def text_geometry_type
        "POINT"
      end
      
      #creates a point from an array of coordinates
      def self.from_coordinates(coords,srid=DEFAULT_SRID)
        point= Point::new(srid)
        if coords.length == 2
          point.set_x_y(*coords)
        else
          point.set_x_y_z(*coords)
        end
        point
      end
      #creates a point from the X and Y coordinates
      def self.from_x_y(x,y,srid=DEFAULT_SRID)
        point= Point::new(srid)
        point.set_x_y(x,y)
        point
      end
      #creates a point from the X, Y and Z coordinates
      def self.from_x_y_z(x,y,z,srid=DEFAULT_SRID)
        point= Point::new(srid)
        point.set_x_y_z(x,y,z)
        point
      end
    end
  end
end
