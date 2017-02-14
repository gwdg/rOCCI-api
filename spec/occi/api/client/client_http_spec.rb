require 'rspec'

module Occi
  module Api
    module Client


#    vcr_options = { :record => :new_episodes } # To be used only when (re)implementing tests
    vcr_options = { :record => :none }
    describe ClientHttp, :vcr => vcr_options do

      context "endpoint handling" do
        it "removes query string from endpoint"
        it "correctly handles endpoint with path"
      end

      context "using media type text/plain" do

        before(:each) do
          @client = Occi::Api::Client::ClientHttp.new({
           :endpoint => ENV['ROCCI_SPEC_ENDPOINT'] || 'https://localhost:3300',
           :auth => hash_or_nil_helper( ENV['ROCCI_SPEC_AUTH_JSON'] ) || { :type => "basic", :username => "rocci-test", :password => "edited"},
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
          @client.connected.should be true
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

        it "instantiates a storagelink link using type identifier" do
          storagelink = @client.get_link "http://schemas.ogf.org/occi/infrastructure#storagelink"

          storagelink.should be_a_kind_of Occi::Core::Link
          storagelink.kind.type_identifier.should eq "http://schemas.ogf.org/occi/infrastructure#storagelink"
        end

        it "instantiates a storagelink link using type name" do
          storagelink = @client.get_link "storagelink"

          storagelink.should be_a_kind_of Occi::Core::Link
          storagelink.kind.type_identifier.should eq "http://schemas.ogf.org/occi/infrastructure#storagelink"
        end

        it "instantiates a networkinterface link using type identifier" do
          networkinterface = @client.get_link "http://schemas.ogf.org/occi/infrastructure#networkinterface"

          networkinterface.should be_a_kind_of Occi::Core::Link
          networkinterface.kind.type_identifier.should eq "http://schemas.ogf.org/occi/infrastructure#networkinterface"
        end

        it "instantiates a networkinterface link using type name" do
          networkinterface = @client.get_link "networkinterface"

          networkinterface.should be_a_kind_of Occi::Core::Link
          networkinterface.kind.type_identifier.should eq "http://schemas.ogf.org/occi/infrastructure#networkinterface"
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

        it "lists compute resources" do
          @client.list("compute").should eq ["https://localhost:3300/compute/4011"]
        end

        it "lists network resources" do
          @client.list("network").should eq ["https://localhost:3300/network/1", "https://localhost:3300/network/2", "https://localhost:3300/network/12"]
        end

        it "lists storage resources" do
          @client.list("storage").should include(
            "https://localhost:3300/storage/4",
            "https://localhost:3300/storage/547"
          )
        end

        it "lists all available mixins" do
          @client.list_mixins.should include(
            "http://sitespecific.localhost/occi/infrastructure/resource_tpl#large",
            "http://sitespecific.localhost/occi/infrastructure/resource_tpl#extra_large",
            "http://sitespecific.localhost/occi/infrastructure/resource_tpl#medium",
            "http://sitespecific.localhost/occi/infrastructure/resource_tpl#small",
            "http://localhost/occi/infrastructure/os_tpl#uuid_monitoring_4"
          )
        end

        it "lists os_tpl mixins" do
          mixins = Occi::Core::Mixins.new
          mixins << Occi::Core::Mixin.new("http://localhost/occi/infrastructure/os_tpl#", "uuid_monitoring_4")
          mixins << Occi::Core::Mixin.new("http://localhost/occi/infrastructure/os_tpl#", "uuid_debianvm_5")

          expect(mixins).to be_subset(@client.get_mixins("os_tpl"))
          expect(mixins).to be_subset(@client.get_os_tpls)
        end

        it "lists mixins including self" do
          mixins = Occi::Core::Mixins.new
          mixins << Occi::Core::Mixin.new("http://schemas.ogf.org/occi/infrastructure#", "os_tpl")
          mixins << Occi::Core::Mixin.new("http://localhost/occi/infrastructure/os_tpl#", "uuid_monitoring_4")

          expect(mixins).to be_subset(@client.get_mixins("os_tpl", true))
        end

        it "lists mixins with only self (no related)" do
          mixins = Occi::Core::Mixins.new
          mixins << Occi::Core::Mixin.new("http://localhost/occi/infrastructure/os_tpl#", "uuid_monitoring_4")

          expect(@client.get_mixins("http://localhost/occi/infrastructure/os_tpl#uuid_monitoring_4", true)).to eq mixins
        end

        it "fails to list mixins with only self (no related) without include_self=true" do
          mixins = Occi::Core::Mixins.new
          expect(@client.get_mixins("http://occi.localhost:3300/occi/infrastructure/os_tpl#mytesttemplate")).to eq mixins
        end

        it "lists resource_tpl mixins" do
          mixins = Occi::Core::Mixins.new
          mixins << Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl#", "large")
          mixins << Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl#", "extra_large")
          mixins << Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl#", "medium")
          mixins << Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl#", "small")

          expect(mixins).to be_subset(@client.get_mixins("resource_tpl"))
          expect(mixins).to be_subset(@client.get_resource_tpls)
        end

        it "describes compute resources" do
          cmpts = @client.describe("compute")

          cmpts.length.should eq 1
          cmpts.first.attributes['occi.core.id'].should eq('4011')
          cmpts.first.attributes['occi.core.title'].should eq('DebianTest')
          cmpts.first.attributes['occi.compute.cores'].should eq(2)
          cmpts.first.attributes['org.opennebula.compute.cpu'].should eq(2.0)
          cmpts.first.attributes['occi.compute.memory'].should eq(4.0)
        end

        it "describes network resources" do
          nets = @client.describe "network"

          expect(nets.length).to eq 4
          expect(nets.to_a.select{ |item| item.attributes['occi.core.id'] == '1' && item.attributes['occi.core.title'] == 'public' && item.attributes['occi.network.allocation'] == 'static' && item.attributes['org.opennebula.network.id'] == '1'}.any?).to eql true
        end

        it "describes storage resources" do
          stors = @client.describe "storage"

          expect(stors.length).to eq 6
          expect(stors.to_a.select{ |item| item.attributes['occi.core.id'] == '547' }.any?).to eql true
          expect(stors.to_a.select{ |item| item.attributes['occi.core.title'] == 'winByAli' }.any?).to eql true
          expect(stors.to_a.select{ |item| item.attributes['occi.storage.state'] == 'online' }.any?).to eql true
          expect(stors.to_a.select{ |item| item.attributes['org.opennebula.storage.id'] == '547' }.any?).to eql true

          expect(stors.to_a.select{ |item| item.attributes['occi.core.id'] == '375' }.any?).to eql true
        end

        it "describes all available mixins" do
          expect(@client.get_mixins).to include(
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "large"),
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "extra_large"),
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "medium"),
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "small"),
            Occi::Core::Mixin.new("http://localhost/occi/infrastructure/os_tpl", "uuid_monitoring_4")
          )
        end

        it "finds and describes unscoped mixin" do
          mxn = @client.get_mixin('uuid_monitoring_4', nil, true)
          mxn.type_identifier.should eq 'http://localhost/occi/infrastructure/os_tpl#uuid_monitoring_4'
        end

        it "finds and describes scoped os_tpl mixin" do
          mxn = @client.get_mixin('uuid_monitoring_4', "os_tpl", true)
          mxn.type_identifier.should eq 'http://localhost/occi/infrastructure/os_tpl#uuid_monitoring_4'
        end

        it "finds and describes scoped resource_tpl mixin" do
          mxn = @client.get_mixin('large', "resource_tpl", true)
          mxn.type_identifier.should eq 'http://sitespecific.localhost/occi/infrastructure/resource_tpl#large'
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

        it "creates a new compute resource" do
          compt = Occi::Infrastructure::Compute.new
          compt.mixins << 'http://localhost/occi/infrastructure/os_tpl#uuid_debianvm_5'
          compt.mixins << "http://sitespecific.localhost/occi/infrastructure/resource_tpl#small"
          expect(@client.create compt).to eql "https://localhost:3300/compute/4015"
        end

        it "creates a new storage resource" do
          stor = Occi::Infrastructure::Storage.new
          stor.size=0.006
          stor.title='spec'
          expect(@client.create stor).to eql 'https://localhost:3300/storage/696'
        end

        it "creates a new network resource" do
          net = Occi::Infrastructure::Network.new
          net.mixins << "http://opennebula.org/occi/infrastructure#network"
          net.title='privatetest'
          net.allocation='static'
          net.attributes["org.opennebula.network.bridge"]="xenbr0"
          expect(@client.create net).to eql 'https://localhost:3300/network/63'
        end

        it "deletes a compute resource" do
          expect(@client.delete 'https://localhost:3300/compute/4015').to eql true
        end

        it "deletes a network resource" do
          expect(@client.delete 'https://localhost:3300/network/63').to eql true
        end

        it "deletes a storage resource" do
          expect(@client.delete 'https://localhost:3300/storage/696').to eql true
        end

        it "triggers an action on a compute resource" do
          startaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/compute/action#', term='start', title='start compute instance'
          startactioninstance = Occi::Core::ActionInstance.new startaction, nil
          expect(@client.trigger "https://localhost:3300/compute/4096", startactioninstance).to eq true
        end

        it "triggers an action on a storage resource" do
          onlineaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/storage/action#', term='online', title='activate storage'
          onlineactioninstance = Occi::Core::ActionInstance.new onlineaction, nil
          expect(@client.trigger "https://localhost:3300/storage/709", onlineactioninstance).to eq true
        end

        it "triggers an action on a network resource" do
          upaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/network/action#', term='up', title='activate network'
          upactioninstance = Occi::Core::ActionInstance.new upaction, nil
          expect(@client.trigger "https://localhost:3300/network/66", upactioninstance).to eq true
        end

        it "triggers an action with return mixin" do
          saveaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/compute/action#', term='save', title='save compute'
          saveactioninstance = Occi::Core::ActionInstance.new saveaction, nil
          expect(@client.trigger "https://localhost:3300/compute/4096", saveactioninstance).to be_a_kind_of(Occi::Core::Mixins)
        end

        it 'fails to update without mixins' do
          expect { @client.update "https://localhost:3300/compute/4096", nil }.to raise_error(RuntimeError)
          expect { @client.update "https://localhost:3300/compute/4096", Occi::Core::Mixins.new }.to raise_error(RuntimeError)
        end

        it 'fails to update without resource' do
          mxns = Occi::Core::Mixins.new << Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "small")
          expect { @client.update nil, mxns }.to raise_error(RuntimeError)
          expect { @client.update '', mxns }.to raise_error(RuntimeError)
        end

        it 'updates resource with mixins' do
          mxns = Occi::Core::Mixins.new << Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "small")
          expect(@client.update "https://localhost:3300/compute/4096", mxns).to eq "/compute/4096"
        end

        it "refreshes its model" do
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
          @client = Occi::Api::Client::ClientHttp.new({
           :endpoint => ENV['ROCCI_SPEC_ENDPOINT'] || 'https://localhost:3300',
           :auth => hash_or_nil_helper( ENV['ROCCI_SPEC_AUTH_JSON'] ) || { :type => "basic", :username => "rocci-test", :password => "edited"},
           :log => { :out   => "/dev/null",
                     :level => Occi::Log::DEBUG },
           :auto_connect => true,
           :media_type => "application/occi+json"
          })
        end

        after(:each) do
          @client.logger.close if @client && @client.logger
        end

        it "establishes connection" do
          @client.connected.should be true
        end

        it "lists compute resources" do
          expect(@client.list("compute")).to eq ["https://localhost:3300/compute/4011"]
        end

        it "lists network resources" do
          @client.list("network").should eq ["https://localhost:3300/network/1", "https://localhost:3300/network/2", "https://localhost:3300/network/12", "https://localhost:3300/network/61"]
        end

        it "lists storage resources" do
          @client.list("storage").should include(
            "https://localhost:3300/storage/4",
            "https://localhost:3300/storage/547"
          )
        end

        it "lists all available mixins" do
          @client.list_mixins.should include(
            "http://sitespecific.localhost/occi/infrastructure/resource_tpl#large",
            "http://sitespecific.localhost/occi/infrastructure/resource_tpl#extra_large",
            "http://sitespecific.localhost/occi/infrastructure/resource_tpl#medium",
            "http://sitespecific.localhost/occi/infrastructure/resource_tpl#small",
            "http://localhost/occi/infrastructure/os_tpl#uuid_monitoring_4"
          )
        end

        it "lists os_tpl mixins" do
          mixins = Occi::Core::Mixins.new
          mixins << Occi::Core::Mixin.new("http://localhost/occi/infrastructure/os_tpl#", "uuid_monitoring_4")
          mixins << Occi::Core::Mixin.new("http://localhost/occi/infrastructure/os_tpl#", "uuid_debianvm_5")

          expect(mixins).to be_subset(@client.get_mixins("os_tpl"))
          expect(mixins).to be_subset(@client.get_os_tpls)
        end

        it "lists resource_tpl mixins" do
          mixins = Occi::Core::Mixins.new
          mixins << Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl#", "large")
          mixins << Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl#", "extra_large")
          mixins << Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl#", "medium")
          mixins << Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl#", "small")

          expect(mixins).to be_subset(@client.get_mixins("resource_tpl"))
          expect(mixins).to be_subset(@client.get_resource_tpls)
        end

        it "describes compute resources" do
          cmpts = @client.describe("compute")

          cmpts.length.should eq 1
          cmpts.first.attributes['occi.core.id'].should eq('4011')
          cmpts.first.attributes['occi.core.title'].should eq('DebianTest')
          cmpts.first.attributes['occi.compute.cores'].should eq(2)
          cmpts.first.attributes['org.opennebula.compute.cpu'].should eq(2.0)
          cmpts.first.attributes['occi.compute.memory'].should eq(4.0)
        end

        it "describes network resources" do
          nets = @client.describe "network"

          expect(nets.length).to eq 4
          expect(nets.to_a.select{ |item| item.attributes['occi.core.id'] == '1' && item.attributes['occi.core.title'] == 'public' && item.attributes['occi.network.allocation'] == 'static' && item.attributes['org.opennebula.network.id'] == '1'}.any?).to eql true
        end

        it "describes storage resources" do
          stors = @client.describe "storage"

          expect(stors.length).to eq 6
          expect(stors.to_a.select{ |item| item.attributes['occi.core.id'] == '547' }.any?).to eql true
          expect(stors.to_a.select{ |item| item.attributes['occi.core.title'] == 'winByAli' }.any?).to eql true
          expect(stors.to_a.select{ |item| item.attributes['occi.storage.state'] == 'online' }.any?).to eql true
          expect(stors.to_a.select{ |item| item.attributes['org.opennebula.storage.id'] == '547' }.any?).to eql true

          expect(stors.to_a.select{ |item| item.attributes['occi.core.id'] == '375' }.any?).to eql true
        end

        it "describes all available mixins" do
          expect(@client.get_mixins).to include(
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "large"),
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "extra_large"),
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "medium"),
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "small"),
            Occi::Core::Mixin.new("http://localhost/occi/infrastructure/os_tpl", "uuid_monitoring_4")
          )
        end

        it "describes os_tpl mixins" do
          expect(@client.get_mixins("os_tpl")).to include(
            Occi::Core::Mixin.new("http://localhost/occi/infrastructure/os_tpl", "uuid_monitoring_4")
          )
        end

        it "describes resource_tpl mixins" do
          expect(@client.get_mixins).to include(
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "large"),
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "extra_large"),
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "medium"),
            Occi::Core::Mixin.new("http://sitespecific.localhost/occi/infrastructure/resource_tpl", "small"),
          )
        end

        it "creates a new compute resource" do
          compt = Occi::Infrastructure::Compute.new
          compt.mixins << 'http://localhost/occi/infrastructure/os_tpl#uuid_debianvm_5'
          compt.mixins << "http://sitespecific.localhost/occi/infrastructure/resource_tpl#small"
          expect(@client.create compt).to eql "https://localhost:3300/compute/4017"
        end

        it "creates a new storage resource" do
          stor = Occi::Infrastructure::Storage.new
          stor.size=0.006
          stor.title='spec'
          expect(@client.create stor).to eql 'https://localhost:3300/storage/697'
        end

        it "creates a new network resource" do
          net = Occi::Infrastructure::Network.new
          net.mixins << "http://opennebula.org/occi/infrastructure#network"
          net.title='privatetest'
          net.allocation='static'
          net.attributes["org.opennebula.network.bridge"]="xenbr0"
          expect(@client.create net).to eql 'https://localhost:3300/network/64'
        end

        it "deletes a compute resource" do
          expect(@client.delete 'https://localhost:3300/compute/4017').to eql true
        end

        it "deletes a network resource" do
          expect(@client.delete 'https://localhost:3300/network/64').to eql true
        end

        it "deletes a storage resource" do
          expect(@client.delete 'https://localhost:3300/storage/697').to eql true
        end

        it "triggers an action on a compute resource" do
          startaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/compute/action#', term='start', title='start compute instance'
          startactioninstance = Occi::Core::ActionInstance.new startaction, nil
          expect(@client.trigger "https://localhost:3300/compute/4096", startactioninstance).to eq true
        end

        it "triggers an action on a storage resource" do
          onlineaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/storage/action#', term='online', title='activate storage'
          onlineactioninstance = Occi::Core::ActionInstance.new onlineaction, nil
#          offlineaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/storage/action#', term='offline', title='deactivate storage'
#          offlineactioninstance = Occi::Core::ActionInstance.new offlineaction, nil
          expect(@client.trigger "https://localhost:3300/storage/709", onlineactioninstance).to eq true
        end

        it "triggers an action on a network resource" do
          upaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/network/action#', term='up', title='activate network'
          upactioninstance = Occi::Core::ActionInstance.new upaction, nil
          expect(@client.trigger "https://localhost:3300/network/66", upactioninstance).to eq true
        end

        it "refreshes its model" do
          @client.refresh
        end

      end
    end

    end
  end
end
