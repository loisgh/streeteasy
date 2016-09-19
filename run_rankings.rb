require_relative 'parse_json'
require_relative 'parse_xml'
require_relative 'agent'
require_relative 'listing'

class RunRankings

  def self.run
    parser = ParseJson.new('/Users/loisgh/Documents/rails_projects/ruby_scripts/StreetEasy/streeteasy.json')
    agents = parser.get_all_agents_and_listings
    parserx = ParseXML.new('/Users/loisgh/Documents/rails_projects/ruby_scripts/StreetEasy/streeteasy.xml')
    agents = parserx.get_all_agents_and_listings
  end

  run

end