require 'rspec'

module Occi
  module Api

#    vcr_options = { :record => :new_episodes }
    vcr_options = { :record => :none }

    describe Dsl, :vcr => vcr_options do
      class DummyClass
      end

      before(:each) do
        @dummy = DummyClass.new
        @dummy.extend Occi::Api::Dsl
      end

      context ".connect" do

        it "connects successfully through HTTP" do

          expect(
            @dummy.connect(:http,
            {
              :endpoint => ENV['ROCCI_SPEC_ENDPOINT'] || 'https://localhost:3300',
              :auth => hash_or_nil_helper( ENV['ROCCI_SPEC_AUTH_JSON'] ) || { :type => "basic", :username => "rocci-test", :password => "edited"},
              :log => { :out   => "/dev/null",
                        :level => Occi::Log::DEBUG },
              :auto_connect => true,
              :media_type => "text/plain,text/occi"
            } )).to eql true
        end

        it "raises exception for unsupported protocol" do

          expect{
            @dummy.connect(:ftp,
            { 
              :endpoint => ENV['ROCCI_SPEC_ENDPOINT'] || 'https://localhost:3300',
              :auth => hash_or_nil_helper( ENV['ROCCI_SPEC_AUTH_JSON'] ) || { :type => "basic", :username => "rocci-test", :password => "edited"},
              :log => { :out   => "/dev/null",
                        :level => Occi::Log::DEBUG },
              :auto_connect => true,
              :media_type => "text/plain,text/occi"
            } ) }.to raise_exception(ArgumentError)
        end

        it "accepts block options" do
          expect(
            @dummy.connect(:http, { :auth => 'https://localhost:3300a' } ) { |opts|
              opts.endpoint = ENV['ROCCI_SPEC_ENDPOINT'] || 'https://localhost:3300'
              opts.auth = hash_or_nil_helper( ENV['ROCCI_SPEC_AUTH_JSON'] ) || { :type => "basic", :username => "rocci-test", :password => "edited"}
              opts.log = { :out   => "/dev/null",
                        :level => Occi::Log::DEBUG }
              opts.auto_connect = true
              opts.media_type = "text/plain,text/occi"
            } ).to eql true
        end


      end

    end
  end
end
