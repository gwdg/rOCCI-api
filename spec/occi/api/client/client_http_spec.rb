require 'rspec'

module Occi
  module Api
    module Client

    vcr_options = { :record => :new_episodes, :cassette_name => "Occi_Api_Client_ClientHttp/using_media_type_text_plain/net_http_example_response" }
    describe ClientHttp, :vcr => vcr_options do

      context "using media type text/plain" do

        before(:each) do
          @client = Occi::Api::Client::ClientHttp.new({
           :endpoint => 'https://localhost:3300',
           :auth => { :type  => "none" },
           :log => { :out   => "/dev/null",
                     :level => Occi::Api::Log::DEBUG },
           :auto_connect => true,
           :media_type => "text/plain,text/occi"
          })
        end

        after(:each) do
          @client.logger.close if @client && @client.logger
        end

        it "establishes connection" do
          @client.connected.should be_true
        end

        it "instantiates a compute resource using type name" do
          compute = @client.get_resource "compute"
          
          compute.should be_a_kind_of Occi::Core::Resource
          compute.kind.type_identifier.should eq "http://schemas.ogf.org/occi/infrastructure#compute"
        end

        it "instantiates a compute resource using type identifier" do
          compute = @client.get_resource "http://schemas.ogf.org/occi/infrastructure#compute"
          
          compute.should be_a_kind_of Occi::Core::Resource
          compute.kind.type_identifier.should eq "http://schemas.ogf.org/occi/infrastructure#compute"
        end

        it "instantiates a network resource using type name" do
          network = @client.get_resource "network"

          network.should be_a_kind_of Occi::Core::Resource
          network.kind.type_identifier.should eq "http://schemas.ogf.org/occi/infrastructure#network"
        end

        it "instantiates a network resource using type identifier" do
          network = @client.get_resource "http://schemas.ogf.org/occi/infrastructure#network"

          network.should be_a_kind_of Occi::Core::Resource
          network.kind.type_identifier.should eq "http://schemas.ogf.org/occi/infrastructure#network"
        end

        it "instantiates a storage resource using type name" do
          storage = @client.get_resource "storage"

          storage.should be_a_kind_of Occi::Core::Resource
          storage.kind.type_identifier.should eq "http://schemas.ogf.org/occi/infrastructure#storage"
        end

        it "instantiates a storage resource using type identifier" do
          storage = @client.get_resource "http://schemas.ogf.org/occi/infrastructure#storage"

          storage.should be_a_kind_of Occi::Core::Resource
          storage.kind.type_identifier.should eq "http://schemas.ogf.org/occi/infrastructure#storage"
        end

        it "lists all available resource types" do
          @client.get_resource_types.should include("compute", "storage", "network")
        end

        it "lists all available resource type identifiers" do
          @client.get_resource_type_identifiers.should include(
            "http://schemas.ogf.org/occi/infrastructure#compute",
            "http://schemas.ogf.org/occi/infrastructure#network",
            "http://schemas.ogf.org/occi/infrastructure#storage"
          )
        end

        it "lists all available entity types" do
          @client.get_entity_types.should include("entity", "resource", "link")
        end

        it "lists all available entity type identifiers" do
          @client.get_entity_type_identifiers.should include(
            "http://schemas.ogf.org/occi/core#entity",
            "http://schemas.ogf.org/occi/core#resource",
            "http://schemas.ogf.org/occi/core#link"
          )
        end

        it "lists all available link types" do
          @client.get_link_types.should include("storagelink", "networkinterface")
        end

        it "lists all available link type identifiers" do
          @client.get_link_type_identifiers.should include(
            "http://schemas.ogf.org/occi/infrastructure#storagelink",
            "http://schemas.ogf.org/occi/infrastructure#networkinterface"
          )
        end

        it "lists all available mixin types" do
          @client.get_mixin_types.should include("os_tpl", "resource_tpl")
        end

        it "lists all available mixin type identifiers" do
          @client.get_mixin_type_identifiers.should include(
            "http://schemas.ogf.org/occi/infrastructure#os_tpl",
            "http://schemas.ogf.org/occi/infrastructure#resource_tpl"
          )
        end

        it "lists compute resources", :vcr => { :cassette_name => "Occi_Api_Client_ClientHttp/using_media_type_text_plain/lists_compute_resources" } do
          @client.list("compute").should eq ["https://localhost:3300/compute/c62fce01-0d8e-510c-ba07-973b0d6d5034"]
        end

        it "lists network resources", :vcr => { :cassette_name => "Occi_Api_Client_ClientHttp/using_media_type_text_plain/lists_network_resources" } do
          @client.list("network").should eq ["https://localhost:3300/network/1e8e0d63-e3c8-5be7-8a46-f4df226bca01"]
        end

        it "lists storage resources", :vcr => { :cassette_name => "Occi_Api_Client_ClientHttp/using_media_type_text_plain/lists_storage_resources" } do
          @client.list("storage").should include(
            "https://localhost:3300/storage/32fc6c92-88aa-54dc-b814-be0df741278e",
            "https://localhost:3300/storage/5c1a7099-859e-5c3d-9386-740edbb610b8"
          )
        end

        it "lists all available mixins" do
          @client.list_mixins.should include(
            "http://occi.localhost:3300/occi/infrastructure/resource_tpl#large",
            "http://occi.localhost:3300/occi/infrastructure/resource_tpl#extra_large",
            "http://occi.localhost:3300/occi/infrastructure/resource_tpl#medium",
            "http://occi.localhost:3300/occi/infrastructure/resource_tpl#small",
            "http://occi.localhost:3300/occi/infrastructure/os_tpl#mytesttemplate"
          )
        end

        it "lists os_tpl mixins" do
          mixins = Occi::Core::Mixins.new
          mixins << Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/os_tpl#", "mytesttemplate")

          expect(@client.get_mixins("os_tpl")).to eq mixins
          expect(@client.get_os_tpls).to eq mixins
        end

        it "lists mixins including self" do
          mixins = Occi::Core::Mixins.new
          mixins << Occi::Core::Mixin.new("http://schemas.ogf.org/occi/infrastructure#", "os_tpl")
          mixins << Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/os_tpl#", "mytesttemplate")

          expect(@client.get_mixins("os_tpl", true)).to eq mixins
        end

        it "lists mixins with only self (no related)" do
          mixins = Occi::Core::Mixins.new
          mixins << Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/os_tpl#", "mytesttemplate")

          expect(@client.get_mixins("http://occi.localhost:3300/occi/infrastructure/os_tpl#mytesttemplate", true)).to eq mixins
        end

        it "fails to list mixins with only self (no related) without include_self=true" do
          mixins = Occi::Core::Mixins.new
          expect(@client.get_mixins("http://occi.localhost:3300/occi/infrastructure/os_tpl#mytesttemplate")).to eq mixins
        end

        it "lists resource_tpl mixins" do
          mixins = Occi::Core::Mixins.new
          mixins << Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/resource_tpl#", "large")
          mixins << Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/resource_tpl#", "extra_large")
          mixins << Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/resource_tpl#", "medium")
          mixins << Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/resource_tpl#", "small")

          expect(@client.get_mixins("resource_tpl")).to eq mixins
          expect(@client.get_resource_tpls).to eq mixins
        end

        it "describes compute resources", :vcr => { :cassette_name => "Occi_Api_Client_ClientHttp/using_media_type_text_plain/describes_compute_resources" } do
          cmpts = @client.describe("compute")

          cmpts.length.should eq 1
          cmpts.first.attributes['occi.core.id'].should eq('c62fce01-0d8e-510c-ba07-973b0d6d5034')
          cmpts.first.attributes['occi.core.title'].should eq('one-3')
          cmpts.first.attributes['occi.compute.cores'].should eq(2)
          cmpts.first.attributes['org.opennebula.compute.cpu'].should eq(2.0)
          cmpts.first.attributes['occi.compute.memory'].should eq(1.564)
        end

        it "describes network resources", :vcr => { :cassette_name => "Occi_Api_Client_ClientHttp/using_media_type_text_plain/describes_network_resources" } do
          nets = @client.describe "network"

          nets.length.should eq 1
          nets.first.attributes['occi.core.id'].should eq('1e8e0d63-e3c8-5be7-8a46-f4df226bca01')
          nets.first.attributes['occi.core.title'].should eq('private')
          nets.first.attributes['occi.network.allocation'].should eq('dynamic')
          nets.first.attributes['org.opennebula.network.id'].should eq("1")
        end

        it "describes storage resources", :vcr => { :cassette_name => "Occi_Api_Client_ClientHttp/using_media_type_text_plain/describes_storage_resources" } do
          stors = @client.describe "storage"

          stors.length.should eq 2
          stors.to_a.last.attributes['occi.core.id'].should eq('5c1a7099-859e-5c3d-9386-740edbb610b8')
          stors.to_a.last.attributes['occi.core.title'].should eq('ttylinux - VMware ')
          stors.to_a.last.attributes['occi.storage.state'].should eq('online')
          stors.to_a.last.attributes['org.opennebula.storage.id'].should eq("4")

          stors.first.attributes['occi.core.id'].should eq('32fc6c92-88aa-54dc-b814-be0df741278e')
        end

        it "describes all available mixins" do
          @client.get_mixins.should include(
            Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/resource_tpl#", "large"),
            Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/resource_tpl#", "extra_large"),
            Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/resource_tpl#", "medium"),
            Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/resource_tpl#", "small"),
            Occi::Core::Mixin.new("http://occi.localhost:3300/occi/infrastructure/os_tpl#", "mytesttemplate")
          )
        end

        it "finds and describes unscoped mixin" do
          mxn = @client.get_mixin('mytesttemplate', nil, true)
          mxn.type_identifier.should eq 'http://occi.localhost:3300/occi/infrastructure/os_tpl#mytesttemplate'
        end

        it "finds and describes scoped os_tpl mixin" do
          mxn = @client.get_mixin('mytesttemplate', "os_tpl", true)
          mxn.type_identifier.should eq 'http://occi.localhost:3300/occi/infrastructure/os_tpl#mytesttemplate'
        end

        it "finds and describes scoped resource_tpl mixin" do
          mxn = @client.get_mixin('large', "resource_tpl", true)
          mxn.type_identifier.should eq 'http://occi.localhost:3300/occi/infrastructure/resource_tpl#large'
        end

        it "returns nil when looking for a non-existent mixin" do
          mxn = @client.get_mixin('blablabla', nil, true)
          mxn.should be_nil
        end

        it "returns nil when looking for a non-existent mixin of a specific type" do
          mxn = @client.get_mixin('blablabla', 'os_tpl', true)
          mxn.should be_nil
        end

        it "raises an error when looking for a non-existent mixin type" do
          expect{ @client.get_mixin('blablabla', 'blabla', true) }.to raise_error
        end

        it "creates a new compute resource"

        it "creates a new storage resource"

        it "creates a new network resource"

        it "deploys an instance based on OVF/OVA file"

        it "deletes a compute resource"

        it "deletes a network resource"

        it "deletes a storage resource"

        it "triggers an action on a compute resource"

        it "triggers an action on a storage resource"

        it "triggers an action on a network resource"

        it "refreshes its model", :vcr => { :cassette_name => "Occi_Api_Client_ClientHttp/using_media_type_text_plain/refreshes_its_model" } do
          @client.refresh
        end

        it 'looks up a mixin type identifier for os_tpl' do
          expect(@client.get_mixin_type_identifier('os_tpl')).to eq "http://schemas.ogf.org/occi/infrastructure#os_tpl"
        end

        it 'looks up a mixin type identifier for resource_tpl' do
          expect(@client.get_mixin_type_identifier('resource_tpl')).to eq "http://schemas.ogf.org/occi/infrastructure#resource_tpl"
        end

      end

      context "using media type application/occi+json" do

        before(:each) do
          #@client = Occi::Api::ClientHttp.new({
          #  :endpoint => 'https://localhost:3300',
          #  :auth => { :type  => "none" },
          #  :log => { :out   => "/dev/null",
          #            :level => Occi::Api::Log::DEBUG },
          #  :auto_connect => true,
          #  :media_type => "application/occi+json"
          #})
        end

        it "establishes connection"

        it "lists compute resources"

        it "lists network resources"

        it "lists storage resources"

        it "lists all available mixins"

        it "lists os_tpl mixins"

        it "lists resource_tpl mixins"

        it "describes compute resources"

        it "describes network resources"

        it "describes storage resources"

        it "describes all available mixins"

        it "describes os_tpl mixins"

        it "describes resource_tpl mixins"

        it "creates a new compute resource"

        it "creates a new storage resource"

        it "creates a new network resource"

        it "deletes a compute resource"

        it "deletes a network resource"

        it "deletes a storage resource"

        it "triggers an action on a compute resource"

        it "triggers an action on a storage resource"

        it "triggers an action on a network resource"

        it "refreshes its model"

      end
    end

    end
  end
end
