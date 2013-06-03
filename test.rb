MLB_team_file='MLBteam.txt'
file='schedule.txt'
output_file=File.new('schedules.txt','w')
schedule={}
File.open(file).each_line do|line|
   home_team_id=line.split[3]
   visit_team_id=line.split[7]
   schedule["schedule_time"]=line.split[9]
   File.open(MLB_team_file).each_line do|line|
     team_id=line.split[2]
     team_name=line.split[9]+" "+line.split[5]
     if home_team_id==team_id
       schedule["home_team"]=team_name
     end
     if visit_team_id==team_id
       schedule["visit_team"]=team_name
     end

   end

   output_file.puts "Home team: #{schedule["home_team"]}  Visit team:#{schedule["visit_team"]}   Schedule time:#{schedule["schedule_time"]} "
end
output_file.close



