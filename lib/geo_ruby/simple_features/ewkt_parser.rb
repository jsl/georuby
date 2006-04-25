require 'geo_ruby/simple_features/point'
require 'geo_ruby/simple_features/line_string'
require 'geo_ruby/simple_features/linear_ring'
require 'geo_ruby/simple_features/polygon'
require 'geo_ruby/simple_features/multi_point'
require 'geo_ruby/simple_features/multi_line_string'
require 'geo_ruby/simple_features/multi_polygon'
require 'geo_ruby/simple_features/geometry_collection'

require 'strscan'

module GeoRuby
  module SimpleFeatures

    class EWKTFormatError < StandardError
    end

    #Parses EWKT strings and notifies of events (such as the beginning of the definition of geometry, the value of the SRID...) the factory passed as argument to the constructor.
    #
    #=Example
    # factory = GeometryFactory::new
    # ewkt_parser = EWKTParser::new(factory)
    # ewkt_parser.parse(<EWKT String>)
    # geometry = @factory.geometry
    class EWKTParser
  
      def initialize(factory)
        @factory = factory
        @parse_options ={
          "POINT" => method(:parse_point),
          "LINESTRING" => method(:parse_line_string),
          "POLYGON" => method(:parse_polygon),
          "MULTIPOINT" => method(:parse_multi_point),
          "MULTILINESTRING" => method(:parse_multi_line_string),
          "MULTIPOLYGON" => method(:parse_multi_polygon),
          "GEOMETRYCOLLECTION" => method(:parse_geometry_collection)
        }
      end
      
      #Parses the ewkt string passed as argument and notifies the factory of events
      def parse(ewkt)
        @factory.reset
        @with_z=false
        @with_m=false
        parse_geometry(ewkt)
        @srid=nil
      end
      
      private
      def parse_geometry(ewkt)
        scanner = StringScanner.new(ewkt)
        if scanner.scan(/SRID=(-?\d+);/) 
          if @srid.nil?
            @srid = scanner[1].to_i
          else
            #not the root geometry and repeat of the SRID : shouldn't happen
            raise EWKTFormatError.new("SRID in internal geometry")
          end
        else
          #to manage multi geometries : the srid is not present in sub_geometries, therefore we take the srid of the parent ; if it is the root, we take the default srid
          @srid= @srid || DEFAULT_SRID
        end
        
        if scanner.scan(/(\w+)/)
          geom_type = scanner[1]
          if geom_type[-1] == ?M
            @with_m=true
            geom_type.chop! #remove the M
          end
          #change the parsing method : this one really is ugly...
          if @parse_options.has_key?(geom_type) and scanner.scan(/^\((.*)\)$/)
            @parse_options[to_call].call(scanner[1])
          else
            raise EWKTFormatError.new("Bad token")
          end
        end
        
      end
      def parse_geometry_collection(string)
        @factory.begin_geometry(GeometryCollection,@srid)
        scanner = StringScanner.new(string)
        while(scanner.scan(/\s*(.*?),\s*(?=[A-Z])/))
          parse_geometry(scanner[1])
        end
        parse_geometry(scanner.rest)
        @factory.end_geometry(@with_z,@with_m)
      end
      
      def parse_multi_polygon(string)
        @factory.begin_geometry(MultiPolygon,@srid)
        scanner = StringScanner.new(string)
        while(scanner.scan(/\s*\(\s*(\((.*?)\))\s*\)\s*,?/)) #beeeh
          parse_polygon(scanner[1])
        end
        @factory.end_geometry(@with_z,@with_m)
      end
                 
      def parse_multi_line_string(string)
        @factory.begin_geometry(MultiLineString,@srid)
        scanner = StringScanner.new(string)

        while(scanner.scan(/\s*\(([^\)]*)\)\s*,?/))
          parse_line_string(scanner[1])
        end
        @factory.end_geometry(@with_z,@with_m)
      end

      def parse_polygon(string)
        @factory.begin_geometry(Polygon,@srid)
        scanner = StringScanner.new(string)
        while(scanner.scan(/\s*\(([^\)]*)\)\s*,?/))
          parse_linear_ring(scanner[1])
        end
        @factory.end_geometry(@with_z,@with_m)
      end
            
      def parse_multi_point(string)
        parse_point_list(MultiPoint,string)
      end
      def parse_linear_ring(string)
        parse_point_list(LinearRing,string)
      end
      def parse_line_string(string)
        parse_point_list(LineString,string)
      end
      #used to parse line_strings and linear_rings and multi_points
      def parse_point_list(geometry_type,string)
        @factory.begin_geometry(geometry_type,@srid)
        scanner = StringScanner.new(string)
        while(scanner.scan(/([^,]*),?/))
          parse_point(scanner[1])
        end
        @factory.end_geometry(@with_z,@with_m)
      end
      
      def parse_point(string)
        @factory.begin_geometry(Point,@srid)
        scanner = StringScanner.new(string)
        coords = Array.new
        while scanner.scan(/\s*([-+]?[\d.]+)\s*/)
          coords << scanner[1].to_f
        end
        
        if coords.length == 2
          @factory.add_point_x_y(*coords)
        elsif coords.length == 3
          if @with_m
            @factory.add_point_x_y_m(*coords)
          else
            @with_z=true #we know if it is 3dz only when reading the first point
            @factory.add_point_x_y_z(*coords)
          end
        else
          @with_m=true
          @with_z=true
          @factory.add_point_x_y_z_m(*coords)
        end
        
        @factory.end_geometry(@with_z,@with_m)
      end
    end
    
  end
end
