
require_relative '../lib/cncflora_commons'
require 'rspec'

etcd = 'http://localhost:4001'

describe "CNCFlora Common functions" do


    it "Send request put." do
    	request = http_put( "#{etcd}/v2/keys/foo", "value=bar" )
    	puts "request = #{request}"
    	expect( request['action'] ).to eq( 'set' )
    	expect( request['node']['key'] ).to eq( '/foo' )    	
    	#expect( request['node']['value'] ).to eq( 'bar' )
    	http_delete( "#{etcd}/v2/keys/foo/" )
    end


    it "Send request delete." do
    	http_put( "#{etcd}/v2/keys/foo", "value=test123" )
    	request = http_delete( "#{etcd}/v2/keys/foo/" )
    	puts "request = #{request}"
    	expect( request['action'] ).to eq( 'delete' )
    	expect( request['node']['key'] ).to eq( '/foo' )
    end

    it "Send request get." do
    	http_put( "#{etcd}/v2/keys/foo", "value=test123" )
    	request = http_get( "#{etcd}/v2/keys/foo/" )
    	puts "request = #{request}"
    	expect( request['action'] ).to eq( 'get' )
    	expect( request['node']['key'] ).to eq( '/foo' )
    end

=begin
    it "Send request post." do
    	request = http_post( "#{etcd}/v2/keys/foo", {} )
    	puts "request = #{request}"
    	expect( request['action'] ).to eq( 'create' )
    	expect( request['node']['key'] ).to eq( '/foo' )
    	http_delete( "#{etcd}/v2/keys/foo?recursive=true" )
    end
=end



end

