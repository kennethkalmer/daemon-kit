require File.dirname(__FILE__) + '/spec_helper'
require 'daemon_kit/initializer'

describe DaemonKit::Initializer do

  let(:configuration) { DaemonKit::Configuration.new }

  subject { DaemonKit::Initializer.new( configuration ) }

  describe "#configure_exception_handling" do

    it "should configure threads to abort on exceptions" do
      subject.configure_exception_handling

      expect( Thread.abort_on_exception ).to be_true
    end

    it "should not configure safely if the gem isn't available" do
      DaemonKit::Initializer.stub(:safely_available?).and_return( false )
      subject.should_not_receive( :configure_safely )

      subject.configure_exception_handling
    end

    it "should configure safely if the gem is available" do
      DaemonKit::Initializer.stub(:safely_available?).and_return( true )
      subject.should_receive( :configure_safely )

      subject.configure_exception_handling
    end

  end

  describe "#configure_safely" do
    let(:fake_class) { Class.new }

    before(:each) do
      @safely_log = stub_const('Safely::Strategy::Log', fake_class)
      @safely_backtrace = stub_const('Safely::Backtrace', fake_class)

      DaemonKit.logger = DaemonKit::AbstractLogger.new('/dev/null')
    end

    it "should configure Safely" do
      @safely_log.should_receive(:logger=)

      @safely_backtrace.should_receive(:trace_directory=)
      @safely_backtrace.should_receive(:enable!)

      subject.configure_safely
    end
  end

end

describe DaemonKit::Configuration do

  it "should know our environment" do
    subject.environment.should_not be_nil
  end

  it "should have a default log path" do
    subject.log_path.should_not be_nil
  end

  it "should have a default log level" do
    subject.log_level.should_not be_nil
  end

  it "should have a default pid file" do
    subject.stub(:default_log_path).and_return('/var/log/daemon.log')
    subject.stub(:daemon_name).and_return('spec-daemon')

    subject.pid_file.should == "/var/log/spec-daemon.1.pid"
  end

  it "should set a default umask" do
    File.umask.should_not eq(0)
    File.umask.should eq(18)
  end

end
