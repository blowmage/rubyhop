require "gosu"

def get_my_file file
  "#{File.dirname(__FILE__)}/#{file}"
end

class Player
  attr_accessor :x, :y, :alive
  def initialize window
    @window = window
    @alive  = true
    # position
    @x = window.width/2
    @y = window.height/2
    @velocity = 0.0
    @gravity  = -0.25
    @hop      = 7.5
    # sounds
    @sound    = Gosu::Sample.new @window, get_my_file("hop.mp3")
    @gameover = Gosu::Sample.new @window, get_my_file("gameover.mp3")
    # images
    @rise = Gosu::Image.new window, get_my_file("rubyguy-rise.png")
    @fall = Gosu::Image.new window, get_my_file("rubyguy-fall.png")
    @dead = Gosu::Image.new window, get_my_file("rubyguy-dead.png")
  end
  def hop
    if @alive
      @sound.play
      @velocity += @hop
    end
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
    if @alive && (@y < 32 || @y > @window.height - 32)

    end
    if @y > 5000
      # kick out to loading screen to try again?
      @window.close
    end
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

class Hoop
  attr_accessor :x, :y, :active
  def initialize window
    @window   = window
    @hoop  = Gosu::Image.new window, get_my_file("hoop.png")
    # center of screen
    @movement = 2
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
  def update
    @movement += 0.003
    @x -= @movement
  end
  def draw
    @hoop.draw @x - 66, @y - 98, 1000 - @x
  end
end

class RubyhopGame < Gosu::Window
  VERSION = "1.1.0"
  def initialize width=800, height=600, fullscreen=false
    super
    self.caption = "Ruby Hop"
    @music = Gosu::Song.new self, get_my_file("music.mp3")
    @music.play true
    @background = Gosu::Image.new self, get_my_file("background.png")
    @player = Player.new self
    @hoops = 6.times.map { Hoop.new self }
    init_hoops!
    @score = 0
    @font = Gosu::Font.new self, Gosu::default_font_name, 20
  end

  def init_hoops!
    @hoops.each do |hoop|
      hoop.y = 325
    end
    hoop_start = 600
    @hoops.each do |hoop|
      reset_hoop! hoop
      hoop_start += 200
      hoop.x = hoop_start
    end
  end

  def reset_hoop! hoop
    idx = @hoops.index hoop
    prev = @hoops[idx - 1]
    new_y = ((prev.y-150..prev.y+125).to_a & (150..500).to_a).sample
    hoop.x += 1200
    hoop.y = new_y
    hoop.active = true
  end

  def button_down id
    close       if id == Gosu::KbEscape
    @player.hop if id == Gosu::KbSpace
  end

  def update
    @player.update
    @hoops.each do |hoop|
      hoop.update
      reset_hoop!(hoop) if hoop.x < -200
      @player.die! if hoop.miss @player
      # increase score and flag as inactive
      if hoop.active && @player.alive && hoop.x < @player.x
        @score += 1
        hoop.active = false
      end
    end
  end

  def draw
    @background.draw 0, 0, 0
    @player.draw
    @hoops.each &:draw
    @font.draw "Score: #{@score}", 700, 10, 1, 1.0, 1.0, Gosu::Color::RED
  end
end
