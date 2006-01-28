require 'geo_ruby/simple_features/point'
require 'geo_ruby/simple_features/line_string'
require 'geo_ruby/simple_features/linear_ring'
require 'geo_ruby/simple_features/polygon'
require 'geo_ruby/simple_features/multi_point'
require 'geo_ruby/simple_features/multi_line_string'
require 'geo_ruby/simple_features/multi_polygon'
require 'geo_ruby/simple_features/geometry_collection'


module GeoRuby
  module SimpleFeatures
    #Creates a new geometry according to constructions received from a parser, for example EWKBParser.
    class GeometryFactory
      #the built geometry
      attr_reader :geometry
      
      def initialize
        @geometry_stack = []
      end
      #resets the factory
      def reset
        @geometry_stack = []
      end
      #add a 2D point to the current geometry
      def add_point_x_y(x,y)
        @geometry_stack.last.set_x_y(x,y)
      end
      #add a 3D point to the current geometry
      def add_point_x_y_z(x,y,z)
        @geometry_stack.last.set_x_y_z(x,y,z)
      end
      #begin a geometry of type +geometry_type+
      def begin_geometry(geometry_type,srid=DEFAULT_SRID)
        geometry= geometry_type::new(srid)
        @geometry= geometry if @geometry.nil?
        @geometry_stack << geometry
      end
      #terminates the current geometry
      def end_geometry
        geometry=@geometry_stack.pop
        #add the newly defined geometry to its parent if there is one
        @geometry_stack.last << geometry if !@geometry_stack.empty?
      end
      #abort a geometry
      def abort_geometry
        reset
      end
    end
  end
end
