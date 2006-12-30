module GeoRuby#:nodoc:
  module SimpleFeatures
    #arbitrary default SRID
    DEFAULT_SRID=-1
    #indicates the presence of Z coordinates in EWKB strings
    Z_MASK=0x80000000
    #indicates the presence of M coordinates in EWKB strings.
    M_MASK=0x40000000
    #indicate the presence of a SRID in EWKB strings.
    SRID_MASK=0x20000000
    
    
    #Root of all geometric data classes.
    #Objects of class Geometry should not be instantiated.
    class Geometry
      #SRID of the geometry
      attr_accessor :srid
      #Flag indicating if the z ordinate of the geometry is meaningful
      attr_accessor :with_z
      #Flag indicating if the m ordinate of the geometry is meaningful
      attr_accessor :with_m
      
      def initialize(srid=DEFAULT_SRID,with_z=false,with_m=false)
        @srid=srid
        @with_z=with_z
        @with_m=with_m
      end
            
      #Outputs the geometry as an EWKB string.
      #The +allow_srid+, +allow_z+ and +allow_m+ arguments allow the output to include srid, z and m respectively if they are present in the geometry. If these arguments are set to false, srid, z and m are not included, even if they are present in the geometry. By default, the output string contains all the information in the object.
      def as_ewkb(allow_srid=true,allow_z=true,allow_m=true)
        ewkb="";
       
        ewkb << 1.chr #little_endian by default
        
        type= binary_geometry_type
        if @with_z and allow_z
          type = type | Z_MASK
        end
        if @with_m and allow_m
          type = type | M_MASK
        end
        if @srid != DEFAULT_SRID and allow_srid
          type = type | SRID_MASK
          ewkb << [type,@srid].pack("VV")
        else
          ewkb << [type].pack("V")
        end
        
        ewkb << binary_representation(allow_z,allow_m)
      end
      
      #Outputs the geometry as a strict WKB string.
      def as_wkb
        as_ewkb(false,false,false)
      end

      #Outputs the geometry as a HexEWKB string. It is almost the same as a WKB string, except that each byte of a WKB string is replaced by its hexadecimal 2-character representation in a HexEWKB string.
      def as_hex_ewkb(allow_srid=true,allow_z=true,allow_m=true)
        str = ""
        as_ewkb(allow_srid,allow_z,allow_m).each_byte {|char| str << sprintf("%02x",char).upcase}
        str
      end
      #Outputs the geometry as a strict HexWKB string
      def as_hex_wkb
        as_hex_ewkb(false,false,false)
      end

      #Outputs the geometry as an EWKT string.
      def as_ewkt(allow_srid=true,allow_z=true,allow_m=true)
        if @srid!=DEFAULT_SRID and allow_srid #the default SRID is not output like in PostGIS
          ewkt="SRID=#{@srid};"
        else
          ewkt=""
        end
        ewkt << text_geometry_type 
        ewkt << "M" if @with_m and allow_m and (!@with_z or !allow_z) #to distinguish the M from the Z when there is actually no Z... 
        ewkt << "(" << text_representation(allow_z,allow_m) << ")"        
      end
      
      #Outputs the geometry as strict WKT string.
      def as_wkt
        as_ewkt(false,false,false)
      end

      #outputs the geometry in georss format
      def as_georss(options = {})

      end

      #outputs the geometry in kml format
      def as_kml

      end
      
      #Creates a geometry based on a EWKB string. The actual class returned depends of the content of the string passed as argument. Since WKB strings are a subset of EWKB, they are also valid.
      def self.from_ewkb(ewkb)
        factory = GeometryFactory::new
        ewkb_parser= EWKBParser::new(factory)
        ewkb_parser.parse(ewkb)
        factory.geometry
      end
      #Creates a geometry based on a HexEWKB string
      def self.from_hex_ewkb(hexewkb)
        factory = GeometryFactory::new
        hexewkb_parser= HexEWKBParser::new(factory)
        hexewkb_parser.parse(hexewkb)
        factory.geometry
      end
      #Creates a geometry based on a EWKT string. Since WKT strings are a subset of EWKT, they are also valid.
      def self.from_ewkt(ewkt)
        factory = GeometryFactory::new
        ewkt_parser= EWKTParser::new(factory)
        ewkt_parser.parse(ewkt)
        factory.geometry
      end
    end
  end
end
