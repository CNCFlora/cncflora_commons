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
    if obj["dir"] then
        obj["nodes"].each { |n|
            flat = flat.merge(flatten(n))
        }
    else
        key = obj["key"].gsub("/","_").gsub("-","_")
        flat[key[1..key.length].to_sym]=obj["value"]
    end
        flat
end

def etcd2config(server)
    config = flatten( http_get("#{server}/v2/keys/?recursive=true")["node"] )
    config
end

def etcd2settings(server)
    config = etcd2config(server)
    config.keys.each { |key| set key, config[key] }
    set :config, config
    config
end

