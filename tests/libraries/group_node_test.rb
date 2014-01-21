require 'test/unit'
require "rspec/mocks/standalone"
require_relative('../../../mssqlserver_alwayson/libraries/GroupNode')

class TC_Host < Test::Unit::TestCase
  attr_accessor :host

  attr_accessor :group_node

  def setup
    RSpec::Mocks::setup(self)
  end

  def setup_group_node(struct = nil)
    struct ||= Hash.new
    struct['hostname'] ||= 'hostname'
    struct['domain'] ||= 'domain'
    @group_node = GroupNode.new(struct)
  end

  def test_when_mssqlserver_attribute_not_exists_port_is_5022
    self.setup_group_node()

    assert_equal(5022, @group_node.port)
  end

  def test_when_alwayson_attribute_not_exists_port_is_5022
    self.setup_group_node({'mssqlserver' => { }})

    assert_equal(5022, @group_node.port)
  end

  def test_when_port_attribute_not_exists_port_is_5022
    self.setup_group_node({'mssqlserver' => { 'alwayson' => { } }})

    assert_equal(5022, @group_node.port)
  end

  def test_when_port_attribute_set_returns_expected
    expectedPort = 3500
    self.setup_group_node({'mssqlserver' => { 'alwayson' => { 'port' => expectedPort} }})

    assert_equal(expectedPort, @group_node.port)
  end

  def test_when_failover_mode_not_exists_returns_automatic
    self.setup_group_node({'mssqlserver' => { 'alwayson' => { } }})

    assert_equal('automatic', @group_node.failover_mode)
  end

  def test_when_failover_mode_exists_returns_expected
    expected = 'manual'
    self.setup_group_node({'mssqlserver' => { 'alwayson' => { 'failover_mode' => expected} }})

    assert_equal(expected, @group_node.failover_mode)
  end

  def test_when_availability_mode_not_exists_returns_synchronous_commit
    self.setup_group_node({'mssqlserver' => { 'alwayson' => { } }})

    assert_equal('SYNCHRONOUS_COMMIT', @group_node.availability_mode)
  end

  def test_when_availability_mode_exists_returns_expected
    expected = 'ASYNCHRONOUS_COMMIT'
    self.setup_group_node({'mssqlserver' => { 'alwayson' => { 'availability_mode' => expected} }})

    assert_equal(expected, @group_node.availability_mode)
  end

  def test_when_backup_priority_not_exists_returns_50
    self.setup_group_node({'mssqlserver' => { 'alwayson' => { } }})

    assert_equal(50, @group_node.backup_priority)
  end

  def test_when_backup_priority_exists_returns_expected
    expected = 10
    self.setup_group_node({'mssqlserver' => { 'alwayson' => { 'backup_priority' => expected} }})

    assert_equal(expected, @group_node.backup_priority)
  end

  def test_when_allow_connections_not_exists_returns_all
    self.setup_group_node({'mssqlserver' => { 'alwayson' => { } }})

    assert_equal('ALL', @group_node.allow_connections)
  end

  def test_when_allow_connections_exists_returns_expected
    expected = 10
    self.setup_group_node({'mssqlserver' => { 'alwayson' => { 'allow_connections' => expected} }})

    assert_equal(expected, @group_node.allow_connections)
  end
end