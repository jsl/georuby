require "geo_ruby/simple_features/geometry"

module GeoRuby
  module SimpleFeatures
    #Represents a line string as an array of points (see Point).
    class LineString < Geometry
      #the list of points forming the line string
      attr_reader :points

      def initialize(srid= DEFAULT_SRID,with_z=false,with_m=false)
        super(srid,with_z,with_m)
        @points=[]
      end
      
      #Delegate the unknown methods to the points array
      def method_missing(method_name,*args,&b)
        @points.send(method_name,*args,&b)
      end
      
      #tests if the line string is closed
      def is_closed
        #a bit naive...
        @points.first == @points.last
      end

      #Bounding box in 2D. Returns an array of 2 points
      def bounding_box
        max_x, min_x, max_y, min_y = -Float::MAX, Float::MAX, -Float::MAX, Float::MAX
        each do |point|
          max_y = point.y if point.y > max_y
          min_y = point.y if point.y < min_y
          max_x = point.x if point.x > max_x
          min_x = point.x if point.x < min_x 
        end
        [Point.from_x_y(min_x,min_y),Point.from_x_y(max_x,max_y)]
      end
      
      #Tests the equality of line strings
      def ==(other_line_string)
        if(other_line_string.class != self.class or 
             other_line_string.length != self.length)
          false
        else
          index=0
          while index<length
            return false if self[index] != other_line_string[index]
            index+=1
          end
          true
        end
      end

      #Binary representation of a line string
      def binary_representation(allow_z=true,allow_m=true)
        rep = [length].pack("V")
        each {|point| rep << point.binary_representation(allow_z,allow_m) }
        rep
      end
      
      #WKB geometry type
      def binary_geometry_type
        2
      end

      #Text representation of a line string
      def text_representation(allow_z=true,allow_m=true)
        @points.collect{|point| point.text_representation(allow_z,allow_m) }.join(",") 
      end
      #WKT geometry type
      def text_geometry_type
        "LINESTRING"
      end
      
      #Creates a new line string. Accept an array of points as argument
      def self.from_points(points,srid=DEFAULT_SRID,with_z=false,with_m=false)
        line_string = LineString::new(srid,with_z,with_m)
        line_string.concat(points)
        line_string
      end

      #Creates a new line string. Accept a sequence of points as argument : ((x,y)...(x,y))
      def self.from_coordinates(points,srid=DEFAULT_SRID,with_z=false,with_m=false)
        line_string = LineString::new(srid,with_z,with_m)
        line_string.concat( points.collect{|point_coords| Point.from_coordinates(point_coords,srid,with_z,with_m)  } )
        line_string
      end

     end
  end
end
