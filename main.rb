require "./MLB_schedule_loader.rb"
require "./MLB_Team_loader.rb"
require "./MLB_team_rosters_loader.rb"

teams_loader=MLB_TeamDataLoader.new
teams_loader.grab_API_data_and_add_to_db('http://api.sportsdatallc.org/mlb-t3/teams/2013.xml?api_key=d568qhj3huppbdds2pauuqya')


schedules_loader=MLB_ScheduleLoader.new
schedules_loader.grab_API_data_and_add_to_db('http://api.sportsdatallc.org/mlb-t3/schedule/2013.xml?api_key=d568qhj3huppbdds2pauuqya')


rosters_loader=MLB_TeamRostersLoader.new
rosters_loader.grab_API_data_and_add_to_db("http://api.sportsdatallc.org/mlb-t3/rosters-full/2013.xml?api_key=d568qhj3huppbdds2pauuqya")




