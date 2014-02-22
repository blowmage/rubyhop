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
