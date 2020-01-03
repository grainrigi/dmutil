require 'sqlite3'
require_relative 'util/http.rb'
require_relative 'util/io.rb'

class MLTDManifest
    private
    DB_NAME = 'db/mltd.mdb'
    BASE_URL = 'https://d2sf4w9bkv485c.cloudfront.net/'
    UNITY_VERSION = '2018'

    public
    def self.update(version, hash)
        if(Config.get("mltdver") == version) then
            return false
        end

        uri = URI.parse("#{baseDirName(version)}#{hash}")
        raw = HttpUtil.getdata(uri)

        r = Reader.new(raw)
        w = Writer.new(DB_NAME)
        w.begin
        loop do
            entry = r.readNext
            if entry == nil then
                break
            end
            w.add(entry)
        end
        w.commit

        Config.set("mltdver", version)
    end

    def self.opendb()
        SQLite3::Database.new(DB_NAME) do |db|
            yield db
        end
    end

    def self.getURL(name)
        m = nil
        opendb do |db|
            m = db.execute(%(SELECT hash FROM manifests WHERE name = "#{name}"))[0]
            if m == nil then
                return "[NOT FOUND]"
            end
        end

        return baseDirName(Config.get("mltdver")).to_s + m[0]
    end

    private
    def self.baseDirName(version)
        return "#{BASE_URL}#{version}/production/#{UNITY_VERSION}/Android/"
    end

    private
    class Reader
        def initialize(data)
            @r = BinaryReader.new(data)
            @r.seekAbs(4)
        end

        def readNext()
            if !@r.readable? then
                return nil
            else
                ret = {}
                ret[:filename] = readString
                @r.readByte
                ret[:localhash] = readString
                ret[:remotehash] = readString
                ret[:filesize] = readInteger
                return ret
            end
        end

        def readString()
            type = @r.readByte
            if type == 0xD9 then
                size = @r.readByte
            else
                size = type - 0xA0
            end
            return @r.readBytes(size).pack("C*")
        end

        def readInteger()
            type = @r.readByte
            if type == 0xCD then
                return @r.readByte << 8 | @r.readByte
            elsif type == 0xCE then
                return @r.readByte << 24 | @r.readByte << 16 | @r.readByte << 8 | @r.readByte
            end
            return 0
        end
    end

    private
    class Writer
        def initialize(filename)
            ddl = "CREATE TABLE manifests (name VARCHAR(255), hash CHAR(48), size INTEGER);"

            # clean the oldDB
            if File.exist?(filename) then
                File.delete(filename)
            end

            @db = SQLite3::Database.new(filename)
            @db.execute(ddl)
        end

        def begin()
            @db.execute('BEGIN')
        end

        def commit()
            @db.execute('COMMIT')
        end

        def add(entry)
            @db.execute("INSERT INTO manifests VALUES('#{entry[:filename]}', '#{entry[:remotehash]}', #{entry[:filesize]})")
        end
    end

end

