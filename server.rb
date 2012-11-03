require 'rubygems'
require 'bundler/setup'
require 'reel'
require 'json'
require 'simcity'

require_relative './lib/simcity_server'
require_relative './lib/simcity_client'

class WebServer < Reel::Server
  include Celluloid::Logger

  def initialize(host = "127.0.0.1", port = 1234)
    info "Simcity server starting on #{host}:#{port}"
    super(host, port, &method(:on_connection))
  end

  def on_connection(connection)
    while request = connection.request
      case request
      when Reel::Request
        route_request connection, request
      when Reel::WebSocket
        info "Received a WebSocket connection"
        route_websocket request
      end
    end
  end

  def route_request(connection, request)
    info "404 Not Found: #{request.path}"
    connection.respond :not_found, "Not found"
  end

  def route_websocket(socket)
    if socket.url == "/structures"
      SimcityClient.new(socket)
    else
      info "Received invalid WebSocket request for: #{socket.url}"
      socket.close
    end
  end
end

SimcityServer.supervise_as :simcity_server
WebServer.supervise_as :reel

sleep
