class SimcityClient
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  def initialize(websocket)
    info "Streaming structures to client"
    @socket = websocket
    subscribe('map', :notify_map)
  end

  def notify_map(topic, map)
    @socket << JSON.generate(map)
  rescue Reel::SocketError
    info "Simcity client disconnected"
    terminate
  end
end
