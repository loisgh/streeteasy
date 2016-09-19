require_relative 'parse_json'
require_relative 'parse_xml'
require_relative 'agent'
require_relative 'listing'

class RunRankings

  def self.run(infile)

    extension = infile.split(".").last

    case extension
      when "json"
        parser = ParseJson.new(infile)
        json_out = parser.get_all_agents_and_listings
      when "xml"
        parser = ParseXML.new(infile)
        xml_out = parser.get_all_agents_and_listings
        puts "hello"
    end
  end

#  run('/Users/loisgh/Documents/rails_projects/ruby_scripts/StreetEasy/streeteasy.json')
  run('/Users/loisgh/Documents/rails_projects/ruby_scripts/StreetEasy/streeteasy.xml')

end