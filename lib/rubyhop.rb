require "gosu"

def get_my_file file
  "#{File.dirname(__FILE__)}/#{file}"
end

class Player
  attr_accessor :x, :y, :alive
  def initialize level
    @level = level
    @window = @level.window
    # position
    start!
    @gravity  = -0.25
    @hop      = 7.5
    # sounds
    @sound    = Gosu::Sample.new @window, get_my_file("hop.mp3")
    @gameover = Gosu::Sample.new @window, get_my_file("gameover.mp3")
    # images
    @rise = Gosu::Image.new @window, get_my_file("rubyguy-rise.png")
    @fall = Gosu::Image.new @window, get_my_file("rubyguy-fall.png")
    @dead = Gosu::Image.new @window, get_my_file("rubyguy-dead.png")
  end
  def hop
    if @alive
      @sound.play
      @velocity += @hop
    end
  end
  def start!
    @x = @window.width/2
    @y = @window.height/2
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
    if @alive && (@y < 32 || @y > @window.height - 32)
      die!
    end
    if @y > 1000
      # kick out to loading screen to try again?
      @level.fail!
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
  def initialize level
    @level = level
    @window   = @level.window
    @hoop  = Gosu::Image.new @window, get_my_file("hoop.png")
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
  def update
    @x -= @level.movement
  end
  def draw
    @hoop.draw @x - 66, @y - 98, 1000 - @x
  end
end

class HopLevel
  attr_accessor :window, :movement, :score
  def initialize window
    @window = window
    @window.caption = "Ruby Hop"
    @music = Gosu::Song.new @window, get_my_file("music.mp3")
    @music.play true
    @background = Gosu::Image.new @window, get_my_file("background.png")
    @player = Player.new self
    @hoops = 6.times.map { Hoop.new self }
    init_hoops!
    @font = Gosu::Font.new @window, Gosu::default_font_name, 20
    @movement = 2

    # Add callback holders
    @fail_callbacks = []
    @quit_callbacks = []
  end

  def on_fail &block
    @fail_callbacks << block
  end

  def on_quit &block
    @quit_callbacks << block
  end

  def start!
    @score = 0
    @movement = 2
    @player.start!
    init_hoops!
  end

  def fail!
    @fail_callbacks.each { |c| c.call }
  end

  def quit!
    @quit_callbacks.each { |c| c.call }
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
    quit!       if id == Gosu::KbEscape
    @player.hop if id == Gosu::KbSpace
  end

  def update
    @movement += 0.003
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

class FailLevel
  attr_accessor :window
  def initialize window
    @window = window
    @background = Gosu::Image.new @window, get_my_file("background.png")
    @rubyguy = Gosu::Image.new @window, get_my_file("rubyguy.png")

    create_image!

    # Add callback holders
    @continue_callbacks = []
    @quit_callbacks = []
  end

  def create_image!
    @msg = Gosu::Image.from_text @window,
                                "You scored #{@window.score}.\n" +
                                "Your high score is #{@window.high_score}.\n" +
                                "Press SPACE if you dare to continue...\n" +
                                "Or ESCAPE if it is just too much for you.",
                                Gosu::default_font_name, 24
    @msg_x = @window.width/2 - @msg.width/2
    @msg_y = @window.height * 2 / 3
  end

  def on_continue &block
    @continue_callbacks << block
  end

  def on_quit &block
    @quit_callbacks << block
  end

  def continue!
    @continue_callbacks.each { |c| c.call }
  end

  def quit!
    @quit_callbacks.each { |c| c.call }
  end

  def start!
    create_image!
  end

  def update
    quit!     if @window.button_down? Gosu::KbEscape
    continue! if ( @window.button_down?(Gosu::KbSpace)  ||
                   @window.button_down?(Gosu::KbReturn) ||
                   @window.button_down?(Gosu::KbEnter)  )
  end

  def draw
    @background.draw 0, 0, 0
    c = Math.cos(@window.time*4)
    @rubyguy.draw_rot(((@window.width)/2), ((@window.height)/2 - 80), 1, 0,
                      0.5, 0.5, 1.0+c*0.1, 1.0+c*0.1)
    s = Math.sin @window.time
    @msg.draw_rot( ((@window.width)/2 + (100*(s)).to_i),
                    ((@window.height)/2 + 160 + s*s*s.abs*50),
                    1, s*5, 0.5, 0.5,
                    1.0+(0.1*s*s*s.abs), 1.0+(0.1*s*s*s.abs),
                    Gosu::Color::RED )
  end
end

class RubyhopGame < Gosu::Window
  VERSION = "1.2.0"
  attr_reader :time, :sounds, :score, :high_score
  def initialize width=800, height=600, fullscreen=false
    super

    self.caption = 'Ruby Hop'

    # Scores
    @score = @high_score = 0

    # Levels
    @hop  = HopLevel.new self
    @fail = FailLevel.new self

    @hop.on_fail     { fail! }
    @hop.on_quit     { close }

    @fail.on_continue { play! }
    @fail.on_quit     { close }

    play!
  end

  def play!
    @level = @hop
    @level.start!
  end

  def fail!
    @score = @hop.score
    @high_score = @score if @score > @high_score
    @level = @fail
    @level.start!
  end

  def button_down id
    @level.button_down id if @level.respond_to? :button_down
  end

  def button_up id
    @level.button_up id if @level.respond_to? :button_up
  end

  def update
    @time = Time.now.to_f
    @level.update
  end

  def draw
    @level.draw
  end
end
