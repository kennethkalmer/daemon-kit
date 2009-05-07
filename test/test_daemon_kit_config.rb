require File.join(File.dirname(__FILE__), "test_helper")

class TestDaemonKitConfig < Test::Unit::TestCase

  def test_initialize_with_env_hash
    data = {
      'test' => {
        'foo' => 'bar'
      }
    }

    config = DaemonKit::Config.new( data )

    assert_equal config['foo'], 'bar'
    assert_equal config.foo, 'bar'
  end

  def test_initialize_without_env_hash
    data = {
      'foo' => 'bar'
    }

    config = DaemonKit::Config.new( data )

    assert_equal config['foo'], 'bar'
    assert_equal config.foo, 'bar'
  end
end
