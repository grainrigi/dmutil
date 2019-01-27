require 'net/http'
require 'json'

class MatsurihiMe
    private
        ENDPOINT_MLTD = URI.parse('https://api.matsurihi.me/mltd/v1/version/latest')
        ENDPOINT_CGSS = URI.parse('https://api.matsurihi.me/cgss/v1/version/latest')

    public
    def self.mltdAssetInfo
        response = Net::HTTP.get ENDPOINT_MLTD
        parsed = JSON.parse(response)
        return {version: parsed["res"]["version"], hash: parsed["res"]["indexName"]}
    end

    def self.cgssAssetVersion
        response = Net::HTTP.get ENDPOINT_CGSS
        parsed = JSON.parse(response)
        return parsed["res"]["version"]
    end
end
