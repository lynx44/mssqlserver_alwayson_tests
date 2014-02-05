require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_alwayson::default' do
  let(:chef_run) { ChefSpec::Runner.new }
  let(:converge) { chef_run.converge(described_recipe) }
  let(:node) { chef_run.node }

  before do
    Chef::Search::Query.any_instance.stub(:search).and_return([ [ {'hostname' => 'test'} ] ])
  end

  it 'passes syntax checks' do
    expect(converge)
  end

  it 'ignores endpoint configuration if not present' do
    node.set['mssqlserver']['alwayson']['endpoint']['name'] = nil
    expect(converge).to_not create_mssqlserver_alwayson_group_endpoint(nil)
  end

  it 'creates endpoint configuration if present' do
    expected = 'endpoint_name'
    node.set['mssqlserver']['alwayson']['endpoint']['name'] = expected
    expect(converge).to create_mssqlserver_alwayson_group_endpoint(expected)
  end
end