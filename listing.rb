class Listing

  attr_accessor :price, :average_response_time

  def initialize(price, average_response_time)
    @price = price
    @average_response_time = average_response_time
  end

end