require_relative 'matsurihime.rb'
require_relative 'cgss.rb'
require_relative 'mltd.rb'
require_relative 'manifests.rb'
require_relative 'fetch.rb'
require_relative 'util/commander.rb'


def checkCGSS()
    print "Checking CGSS DB... "
    cgssver = MatsurihiMe.cgssAssetVersion
    if CGSSManifest.update(cgssver) then
        print "Updated."
    else
        print "Already up-to-date."
    end
    puts " ResVer=#{cgssver}"
end

def checkMLTD()
    print "Checking MLTD DB... "
    mltdinfo = MatsurihiMe.mltdAssetInfo
    if MLTDManifest.update(mltdinfo[:version], mltdinfo[:hash]) then
        print "Updated."
    else
        print "Already up-to-date."
    end
    puts " ResVer=#{mltdinfo[:version]}"
end

def initDir()
    puts "Initializing directories..."
    if !Dir.exist?("db") then
        Dir.mkdir("db", 0755)
    end
    if !Dir.exist?("assets") then
        Dir.mkdir("assets", 0755)
    end
end


### MAIN ###
initDir
checkCGSS
checkMLTD

puts "Initializing the database..."
manifests = Manifests.new

fetch = FetchCommand.new(manifests)

cmd = Commander.new("dmutil")
cmd.add("fetch", fetch)
cmd.run
