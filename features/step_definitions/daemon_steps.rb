Given(/^I have an existing daemon called "(.*?)"$/) do |name|
  step %Q{I run `daemon-kit #{name}`}
end


When(/^I accept the conflicts$/) do
  step %Q{I wait for stdout to contain "Overwrite"}
  type "a\n"
  #eot
end
