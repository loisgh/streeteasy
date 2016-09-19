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
      out = get_average_sale_price_response_time(@listings[idx])
      agent.average_sale_price = out[0]
      agent.response_time = out[1]
      agent.rating = fill_out_ratings(@ratings[idx])
      @agents.push agent
    end
    @agents
  end

  def get_average_sale_price_response_time(listings)
    out = Array.new
    average_sale_price = 0
    num_sales = 0
    average_response_time = Array.new
    listings.each do |listing|
      if listing["type"] == "sale"
        average_sale_price += listing["price"].to_i
        num_sales += 1
        average_response_time.push listing["leads"]["average_response_time"].to_i
      end
    end
    average_sale_price = average_sale_price/num_sales if num_sales > 0
    out.push average_sale_price, average_response_time.sort.last
  end

  def fill_out_ratings(ratings)
    agent_ratings = Array.new
    ratings.each do |rating|
      agent_ratings.push rating["rating"]
    end
    agent_ratings.sort.last
  end

end