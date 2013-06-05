require "rexml/document"
include REXML
require 'pg'

class MLB_ScheduleLoader
     @@listOfEvents=[]

     def resultlistOfEvents
       @@listOfEvents
     end

     def open_file(source_file_name)
       source=File.open(source_file_name)
       @doc = REXML::Document.new source
       source.close
     end

    def get_list_of_events
        @doc.elements.each("calendars/event") do |event|
        @TheEvent={}
        @TheEvent["homeTeam"]= event.attributes['home']
        @TheEvent["visitTeam"]=event.attributes['visitor']
        @TheEvent["venue"]=event.attributes['venue']
        @TheEvent["eventSchedule"]=event.elements['scheduled_start'].text
        @@listOfEvents<<@TheEvent
      end
    end

     def listOfEvents_isEmpty
       @@listOfEvents.empty?
     end

     def connect_to_db
       @conn = PG.connect("localhost", 5432, '', '', "SportsData", "fanzo_site", "fanzo_site")
     end

     def prepareInsertEvent
       @conn.prepare('add events data','INSERT INTO mlb_schedules(home_team,visitor_team,venue,
       scheduled_start) VALUES($1,$2,$3,$4)')
     end

     def prepareInsertFanzoEvent
       @conn.prepare('add events data','INSERT INTO fanzo_mlb_schedules(home_team,visit_team,venue,
       scheduled_start,updated_at) VALUES($1,$2,$3,$4,$5)')
     end

     def add_events(event)
       @conn.exec_prepared('add events data',[event["homeTeam"],event["visitTeam"],event["venue"],event["eventSchedule"]])
       puts"add the new event #{event["homeTeam"]} #{event["visitTeam"]} #{event["venue"]} #{event["eventSchedule"]}   "
     end

     def add_fanzo_events(event)
       @conn.exec_prepared('add events data',[event["homeTeam_name"],event["visitTeam_name"],event["venue"],event["eventSchedule"],Time.now])
       puts"add the new event #{event["homeTeam_name"]} #{event["visitTeam_name"]} #{event["eventSchedule"]} "
     end

     def find_event_in_db(event,db_name)
      @conn.exec("SELECT * FROM "+ db_name + " WHERE venue='"+event["venue"]+"' AND scheduled_start= '"+event["eventSchedule"]+"'")

     end

     def disconnect_from_db
       @conn.close
     end

     def add_to_db
       if !listOfEvents_isEmpty
         connect_to_db
         prepareInsertEvent
         @@listOfEvents.each do|event|
           if (find_event_in_db(event,"mlb_schedules").cmdtuples>0)
             puts "find the event has the venue  #{event["venue"]} and scheduled_start #{event["eventSchedule"]}"
           else
             add_events(event)
           end
         end
       else
         puts "the listOfEvents array is empty"
       end
       disconnect_from_db
     end
end


