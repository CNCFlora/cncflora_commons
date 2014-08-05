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

    it "Can read etcd config" do
        http_put( "#{etcd}/language","value=pt" )
        http_put( "#{etcd}/dwc-services","value=dwc" )
        http_put( "#{etcd}/proj1/host","value=host1" )
        http_put( "#{etcd}/proj1/ip","value=ip1" )
        http_put( "#{etcd}/proj2/host","value=host2" )
        http_put( "#{etcd}/proj2/url","value=yadayada" )
        config = etcd2config("http://localhost:4001")
        expect(config).to include(:proj1_host=>"host1",:proj1_ip=>"ip1",:proj2=>"yadayada",:proj2_url=>"yadayada",:proj2_host=>"host2",:language=>"pt",:dwc_services=>"dwc")
        http_delete( "#{etcd}/proj1?recursive=true" )
        http_delete( "#{etcd}/proj2?recursive=true" )
        http_delete( "#{etcd}/language" )
        http_delete( "#{etcd}/dwc-services" )
    end

    it "Can reread etcd" do
        http_put( "#{etcd}/dwc-services","value=dwc" )
        @config = {}
        #etcd2config("http://localhost:4001")
        onchange("http://localhost:4001") {|newcfg| @config = newcfg}
        sleep 6
        expect(@config).to include(:dwc_services=>"dwc")
        http_put( "#{etcd}/dwc-services","value=dwc2" )
        sleep 6
        expect(@config).to include(:dwc_services=>"dwc2")
        http_delete( "#{etcd}/dwc-services" )
    end

end
