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
  end
end
