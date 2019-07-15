require 'json'

playerFile = File.read('../players.json')

initial_player_hash =  JSON.parse(playerFile)


player_info_hash = {}

initial_player_hash.each do |k,v|
  profile_id = v["profile_id"].to_s
  player_info_hash[profile_id] = v
end


