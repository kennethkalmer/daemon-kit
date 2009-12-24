require 'spec_helper'

class MockComponent
  include DaemonKit::Slice

  attr_accessor :arguments_called, :environment_called

  def arguments
    self.arguments_called = true
  end

  on :environment do
    self.environment_called = true
  end
end

describe DaemonKit::Slice do
  before(:each) do
    DaemonKit::Timeline.reset!

    @component = MockComponent.new
    DaemonKit::Timeline.subscribe( @component )
  end

  it "should respond to events" do
    lambda {
      @component.handle_event!( 'after_daemonize' )
    }.should_not raise_error
  end

  it "should have method callbacks" do
    @component.handle_event!( 'arguments' )

    @component.arguments_called.should be_true
  end

  it "should have block callbacks" do
    @component.handle_event!( 'environment' )

    @component.environment_called.should be_true
  end
end
