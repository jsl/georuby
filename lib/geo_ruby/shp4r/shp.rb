require  File.dirname(__FILE__) + '/dbf'

module GeoRuby
  module Shp4r
    
    #Enumerates all the types of SHP geometries. The MULTIPATCH one is the only one not currently supported by GeoRuby.
    module ShpType
      NULL_SHAPE = 0
      POINT = 1
      POLYLINE = 3
      POLYGON = 5
      MULTIPOINT = 8
      POINTZ = 11
      POLYLINEZ = 13
      POLYGONZ = 15
      MULTIPOINTZ = 18
      POINTM = 21
      POLYLINEM = 23
      POLYGONM = 25
      MULTIPOINTM = 28
      MULTIPATCH = 31 #not supported here
    end
    
    #An interface to an ESRI shapefile (actually 3 files : shp, shx and dbf). Currently supports only the reading of geometries.
    class ShpFile
      attr_reader :shp_type, :record_count, :xmin, :ymin, :xmax, :ymax, :zmin, :zmax, :mmin, :mmax

      include Enumerable

      #Opens a SHP file. Both "abc.shp" and "abc" are accepted. The files "abc.shp", "abc.shx" and "abc.dbf" must be present
      def initialize(file, access = "r")
        #strip the shp out of the file if present
        file = file.gsub(/.shp$/i,"")
        #check existence of shp, dbf and shx files       
        unless File.exists?(file + ".shp") and File.exists?(file + ".dbf") and File.exists?(file + ".shx")
          raise MalformedShpException.new("Missing one of shp, dbf or shx for: #{file}")
        end

        @dbf = Dbf::Reader.open(file + ".dbf")
        @shx = File.open(file + ".shx","rb")
        @shp = File.open(file + ".shp","rb")
        read_index
      end
      
      #opens a SHP "file". If a block is given, the ShpFile object is yielded to it and is closed upon return. Else a call to <tt>open</tt> is equivalent to <tt>ShpFile.new(...)</tt>.
      def self.open(file,access = "r")
        shpfile = ShpFile.new(file,access)
        if block_given?
          yield shpfile
          shpfile.close
        else
          shpfile
        end
      end
      
      #Closes a shapefile
      def close
        @dbf.close
        @shx.close
        @shp.close
      end
      
      #return the description of data fields
      def fields
        @dbf.fields
      end
      
      #Tests if the file has no record
      def empty?
        record_count == 0
      end
      
      #Goes through each record
      def each
        (0...record_count).each do |i|
          yield get_record(i)
        end
      end
      alias :each_record :each
      
      #Returns record +i+
      def [](i)
        get_record(i)
      end

      #Returns all the records
      def records
        Array.new(record_count) do |i|
          get_record(i)
        end
      end

      private   
      def read_index
        file_length, @shp_type, @xmin, @ymin, @xmax, @ymax, @zmin, @zmax, @mmin,@mmax = @shx.read(100).unpack("x24Nx4VE8")
        @record_count = (file_length - 50) / 4
        unless @record_count == @dbf.record_count
          raise MalformedShpException.new("Not the same number of records in SHP and DBF")
        end
      end

      #TODO : refactor to minimize redundant code
      def get_record(i)
        return nil if record_count <= i or i < 0
        dbf_record = @dbf.record(i)
        @shx.seek(100 + 8 * i) #100 is the header length
        offset,length = @shx.read(8).unpack("N2")
        @shp.seek(offset * 2 + 8)
        rec_shp_type = @shp.read(4).unpack("V")[0]

        case(rec_shp_type)
        when ShpType::POINT
          x, y = @shp.read(16).unpack("E2")
          geometry = GeoRuby::SimpleFeatures::Point.from_x_y(x,y)


        when ShpType::POLYLINE #actually creates a multi_polyline
          @shp.seek(32,IO::SEEK_CUR) #extent 
          num_parts, num_points = @shp.read(8).unpack("V2")
          
          parts =  @shp.read(num_parts * 4).unpack("V" + num_parts.to_s)
          parts << num_points #indexes for LS of idx i go to parts of idx i to idx i +1
          
          points = Array.new(num_points) do
            x, y = @shp.read(16).unpack("E2")
            GeoRuby::SimpleFeatures::Point.from_x_y(x,y)
          end
          
          line_strings = Array.new(num_parts) do |i|
            GeoRuby::SimpleFeatures::LineString.from_points(points[(parts[i])...(parts[i+1])])
          end
          
          geometry = GeoRuby::SimpleFeatures::MultiLineString.from_line_strings(line_strings)


        when ShpType::POLYGON
          #TODO : TO CORRECT
          #does not take into account the possibility that the outer loop could be after the inner loops in the SHP + more than one outer loop
          #Still sends back a multi polygon (so the correction above won't change what gets sent back)
          @shp.seek(32,IO::SEEK_CUR)
          num_parts, num_points = @shp.read(8).unpack("V2")
          parts =  @shp.read(num_parts * 4).unpack("V" + num_parts.to_s)
          parts << num_points #indexes for LS of idx i go to parts of idx i to idx i +1
          points = Array.new(num_points) do 
            x, y = @shp.read(16).unpack("E2")
            GeoRuby::SimpleFeatures::Point.from_x_y(x,y)
          end
          linear_rings = Array.new(num_parts) do |i|
            GeoRuby::SimpleFeatures::LinearRing.from_points(points[(parts[i])...(parts[i+1])])
          end
          geometry = GeoRuby::SimpleFeatures::MultiPolygon.from_polygons([GeoRuby::SimpleFeatures::Polygon.from_linear_rings(linear_rings)])


        when ShpType::MULTIPOINT
          @shp.seek(32,IO::SEEK_CUR)
          num_points = @shp.read(4).unpack("V")[0]
          points = Array.new(num_points) do
            x, y = @shp.read(16).unpack("E2")
            GeoRuby::SimpleFeatures::Point.from_x_y(x,y)
          end
          geometry = GeoRuby::SimpleFeatures::MultiPoint.from_points(points)


        when ShpType::POINTZ
          x, y, z, m = @shp.read(24).unpack("E4")
          geometry = GeoRuby::SimpleFeatures::Point.from_x_y_z_m(x,y,z,m)


        when ShpType::POLYLINEZ
          @shp.seek(32,IO::SEEK_CUR)
          num_parts, num_points = @shp.read(8).unpack("V2")
          parts =  @shp.read(num_parts * 4).unpack("V" + num_parts.to_s)
          parts << num_points #indexes for LS of idx i go to parts of idx i to idx i +1
          xys = Array.new(num_points) { @shp.read(16).unpack("E2") }
          @shp.seek(16,IO::SEEK_CUR)
          zs = Array.new(num_points) {@shp.read(8).unpack("E")[0]}
          @shp.seek(16,IO::SEEK_CUR)
          ms = Array.new(num_points) {@shp.read(8).unpack("E")[0]}
          points = Array.new(num_points) do |i|
            GeoRuby::SimpleFeatures::Point.from_x_y_z_m(xys[i][0],xys[i][1],zs[i],ms[i])
          end
          line_strings = Array.new(num_parts) do |i|
            GeoRuby::SimpleFeatures::LineString.from_points(points[(parts[i])...(parts[i+1])],GeoRuby::SimpleFeatures::DEFAULT_SRID,true,true)
          end
          geometry = GeoRuby::SimpleFeatures::MultiLineString.from_line_strings(line_strings,GeoRuby::SimpleFeatures::DEFAULT_SRID,true,true)

          
        when ShpType::POLYGONZ
          #TODO : CORRECT

          @shp.seek(32,IO::SEEK_CUR)#extent 
          num_parts, num_points = @shp.read(8).unpack("V2")
          parts =  @shp.read(num_parts * 4).unpack("V" + num_parts.to_s)
          parts << num_points #indexes for LS of idx i go to parts of idx i to idx i +1
          xys = Array.new(num_points) { @shp.read(16).unpack("E2") }
          @shp.seek(16,IO::SEEK_CUR)#extent 
          zs = Array.new(num_points) {@shp.read(8).unpack("E")[0]}
          @shp.seek(16,IO::SEEK_CUR)#extent 
          ms = Array.new(num_points) {@shp.read(8).unpack("E")[0]}
          points = Array.new(num_points) do |i|
            Point.from_x_y_z_m(xys[i][0],xys[i][1],zs[i],ms[i])
          end
          linear_rings = Array.new(num_parts) do |i|
            GeoRuby::SimpleFeatures::LinearRing.from_points(points[(parts[i])...(parts[i+1])],GeoRuby::SimpleFeatures::DEFAULT_SRID,true,true)
          end
          geometry = GeoRuby::SimpleFeatures::MultiPolygon.from_polygons([GeoRuby::SimpleFeatures::Polygon.from_linear_rings(linear_rings)],GeoRuby::SimpleFeatures::DEFAULT_SRID,true,true)


        when ShpType::MULTIPOINTZ
          @shp.seek(32,IO::SEEK_CUR)
          num_points = @shp.read(4).unpack("V")[0]
          xys = Array.new(num_points) { @shp.read(16).unpack("E2") }
          @shp.seek(16,IO::SEEK_CUR)
          zs = Array.new(num_points) {@shp.read(8).unpack("E")[0]}
          @shp.seek(16,IO::SEEK_CUR)
          ms = Array.new(num_points) {@shp.read(8).unpack("E")[0]}
          
          points = Array.new(num_points) do |i|
            Point.from_x_y_z_m(xys[i][0],xys[i][1],zs[i],ms[i])
          end
          
          geometry = GeoRuby::SimpleFeatures::MultiPoint.from_points(points,GeoRuby::SimpleFeatures::DEFAULT_SRID,true,true)

        when ShpType::POINTM
          x, y, m = @shp.read(24).unpack("E3")
          geometry = GeoRuby::SimpleFeatures::Point.from_x_y_m(x,y,m)

        when ShpType::POLYLINEM
          @shp.seek(32,IO::SEEK_CUR)
          num_parts, num_points = @shp.read(8).unpack("V2")
          parts =  @shp.read(num_parts * 4).unpack("V" + num_parts.to_s)
          parts << num_points #indexes for LS of idx i go to parts of idx i to idx i +1
          xys = Array.new(num_points) { @shp.read(16).unpack("E2") }
          @shp.seek(16,IO::SEEK_CUR)
          ms = Array.new(num_points) {@shp.read(8).unpack("E")[0]}
          points = Array.new(num_points) do |i|
            Point.from_x_y_m(xys[i][0],xys[i][1],ms[i])
          end
          line_strings = Array.new(num_parts) do |i|
            GeoRuby::SimpleFeatures::LineString.from_points(points[(parts[i])...(parts[i+1])],GeoRuby::SimpleFeatures::DEFAULT_SRID,false,true)
          end
          geometry = GeoRuby::SimpleFeatures::MultiLineString.from_line_strings(line_strings,GeoRuby::SimpleFeatures::DEFAULT_SRID,false,true)

          
        when ShpType::POLYGONM
          #TODO : CORRECT

          @shp.seek(32,IO::SEEK_CUR)
          num_parts, num_points = @shp.read(8).unpack("V2")
          parts =  @shp.read(num_parts * 4).unpack("V" + num_parts.to_s)
          parts << num_points #indexes for LS of idx i go to parts of idx i to idx i +1
          xys = Array.new(num_points) { @shp.read(16).unpack("E2") }
          @shp.seek(16,IO::SEEK_CUR)
          ms = Array.new(num_points) {@shp.read(8).unpack("E")[0]}
          points = Array.new(num_points) do |i|
            Point.from_x_y_m(xys[i][0],xys[i][1],ms[i])
          end
          linear_rings = Array.new(num_parts) do |i|
            GeoRuby::SimpleFeatures::LinearRing.from_points(points[(parts[i])...(parts[i+1])],GeoRuby::SimpleFeatures::DEFAULT_SRID,false,true)
          end
          geometry = GeoRuby::SimpleFeatures::MultiPolygon.from_polygons([GeoRuby::SimpleFeatures::Polygon.from_linear_rings(linear_rings)],GeoRuby::SimpleFeatures::DEFAULT_SRID,false,true)


        when ShpType::MULTIPOINTM
          @shp.seek(32,IO::SEEK_CUR)
          num_points = @shp.read(4).unpack("V")[0]
          xys = Array.new(num_points) { @shp.read(16).unpack("E2") }
          @shp.seek(16,IO::SEEK_CUR)
          ms = Array.new(num_points) {@shp.read(8).unpack("E")[0]}
          
          points = Array.new(num_points) do |i|
            Point.from_x_y_m(xys[i][0],xys[i][1],ms[i])
          end
          
          geometry = GeoRuby::SimpleFeatures::MultiPoint.from_points(points,GeoRuby::SimpleFeatures::DEFAULT_SRID,false,true)
        else
          geometry = nil
        end
        
        ShpRecord.new(geometry,dbf_record)
      end
    end
    
    #A SHP record : contains both the geometry and the data fields (from the DBF)
    class ShpRecord
      attr_reader :geometry , :data
      
      def initialize(geometry, data)
        @geometry = geometry
        @data = data
      end
      
      #Tests if the geometry is a NULL SHAPE
      def has_null_shape?
        @geometry.nil?
      end
    end

    class MalformedShpException < StandardError
    end
    
  end
end
