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
    run!
  end

  def run
    every(1) do
      # render every object in every map cell
      objects = []
      @map.grid.each do |row|
        row.each do |cell|
          cell.each do |o|
            objects << { id: o.object_id, x: cell.point.x, y: cell.point.y, type: html_class(o.class) }
          end
        end
      end
      STDOUT.puts objects.inspect
      publish 'map', objects
      @map.tick
    end
  end

  def html_class(klass)
    klass.to_s.downcase.gsub(/::/, '-').gsub(/^simcity-/, '')
  end
end
