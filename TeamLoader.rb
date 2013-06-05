require "rexml/document"
include REXML
require 'pg'

class MLB_TeamDataLoader

  @@listOfTeams=[]

  def resultlistOfTeams
    @@listOfTeams
  end


  def open_file(source_file_name)
      source=File.open(source_file_name)
      @doc = REXML::Document.new source
      source.close
  end

  def get_list_of_teams

    @doc.elements.each("teams/team") do |team|
      @TheTeam={}
      @TheTeam["id"]= team.attributes['id']
      @TheTeam["name"]=team.attributes['name']
      @TheTeam["abbr"]=team.attributes['abbr']
      @TheTeam["market"]=team.attributes['market']
      @TheTeam["league"]=team.attributes['league']
      @TheTeam["division"]=team.attributes['division']
      @TheTeam["venue"]=team.attributes['venue']
      @@listOfTeams<<@TheTeam
    end

  end

  def listOfTeams_isEmpty
     @@listOfTeams.empty?
  end

  def connect_to_db
    @conn = PG.connect("localhost", 5432, '', '', "SportsData", "fanzo_site", "fanzo_site")
  end

  def prepareInsertTeam
    @conn.prepare('add teams data','INSERT INTO mlb_teams(sports_data_team_id,team_name,team_abbr,market,league,
          division,venue) VALUES($1,$2,$3,$4,$5,$6,$7)')
  end

  def add_teams(team)
    @conn.exec_prepared('add teams data',[team["id"],team["name"],team["abbr"],team["market"],team["league"],team["division"],team["venue"]])
    puts"add the new team #{team["id"]} #{team["name"]} #{team["abbr"]} #{team["market"]} #{team["league"]}
        #{team["division"]} #{team["venue"]}  "
  end

  def find_team_in_db(team)
    @conn.exec("SELECT * FROM mlb_teams WHERE sports_data_team_id='"+team["id"]+"'")

  end

  def disconnect_from_db
    @conn.close
  end

  def add_to_db
    if !listOfTeams_isEmpty
      connect_to_db
      prepareInsertTeam
      @@listOfTeams.each do|team|
          if find_team_in_db(team).cmdtuples>0
            puts "find the team has the sports_data_team_id #{team["id"]}"
          else
            add_teams(team)
          end
      end
    else
      puts "the listOfTeams array is empty"
    end
    disconnect_from_db
  end

end





