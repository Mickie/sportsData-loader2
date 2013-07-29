require "rexml/document"
include REXML
require 'pg'
require 'open-uri'
class MLB_ScheduleLoader
 # def open_file(source_file_name)
 #      source=File.open(source_file_name)
 #      @doc = REXML::Document.new source
 #      source.close
 #    end
    def access_api_data(api_Url)
      @api_Url=api_Url
      @contents=open(@api_Url)
      puts "the status of the connetion is #{@contents.status}"
    end

    def get_list_of_events
        @listOfEvents=[]
        @doc = REXML::Document.new @contents
        @doc.elements.each("calendars/event") do |event|
        theEvent={}
        theEvent["homeTeam"]= event.attributes['home']
        theEvent["visitTeam"]=event.attributes['visitor']
        theEvent["event_date"]=event.elements['scheduled_start'].text.split("T")[0]
        theEvent["event_time"]=event.elements['scheduled_start'].text.split("T")[1]
        @listOfEvents<<theEvent
        end
      return @listOfEvents
    end

     def listOfEvents_isEmpty
       @listOfEvents.empty?
     end

     def connect_to_db
       @conn = PG.connect("localhost", 5432, '', '', "fanzo_site_development", "fanzo_site", "fanzo_site")
     end

     def prepareInsertFanzoEvent
       @conn.prepare('add events data','INSERT INTO events(name,home_team_id,visiting_team_id,event_date,
       event_time,created_at,updated_at) VALUES($1,$2,$3,$4,$5,$6,$7)returning id')
     end


     def add_fanzo_events(event)
       @conn.exec_prepared('add events data',["game",event["home_team_id"],event["visiting_team_id"],event["event_date"],
       event["event_time"],Time.now,Time.now])
       puts"add the new event #{event["home_team_id"]} #{event["visiting_team_id"]} #{event["event_date"]} #{event["event_time"]}"
     end

     def find_event_in_db?(event)
      res= @conn.exec("SELECT * FROM events WHERE home_team_id=#{event["home_team_id"]} AND event_date= '"+event["event_date"]+"'
                      AND event_time='"+event["event_time"]+"'")
      return res.cmdtuples>0
     end

    def find_id_from_teamsTable(event,typeOfTeam)

      res=@conn.exec("select id from teams where espn_team_name_id ='"+event[typeOfTeam]+"'")
      res.getvalue( 0, 0 ).to_i

    end

    def mapIdToFanzoId(aList)
      listOfFanzoSchedules=[]
      connect_to_db
      aList.each do |event|
        schedule={}
        schedule["event_date"]=event["event_date"]
        schedule["event_time"]=event["event_time"]
        schedule["home_team_id"]=find_id_from_teamsTable(event,"homeTeam")
        schedule["visiting_team_id"]=find_id_from_teamsTable(event,"visitTeam")
        listOfFanzoSchedules << schedule
      end
      return listOfFanzoSchedules
    end

     def disconnect_from_db
       @conn.close
     end

     def grab_API_data_and_add_to_db(aUrl)
      begin
            access_api_data(aUrl)
            theEventList=mapIdToFanzoId(get_list_of_events)
           if !listOfEvents_isEmpty
             prepareInsertFanzoEvent
             theEventList.each do|event|
               if find_event_in_db?(event)
                 puts "find the event has the home_team_id #{event["home_team_id"]} visiting_home_id #{event["visiting_team_id"]}
                      and scheduled_at #{event["event_date"]}"
               else
                 add_fanzo_events(event)
               end
             end
           else
             puts "the listOfEvents array is empty"
           end
      rescue Exception=>e
            puts e.message
            puts e.backtrace.inspect
      ensure
            disconnect_from_db
      end
    end
end


