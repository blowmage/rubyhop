require "gosu"
require "singleton"
require "rubyhop/level"
require "rubyhop/player"
require "rubyhop/hoop"

def get_my_file file
  "#{File.dirname(__FILE__)}/rubyhop/assets/#{file}"
end

class Sound < Gosu::Sample
  def initialize filename
    super Rubyhop.instance, get_my_file(filename)
  end
end

class Song < Gosu::Song
  def initialize filename
    super Rubyhop.instance, get_my_file(filename)
  end
end

class Image < Gosu::Image
  attr_accessor :filename
  def initialize filename
    @filename = filename
    super Rubyhop.instance, get_my_file(filename)
  end

  def self.from_text message, font = Gosu::default_font_name, size = 24
    super Rubyhop.instance, message, font, size
  end
end

class Rubyhop < Gosu::Window
  VERSION = "1.4.0"

  include Singleton

  attr_reader :time, :sounds, :score, :high_score

  def self.image filename
    Image.new filename
  end

  def self.text_image message, font = Gosu::default_font_name, size = 24
    Image.from_text message, font, size
  end

  def self.song filename
    Song.new filename
  end

  def self.sound filename
    Sound.new filename
  end

  def self.score_font
    @@font ||= Gosu::Font.new Rubyhop.instance, Gosu::default_font_name, 20
  end

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
    @background = Rubyhop.image "background.png"

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
