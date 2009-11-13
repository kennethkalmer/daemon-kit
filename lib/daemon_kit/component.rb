module DaemonKit
  module Component

    def fire!( event_name )
      self.send( event_name ) if self.respond_to?( event_name )
    end

  end
end
