require "./API_loader.rb"
require "./MLB_schedule_loader.rb"
require "./TeamLoader.rb"

def mapIdToName(scheduleInstance,teamInstance)
  listOfSchedules=[]
  scheduleInstance.resultlistOfEvents.each do |event|
    schedule={}
    schedule["venue"]=event["venue"]
    schedule["eventSchedule"]=event["eventSchedule"]
    teamInstance.resultlistOfTeams.each do|team|
      schedule["homeTeam_name"]=team["name"] if event["homeTeam"]==team["id"]
      schedule["visitTeam_name"]=team["name"] if event["visitTeam"]==team["id"]
    end
    listOfSchedules << schedule
  end
  return listOfSchedules
end

def add_to_db(scheduleList,scheduleInstance)
  scheduleList.each do|event|

    if (scheduleInstance.find_event_in_db(event,"fanzo_mlb_schedules").cmdtuples>0)
      puts "find the event has the venue  #{event["venue"]} and scheduled_start #{event["eventSchedule"]}"
    else
      scheduleInstance.add_fanzo_events(event)
    end
  end

end

#load_teams=API_loader.new
#load_teams.access_api_data('http://api.sportsdatallc.org/mlb-t3/teams/2013.xml?api_key=d568qhj3huppbdds2pauuqya')
#load_teams.store_loaded_data("MLBream.txt")

#load_schedules=API_loader.new
#load_schedules.access_api_data('http://api.sportsdatallc.org/mlb-t3/schedule/2013.xml?api_key=d568qhj3huppbdds2pauuqya')
#load_schedules.store_loaded_data("event.txt")

mlb_teamDataLoader=MLB_TeamDataLoader.new
mlb_teamDataLoader.open_file("MLBteam.txt")
mlb_teamDataLoader.get_list_of_teams
#mlb_teamDataLoader.add_to_db

mlb_scheduleLoader=MLB_ScheduleLoader.new
mlb_scheduleLoader.open_file("event.txt")
mlb_scheduleLoader.get_list_of_events
#mlb_scheduleLoader.add_to_db


fanzo_mlb_scheduleLoader=MLB_ScheduleLoader.new
fanzo_mlb_scheduleLoader.connect_to_db
fanzo_mlb_scheduleLoader.prepareInsertFanzoEvent
schedules_with_name=mapIdToName(mlb_scheduleLoader,mlb_teamDataLoader)
add_to_db(schedules_with_name,fanzo_mlb_scheduleLoader)

