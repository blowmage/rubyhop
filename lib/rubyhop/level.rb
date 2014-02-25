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


class HopLevel < Level
  attr_accessor :movement, :score
  def initialize
    super
    @music = Song.new "music.mp3"
    @music.play true
    @player = Player.new
    @hoops = 6.times.map { Hoop.new }
    init_hoops!
    @font = Gosu::Font.new Rubyhop.instance, Gosu::default_font_name, 20
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
    @hoops.each(&:draw)
    @font.draw "Score: #{@score}", 700, 10, 1, 1.0, 1.0, Gosu::Color::RED
  end
end

class MessageLevel < Level
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
    quit!     if Rubyhop.button_down? Gosu::KbEscape
    continue! if ( Rubyhop.button_down?(Gosu::KbSpace)  ||
                   Rubyhop.button_down?(Gosu::KbReturn) ||
                   Rubyhop.button_down?(Gosu::KbEnter)  )
  end

  def draw
    c = Math.cos(Rubyhop.time*4)
    half_w = Rubyhop.width / 2
    half_h = Rubyhop.height / 2
    scale  = 1.0+c*0.1
    @rubyguy.draw_rot(half_w, half_h - 80, 1,
                      0, 0.5, 0.5, scale, scale)

    s = Math.sin Rubyhop.time
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
    "You scored #{Rubyhop.score}.\n" +
    "Your high score is #{Rubyhop.high_score}.\n" +
    "Press SPACE if you dare to continue...\n" +
    "Or ESCAPE if it is just too much for you."
  end
end
