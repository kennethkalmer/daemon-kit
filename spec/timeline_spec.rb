require File.dirname(__FILE__) + '/spec_helper'

describe DaemonKit::Timeline do
  it "should have a default sequence of events" do
    DaemonKit::Timeline.sequence.should == [
      'framework',
      'arguments',
      'environment',
      'dependencies',
      'before_daemonize',
      'after_daemonize',
      'application',
      'shutdown'
    ]
  end

  it "should have a list of subscribers" do
    DaemonKit::Timeline.subscribers.should be_empty
  end

  it "should fire off events in sequence"
  it "should call subscribers in sequence"
  it "should be able to remove subscribers"
end
