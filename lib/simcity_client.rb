class SimcityClient
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  def initialize(websocket)
    info "Streaming structures to client"
    @socket = websocket
    reader = Reader.new(@socket)
    reader.read!
    subscribe('map', :notify_map)
  end

  def notify_map(topic, map)
    @socket << JSON.generate(map)
  rescue Reel::SocketError
    info "Simcity client disconnected"
    terminate
  end

  class Reader
    include Celluloid
    include Celluloid::Logger
    include Celluloid::Notifications
    def initialize(socket)
      @socket = socket
    end

    def read
      every(1) do
        message = @socket.read
        handle_message(message)
      end
    end

    def handle_message(data)
      data = JSON.parse(data)
      publish 'incoming_message', data
    end
  end
end
