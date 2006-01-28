require 'geo_ruby/simple_features/geometry'

module GeoRuby
  module SimpleFeatures
    #Represents a collection of arbitrary geometries
    class GeometryCollection < Geometry
      attr_reader :geometries

      def initialize(srid = DEFAULT_SRID)
        super(srid)
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
      def binary_representation(dimension=2)
        rep = [length].pack("V")
        each {|geometry| rep << geometry.as_binary(dimension,false) }
        rep
      end
      #WKB geometry type of the collection
      def binary_geometry_type
        7
      end
      #Text representation of a geometry collection
      def text_representation(dimension=2)
        @geometries.collect{|geometry| geometry.as_text(dimension,false)}.join(",")
      end
      #WKT geometry type
      def text_geometry_type
        "GEOMETRYCOLLECTION"
      end
      #creates a new GeometryCollection from an array of geometries
      def self.from_geometries(geometries,srid=DEFAULT_SRID)
        geometry_collection = GeometryCollection::new(srid)
        geometry_collection.concat(geometries)
        geometry_collection
      end
    end
  end
end
