require 'open-uri'
require "rexml/document"
include REXML
contents=open('http://api.sportsdatallc.org/mlb-t3/teams/2013.xml?api_key=d568qhj3huppbdds2pauuqya')
status=contents.status
puts status
f=File.new('MLBteam.txt','w')
contents.each do |content|
    f.write(content)
end
f.close

source=File.open('MLBteam.txt')
doc = REXML::Document.new source
source.close

listOfTeams=[]
doc.elements.each("teams/team") do |team|
  TheTeam={}
  TheTeam["id"]= team.attributes['id']
  TheTeam["name"]=team.attributes['name']
  TheTeam["abbr"]=team.attributes['abbr']
  TheTeam["market"]=team.attributes['market']
  TheTeam["league"]=team.attributes['league']
  listOfTeams<<TheTeam
end

puts"complete the array"
output_file=File.open('MLBteam.txt','w')
listOfTeams.each do |team|
  output_file.puts "team id: #{team["id"]} team name: #{team["name"]}   abbr: #{team["abbr"]}    market: #{team["market"]}    league: #{team["league"]}"
end

output_file.close
