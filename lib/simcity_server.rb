class SimcityServer
  include Celluloid
  include Celluloid::Notifications
  include Simcity

  def initialize
    @session = SimcityApp::Session.new(20, 20)
    subscribe('incoming_message', :handle_incoming_data)
    run!
  end

  def run
    every(0.1) do
      # render every object in every map cell
      objects = []
      @session.map.grid.each do |row|
        row.each do |cell|
          cell.each_pair do |type, array|
            array.each do |o|
              objects << object_for(o, cell)
            end
          end
        end
      end
      STDOUT.puts objects.count
      publish 'map', objects
      publish 'cash', @session.cash.to_s('F')
      @session.tick
    end
  end

  def handle_incoming_data(topic, data)
    STDOUT.puts data.inspect
    point = Map::Point.new(data["x"], data["y"])
    case data['action']
    when 'add-object'
      klass = get_class_for(data["type"])
      @session.insert_object(point, klass)
    when 'remove-object'
      cell.clear
      @session.clear
    end
  end

  protected
  def object_for(o, cell)
    object = { id: o.object_id, x: cell.point.x, y: cell.point.y, type: html_class(o.class) }
    if o.respond_to?(:powered?)
      object[:powered] = o.powered?
    end
    if o.respond_to?(:watered?)
      object[:watered] = o.watered?
    end
    object
  end

  def get_class_for(klass_string)
    {
      'powerplant' => PowerPlant,
      'road' => Structure::Road,
      'house' => House,
      'waterpump' => WaterPump,
      'garbagedump' => GarbageDump
    }[klass_string]
  end

  def html_class(klass)
    klass.to_s.downcase.gsub(/::/, '-').gsub(/^simcity-/, '')
  end
end
