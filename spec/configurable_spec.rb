require File.dirname(__FILE__) + '/spec_helper'

class FooConfig
  include DaemonKit::Configurable

  configurable :has_default, true
  configurable :no_default
  configurable :has_lock, :locked => true
end

describe DaemonKit::Configurable do

  before(:each) do
    @foo = FooConfig.new
  end

  it "should support default values" do
    lambda {
      @foo.has_default.should be_true
    }.should_not raise_error( NoMethodError )
  end

  it "should support overwriting unlocked defaults" do
    lambda {
      @foo.has_default = false
      @foo.has_default.should be_false
    }.should_not raise_error
  end

  it "should support no default values" do
    lambda {
      @foo.no_default.should be_nil
    }.should_not raise_error( NoMethodError )
  end

  it "should allow setting locked values once" do
    lambda {
      @foo.has_lock = 1
      @foo.has_lock.should == 1

      @foo.has_lock = 2
      @foo.has_lock.should == 1
    }.should_not raise_error
  end

  it "should allow bypassing the lock explicitly" do
    lambda {
      @foo.has_lock = 1
      @foo.has_lock.should == 1

      @foo.set(:has_lock, 2)
      @foo.has_lock.should == 2
    }.should_not raise_error
  end

end
