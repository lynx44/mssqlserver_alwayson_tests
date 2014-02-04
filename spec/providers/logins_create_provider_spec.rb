require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')
require_relative('../template_context')

describe 'mssqlserver_alwayson_tests::logins_create_provider' do
  include_context 'templates'

  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_alwayson_logins']) do |node|
      node.set['nodes'] = [{ 'hostname' => 'host1', 'domain' => 'domain1' }]
    end
  end
  let(:converge) { chef_run.converge(described_recipe) }
  let(:node) { chef_run.node }

  it 'passes syntax checks' do
    expect(converge)
  end

  before do
    @script_path = "#{Chef::Config[:file_cache_path]}\\Logins.sql"
  end

  it 'renders login script to specify other nodes when sql service user is not specified' do
    node.set['service_username'] = nil
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
    account = 'custom_domain\user'
    node.set['service_username'] = account

    expect(converge).to_not run_mssqlserver_sql_command('create server logins')
  end
end
