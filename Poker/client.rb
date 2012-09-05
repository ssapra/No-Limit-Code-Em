require 'net/http'
require 'json'

print "Hostname: "
hostname = gets.chomp
print "Port number: "
port = gets.chomp
print "Name: "
name = gets.chomp
print "Game ID: "
game_id = gets.chomp

begin

url = URI.parse("http://#{hostname}:#{port}")

response = Net::HTTP.post_form(url, {:name => name, :game_id => game_id})
  
  #puts response.inspect
  
  if response.code.to_i == 200
    resp = JSON.parse(response.body)
    if resp.has_key?("player_key")
      puts "Your player key: #{resp["player_key"]}"
      player_key = resp["player_key"]
    else
      puts resp["message"]
    end
  end
rescue
  puts "Did not connect"
end

while player_key
  
  print "Name: "
  name = gets.chomp
  print "Game Id: "
  game_id = gets.chomp
  
  uri = URI('http://localhost:3000/states')
  
  uri.query = URI.encode_www_form({:name => name, :game_id => game_id})
  
  res = Net::HTTP.get_response(uri)
  puts JSON.parse(res.body)
  
  #new_response = Net::HTTP.post_form(url, {:name => name, :game_id => game_id, :player_key => player_key})
  #puts JSON.parse(new_response.body)["message"]
  
end


  