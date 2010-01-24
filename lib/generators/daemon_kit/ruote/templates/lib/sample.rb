require 'open-uri'

# Sample pseudo participant
#
# See http://gist.github.com/144861 for a test engine
class Sample < DaemonKit::RuotePseudoParticipant

  on_exception :dammit

  on_complete do |workitem|
    workitem['success'] = true
  end

  def quote
    workitem["quote"] = open("http://www.iheartquotes.com/api/v1/random").read
  end

  def err
    raise ArgumentError, "Does not compute"
  end

  def dammit( exception )
    workitem["error"] = exception.message
  end

end
