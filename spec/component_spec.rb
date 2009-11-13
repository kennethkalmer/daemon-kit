require File.dirname(__FILE__) + '/spec_helper'

class MockComponent
  include DaemonKit::Component
end

describe DaemonKit::Component do
  before(:each) do
    @component = MockComponent.new
  end

  it "should respond to events" do
    lambda {
      @component.fire!( :after_daemonize )
    }.should_not raise_error
  end
end
