require 'heroics'

# Ruby HTTP client for the Heroku API.
module PlatformAPI
end

require 'platform-api/client'
require 'platform-api/version'


class Dyno
  DEFAULT_COUNT='1'
  DEFAULT_SIZE='1X'

  # Initialize an Dyno or partial Dyno topology; ex (1 web, 3 Workers)
  #
  # @param [Dyno] class, [Web],[Worker]
  # @param Number of this/these Dynos to be set
  # @param Size of this/these Dynos to be set
  # @return [Dyno] A type of Dyno with all the info needed to modify 
  #     given apps topology.
  def initialize(process, count=DEFAULT_COUNT, size=DEFAULT_SIZE)
    @process = process.to_s.downcase
    @count = count
    @size = size
  end
  
  def to_p
    {process: @process, quantity: @count, size: @size}
  end
end

class Topology
  def self.scale(app, topology)
    heroku = PlatformAPI.connect_oauth ENV['HEROKU_TOKEN']
    params = { updates: topology.collect {|t| t.to_p } }
    heroku.formation.batch_update( app, params )
  end
end

class Worker < Dyno; end
class Web < Dyno;    end
