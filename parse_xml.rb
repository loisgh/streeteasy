require_relative 'listing'
require 'nokogiri'
require 'pp'

class ParseXML

  attr_accessor :agent_xml, :agent_emails, :listings, :size, :ratings, :agents

  def initialize(file_string_in)
    @agent_xml = Nokogiri::XML(File.open(file_string_in)) { |config| config.noblanks }
  end

  def get_all_agents_and_listings
    @agent_names = @agent_xml.xpath("//agents//agents//name")
    create_agents_array
    @agents = fill_out_agents
  end

  def create_agents_array
    @agents = Array.new
  end

  def fill_out_agents
    agent_names = @agent_xml.xpath("//agents//agents//name")
    @agent_emails = @agent_xml.xpath("//agents//agents//email")

    @agent_emails.each_with_index do |email, idx|
      agent = Agent.new
      agent.name = agent_names[idx].text
      agent.listings = fill_out_listings(email.text)
      agent.ratings = get_ratings(email)
      @agents.push agent
    end
    @agents
  end

  def fill_out_listings(email)
    listings = Array.new
    price_array = @agent_xml.xpath("//element[email = '#{email}']//listings[type = 'sale']//price").map(&:text).map(&:to_f)
    response_array = @agent_xml.xpath("//element[email = '#{email}']//listings[type = 'sale']//leads//averageResponseTime").map(&:text).map(&:to_i)
    price_array.each_with_index do |price,idx|
      listing = Listing.new(price, response_array[idx])
      listings.push listing
    end
    listings
  end

  def get_ratings(email)
    @agent_xml.xpath("//element[email = '#{email}']/ratings//rating").map(&:text).map(&:to_i)
  end

end