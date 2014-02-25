class Player
  attr_accessor :x, :y, :alive
  def initialize
    # position
    start!
    @gravity  = -0.25
    @hop      = 7.5
    # sounds
    @sound    = Sound.new "hop.mp3"
    @gameover = Sound.new "gameover.mp3"
    # images
    @rise = Image.new "rubyguy-rise.png"
    @fall = Image.new "rubyguy-fall.png"
    @dead = Image.new "rubyguy-dead.png"
  end
  def hop
    if @alive
      @sound.play
      @velocity += @hop
    end
  end
  def start!
    @x = Rubyhop.width / 3
    @y = Rubyhop.height / 2
    @velocity = 0.0
    @alive = true
  end
  def die!
    if @alive
      # Set velocity to one last hop
      @velocity = 5.0
      @gameover.play
      @alive = false
    end
  end
  def update
    @velocity += @gravity
    @y -= @velocity
    if @alive && (@y < 32 || @y > Rubyhop.height - 32)
      die!
    end
  end
  def offscreen?
    @y > 1000
  end
  def draw
    image.draw @x - 32, @y - 32, 1000 - @x
  end
  def image
    if @alive
      if @velocity >= 0
        @rise
      else
        @fall
      end
    else
      @dead
    end
  end
end
