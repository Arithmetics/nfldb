require 'csv'

data = CSV.read("./97062_starts.csv", { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

data2 = CSV.read("./player_games.csv", { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

player_starts = data.map { |d| d.to_hash }
player_games = data2.map { |d| d.to_hash }


player_games.each do |game|
  if game[:position] == "WR/TE"
    player_starts.each do |start|
      if start[:profile_id] == game[:profile_id] && (start[:position] == "WR" || start[:position] == "TE")
        puts "#{game[:profile_id]}, #{game[:position]} was flipped to #{start[:position]}, #{start[:name]}"

        game[:position] = start[:position]

        break
      end
    end
  end
end


CSV.open("results.csv", "a+") do |csv|
  player_games.each do |game|
    csv << game.values
  end
end