require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')
require_relative('../template_context')
require_relative('../../../../cookbooks/mssqlserver_alwayson/libraries/sql_server_service')

describe 'mssqlserver_alwayson_tests::logins_create_provider' do
  include_context 'templates'

  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_alwayson_logins']) do |node|
      node.set['nodes'] = [{ 'hostname' => 'host1', 'domain' => 'domain1' }]
    end
  end
  let(:converge) { chef_run.converge(described_recipe) }
  let(:node) { chef_run.node }

  before do
    @script_path = "#{Chef::Config[:file_cache_path]}\\Logins.sql"
    stub_sql_service(true, 'LocalSystem')
  end

  it 'passes syntax checks' do
    expect(converge)
  end

  it 'renders login script to specify other nodes when sql service user is system account' do
    stub_sql_service(true, 'LocalSystem')
    hostname = 'host1'
    domain = 'domain1'
    expectedHostname = hostname
    expectedDomain = domain.upcase
    node.set['nodes'] = [{ 'hostname' => hostname, 'domain' => domain}]

    expect(converge).to render_file(@script_path).with_content(
    /IF NOT EXISTS \(SELECT loginname FROM master.dbo.syslogins WHERE name = '#{expectedDomain}[\\]#{expectedHostname}[$]'\)[\s]+
    CREATE LOGIN \[#{expectedDomain}[\\]#{expectedHostname}[$]\] FROM WINDOWS[\s]*/)
  end

  it 'renders login script to specify other nodes when sql service user is not specified' do
    username = 'domain\someone'
    escaped_username = username.sub("\\", "[\\\\\\]")
    stub_sql_service(false, username)

    expect(converge).to render_file(@script_path).with_content(
      /IF NOT EXISTS \(SELECT loginname FROM master.dbo.syslogins WHERE name = '#{escaped_username}'\)[\s]+CREATE LOGIN \[#{escaped_username}\] FROM WINDOWS[\s]*/)
  end

  def stub_sql_service(is_system, logon_username)
    service = double()
    service.stub(:uses_system_account).and_return(is_system)
    service.stub(:logon_username).and_return(logon_username)
    AlwaysOn::SqlServerService.stub(:new).and_return(service)
  end
end
