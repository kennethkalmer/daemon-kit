require File.dirname(__FILE__) + '/spec_helper'

describe DaemonKit::Safety do
end

describe DaemonKit::ErrorHandlers::Mail do
  it "should send an email report" do
    conf = Object.new
    conf.stubs(:daemon_name).returns('test')
    DaemonKit.stubs(:configuration).returns(conf)

    fake_smtp = Object.new
    fake_smtp.expects(:start).with('localhost.localdomain', nil, nil, nil)
    Net::SMTP.expects(:new).with('localhost', 25).returns(fake_smtp)

    begin
      raise RuntimeError, "specs don't fail :)"
    rescue => e
      handler = DaemonKit::ErrorHandlers::Mail.instance
      handler.handle_exception( e )
    end
  end
end
