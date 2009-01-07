require File.dirname(__FILE__) + '/spec_helper'

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
    
end


describe DaemonKit::Initializer do

  it "should setup a logger" do
    pending
    DaemonKit::Initializer.run(:initialize_logger)
    DaemonKit.logger.should_not be_nil
  end
  
end
