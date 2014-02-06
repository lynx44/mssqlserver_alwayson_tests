require 'test/unit'
require "rspec/mocks/standalone"
require_relative('../../../mssqlserver_alwayson/libraries/sql_server_service')
require('chef')

class TestSqlServerService < Test::Unit::TestCase
  def setup
    RSpec::Mocks::setup(self)

  end

  def service
    @service ||= AlwaysOn::SqlServerService.new()
  end

  def setup_shell_out(args)
    mock = double()
    mock.stub(:run_command)
    mock.stub(:stdout).and_return(format_service_output(args))
    Chef::Mixlib::ShellOut.stub(:new).with('sc qc MSSQLSERVER').and_return(mock)
  end

  def format_service_output(args)
    service_start_name = args[:service_start_name] || 'LocalSystem'
    <<-EOH
        SERVICE_NAME: MSSQLSERVER
        TYPE               : 10  WIN32_OWN_PROCESS
        START_TYPE         : 2   AUTO_START
        ERROR_CONTROL      : 1   NORMAL
        BINARY_PATH_NAME   : "C:\\Program Files\\Microsoft SQL Server\\MSSQL10_50.MSSQLSERVER\\MSSQL\\Binn\\sqlservr.exe" -sMSSQLSERVER
        LOAD_ORDER_GROUP   :
        TAG                : 0
        DISPLAY_NAME       : SQL Server (MSSQLSERVER)
        DEPENDENCIES       :
        SERVICE_START_NAME : #{service_start_name}
    EOH
  end

  def test_logon_username
    username = 'domain\dude'
    setup_shell_out({ :service_start_name => username })

    assert_equal(username, service.logon_username)
  end

  def test_uses_system_account_returns_true_for_localsystem
    setup_shell_out({ :service_start_name => 'LocalSystem' })

    assert_true(service.uses_system_account)
  end

  def test_uses_system_account_returns_true_for_networkservice
    setup_shell_out({ :service_start_name => 'NT AUTHORITY\NetworkService' })

    assert_true(service.uses_system_account)
  end

  def test_uses_system_account_returns_true_for_mssqlserver
    setup_shell_out({ :service_start_name => 'NT Service\MSSQLSERVER' })

    assert_true(service.uses_system_account)
  end

  def test_uses_system_account_returns_false_when_custom
    setup_shell_out({ :service_start_name => 'domain\someone' })

    assert_false(service.uses_system_account)
  end

  def test_removes_line_endings
    expected = 'domain\someone'
    setup_shell_out({ :service_start_name => "#{expected} " })

    assert_equal(expected, service.logon_username)
  end
end