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
      #add a geometry to the collection
      def <<(geometry)
        @geometries << geometry
      end
      #add geometries to the collection
      def concat(geometries)
        @geometries.concat geometries
      end
      #number of geometries in the collection
      def length
        @geometries.length
      end
      #gets the nth geometry
      def [](n)
        @geometries[n]
      end
      #replaces the nth geometry
      def []=(n,geometry)
        @geometries[n]=geometry
      end
      #iterates over all the geometries
      def each(&proc)
        @geometries.each(&proc)
      end
      #iterates over all the geometries, passing the index to the bloc
      def each_index(&proc)
        @geometries.each_index(&proc)
      end
      #inserts geometries at the nth position
      def insert(n,*geometry)
        @geometries.insert(n,*geometry)
      end
      #index of the geometry
      def index(geometry)
        @geometries.index(geometry)
      end
      #remove a slice of the collection
      def remove(*slice)
        @geometries.slice(*slice)
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
