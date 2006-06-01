require 'geo_ruby/simple_features/geometry'

module GeoRuby
  module SimpleFeatures
    #Represents a collection of arbitrary geometries
    class GeometryCollection < Geometry
      attr_reader :geometries

      def initialize(srid = DEFAULT_SRID,with_z=false,with_m=false)
        super(srid,with_z,with_m)
        @geometries = []
      end
      
      #Delegate the unknown methods to the geometries array
      def method_missing(method_name,*args,&b)
        @geometries.send(method_name,*args,&b)
      end

      #Bounding box in 2D. Returns an array of 2 points
      def bounding_box
        max_x, min_x, max_y, min_y = -Float::MAX, Float::MAX, -Float::MAX, Float::MAX
        each do |geometry|
          bbox = geometry.bounding_box
          sw = bbox[0]
          ne = bbox[1]
          max_y = ne.y if ne.y > max_y
          min_y = sw.y if sw.y < min_y
          max_x = ne.x if ne.x > max_x
          min_x = sw.x if sw.x < min_x 
        end
        [Point.from_x_y(min_x,min_y),Point.from_x_y(max_x,max_y)]
      end

      #tests the equality of geometry collections
      def ==(other_collection)
        if(other_collection.class != self.class)
          false
        elsif length != other_collection.length
          false
        else
          index=0
          while index<length
            return false if self[index] != other_collection[index]
            index+=1
          end
          true
        end
      end
      
      #Binary representation of the collection
      def binary_representation(allow_z=true,allow_m=true)
        rep = [length].pack("V")
        #output the list of geometries without outputting the SRID first and with the same setting regarding Z and M
        each {|geometry| rep << geometry.as_ewkb(false,allow_z,allow_m) }
        rep
      end
      
      #WKB geometry type of the collection
      def binary_geometry_type
        7
      end

      #Text representation of a geometry collection
      def text_representation(allow_z=true,allow_m=true)
        @geometries.collect{|geometry| geometry.as_ewkt(false,allow_z,allow_m)}.join(",")
      end
      
      #WKT geometry type
      def text_geometry_type
        "GEOMETRYCOLLECTION"
      end
      
      #creates a new GeometryCollection from an array of geometries
      def self.from_geometries(geometries,srid=DEFAULT_SRID,with_z=false,with_m=false)
        geometry_collection = GeometryCollection::new(srid,with_z,with_m)
        geometry_collection.concat(geometries)
        geometry_collection
      end
    end
  end
end
