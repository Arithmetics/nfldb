require 'csv'


data = CSV.read("./97062_starts.csv", { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

player_starts = data.map { |d| d.to_hash }

years = [2011,2012,2013,2014,2015,2016,2017,2018]
positions = ["QB","RB","WR","TE"]

sorted_players = {}

years.each do |year|
  sorted_players[year] = []
end

# sorted_players = {2011: [{player1}, {player2}], 2012: [].....}



player_starts.each do |player_start|
  player_exists_yet = false
  sorted_players[player_start[:year]].each do |sorted_player|
    if sorted_player[:profile_id] == player_start[:profile_id]
      player_exists_yet = true
      if player_start[:position] != "K" && player_start[:position] != "DEF"
        sorted_player[:positions].push(player_start[:position])
      end
    end
  end
  if !player_exists_yet
    sorted_players[player_start[:year]].push(
      {
        profile_id: player_start[:profile_id], 
        name: player_start[:name], 
        positions: [player_start[:position]]
      }
    )
  end
end

all_rankings = []
years.each do |year|
  positions.each do |position|
    data = CSV.read("./rankings/#{year}_#{position}.csv", { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

    rankings = data.map{ |d| d.to_hash}

    rankings.each do |ranking|
      ranking[:year] = year
      ranking[:position] = position
    end

    all_rankings.concat(rankings)
  end
end


sorted_players[2011].each do |sorted_player|
  found = false
  all_rankings.each do |ranked_player|

    if ranked_player[:year] == 2011 && ranked_player[:name] == sorted_player[:name] && sorted_player[:positions].include?(ranked_player[:position])
      found = true
      puts "matched #{ranked_player[:name]} to #{sorted_player[:name]}"
    end
  end

  if found == false
    puts "could not find #{sorted_player[:name]}"
  end
end