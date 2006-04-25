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
      #tests if the line string is closed
      def is_closed
        #a bit naive...
        @points.first == @points.last
      end
      #add a point to the end of the line string
      def <<(point)
        @points << point
      end
      #add points to the end of the line string
      def concat(points)
        @points.concat points
      end
      #number of points of the line string
      def length
        @points.length
      end
      #accesses the nth point in the line string
      def [](n)
        @points[n]
      end
      #replaces the nth point in the line string
      def []=(n,point)
        @points[n]=point
      end
      #iterates over the points in the line string
      def each(&proc)
        @points.each(&proc)
      end
      #iterates over the points, passing their indices to the bloc
      def each_index(&proc)
        @points.each_index(&proc)
      end
      #inserts points at the nth position
      def insert(n,*point)
        @points.insert(n,*point)
      end
      #gets the indices of point
      def index(point)
        @points.index(point)
      end
      #Removes a slice of points
      def remove(*slice)
        @points.slice(*slice)
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
      def binary_representation(allow_3d=true,allow_m=true)
        rep = [length].pack("V")
        each {|point| rep << point.binary_representation(allow_3d,allow_m) }
        rep
      end
      
      #WKB geometry type
      def binary_geometry_type
        2
      end

      #Text representation of a line string
      def text_representation(allow_3d=true,allow_m=true)
        @points.collect{|point| point.text_representation(allow_3d,allow_m) }.join(",") 
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
