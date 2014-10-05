require 'heroics'
require 'pp'

# Ruby HTTP client for the Heroku API.
module PlatformAPI
end

require 'platform-api/client'
require 'platform-api/version'

class Dyno
  DEFAULT_COUNT='1'
  DEFAULT_SIZE='1X'

  attr_reader :process, :count, :size

  # Initialize an Dyno or partial Dyno topology; ex (1 web, 3 Workers)
  #
  # @param [Dyno] class, [Web],[Worker]
  # @param [count] of this/these Dynos to be set
  # @param [size] of this/these Dynos to be set
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
  # Scales the given Heroku application to supplied topology.
  #
  # @param [Dyno] class, [Web],[Worker]
  # @param [app_name] of this/these Dynos to be set
  # @param [topology] of this/these Dynos to be set
  # @return Current state of topology
  def self.scale(app_name, topology)
    heroku = PlatformAPI.connect_oauth ENV['HEROKU_TOKEN']
    params = { updates: topology.collect {|t| t.to_p } }
    heroku.formation.batch_update( app_name, params )
    self.current(app_name)
  end

  def self.current(app_name)
    heroku = PlatformAPI.connect_oauth ENV['HEROKU_TOKEN']
    response = heroku.dyno.list(app_name)
    self.agg(response.collect { |d| Dyno.new self.from_type(d['type']), 1, d['size'] })
  end

  private

  def self.from_type(t)
    case t
    when 'web'; Web
    when 'worker'; Worker
    else raise "No such dyno type #{t}"; end
  end

  def self.agg(dynos)
    [ 
      Dyno.new(Web, dynos.inject(0) {|sum, d| d.process == 'web' ? d.count : 0 }, '1X'),
      Dyno.new(Web, dynos.inject(0) {|sum, d| d.process == 'web' ? d.count : 0 }, '2X'),
      Dyno.new(Web, dynos.inject(0) {|sum, d| d.process == 'worker' ? d.count : 0 }, '1X'),
      Dyno.new(Web, dynos.inject(0) {|sum, d| d.process == 'worker' ? d.count : 0 }, '2X')
    ].select {|d| d.count > 0}
  end
end

class Worker < Dyno; end
class Web < Dyno;    end
