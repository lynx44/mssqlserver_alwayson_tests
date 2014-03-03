require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')
require_relative('../../../../cookbooks/mssqlserver_alwayson/libraries/sql_server_service')
require_relative('../template_context')

describe 'mssqlserver_alwayson_tests::hadr_endpoint_create_provider' do
  include_context 'templates'

  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_alwayson_hadr_endpoint']) do |node|
      node.set['nodes'] = [{ 'hostname' => 'host1', 'domain' => 'domain1' }]
      node.set['description'] = 'test'
    end
  end
  let(:converge) { chef_run.converge(described_recipe) }
  let(:node) { chef_run.node }

  before do
    @script_path = "#{Chef::Config[:file_cache_path]}\\CreateHadrEndpoint.sql"
    stub_sql_service(true, 'LocalSystem')
  end

  it 'passes expected attributes' do
    expect(converge).to create_mssqlserver_alwayson_hadr_endpoint(node['description']).with({
        :nodes => node['nodes']
      })
  end

  it 'grants connect to service logon name' do
    expected_username = 'domain\username'
    escaped_username = expected_username.sub("\\", "[\\\\\\]")
    stub_sql_service(false, expected_username)
    expect(converge).to render_file(@script_path).with_content(
      /GRANT CONNECT ON ENDPOINT::\[Hadr_endpoint\] TO \[#{escaped_username}\]/)
  end

  it 'grants connect to server accounts when logon is a system account' do
    hostname = 'host1'
    domain = 'domain1.something.com'
    node.set['nodes'] = [{ 'hostname' => hostname, 'domain' => domain}, { 'hostname' => 'host2', 'domain' => domain}]
    stub_sql_service(true, 'LocalSystem')
    expect(converge).to render_file(@script_path).with_content(
      /GRANT CONNECT ON ENDPOINT::\[Hadr_endpoint\] TO \[DOMAIN1[\\]#{hostname}\$\]/)
  end

  it 'does not grant connect to server accounts when logon is not a system account' do
    hostname = 'host1'
    domain = 'domain1.something.com'
    node.set['nodes'] = [{ 'hostname' => hostname, 'domain' => domain}, { 'hostname' => 'host2', 'domain' => domain}]
    stub_sql_service(false, 'domain\someone')
    expect(converge).to_not render_file(@script_path).with_content(
      /GRANT CONNECT ON ENDPOINT::\[Hadr_endpoint\] TO \[DOMAIN1[\\]#{hostname}\$\]/)
  end

  def stub_sql_service(is_system, logon_username)
    service = double()
    service.stub(:uses_system_account).and_return(is_system)
    service.stub(:logon_username).and_return(logon_username)
    AlwaysOn::SqlServerService.stub(:new).and_return(service)
  end
end
