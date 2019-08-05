require 'csv'
require "json"
file = File.open "../players.json"
json_data = JSON.load file
file.close()

player_starts = CSV.read("./psql_seeds/97062_starts.csv", { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

rankings = CSV.read("./psql_seeds/updated_rankings.csv", { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})


all_players = {}

player_starts.each do |start|
  profile_id = start[:profile_id]
  name = start[:name]
  birthdate = start[:birthdate]
  gsis_id = start[:gsis_id]

  if all_players[profile_id] == nil
    all_players[profile_id] = {profile_id: profile_id, name: name, birthdate: birthdate, gsis_id: gsis_id}
  end
end


rankings.each do |ranking|
  if all_players[ranking[:profile_id]] == nil
    profile_id = ranking[:profile_id]
    name = ranking[:name]
    birthdate = ""
    gsis_id = ""
    printit = false
    json_data.each do |k,player|
      if player["profile_id"] == profile_id
        birthdate = player["birthdate"]
        gsis_id = player["gsis_id"]
        printit = true
      end
    end
    new_guy = {profile_id: profile_id, name: name, birthdate: birthdate, gsis_id: gsis_id}
    all_players[profile_id] = new_guy
    if printit
      puts new_guy
    end
  end
end

all_array = []

all_players.each do |k,v|
  all_array.push(v)
end

CSV.open("player_master.csv", "a+") do |csv|
  all_array.each do |player|
    csv << player.values
  end
end
