# Sample pseudo participant
class Sample

  def quote( workitem )
    workitem["attributes"]["quote"] = open("http://www.iheartquotes.com/api/v1/random").read

    workitem
  end

end
