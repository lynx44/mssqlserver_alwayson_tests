require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_alwayson::test' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
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
    @script_path = "#{Chef::Config[:file_cache_path]}\\Logins.sql".gsub("\\", '/')
    node.set['mssqlserver']['service_username'] = nil

    expect(converge).to render_file(@script_path).with_content(/IF NOT EXISTS/)
  end
end
