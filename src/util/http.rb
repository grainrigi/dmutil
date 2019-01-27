require 'net/http'

class HttpUtil
    # fetch the data and save to the specified path
    def self.download(uri, path)
        starthttp(uri) {|http|
            header = {'X-Unity-Version' => '2017.4.2f2'}
            res = http.get(uri.path, header)
            res.value
            File.open(path, 'wb') {|f|
                f.write(res.body)
            }
        }
    end

    # fetch the data and return the body as a string
    def self.getdata(uri)
        starthttp(uri) {|http|
            header = {'X-Unity-Version' => '2017.4.2f2'}
            res = http.get(uri.path, header)
            res.value
            return res.body
        }
    end

    private
    def self.starthttp(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https' then
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.start  {|h|
            yield h
        }
    end
end
