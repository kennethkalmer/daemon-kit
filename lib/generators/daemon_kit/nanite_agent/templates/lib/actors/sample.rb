class Sample
  include Nanite::Actor

  expose :echo

  # Print to STDOUT and return
  def echo( payload )
    p payload
    payload
  end
end
