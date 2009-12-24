require 'spec_helper'

class Slice1
  attr_accessor :event_called

  def handle_event!( event )
    self.event_called = event
  end
end

describe DaemonKit::Timeline do
  before(:each) do
    DaemonKit::Timeline.reset!
  end

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
    DaemonKit::Timeline.subscribers.should be_a_kind_of( Hash )
  end

  it "should be able to register subscriber objects" do
    s = Slice1.new
    DaemonKit::Timeline.subscribe( 'framework', s )

    DaemonKit::Timeline.subscribers['framework'].should include( s )

    DaemonKit::Timeline.fire_event!( 'framework' )
    s.event_called.should == 'framework'
  end

  it "should be able to register subscriber blocks" do
    @called = false

    DaemonKit::Timeline.subscribe( 'framework' ) { @called = true }

    DaemonKit::Timeline.subscribers['framework'].should_not be_empty
    DaemonKit::Timeline.subscribers['framework'].first.should_not be_nil

    DaemonKit::Timeline.fire_event!( 'framework' )

    @called.should be_true
  end

  it "should be able to remove subscribers from specifc events" do
    s = Slice1.new
    DaemonKit::Timeline.subscribe( 'framework', s )
    DaemonKit::Timeline.unsubscribe( 'framework', s )

    DaemonKit::Timeline.fire_event!( 'framework' )
    s.event_called.should be_nil
  end

  it "should be able to remove subscribers from all events" do
    s = Slice1.new
    DaemonKit::Timeline.subscribe( 'framework', s )
    DaemonKit::Timeline.subscribe( 'arguments', s )
    DaemonKit::Timeline.unsubscribe( s )

    DaemonKit::Timeline.fire_event!( 'framework' )
    DaemonKit::Timeline.fire_event!( 'arguments' )
    s.event_called.should be_nil
  end

  it "should be able to clear the subscriber queue" do
    DaemonKit::Timeline.subscribe( 'framework' ) { '1' }
    DaemonKit::Timeline.reset!

    DaemonKit::Timeline.subscribers['framework'].should be_empty
  end

  it "should fire off events in sequence" do
    step = states('boot_sequence')
    DaemonKit::Timeline.expects(:fire_event!).with('framework').then(step.is('framework'))
    DaemonKit::Timeline.expects(:fire_event!).with('arguments').then(step.is('arguments'))
    DaemonKit::Timeline.expects(:fire_event!).with('environment').then(step.is('environment'))
    DaemonKit::Timeline.expects(:fire_event!).with('dependencies').then(step.is('dependencies'))
    DaemonKit::Timeline.expects(:fire_event!).with('before_daemonize').then(step.is('before_daemonize'))
    DaemonKit::Timeline.expects(:fire_event!).with('after_daemonize').then(step.is('after_daemonize'))
    DaemonKit::Timeline.expects(:fire_event!).with('application').then(step.is('application'))
    DaemonKit::Timeline.expects(:fire_event!).with('shutdown').then(step.is('shutdown'))

    DaemonKit::Timeline.execute!
  end

  it "should call subscribers in sequence"
end
