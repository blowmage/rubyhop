require "gosu"
require "singleton"

def get_my_file file
  "#{File.dirname(__FILE__)}/#{file}"
end

class Level
  def initialize
    # Add callback holders
    @continue_callbacks = []
    @quit_callbacks = []
    @fail_callbacks = []
  end

  def on_continue &block
    @continue_callbacks << block
  end

  def on_quit &block
    @quit_callbacks << block
  end

  def on_fail &block
    @fail_callbacks << block
  end

  def continue!
    @continue_callbacks.each { |c| c.call }
  end

  def quit!
    @quit_callbacks.each { |c| c.call }
  end

  def fail!
    @fail_callbacks.each { |c| c.call }
  end

  def start!
    raise "Must override"
  end

  def update
    raise "Must override"
  end

  def draw
    raise "Must override"
  end
end

class Sound < Gosu::Sample
  def initialize filename
    super RubyhopGame.instance, get_my_file(filename)
  end
end

class Song < Gosu::Song
  def initialize filename
    super RubyhopGame.instance, get_my_file(filename)
  end
end

class Image < Gosu::Image
  def initialize filename
    super RubyhopGame.instance, get_my_file(filename)
  end

  def self.from_text message
    super RubyhopGame.instance,
          message,
          Gosu::default_font_name, 24
  end
end

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
    @x = RubyhopGame.width / 3
    @y = RubyhopGame.height / 2
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
    if @alive && (@y < 32 || @y > RubyhopGame.height - 32)
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

class Hoop
  attr_accessor :x, :y, :active
  def initialize
    @hoop  = Image.new "hoop.png"
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

class HopLevel < Level
  attr_accessor :movement, :score
  def initialize
    super
    @music = Song.new "music.mp3"
    @music.play true
    @player = Player.new
    @hoops = 6.times.map { Hoop.new }
    init_hoops!
    @font = Gosu::Font.new RubyhopGame.instance, Gosu::default_font_name, 20
    @movement = 3
  end

  def start!
    @score = 0
    @movement = 3
    @player.start!
    init_hoops!
  end

  def init_hoops!
    @hoops.each do |hoop|
      hoop.y = 325
    end
    hoop_start = 400
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
    @movement += 0.0025
    @player.update
    if @player.offscreen?
      # kick out to loading screen to try again?
      fail!
    end
    @hoops.each do |hoop|
      hoop.update @movement
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
    @player.draw
    @hoops.each &:draw
    @font.draw "Score: #{@score}", 700, 10, 1, 1.0, 1.0, Gosu::Color::RED
  end
end

class MessageLevel < Level
  attr_accessor :message
  def initialize
    super
    @rubyguy = Image.new "rubyguy.png"

    create_image!
  end

  def message
    "This is a dumb message, you should override it"
  end

  def create_image!
    @msg = Image.from_text message
  end

  def start!
    create_image!
  end

  def update
    quit!     if RubyhopGame.button_down? Gosu::KbEscape
    continue! if ( RubyhopGame.button_down?(Gosu::KbSpace)  ||
                   RubyhopGame.button_down?(Gosu::KbReturn) ||
                   RubyhopGame.button_down?(Gosu::KbEnter)  )
  end

  def draw
    c = Math.cos(RubyhopGame.time*4)
    half_w = RubyhopGame.width / 2
    half_h = RubyhopGame.height / 2
    scale  = 1.0+c*0.1
    @rubyguy.draw_rot(half_w, half_h - 80, 1,
                      0, 0.5, 0.5, scale, scale)

    s = Math.sin RubyhopGame.time
    scale = 1.0+(0.1*s**3).abs
    @msg.draw_rot( (half_w + (100*(s)).to_i),
                   (half_h + 160 + (50*s**3).abs),
                   1, s*5, 0.5, 0.5, scale, scale,
                   Gosu::Color::RED )
  end
end

class TitleLevel < MessageLevel
  def message
    "Stay alive by hopping!\n" +
    "Press SPACE to hop!\n" +
    "Press ESCAPE to close."
  end
end

class FailLevel < MessageLevel
  def message
    "You scored #{RubyhopGame.score}.\n" +
    "Your high score is #{RubyhopGame.high_score}.\n" +
    "Press SPACE if you dare to continue...\n" +
    "Or ESCAPE if it is just too much for you."
  end
end

class RubyhopGame < Gosu::Window
  VERSION = "1.3.1"

  include Singleton

  attr_reader :time, :sounds, :score, :high_score

  def self.play!
    self.instance.setup.show
  end

  def self.method_missing method, *args
    self.instance.send(method, *args)
  end

  def initialize width=800, height=600, fullscreen=false
    super
  end

  def setup
    self.caption = "Ruby Hop - #{VERSION}"
    @background = Image.new "background.png"

    # Scores
    @score = @high_score = 0

    # Levels
    @title = TitleLevel.new
    @hop   = HopLevel.new
    @fail  = FailLevel.new

    @title.on_continue { play! }
    @title.on_quit     { close }

    @hop.on_fail       { fail! }
    @hop.on_quit       { close }

    @fail.on_continue  { play! }
    @fail.on_quit      { close }

    title!
    self
  end

  def title!
    @level = @title
    @level.start!
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
    @background.draw 0, 0, 0
    @level.draw
  end
end
