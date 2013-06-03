require 'open-uri'
require "rexml/document"
include REXML
class DataLoader





end

#contents=open('http://api.sportsdatallc.org/mlb-t3/schedule/2013.xml?api_key=d568qhj3huppbdds2pauuqya')
#status=contents.status
#puts status
#f=File.new('event.txt','w')
#contents.each do |content|
#    f.write(content)
#end
#f.close

source=File.open('event.txt')
doc = REXML::Document.new source
source.close


listOfEvents=[]
doc.elements.each("calendars/event") do |event|
        TheEvent={}
        TheEvent["homeTeam"]= event.attributes['home']
        TheEvent["visitTeam"]=event.attributes['visitor']
        TheEvent["eventSchedule"]=event.elements['scheduled_start'].text
        listOfEvents<<TheEvent
end

puts"complete the array"
output_file=File.new('schedule.txt','w')
listOfEvents.each do |event|
  output_file.puts "the home team: #{event["homeTeam"]} the visitor team: #{event["visitTeam"]} Time: #{event["eventSchedule"]}"
end

output_file.close

#--------------------------------------------------------------------------
#kittens = open('http://placekitten.com/200/300')

#f = File.open('kittens.jpg', 'w')
#kittens.each do |kitten|
#  f.write(kitten)
#end

#f.close


#require "rexml/document"

#file = File.open("pets.txt")
#doc = REXML::Document.new file
#file.close

#doc.elements.each("pets/pet/name") do |element|
#  puts element
#end

#have a team table
#have a event table