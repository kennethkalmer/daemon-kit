# Load all the take tasks in the gem
Dir[File.join(File.dirname(__FILE__), '**/*.rake')].each { |rake| load rake }
