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
    #Parses EWKB strings and notifies of events (such as the beginning of the definition of geometry, the value of the SRID...) the factory passed as argument to the constructor.
    #
    #=Example
    # factory = GeometryFactory::new
    # ewkb_parser = EWKBParser::new(factory)
    # ewkb_parser.parse(<EWKB String>)
    # geometry = @factory.geometry
    class EWKBParser
  
      def initialize(factory)
        @factory = factory
        @parse_options ={
          1 => method(:parse_point),
          2 => method(:parse_line_string),
          3 => method(:parse_polygon),
          4 => method(:parse_multi_point),
          5 => method(:parse_multi_line_string),
          6 => method(:parse_multi_polygon),
          7 => method(:parse_geometry_collection)
        }
      end
      
      #Parses the ewkb string passed as argument and notifies the factory of events
      def parse(ewkb)
        @factory.reset
        @unpack_structure=UnpackStructure::new(ewkb)
        parse_geometry
        @unpack_structure.done
      end
      private
      def parse_geometry
        @unpack_structure.endianness=@unpack_structure.read_byte
        @geometry_type = @unpack_structure.read_uint
        @dimension=2
        
        if (@geometry_type & Z_MASK) != 0
          @dimension=3
          @geometry_type = @geometry_type & ~Z_MASK
        end
        if (@geometry_type & M_MASK) != 0
          raise StandardError::new("For next version")
        end
        if (@geometry_type & SRID_MASK) != 0
          @srid = @unpack_structure.read_uint
          @geometry_type = @geometry_type & ~SRID_MASK
        else
          #to manage multi geometries : the srid is not present in sub_geometries, therefore we take the srid of the parent ; if it is the parent, we take the default srid
          @srid= @srid || DEFAULT_SRID
        end
        if @parse_options.has_key? @geometry_type
          @parse_options[@geometry_type].call
        else
          raise StandardError::new("Unknown geometry type")
        end
      end
      def parse_geometry_collection
        parse_multi_geometries(GeometryCollection)
      end
      ##must be corrected : endianness + geometry_type present
      def parse_multi_polygon
        parse_multi_geometries(MultiPolygon)
      end
      #must be corrected
      def parse_multi_line_string
        parse_multi_geometries(MultiLineString)
      end
      #must be corrected
      def parse_multi_point
        parse_multi_geometries(MultiPoint)
      end
      def parse_multi_geometries(geometry_type)
        @factory.begin_geometry(geometry_type,@srid)
        num_geometries = @unpack_structure.read_uint
        1.upto(num_geometries) { parse_geometry }
        @factory.end_geometry
      end
      def parse_polygon
        @factory.begin_geometry(Polygon,@srid)
        num_linear_rings = @unpack_structure.read_uint
        1.upto(num_linear_rings) {parse_linear_ring}
        @factory.end_geometry
      end
      def parse_linear_ring
        parse_point_list(LinearRing)
      end
      def parse_line_string
        parse_point_list(LineString)
      end
      #used to parse line_strings and linear_rings
      def parse_point_list(geometry_type)
        @factory.begin_geometry(geometry_type,@srid)
        num_points = @unpack_structure.read_uint
        1.upto(num_points) {parse_point}
        @factory.end_geometry
      end
      def parse_point
        @factory.begin_geometry(Point,@srid)
        x = @unpack_structure.read_double
        y = @unpack_structure.read_double
        if @dimension == 3
          z = @unpack_structure.read_double
          @factory.add_point_x_y_z(x,y,z)
        else
          @factory.add_point_x_y(x,y)
        end
        @factory.end_geometry
      end
    end

    #Parses HexEWKB strings. In reality, it just transforms the HexEWKB string into the equivalent EWKB string and lets the EWKBParser do the actual parsing.
    class HexEWKBParser < EWKBParser
      def initialize(factory)
        super(factory)
      end
      #parses an HexEWKB string
      def parse(hexewkb)
        super(decode_hex(hexewkb))
      end
      #transforms a HexEWKB string into an EWKB string 
      def decode_hex(hexewkb)
        temp_hexewkb= hexewkb.clone
        result=""
        while c = temp_hexewkb.slice!(0,2) do
          break if c.length==0
          result << c.hex
        end
        result
      end

    end

    class UnpackStructure #:nodoc:
      NDR=1
      XDR=2
      def initialize(ewkb)
        @position=0
        @ewkb=ewkb
      end
      def done
        raise StandardError::new("Trailing data") if @position != @ewkb.length
      end
      def read_double
        i=@position
        @position += 8
        packed_double = @ewkb[i...@position]
        raise StandardError::new("Truncated data") if packed_double.nil? or packed_double.length < 8
        packed_double.unpack(@double_mark)[0]
      end
      def read_uint
        i=@position
        @position += 4
        packed_uint = @ewkb[i...@position]
        raise StandardError::new("Truncated data") if packed_uint.nil? or packed_uint.length < 4
        packed_uint.unpack(@uint_mark)[0]
      end
      def read_byte
        i = @position
        @position += 1
        packed_byte = @ewkb[i...@position]
        raise StandardError::new("Truncated data") if packed_byte.nil? or packed_byte.length < 1
        packed_byte.unpack("C")[0]
      end
      def endianness=(byte_order)
        if(byte_order == NDR)
          @uint_mark="V"
          @double_mark="E"
        elsif(byte_order == XDR)
          @uint_mark="N"
          @double_mark="G"
        end
      end
    end
  end
end