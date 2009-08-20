require File.dirname(__FILE__) + '/test_helper.rb'

class Test<%= module_name %> < Test::Unit::TestCase

  context "<%= module_name %>" do
    should "have tests" do
      assert(false)
    end
  end

end

