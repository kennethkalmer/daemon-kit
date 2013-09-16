Given(/^I have an existing daemon called "(.*?)"$/) do |name|
  step %Q{I run `daemon-kit #{name}`}
end


When(/^I accept the conflicts$/) do
  step %Q{I wait for stdout to contain "Overwrite"}
  type "a\n"
  #eot
end

Then(/^the Gemfile should point to edge daemon\-kit$/) do
  prep_for_fs_check do
    gemfile = IO.read('Gemfile')

    gemfile.should =~ /^gem 'daemon\-kit', :github => 'kennethkalmer\/daemon\-kit'$/
    gemfile.should_not =~ /^gem 'daemon\-kit'$/
  end
end
