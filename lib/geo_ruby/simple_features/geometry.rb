module GeoRuby#:nodoc:
  module SimpleFeatures
    #arbitrary default SRID
    DEFAULT_SRID=-1
    #indicates the presence of Z coordinates in EWKB strings
    Z_MASK=0x80000000
    #indicates the presence of M coordinates in EWKB strings. It is not supported at present.
    M_MASK=0x40000000
    #indicate the presence of a SRID in EWKB strings.
    SRID_MASK=0x20000000
    
    
    #Root of all geometric data classes.
    #Objects of class Geometry should not be instantiated.
    class Geometry
      #SRID of the geometry
      attr_accessor :srid
      
      def initialize(srid=DEFAULT_SRID)
        @srid=srid
      end
            
      #Outputs the geometry as an EWKB string.
      #
      #The argument +dimension+ forces the dimension of the output. The argument +with_srid+ indicates if the output must contain the SRID.
      #
      #WKB output can be obtained for any geometry by passing a +dimension+ of 2 and +with_srid+ set to false.
      def as_binary(dimension=2,with_srid=true)
        ewkb="";
       
        ewkb << 1.chr #little_endian by default
        
        type= binary_geometry_type
        if dimension == 3
          type = type | Z_MASK
        end
        if(with_srid)
          type = type | SRID_MASK
          ewkb << [type,@srid].pack("VV")
        else
          ewkb << [type].pack("V")
        end
        ewkb << binary_representation(dimension)
      end
      #Outputs the geometry as a HexEWKB string. It is almost the same as a WKB string, except that each byte of a WKB string is replaced by its hexadecimal 2-character representation in a HexEWKB string.
      #
      #The argument +dimension+ forces the dimension of the output. The argument +with_srid+ indicates if the output must contain the SRID.
      #
      #HexWKB output can be obtained for any geometry by passing a +dimension+ of 2 and +with_srid+ set to false.
      def as_hex_binary(dimension=2,with_srid=true)
        str = ""
        as_binary(dimension,with_srid).each_byte {|char| str << sprintf("%02x",char).upcase}
        str
      end

      #Outputs the geometry as a EWKT string.
      #
      #
      #The argument +dimension+ forces the dimension of the output. The argument +with_srid+ indicates if the output must contain the SRID.
      #
      #WKT output can be obtained for any geometry by passing a +dimension+ of 2 and +with_srid+ set to false.
      def as_text(dimension=2,with_srid=true)
        if with_srid
          ewkt="SRID=#{@srid};"
        else
          ewkt=""
        end
        ewkt << text_geometry_type << "("
        ewkt << text_representation(dimension) << ")"        
      end

      def self.from_ewkb(ewkb)
        factory = GeometryFactory::new
        ewkb_parser= EWKBParser::new(factory)
        ewkb_parser.parse(ewkb)
        factory.geometry
      end

      def self.from_hexewkb(hexewkb)
        factory = GeometryFactory::new
        hexewkb_parser= HexEWKBParser::new(factory)
        hexewkb_parser.parse(hexewkb)
        factory.geometry
      end

      def self.from_ewkt(ewkt)
        factory = GeometryFactory::new
        ewkt_parser= EWKTParser::new(factory)
        ewkt_parser.parse(ewkt)
        factory.geometry
      end
    end
  end
end
