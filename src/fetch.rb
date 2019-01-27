
class FetchCommand
    def initialize(manifests)
        @m = manifests
    end

    def call(args)
        if args.length < 2 then
            puts "USAGE: fetch [filename]"
            return true
        end

        manifest = @m.get(args[1])
        if manifest == nil then
            puts "manifest not found"
        else
            print "Downloading '#{manifest[:name]}'..."

            if manifest[:type] == 0 then
                dlCGSS(manifest[:name])
            else
                dlMLTD(manifest[:name])
            end

            puts "Done."
        end
        return true
    end

    def search(args, prefix)
        if args.length == 2 then
            return @m.search(prefix)
        end
    end

	def dlCGSS(name)
        m = CGSSManifest.get(name)
        uri = URI.parse(CGSSManifest.getURL(m))
        path = "assets/" + name

        if m[:attr] == 1 then
            raw = HttpUtil.getdata(uri)
            dec = Lz4Util.decompress(raw)
            File.open(path, 'wb') {|f|
                f.write(dec)
            }
        else
            HttpUtil.download(uri, path)
        end
	end

    def dlMLTD(name)
        uri = URI.parse(MLTDManifest.getURL(name))
        path = "assets/" + name

        HttpUtil.download(uri, path)
    end
end
