class Hoop
  attr_accessor :x, :y, :active
  def initialize
    @hoop  = Rubyhop.image "hoop.png"
    # center of screen
    @x = @y = 0
    @active = true
  end
  def miss player
    if (@x - player.x).abs < 12 &&
       (@y - player.y).abs > 72
       # the player missed the hoop
       return true
    end
    false
  end
  def update movement
    @x -= movement
  end
  def draw
    @hoop.draw @x - 66, @y - 98, 1000 - @x
  end
end
