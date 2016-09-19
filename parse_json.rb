require 'rubygems'
require 'json'
require 'jsonpath'
require_relative 'listing'

class ParseJson

  attr_accessor :agent_hash, :listings, :names, :ratings, :agents

  def initialize(file_string_in)
    file = File.read(file_string_in)
    @agent_hash = JSON.parse(file)
  end

  #TODO TYPE=SALE for listings
  def get_all_agents_and_listings
    listing_path = JsonPath.new('$..brokerage.agents[*][*].listings')
    name_path = JsonPath.new('$..brokerage.agents[*][*].name')
    ratings_path = JsonPath.new('$..brokerage.agents[*][*].ratings')
    @listings = listing_path.on(@agent_hash)
    @names = name_path.on(@agent_hash)
    @ratings = ratings_path.on(@agent_hash)
    create_agents_array
    @agents = fill_out_agents
  end

  def create_agents_array
    @agents = Array.new
  end

  def fill_out_agents
    @names.each_with_index do |name, idx|
      agent = Agent.new
      agent.name = name
      agent.listings = fill_out_listings(@listings[idx])
      agent.ratings = fill_out_ratings(@ratings[idx])
      @agents.push agent
    end
    @agents
  end

  def fill_out_listings(listings)
    listings_for_agent = Array.new
    listings.each do |listing|
      if listing["type"] == "sale"
        listing_for_agent = Listing.new(listing["price"], listing["leads"]["average_response_time"])
        listings_for_agent.push listing_for_agent
      end
    end
    listings_for_agent
  end

  def fill_out_ratings(ratings)
    agent_ratings = Array.new
    ratings.each do |rating|
      agent_ratings.push rating["rating"]
    end
    agent_ratings
  end

end