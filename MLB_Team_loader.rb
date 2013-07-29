require "rexml/document"
include REXML
require 'pg'
require 'open-uri'
class MLB_TeamDataLoader
#def open_file(source_file_name)
#      source=File.open(source_file_name)
#      @doc = REXML::Document.new source
#      source.close
#  end
  def access_api_data(api_Url)
    @api_Url=api_Url
    @contents=open(@api_Url)
    puts "the status of the connetion is #{@contents.status}"
  end

  def get_list_of_teams
    @listOfTeams=[]
    @doc = REXML::Document.new @contents
    @doc.elements.each("teams/team") do |team|
      theTeam={}
      theTeam["id"]= team.attributes['id']
      theTeam["name"]=team.attributes['market']+" "+team.attributes['name']
      theTeam["short_name"]=team.attributes['name']
      theTeam["abbr"]=team.attributes['abbr']
      theTeam["league"]=team.attributes['league']
      theTeam["division"]=team.attributes['division']
      theTeam["venue"]=team.attributes['venue']
      @listOfTeams<<theTeam
    end
    return @listOfTeams
  end

  def listOfTeams_isEmpty
     @listOfTeams.empty?
  end

  def connect_to_db
    @conn = PG.connect("localhost", 5432, '', '', "fanzo_site_development", "fanzo_site", "fanzo_site")
  end

  def prepareInsertTeam
    @conn.prepare('add teams data','INSERT INTO teams(name,sport_id,league_id,location_id,
          created_at,updated_at,short_name,espn_team_name_id) VALUES($1,$2,$3,$4,$5,$6,$7,$8)returning id')
  end

  def add_teams(team)
    @conn.exec_prepared('add teams data',[team["name"],1,2,4,Time.now,Time.now,team["short_name"],team["id"]])
    puts"add the new team #{team["name"]} #{team["short_name"]} #{team["id"]}   "
  end

  def mapIdToFanzoId(team)
    res=@conn.exec("select id from teams where short_name ='"+team["short_name"]+"'")
    res.getvalue( 0, 0 ).to_i
  end

  def find_team_in_db?(team)
  #res= @conn.exec("SELECT * FROM teams WHERE short_name='"+team["short_name"]+"'")
  #return res.cmdtuples>0
    (mapIdToFanzoId(team))>=0
  end


  def disconnect_from_db
    @conn.close
  end

  def grab_API_data_and_add_to_db(aUrl)
    begin
      access_api_data(aUrl)
        aTeamList=get_list_of_teams
        if !listOfTeams_isEmpty
          connect_to_db
          prepareInsertTeam
          aTeamList.each do|team|
              if find_team_in_db?(team)
                theId=mapIdToFanzoId(team)
                puts "find the team has the  id #{theId}"
              else
                add_teams(team)
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







