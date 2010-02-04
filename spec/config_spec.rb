require File.dirname(__FILE__) + '/spec_helper'

describe DaemonKit::Config do

  describe "working with config data" do
    before(:each) do
      @config = DaemonKit::Config.new('foo' => 'bar', 'nes' => { 'ted' => 'value' }, 'dash-ed' => 'keys')
    end

    it "should have string key access to values" do
      @config['foo'].should == 'bar'
    end

    it "should have symbol key access to values" do
      @config[:foo].should == 'bar'
    end

    it "should have instance accessors to values" do
      @config.foo.should == 'bar'
    end

    it "should have nested instance accessors to values" do
      @config.nes.ted.should == 'value'
    end

    it "should return the config as a hash" do
      @config.to_h.should == { 'foo' => 'bar', 'nes' => { 'ted' => 'value' }, 'dash-ed' => 'keys' }
    end

    it "should be able to symbolize keys in returned hash" do
      @config.to_h(true).should == { :foo => 'bar', :nes => { :ted => 'value' }, :'dash-ed' => 'keys' }
    end

    it "should be able to handle dashed keys via accessors" do
      @config.dash_ed.should == 'keys'
    end
  end

  describe "parsing files" do
    before(:all) do
      FileUtils.mkdir_p( DAEMON_ROOT + "/config" )
      FileUtils.cp( File.dirname(__FILE__) + '/fixtures/env.yml', DAEMON_ROOT + '/config/' )
      FileUtils.cp( File.dirname(__FILE__) + '/fixtures/noenv.yml', DAEMON_ROOT + '/config/' )
    end

    it "should parse env keys correctly" do
      config = DaemonKit::Config.load('env')

      config.test.should == 'yes!'
      config.array.should_not be_empty
    end

    it "should not be worried about missing env keys" do
      config = DaemonKit::Config.load('noenv')

      config.string.should == 'value'
    end

    it "should accept symbol file names" do
      config = DaemonKit::Config.load(:env)
      config.test.should == 'yes!'
    end

    it "should bail on missing files" do
      lambda {
        DaemonKit::Config.load('missing')
      }.should raise_error(ArgumentError)
    end

    it "should give direct hash access to a config" do
      config = DaemonKit::Config.hash(:env)

      config.should be_a_kind_of(Hash)
      config.keys.should include('test')
    end

    it "should give direct symbolized hash access to a config" do
      config = DaemonKit::Config.hash(:env, true)

      config.keys.should include(:test)
    end
  end
end
