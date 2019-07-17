require 'nokogiri'
require 'open-uri'
require 'csv'

def get_seasons_played(doc)
  season_options = []
  doc.css("#season").css("option").each do |option|
    season_options.push(option.attr("value"))
  end
end

def type_game(game)
  game.each do |k,v|
    if v == "--"
      v = "0"
    end
    game[k] = v.to_i
  end
  return game
end

def get_qb_game(cells, profile_id, year)
  puts cells[1]
  new_game = {profile_id: profile_id, year: year}
  new_game[:week] = cells[0].text
  new_game[:passing_completions] = cells[6].text 
  new_game[:passing_attempts] = cells[7].text
  new_game[:passing_yards] = cells[9].text
  new_game[:passing_touchdowns] = cells[11].text 
  new_game[:interceptions] = cells[12].text
  new_game[:rushing_attempts] = cells[16].text
  new_game[:rushing_yards] = cells[17].text
  new_game[:rushing_touchdowns] = cells[19].text
  new_game[:fumbles_lost] = cells[21].text
  return type_game(new_game)
end

def get_rb_game(cells, profile_id, year)
  new_game = {profile_id: profile_id, year: year}
  new_game[:week] = cells[0].text
  new_game[:rushing_attempts] = cells[6].text
  new_game[:rushing_yards] = cells[7].text
  new_game[:rushing_touchdowns] = cells[10].text
  new_game[:receiving_yards] = cells[12].text 
  new_game[:receptions] = cells[15].text
  new_game[:receiving_touchdowns] = cells[9].text
  new_game[:fumbles_lost] =  cells[17].text
  return type_game(new_game)
end

def get_wr_game(cells, profile_id, year)
  new_game = {profile_id: profile_id, year: year}
  new_game[:week] = cells[0].text
  new_game[:receiving_yards] = cells[7].text 
  new_game[:receptions] = cells[6].text
  new_game[:receiving_touchdowns] = cells[10].text
  new_game[:rushing_attempts] = cells[11].text
  new_game[:rushing_yards] = cells[12].text
  new_game[:rushing_touchdowns] = cells[15].text
  new_game[:fumbles_lost] =  cells[17].text
  return type_game(new_game)
end

def is_a_legit_row?(cells)
  return (cells.length > 17 && cells[0].text != "WK" && cells[4].text == "1" && cells[1].text != "TOTAL")
end

def get_all_player_games(profile_id)
  begin
    doc = Nokogiri::HTML(open("http://www.nfl.com/player/drewbrees/#{profile_id}/gamelogs"))
  rescue OpenURI::HTTPError => ex
    puts "could not find player #{profile_id}"
    return []
  end
  all_player_games = []
  get_seasons_played(doc).each do |option|
    year = option.text
    doc = Nokogiri::HTML(open("http://www.nfl.com/player/drewbrees/#{profile_id}/gamelogs?season=#{year}"))
    position = doc.css(".player-number").text.split(" ")[1]
    game_tables = doc.css(".data-table1")
    game_tables.each do |table|
      type = table.css(".player-table-header").css("td")[0].text
      if type == "Regular Season"
        game_row = table.css("tr")
        game_row.each do |row|
          cells = row.css("td")
          if is_a_legit_row?(cells)
            if position == "QB"
              all_player_games.push(get_qb_game(cells, profile_id, year))
            elsif position == "RB"
              all_player_games.push(get_rb_game(cells, profile_id, year))
            elsif position == "WR" || position == "TE"
              all_player_games.push(get_wr_game(cells,profile_id, year))
            end
          end
        end
      end
    end
  end
  return all_player_games
end


# data = CSV.read("./97062_starts.csv", { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

# hashed_data = data.map { |d| d.to_hash }
# to_scrape = {}

# hashed_data.each do |row|
#   to_scrape[row[:profile_id].to_s] = row[:name]
# end

# all_games_ever = []

# to_scrape.each do |k,v|
#   puts ".."
#   puts "scraping #{v}"
#   players_games = get_all_player_games(k.to_i)
#   if players_games.length == 0
#     puts "#{v} didnt have a game played"
#   else 
#     all_games_ever.concat(players_games)
#   end
# end

# puts all_games_ever.length
# puts all_games_ever[2]



x = get_all_player_games(2495240)