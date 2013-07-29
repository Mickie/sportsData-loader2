require "rexml/document"
include REXML
require 'pg'
require 'open-uri'

class MLB_TeamRostersLoader

  def access_api_data(api_Url)
    @api_Url=api_Url
    @contents=open(@api_Url)
    puts "the status of the connetion is #{@contents.status}"
  end

  def mapTeamIdtoFanzoId(teamId)
    res=@conn.exec("select id from teams where espn_team_name_id ='"+teamId+"'")
    res.getvalue( 0, 0 ).to_i
  end

  def get_list_of_rosters
    @listOfRosters=[]
    @doc = REXML::Document.new @contents
    @doc.elements.each("rosters/team") do |roster|
      team_id= roster.attributes['id']
      roster.elements.each("players/profile") do |player|
        thePlayer={}
        thePlayer["team_id"]=mapTeamIdtoFanzoId(team_id)
        #thePlayer["team_id"]=team_id
        thePlayer["type"]="athlete"
        #thePlayer["mlb_id"]=player.attributes['mlbam_id']
        thePlayer["position"]=player.attributes['position']
        thePlayer["first_name"]=player.elements['first'].text
        thePlayer["last_name"]=player.elements['last'].text
        #thePlayer["bat_hand"]=player.elements['bat_hand'].text
        #thePlayer["throw_hand"]=player.elements['throw_hand'].text
        #thePlayer["weight"]=player.elements['weight'].text.to_i
        #thePlayer["height"]=player.elements['height'].text.to_i
        #thePlayer["birthday"]=player.elements['birthdate'].text
        thePlayer["home_town"]="#{player.elements['birthcity'].text} #{player.elements['birthstate'].text} #{player.elements['birthcountry'].text}"
        thePlayer["home_school"]="#{player.elements['highschool'].text} #{player.elements['college'].text}"
        @listOfRosters<<thePlayer
      end
    end
    return @listOfRosters
  end

  def listOfRosters_isEmpty
    @listOfRosters.empty?
  end
  def connect_to_db
    @conn = PG.connect("localhost", 5432, '', '', "fanzo_site_development", "fanzo_site", "fanzo_site")
  end

  def prepareInsertRoster
    @conn.prepare('add rosters data','INSERT INTO people(first_name,last_name,
          home_town,home_school,position,type,team_id,created_at,updated_at)
          VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9)returning id')
  end
  def add_rosters(roster)
    @conn.exec_prepared('add rosters data',[roster["first_name"],roster["last_name"],roster["home_town"],roster["home_school"],
          roster["position"],roster["type"],roster["team_id"],Time.now,Time.now])
    puts"add the new teamRoster the player with first_name #{roster["first_name"]} and last_name #{roster["last_name"]}  "
  end

  def find_roster_in_db?(roster)
    res=@conn.exec('SELECT * FROM people WHERE first_name = $1 AND last_name = $2',[roster["first_name"],roster["last_name"]])
    return res.cmdtuples>0
  end

  def disconnect_from_db
    @conn.close
  end

  def grab_API_data_and_add_to_db(aUrl)
    begin
      access_api_data(aUrl)
      connect_to_db
      aRosterList=get_list_of_rosters
      if !listOfRosters_isEmpty
        prepareInsertRoster
        aRosterList.each do|roster|
          if find_roster_in_db?(roster)
            puts "find the player has the first_name #{roster["first_name"]} and the last name #{roster["last_name"]} "
          else
            add_rosters(roster)
          end
        end
      else
        puts "the return array from the data source is empty"
      end
    rescue Exception=>e
      puts e.message
      puts e.backtrace.inspect
    ensure
      disconnect_from_db
    end
  end


end


