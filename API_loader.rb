require 'open-uri'

class API_loader

    def initialize
      @api_Url=""
    end

    def access_api_data(api_Url)
      @api_Url=api_Url
      @contents=open(@api_Url)
      puts "the status of the connetion is #{@contents.status}"
    end

    def store_loaded_data(output_file_name)
      f=File.new(output_file_name,'w')
      @contents.each do |content|
        f.write(content)
      end
      f.close
      puts "data loading is completed"
    end
end


#mlb_team api_url= 'http://api.sportsdatallc.org/mlb-t3/teams/2013.xml?api_key=d568qhj3huppbdds2pauuqya'
#mlb_schedule api_url='http://api.sportsdatallc.org/mlb-t3/schedule/2013.xml?api_key=d568qhj3huppbdds2pauuqya'