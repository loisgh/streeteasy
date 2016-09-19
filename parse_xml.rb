require_relative 'listing'
require 'nokogiri'
require 'active_support/all'
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
      agent.average_sale_price = avg_sale_price(email.text)
      agent.response_time = agent.average_sale_price > 0 ? response_time(email.text) : 0
      agent.rating = get_rating(email.text)
      @agents.push agent if agent.response_time > 0
    end
    @agents.sort_by! { |a| [-a.rating, a.response_time, -a.average_sale_price] }
  end

  def avg_sale_price(email)
    price_array = @agent_xml.xpath("//element[email = '#{email}']//listings[type = 'sale']//price").map(&:text).map(&:to_f)
    average__sale_price = price_array.length > 0 ? price_array.sum / price_array.length : 0
  end

  def response_time(email)
    @agent_xml.xpath("//element[email = '#{email}']//listings[type = 'sale']//leads//averageResponseTime").map(&:text).map(&:to_i).sort.first
  end

  def get_rating(email)
    @agent_xml.xpath("//element[email = '#{email}']/ratings//rating").map(&:text).map(&:to_i).sort.last
  end

end