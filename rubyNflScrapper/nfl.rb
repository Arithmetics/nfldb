require 'selenium-webdriver'
require 'nokogiri'
require 'csv'
require 'pp'

def get_player_performances(year, driver, owners)
  weeks=*(1..16)
  teams=*(1..12)
  players = []
  # weeks=*(4)
  # teams=*(4)
  weeks.each do |week|
    teams.each do |team|
      driver.navigate.to "https://fantasy.nfl.com/league/400302/history/#{year}/teamhome?statCategory=stats&statSeason=2018&statType=weekStats&statWeek=1&teamId=#{team}&week=#{week}"
      sleep(3)
      doc = Nokogiri::HTML(driver.page_source)
      owners = doc.css(".owners")
      team_owner = owners.css(".userName").text
      
      team_table = doc.css("tableType-player")
      player_rows = doc.css("tr")
      # puts player_rows[2]
      player_rows.each do |row|
        player = {}
        player[:position] = row.css(".teamPosition").text
        player[:name] = row.css(".playerNameAndInfo").css("a").text
        link = row.css(".playerNameAndInfo").css("a").map { |link| link['href'] }
        if (link.length > 0)
          # player[:id] = link[0].match(("?<=WORD).*$"))
          re = Regexp.new "(?<=playerId=).*$"
          player[:id] = link[0].scan(re)[0]
        end
        player[:pts] = row.css(".statTotal").text
        player[:owner] = team_owner
        player[:year] = year
        player[:week] = week
        puts player
        players.push(player)
      end
    end
  end
end



########################################################
########################################################
########################################################
########################################################
########################################################
########################################################

owners = { 
  "Matt" => {},
  "Jeremy" => {},
  "woody" => {},
  "Michael" => {},
  "Brock" => {},
  "Daniel" => {},
  "Jared" => {},
  "Kevin" => {},
  "tim" => {},
  "jordan" => {},
  "Brandon" => {},
  "Eric" => {},
  "joe" => {},
  "Keenan" => {},
}

years = [2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018]
# years = [2017]


owners.each do |k,_|
  years.each do |year|
    owners[k][year] = []
  end
end


driver = Selenium::WebDriver.for :firefox

########### driver setup and login #############
driver.navigate.to "https://www.nfl.com/login?s=fantasy&returnTo=http%3A%2F%2Ffantasy.nfl.com%2Fleague%2F400302"
sleep(1)
username = driver.find_element(id: "fanProfileEmailUsername")
password = driver.find_element(id: "fanProfilePassword")
submit = driver.find_element(xpath: "/html/body/div[1]/div/div/div[2]/div[1]/div/div/div[2]/main/div/div[2]/div[2]/form/div[3]/button")
sleep(1)
username.send_keys("brock.m.tillotson@gmail.com")
password.send_keys("rock7900")
submit.click()
sleep(2)


years.each do |year|
  get_player_performances(year, driver, owners)
end


driver.quit

########################################################
########################################################
########################################################
########################################################
########################################################







