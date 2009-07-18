require File.dirname(__FILE__) + '/spec_helper'
require 'daemon_kit/initializer'

describe DaemonKit::Configuration do
  before(:each) do
    @configuration = DaemonKit::Configuration.new
  end

  it "should know our environment" do
    @configuration.environment.should_not be_nil
  end

  it "should have a default log path" do
    @configuration.log_path.should_not be_nil
  end

  it "should have a default log level" do
    @configuration.log_level.should_not be_nil
  end

  it "should set a default umask" do
    File.umask.should_not be(0)
    File.umask.should be(18)
  end

end
