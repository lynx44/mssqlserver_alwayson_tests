require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_alwayson::drop_group' do
  let(:chef_run) { ChefSpec::Runner.new }
  let(:converge) { chef_run.converge(described_recipe) }
  let(:node) { chef_run.node }

  it 'drops group' do
    node.set['mssqlserver']['alwayson']['name'] = 'group name'
    expect(converge).to destroy_mssqlserver_alwayson_group(node['mssqlserver']['alwayson']['name'])
  end
end
