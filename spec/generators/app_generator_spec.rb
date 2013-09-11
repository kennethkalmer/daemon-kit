require 'spec_helper'

describe DaemonKit::Generators::AppGenerator do

  with_args 'specd', '-d', 'capistrano' do
    pending "should generate capistrano config" do
      subject.should generate("Capfile")
    end
  end

end
