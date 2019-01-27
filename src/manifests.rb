require 'sqlite3'
require_relative 'cgss.rb'
require_relative 'mltd.rb'

class Manifests
    def initialize()
        ddl = 'CREATE TABLE manifests (name VARCHAR(255), type INTEGER);'

        @db = SQLite3::Database.new(":memory:")

        @db.execute(ddl)

        load_cgss
        load_mltd

        @db.execute('CREATE INDEX idx_name ON manifests (name)')
    end

    def search(prefix)
        return @db.execute(%(SELECT name FROM manifests WHERE name LIKE "#{prefix.gsub(/_/, "$_").gsub(/%/, "$%")}%" ESCAPE '$' ORDER BY name)).map{|e| e[0]}
    end

	def get(name)
        m = @db.execute(%(SELECT * FROM manifests WHERE name = "#{name}"))[0]
        if m == nil then
            return nil
        else
            return {name: m[0], type: m[1]}
        end
	end

    private
    def load_cgss()
        CGSSManifest.opendb do |db|
            db.execute('SELECT name FROM manifests') do |row|
                @db.execute(%(INSERT INTO manifests VALUES("#{row[0]}", 0)))
            end
        end
    end

    private
    def load_mltd()
        MLTDManifest.opendb do |db|
            db.execute('SELECT name FROM manifests') do |row|
                @db.execute(%(INSERT INTO manifests VALUES("#{row[0]}", 1)))
            end
        end
    end
end
