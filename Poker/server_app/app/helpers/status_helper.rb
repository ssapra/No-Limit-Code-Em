module StatusHelper
  def status(state)
    if state == "registration"
  		  if Status.first.registration then return "open" else return "closed" end
    elsif state == "play"
  	    if Status.first.play then return "open" else return "closed" end
    elsif state == "game"
  	    if Status.first.game then return "open" else return "closed" end
    end
  end
  
end
