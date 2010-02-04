require File.dirname(__FILE__) + '/spec_helper'

describe DaemonKit::Arguments do

  describe "parsing ARGV" do

    it "should extract the given command" do
      argv = [ 'start', '-f', 'foo' ]
      res = DaemonKit::Arguments.parse( argv )

      res.first.should == :start
    end

    it "should have a default command if missing" do
      argv = [ '-h' ]
      res = DaemonKit::Arguments.parse( argv )

      res.first.should == :run
    end

    it "should extract explicit configuration options" do
      argv = [ 'start', '--config', 'environment=development' ]
      res = DaemonKit::Arguments.parse( argv )

      res.shift
      res.first.should == [ 'environment=development' ]

      res.last.should == []
    end

    it "should extract implicit configuration options" do
      argv = [ '-e', 'production' ]
      res = DaemonKit::Arguments.parse( argv )

      res.shift
      res.first.should == ['environment=production']

      res.last.should == []
    end

    it "should extract daemon options" do
      argv = [ 'start', '-h' ]
      res = DaemonKit::Arguments.parse( argv )

      res.shift
      res.first.should == []

      res.last.should == [ '-h' ]
    end

    it "should handle different ordered configurations easily" do
      argv = [ '--pidfile', '/tmp/piddy', '--log', '/tmp/loggy' ]
      res = DaemonKit::Arguments.configuration( argv )

      # No additional args
      res.last.should be_empty

      res.first[0].should == "pid_file=/tmp/piddy"
      res.first[1].should == "log_path=/tmp/loggy"
    end

    it "should handle mixed configurations easily" do
      argv = [ '--rest', 'yes', '-l', '/tmp/loggy', '-f', 'bar' ]
      res = DaemonKit::Arguments.configuration( argv )

      res.first.should == [ 'log_path=/tmp/loggy' ]
      res.last.should  == [ '--rest', 'yes', '-f', 'bar' ]
    end
  end
end
