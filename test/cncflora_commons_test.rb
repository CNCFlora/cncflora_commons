require_relative '../lib/cncflora_commons'
require 'rspec'

etcd = 'http://localhost:4001/v2/keys'

describe "CNCFlora Common functions" do

    it "Send put request." do
    	request = http_put( "#{etcd}/foo", "value=bar" )
    	expect( request['action'] ).to eq( 'set' )
    	expect( request['node']['key'] ).to eq( '/foo' )    	
    	expect( request['node']['value'] ).to eq( 'bar' )
    	http_delete( "#{etcd}/foo" )
    end

    it "Send put request passing data hash." do
    	request = http_put( "#{etcd}/foo", "value={key1=>value1}" )
    	expect( request['action'] ).to eq( 'set' )
    	expect( request['node']['key'] ).to eq( '/foo' )    	
    	expect( request['node']['value'] ).to eq( '{key1=>value1}' )
    	http_delete( "#{etcd}/foo" )
    end


    it "Send delete request." do
    	http_put( "#{etcd}/foo", "value=bar" )
    	request = http_delete( "#{etcd}/foo" )
    	expect( request['action'] ).to eq( 'delete' )
    	expect( request['node']['key'] ).to eq( '/foo' )
    end

    it "Send get request." do
    	http_put( "#{etcd}/foo", "value=bar" )
    	request = http_get( "#{etcd}/foo" )
    	expect( request['action'] ).to eq( 'get' )
    	expect( request['node']['key'] ).to eq( '/foo' )
        http_delete( "#{etcd}/foo" )
    end


    it "Send post request." do
    	request = http_post( "#{etcd}/foo", "value=bar" )
    	expect( request['action'] ).to eq( 'create' )
    	expect( request['node']['key'] ).to eq( "/foo/#{request['node']['modifiedIndex']}" )
    	request = http_delete( "#{etcd}/foo?recursive=true" )
    end

    it "Load config, with env and stuff" do
      ENV["name"] = 'Fuz'
      cfg = setup 'config.yml'
      expect(cfg['foo']).to eq('bar')
      expect(cfg['test']).to eq('Hello, Fuz.')
      expect(cfg['name']).to eq('Fuz')

      ENV['RACK_ENV']='test'
      cfg = setup 'config.yml'
      expect(cfg['foo']).to eq('baz')
      expect(cfg['test']).to eq('Hello, Fuz.')
      expect(cfg['RACK_ENV']).to eq('test')
    end

end
