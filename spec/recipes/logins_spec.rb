require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')
require_relative('../../../../cookbooks/mssqlserver_alwayson/libraries/sql_server_service')

describe 'mssqlserver_alwayson::logins' do
  let(:chef_run) { ChefSpec::Runner.new }
  let(:converge) { chef_run.converge(described_recipe) }

  before do
    Chef::Search::Query.any_instance.stub(:search).and_return([ [ {'hostname' => 'test'} ] ])
  end

  it 'does not blow up' do
    expect(converge)
  end

  it 'runs resource if system account' do
    stub_uses_system_account(true)

    expect(converge).to create_mssqlserver_alwayson_logins('create logins')
  end

  it 'does not run resource if non-system account' do
    stub_uses_system_account(false)

    expect(converge).to_not create_mssqlserver_alwayson_logins('create logins')
  end

  def stub_uses_system_account(is_system)
    service = double()
    service.stub(:uses_system_account).and_return(is_system)
    AlwaysOn::SqlServerService.stub(:new).and_return(service)
  end
end