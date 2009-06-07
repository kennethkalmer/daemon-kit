require File.dirname(__FILE__) + '/spec_helper'

describe DaemonKit::AbstractLogger do

  before(:each) do
    @log_file = "#{DAEMON_ROOT}/log/spec.log"
    @logger = DaemonKit::AbstractLogger.new( @log_file )
    @logger.level = :debug
  end

  it "should have a log level" do
    @logger.level.should == :debug
  end

  it "should have a backend logger" do
    @logger.logger.should_not be_nil
  end

  it "should accept a different backend" do
    l = Logger.new('/dev/null')
    @logger.logger = l
    @logger.logger.should == l
  end

  it "should be able to log to STDOUT as well" do
    @logger.copy_to_stdout = true

    STDOUT.expects(:puts).with(regexp_matches(/test/))

    @logger.debug "test"
    IO.readlines( @log_file ).last.should match(/test/)
  end

  it "should log debug level messages" do
    @logger.debug( "Debug test" )

    IO.readlines( @log_file ).last.should match(/\[DEBUG\].*Debug test/)
  end

  it "should log info level messages" do
    @logger.info( "Info test" )

    IO.readlines( @log_file ).last.should match(/\[INFO\].*Info test/)
  end

  it "should log warn level messages" do
    @logger.warn( "Warn test" )

    IO.readlines( @log_file ).last.should match(/\[WARN\].*Warn test/)
  end

  it "should log error level messages" do
    @logger.error( "Err test" )

    IO.readlines( @log_file ).last.should match(/\[ERROR\].*Err test/)
  end

  it "should log fatal level messages" do
    @logger.fatal( "Fatal test" )

    IO.readlines( @log_file ).last.should match(/\[FATAL\].*Fatal test/)
  end

  it "should log unknown level messages" do
    @logger.unknown( "Unknown test" )

    IO.readlines( @log_file ).last.should match(/\[ANY\].*Unknown test/)
  end

  it "should log the caller file and line number" do
    f = File.basename(__FILE__)
    l = __LINE__ + 2

    @logger.info( "Caller test" )

    IO.readlines( @log_file ).last.should match(/#{f}:#{l}:/)
  end

  it "should log exceptions with daemon traces" do
    fake_trace = [
                  "/home/kenneth/daemon/libexec/daemon-daemon.rb:1:in `foo'",
                  "/usr/lib/ruby/gems/1.8/gems/daemon-kit-0.0.1/lib/daemon_kit/abstract_logger.rb:49: in `info'"
                 ]

    e = RuntimeError.new( 'Test error' )
    e.set_backtrace( fake_trace )

    @logger.exception( e )

    IO.readlines( @log_file ).last.should match(/EXCEPTION: Test error/)
  end

  it "should log exceptions without framework traces" do
    fake_trace = [
                  "/home/kenneth/daemon/libexec/daemon-daemon.rb:1:in `foo'",
                  "/usr/lib/ruby/gems/1.8/gems/daemon-kit-0.0.1/lib/daemon_kit/abstract_logger.rb:49: in `info'"
                 ]

    clean_trace = @logger.clean_trace( fake_trace )

    clean_trace.should include("/home/kenneth/daemon/libexec/daemon-daemon.rb:1:in `foo'")
    clean_trace.should_not include("/usr/lib/ruby/gems/1.8/gems/daemon-kit-0.0.1/lib/daemon_kit/abstract_logger.rb:49: in `info'")
  end

  it "should support reopening log files" do
    @logger.close

    FileUtils.rm( @log_file )

    @logger.info( 'Reopen')
    IO.readlines( @log_file ).last.should match(/Reopen/)
  end

  it "should support silencing" do
    @logger.silence do |logger|
      logger.info "This should never be logged"
    end

    @logger.info "This should be logged"

    log = IO.readlines( @log_file )

    log.detect { |l| l =~ /This should never be logged/ }.should be_nil
    log.detect { |l| l =~ /This should be logged/ }.should_not be_nil
  end
end
