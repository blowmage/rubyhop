require "minitest/autorun"
require "rubyhop"

class TestRubyhop < MiniTest::Test
  def test_sanity
    flunk "write tests or I will kneecap you"
  end
end

class TestLevel < MiniTest::Test

  def setup
    @callbacks = {quit: 0, fail: 0, continue: 0}
    @level = Level.new
    @level.on_quit { @callbacks[:quit] += 1 }
    @level.on_fail { @callbacks[:fail] += 1 }
    @level.on_continue { @callbacks[:continue] += 1 }
  end

  def test_fail
    assert_equal 0, @callbacks[:fail]
    @level.fail!
    assert_equal 1, @callbacks[:fail]
    @level.fail!
    @level.fail!
    assert_equal 3, @callbacks[:fail]
  end

  def test_quit
    assert_equal 0, @callbacks[:quit]
    @level.quit!
    assert_equal 1, @callbacks[:quit]
    @level.quit!
    @level.quit!
    assert_equal 3, @callbacks[:quit]
  end

  def test_continue
    assert_equal 0, @callbacks[:continue]
    @level.continue!
    assert_equal 1, @callbacks[:continue]
    @level.continue!
    @level.continue!
    assert_equal 3, @callbacks[:continue]
  end

  def test_raises
    assert_raises RuntimeError do
      @level.start!
    end
    assert_raises RuntimeError do
      @level.update
    end
    assert_raises RuntimeError do
      @level.draw
    end
  end
end

class TestPlayer < MiniTest::Test

  def setup
    @player = Player.new
  end

  def test_initialization
    assert_equal 266, @player.x
    assert_equal 300, @player.y
    assert_equal true, @player.alive
    assert_equal 'rubyguy-rise.png', @player.image.filename
  end

  def test_hop
    @player.hop
    @player.update
    assert_equal 266, @player.x
    assert_equal 292.75, @player.y
  end

  def test_gravity
    3.times do
      @player.update
    end
    assert_equal 'rubyguy-fall.png', @player.image.filename
  end

  def test_die_bang
    @player.die!
    assert_equal false, @player.alive
    assert_equal 'rubyguy-dead.png', @player.image.filename
  end

  def test_offscreen_eh
    assert_equal false, @player.offscreen?
    140.times do
      @player.update
    end
    assert_equal true, @player.offscreen?
  end
end

class TestHoop < MiniTest::Test

  def setup
    @hoop = Hoop.new
  end

  def test_initialize
    assert_equal 0, @hoop.x
    assert_equal 0, @hoop.y
    assert_equal true, @hoop.active
  end

  def test_update
    @hoop.update 10
    assert_equal -10, @hoop.x
    assert_equal 0, @hoop.y
  end

end
