require "geo_ruby/simple_features/geometry"

module GeoRuby
  module SimpleFeatures
    #Represents a point. It is in 3D if the Z coordinate is not +nil+.
    class Point < Geometry
      
      attr_accessor :x,:y,:z,:m
      #if you prefer calling the coordinates lat and lon
      alias :lon :x
      alias :lat :y
      
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
      alias :set_lon_lat_z :set_x_y_z
      
      #sets all coordinates of a 2D point in one call
      def set_x_y(x,y)
        @x=x
        @y=y
      end
      alias :set_lon_lat :set_x_y
      
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
      
      
      #Bounding box in 2D/3D. Returns an array of 2 points
      def bounding_box
        unless with_z
          [Point.from_x_y(@x,@y),Point.from_x_y(@x,@y)]
        else
          [Point.from_x_y_z(@x,@y,@z),Point.from_x_y_z(@x,@y,@z)]
        end
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
      def binary_representation(allow_z=true,allow_m=true) #:nodoc:
        bin_rep = [@x,@y].pack("EE")
        bin_rep += [@z].pack("E") if @with_z and allow_z #Default value so no crash
        bin_rep += [@m].pack("E") if @with_m and allow_m #idem
        bin_rep
      end
      #WKB geometry type of a point
      def binary_geometry_type#:nodoc:
        1
      end
      
      #text representation of a point
      def text_representation(allow_z=true,allow_m=true) #:nodoc:
        tex_rep = "#{@x} #{@y}"
        tex_rep += " #{@z}" if @with_z and allow_z
        tex_rep += " #{@m}" if @with_m and allow_m
        tex_rep
      end
      #WKT geometry type of a point
      def text_geometry_type #:nodoc:
        "POINT"
      end

      #georss simple representation
      def georss_simple_representation(options) #:nodoc:
        georss_ns = options[:georss_ns] || "georss"
        geom_attr = options[:geom_attr]
        "<#{georss_ns}:point#{geom_attr}>#{y} #{x}</#{georss_ns}:point>\n"
      end
      #georss w3c representation
      def georss_w3cgeo_representation(options) #:nodoc:
        w3cgeo_ns = options[:w3cgeo_ns] || "geo"
        "<#{w3cgeo_ns}:lat>#{y}</#{w3cgeo_ns}:lat>\n<#{w3cgeo_ns}:lon>#{x}</#{w3cgeo_ns}:lon>\n"
      end
      #georss gml representation
      def georss_gml_representation(options) #:nodoc:
        georss_ns = options[:georss_ns] || "georss"
        gml_ns = options[:gml_ns] || "gml"
        result = "<#{georss_ns}:where>\n<#{gml_ns}:Point>\n<#{gml_ns}:pos>"
        result += "#{y} #{x}"
        result += "</#{gml_ns}:pos>\n</#{gml_ns}:Point>\n</#{georss_ns}:where>\n"
      end

      #outputs the geometry in kml format : options are <tt>:id</tt>, <tt>:tesselate</tt>, <tt>:extrude</tt>,
      #<tt>:altitude_mode</tt>. If the altitude_mode option is not present, the Z (if present) will not be output (since
      #it won't be used by GE anyway: clampToGround is the default)
      def kml_representation(options = {}) #:nodoc: 
        result = "<Point#{options[:id_attr]}>\n"
        result += options[:geom_data]
        result += "<coordinates>#{x},#{y}"
        result += ",#{z || 0}" if options[:allow_z]
        result += "</coordinates>\n"
        result += "</Point>\n"
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
      
      #aliasing the constructors in case you want to use lat/lon instead of y/x
      class << self
        alias :from_lon_lat :from_x_y
        alias :from_lon_lat_z :from_x_y_z
        alias :from_lon_lat_m :from_x_y_m
        alias :from_lon_lat_z_m :from_x_y_z_m
      end
    end
  end
end
