class SimcityServer
  include Celluloid
  include Celluloid::Notifications
  include Simcity

  def initialize
    @map = Map.new(10, 10)
    # Put a power plant at the top left
    @map.cell_at(Map::Point.new(0, 2)) << PowerPlant.new(@map)
    @map.cell_at(Map::Point.new(0,1)) << Structure::Road.new(@map)
    @map.cell_at(Map::Point.new(1,1)) << Structure::Road.new(@map)
    @map.cell_at(Map::Point.new(2,1)) << Structure::Road.new(@map)
    subscribe('incoming_message', :handle_incoming_data)
    run!
  end

  def run
    every(1) do
      # render every object in every map cell
      objects = []
      @map.grid.each do |row|
        row.each do |cell|
          cell.each do |o|
            objects << object_for(o, cell)
          end
        end
      end
      STDOUT.puts objects.inspect
      publish 'map', objects
      @map.tick
    end
  end

  def handle_incoming_data(topic, data)
    klass = get_class_for(data["type"])
    @map.cell_at(Map::Point.new(data["x"], data["y"])) << klass.new(@map)
  end

  protected
  def object_for(o, cell)
    object = { id: o.object_id, x: cell.point.x, y: cell.point.y, type: html_class(o.class) }
    if o.respond_to?(:powered?)
      object[:state] = o.powered? ? 'powered' : 'unpowered'
    end
    object
  end

  def get_class_for(klass_string)
    {
      'power-plant' => PowerPlant,
      'road' => Structure::Road,
      'house' => House
    }[klass_string]
  end

  def html_class(klass)
    klass.to_s.downcase.gsub(/::/, '-').gsub(/^simcity-/, '')
  end
end
