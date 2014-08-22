require 'uri'
require 'json'
require 'net/http'

def http_get(uri)
    JSON.parse(Net::HTTP.get(URI(uri)))
end

def http_post(uri,doc)
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)

    if doc.class == Hash
        header = {'Content-Type'=> 'application/json'}
    elsif doc.class == String
        header = {'Content-Type'=> 'application/x-www-form-urlencoded'}
    end

    request = Net::HTTP::Post.new(uri.request_uri, header)

    if doc.class == Hash
        request.body = doc.to_json
    elsif doc.class == String
        request.body = doc
    end

    response = http.request(request)
    JSON.parse(response.body)
end

def http_put(uri,doc) 
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)

    if doc.class == Hash
        header = {'Content-Type'=> 'application/json'}
    elsif doc.class == String
        header = {'Content-Type'=> 'application/x-www-form-urlencoded'}
    end

    request = Net::HTTP::Put.new(uri.request_uri, header)

    if doc.class == Hash
        request.body = doc.to_json
    elsif doc.class == String
        request.body = doc
    end

    response = http.request(request)

    JSON.parse(response.body)
end

def http_delete(uri)
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Delete.new(uri.request_uri)
    response = http.request(request)
    JSON.parse(response.body)
end

def search(index,query)
    query="scientificName:'Aphelandra longiflora'" unless query != nil && query.length > 0
    result = []
    r = http_get("#{settings.elasticsearch}/#{index}/_search?size=999&q=#{URI.encode(query)}")
    if r['hits'] && r['hits']['hits'] then
        r['hits']['hits'].each{|hit|
            result.push(hit["_source"])
        }
    else
        puts "search error #{r}"
    end
    result
end

def flatten(obj)
    flat = {}
    if obj["dir"] && obj["nodes"] then
        obj["nodes"].each { |n|
            flat = flat.merge(flatten(n))
        }
    else
        key = obj["key"].gsub("/","_").gsub("-","_")
        flat[key[1..key.length].to_sym]=obj["value"]
    end
        flat
end

def etcd2config(server,prefix="")
    config = flatten( http_get("#{server}/v2/keys/?recursive=true")["node"] )
    config.keys.each {|k|
        if k.to_s.end_with?("_url") then
            config[k.to_s.gsub(prefix,"").gsub("_url","").to_sym] = config[k]
        end
    }
    config
end

def setup(file)
    config_file file

    use Rack::Session::Pool
    set :session_secret, '1flora2'
    set :views, 'src/views'

    if ENV["DB"] then
        set :db, ENV["DB"]
    end

    if ENV["CONTEXT"] then
        set :context, ENV["CONTEXT"]
    else
        set :context, "connect"
    end

    if ENV["PREFIX"] then
        set :prefix, ENV["PREFIX"]
    else
        set :prefix, ""
    end

    if ENV["BASE"] then
        set :base, ENV["BASE"]
    else
        set :base, ""
    end

    if settings.prefix.length >= 1 then
        set :prefix, "#{settings.prefix}_"
    end

    if ENV["ETCD_PORT_4001_TCP_ADDR"] then
        set :etcd, "http://#{ENV["ETCD_PORT_4001_TCP_ADDR"]}:#{ENV["ETCD_PORT_4001_TCP_PORT"]}"
    elsif ENV["ETCD"] then
        set :etcd, ENV["ETCD"]
    else
        set :etcd, "http://localhost:4001"
    end

    @config = etcd2config(settings.etcd,settings.prefix)

    onchange(settings.etcd,settings.prefix) do |newconfig|
        @config = newconfig
        setup! newconfig
    end

    setup! @config
end

def setup!(config)

    if settings.lang then
        config[:strings] = JSON.parse(File.read("src/locales/#{settings.lang}.json", :encoding => "BINARY"))
    end

    if config.has_key? :elasticsearch then
        config[:elasticsearch] = "#{config[:elasticsearch]}/#{settings.db}"
    else
        config[:elasticsearch] = "#{config[:datahub]}/#{settings.db}"
    end

    if config.has_key? :couchdb then
        config[:couchdb] = "#{config[:couchdb]}/#{settings.db}"
    else
        config[:couchdb] = "#{config[:datahub]}/#{settings.db}"
    end

    if settings.context then
        config[:context] = settings.context
    end

    if settings.base then
        config[:base] = settings.base
    end

    config.keys.each { |key| set key, config[key] }

    set :config, config

    puts "Config loaded"
    puts config

    config
end

def onchange(etcd,prefix="")
    Thread.new do
        while true do
            http_get("#{ etcd }/v2/keys/?recursive=true&wait=true")
            yield etcd2config(etcd,prefix)
        end
    end
end

