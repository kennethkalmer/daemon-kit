require File.dirname(__FILE__) + '/spec_helper'

describe DaemonKit::ForkPool do
  describe "configuration" do
    it "should default to 4 forks" do
      DaemonKit::ForkPool.size.should be(4)
    end

    it "should have an empty work queue" do
      DaemonKit::ForkPool.queue.should be_empty
    end
  end

  describe "running" do
    it "should run blocks without issue" do
      pending "Figure out how to run forks with rspec"

      DaemonKit::ForkPool.fork do
        sleep 1
      end

      DaemonKit::ForkPool.processes.should_not be_empty
      DaemonKit::ForkPool.wait

      DaemonKit::ForkPool.processes.should be_empty
      DaemonKit::ForkPool.queue.should be_empty
    end

    it "should queue overflow blocks" do
      pending "Figure out how to run forks with rspec"

      5.times do
        DaemonKit::ForkPool.process { sleep 1 }
      end

      sleep 0.5
      DaemonKit::ForkPool.processes.size.should be(4)
      DaemonKit::ForkPool.queue.size.should be(1)

      DaemonKit::ForkPool.wait
      DaemonKit::ForkPool.processes.should be_empty
      DaemonKit::ForkPool.queue.should be_empty
    end
  end
end
