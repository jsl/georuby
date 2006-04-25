require 'geo_ruby/simple_features/line_string'

module GeoRuby
  module SimpleFeatures
    #Represents a linear ring, which is a closed line string (see LineString). No check is performed to verify if the linear ring is really closed.
    class LinearRing < LineString
      def initialize(srid= DEFAULT_SRID,with_z=false,with_m=false)
        super(srid,with_z,with_m)
      end

      #creates a new linear ring from an array of points. The first and last points should be equal, although no check is performed here.
      def self.from_points(points,srid=DEFAULT_SRID,with_z=false,with_m=false)
        linear_ring = LinearRing::new(srid,with_z,with_m)
        linear_ring.concat(points)
        linear_ring
      end

      #creates a new linear ring from a sequence of points : ((x,y)...(x,y)).
      def self.from_coordinates(points,srid=DEFAULT_SRID,with_z=false,with_m=false)
        linear_ring = LinearRing::new(srid,with_z,with_m)
        linear_ring.concat( points.collect{|point_coords| Point.from_coordinates(point_coords,srid,with_z,with_m) } )
        linear_ring
      end
      
    end
  end
end
