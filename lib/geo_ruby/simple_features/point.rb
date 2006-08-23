require "geo_ruby/simple_features/geometry"

module GeoRuby
  module SimpleFeatures
    #Represents a point. It is in 3D if the Z coordinate is not +nil+.
    class Point < Geometry
      
      attr_accessor :x,:y,:z,:m
      
      def initialize(srid=DEFAULT_SRID,with_z=false,with_m=false)
        super(srid,with_z,with_m)
        @x=0.0
        @y=0.0
        @z=0.0 #default value : meaningful if with_z
        @m=0.0 #default value : meaningful if with_m
      end
      #sets all coordinates in one call. Use the +m+ accessor to set the m.
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
      
      #Return the distance between the 2D points (ie taking care only of the x and y coordinates), assuming the points are in projected coordinates. Euclidian distance in whatever unit the x and y ordinates are.
      def euclidian_distance(point)
        Math.sqrt((point.x - x)**2 + (point.y - y)**2)
      end

      #Returns the sperical distance, with a radius of 6471000m, with the haversine law. Assumes x is the lon and y the lat, in radians. Returns the distance in meters by default, although by passing a value to the radius argument, this can be changed.
      def spherical_distance(point,radius=6371000)
        dlat = point.y - y
        dlon = point.x - x
        a = Math.sin(dlat/2)**2 + Math.cos(point.y) * Math.cos(y) * (Math.sin(dlon/2)**2)
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
        radius * c
      end

      #Ellipsoidal distance? Not implemented yet. Complicated and don't feel like it today. Check out http://www.movable-type.co.uk/scripts/LatLongVincenty.html for more info. I accept patches...
      def ellipsoidal_distance(point)
      end
      
      
      #Bounding box in 2D. Returns an array of 2 points
      def bounding_box
        [Point.from_x_y(@x,@y),Point.from_x_y(@x,@y)] #not too difficult...
      end
      
      #tests the equality of the position of points + m
      def ==(other_point)
        if other_point.class != self.class
          false
        else
          @x == other_point.x and @y == other_point.y and @z == other_point.z and @m == other_point.m
        end
      end
      #binary representation of a point. It lacks some headers to be a valid EWKB representation.
      def binary_representation(allow_z=true,allow_m=true)
        bin_rep = [@x,@y].pack("EE")
        bin_rep += [@z].pack("E") if @with_z and allow_z #Default value so no crash
        bin_rep += [@m].pack("E") if @with_m and allow_m #idem
        bin_rep
      end
      #WKB geometry type of a point
      def binary_geometry_type
        1
      end
      
      #text representation of a point
      def text_representation(allow_z=true,allow_m=true)
        tex_rep = "#{@x} #{@y}"
        tex_rep += " #{@z}" if @with_z and allow_z
        tex_rep += " #{@m}" if @with_m and allow_m
        tex_rep
      end
      #WKT geometry type of a point
      def text_geometry_type
        "POINT"
      end
      
      #creates a point from an array of coordinates
      def self.from_coordinates(coords,srid=DEFAULT_SRID,with_z=false,with_m=false)
        if ! (with_z or with_m)
          from_x_y(coords[0],coords[1],srid)
        elsif with_z and with_m
          from_x_y_z_m(coords[0],coords[1],coords[2],coords[3],srid)
        elsif with_z
          from_x_y_z(coords[0],coords[1],coords[2],srid)
        else
          from_x_y_m(coords[0],coords[1],coords[2],srid) 
        end
      end
      #creates a point from the X and Y coordinates
      def self.from_x_y(x,y,srid=DEFAULT_SRID)
        point= Point::new(srid)
        point.set_x_y(x,y)
        point
      end
      #creates a point from the X, Y and Z coordinates
      def self.from_x_y_z(x,y,z,srid=DEFAULT_SRID)
        point= Point::new(srid,true)
        point.set_x_y_z(x,y,z)
        point
      end
      #creates a point from the X, Y and M coordinates
      def self.from_x_y_m(x,y,m,srid=DEFAULT_SRID)
        point= Point::new(srid,false,true)
        point.set_x_y(x,y)
        point.m=m
        point
      end
      #creates a point from the X, Y, Z and M coordinates
      def self.from_x_y_z_m(x,y,z,m,srid=DEFAULT_SRID)
        point= Point::new(srid,true,true)
        point.set_x_y_z(x,y,z)
        point.m=m
        point
      end
    end
  end
end
