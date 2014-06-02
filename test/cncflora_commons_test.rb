
require_relative '../lib/cncflora_commons'
require 'rspec'

etcd = 'http://localhost:4001/v2/keys'

describe "CNCFlora Common functions" do

<<<<<<< HEAD
    
    it "Send http put" do
        hash_config = http_put( "#{etcd}/message","value=Hello world." )
        expect( hash_config['action'] ).to eq( 'set' )
        expect( hash_config['node']['value'] ).to eq( 'Hello world.' )
        http_delete( "#{etcd}/message" )
=======

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
>>>>>>> 94dd5862db080e3358edf8a17b1228b0ca6d55fd
    end
=end



    it "Send http get" do
        http_put( "#{etcd}/foo","value=bar" )
        hash_config = http_get( "#{etcd}/foo" )
        expect( hash_config['action'] ).to eq( 'get' )
        expect( hash_config['node']['value'] ).to eq( 'bar' )
        http_delete( "#{etcd}/foo" )

    end

    it "Send http delete" do
        http_put( "#{etcd}/my_key","value=my_value" )
        hash_config = http_delete( "#{etcd}/my_key" )
        expect( hash_config['action'] ).to eq( 'delete' )
        expect( hash_config['node']['key'] ).to eq( '/my_key' )
    end

    it "Send http post" do
        hash_config = http_post( "#{etcd}/my_dir","value=my_dir_value" )
        expect( hash_config['action'] ).to eq( 'create' )
        expect( hash_config['node']['value'] ).to eq( 'my_dir_value' )
        http_delete( "#{etcd}/my_dir?recursive=true" )
    end

=begin
    it "Can read etcd config" do
        http_put( "#{etcd}/language","value=pt" )
        http_put( "#{etcd}/dwc-services","value=dwc" )
        http_put( "#{etcd}/proj1/host","value=host1" )
        http_put( "#{etcd}/proj1/ip","value=ip1" )
        http_put( "#{etcd}/proj2/host","value=host2" )
        config = etcd2config(etcd)
        puts "config = #{config}" 
        #config.should include(:proj1_host=>"host1",:proj1_ip=>"ip1",:proj2_host=>"host2",:language=>"pt",:dwc_services=>"dwc")
        http_delete( "#{etcd}/proj1?recursive=true" )
        http_delete( "#{etcd}/proj2?recursive=true" )
        http_delete( "#{etcd}/language" )
        http_delete( "#{etcd}/dwc-services" )
        expect(1).to eq(1)
    end
=end    

end
