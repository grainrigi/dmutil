require 'json'

class Config
    private
    CONFIG_FILE = 'config.json'

    public
    def self.get(key)
        return load[key]
    end

    def self.set(key, value)
        conf = load
        conf[key] = value
        save(conf)
    end

    private
    def self.load()
        if File.exist?(CONFIG_FILE) then
            conf = nil
            File.open(CONFIG_FILE, "r") do |f|
                conf = JSON.load(f)
            end
        else
            return {}
        end
    end

    def self.save(conf)
        File.open(CONFIG_FILE, "w") do |f|
            JSON.dump(conf, f)
        end
    end
end
