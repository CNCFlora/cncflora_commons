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
    r['hits']['hits'].each{|hit|
        result.push(hit["_source"])
    }
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

def etcd2settings(server,prefix="")
    config = etcd2config(server,prefix)
    config.keys.each { |key| set key, config[key] }
    set :config, config
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
    end

    if ENV["PREFIX"] then
        set :prefix, ENV["PREFIX"]
    else
        set :prefix, ""
    end

    if settings.prefix.length >= 1 then
        set :prefix, "#{settings.prefix}_"
    end

    config = etcd2settings(ENV["ETCD"] || settings.etcd,settings.prefix)

    config[:strings] = JSON.parse(File.read("src/locales/#{settings.lang}.json", :encoding => "BINARY"))
    config[:elasticsearch] = "#{config[:datahub]}/#{settings.db}"
    config[:couchdb] = "#{ config[:datahub] }/#{settings.db}"
    config[:base] = settings.base
    config[:context] = settings.context

    config.keys.each { |key| set key, config[key] }
end

