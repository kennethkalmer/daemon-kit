require 'spec_helper'

describe DaemonKit::Generators::TestUnitGenerator do

  before(:each) do
    DaemonKit::Generators::Base.any_instance.stub(:app_name).and_return('specd')
  end

  it { should generate("test/test_helper.rb") }
  it { should generate("test/specd_test.rb") }
  it { should generate("tasks/test_unit.rake") }

end
