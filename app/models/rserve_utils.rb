class RserveUtils < ActiveRecord::Base
  require 'rserve'

  def self.get_connection()
    return Rserve::Connection.new()
  end
end
