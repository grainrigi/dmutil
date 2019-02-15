require 'sqlite3'
require_relative 'util/http.rb'
require_relative 'util/config.rb'
require_relative 'util/lz4.rb'

class CGSSManifest
    private
    DB_NAME = 'db/cgss.mdb'
    BASE_URL = 'http://asset-starlight-stage.akamaized.net/dl/'

    public
    def self.update(version)
        if(Config.get("cgssver") == version) then
            return false
        end

        uri = URI.parse(versionDirName(version) + "manifests/Android_AHigh_SHigh")
        raw = HttpUtil.getdata(uri)

        # Decompress
        dec = Lz4Util.decompress(raw)
        File.open(DB_NAME, 'wb') {|f|
            f.write(dec)
        }

        Config.set("cgssver", version)

        return true
    end

    public
    def self.get(name)
        opendb do |db|
            m = db.execute(%(SELECT name, hash, attr FROM manifests WHERE name = "#{name}"))[0]
            if m == nil then
                return nil
            else
                return {name: m[0], hash: m[1], attr: m[2]}
            end
        end
    end

    public
    def self.getURL(manifest)
        ext = File.extname(manifest[:name])
        case ext
        when ".unity3d"
            dir = resDirName "AssetBundles"
        when ".acb", ".awb"
            dir = resDirName "Sound"
        when ".bdb", ".mdb"
            dir = genericDirName "Generic"
        end
        hash = manifest[:hash]

        return dir + hash[0,2] + "/" + hash
    end

    public
    def self.search(prefix)
        opendb do |db|
            return db.execute(%(SELECT name FROM manifests WHERE name LIKE "#{prefix}%" ORDER BY name)).map{|e| e[0]}
        end
    end

    def self.opendb()
        SQLite3::Database.new DB_NAME do |db|
            yield db
        end
    end

    private
    def self.versionDirName(version)
        return "#{BASE_URL}#{version}/"
    end

    private
    def self.resDirName(type)
        return "#{BASE_URL}resources/#{type}/"
    end

    private
    def self.genericDirName(type)
        return "#{BASE_URL}resources/#{type}/"
    end
end
