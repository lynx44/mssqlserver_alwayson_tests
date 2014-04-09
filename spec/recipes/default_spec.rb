require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')
require_relative('../../../mssqlserver_alwayson/libraries/GroupNodeCollection')

describe 'mssqlserver_alwayson::default' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['mssqlserver']['alwayson']['name'] = 'test group'
      node.set['mssqlserver']['alwayson']['endpoint']['name'] = 'test'
      node.set['mssqlserver']['alwayson']['name'] = 'availability_group'
    end
  end
  let(:converge) { chef_run.converge(described_recipe) }
  let(:node) { chef_run.node }
  let(:primary_nodes) do
    [{'hostname' => 'primary'}]
  end
  let(:secondary_nodes) do
    [{'hostname' => 'secondary'}]
  end
  let(:all_nodes) do
    primary_nodes.concat(secondary_nodes)
  end

  before do
    #Chef::Search::Query.any_instance.stub(:search).and_return([ [ {'hostname' => 'test'} ] ])
    collection = double()
    GroupNodeCollection.stub(:new).and_return(collection)
    collection.stub(:get_nodes).and_return(all_nodes)
    collection.stub(:get_nodes_except_current).and_return(secondary_nodes)
  end

  it 'passes syntax checks' do
    expect(converge)
  end

  it 'ignores endpoint configuration if not present' do
    node.set['mssqlserver']['alwayson']['endpoint']['name'] = nil
    expect(converge).to_not create_mssqlserver_alwayson_group_endpoint(node['mssqlserver']['alwayson']['endpoint']['name'])
  end

  it 'creates endpoint configuration if present' do
    expected = 'endpoint_name'
    node.set['mssqlserver']['alwayson']['endpoint']['name'] = expected
    expect(converge).to create_mssqlserver_alwayson_group_endpoint(expected)
  end

  it 'creates read-only routing list for all nodes' do
    all_nodes.each do |current_node|
      expect(converge).to update_mssqlserver_alwayson_read_only_routing_list("create readonly routing list for #{current_node['hostname']}").with({
          :availability_group => node['mssqlserver']['alwayson']['name'],
          :primary_node => current_node['hostname'],
          :routing_list => all_nodes.map { |n| n['hostname'] }.select { |hostname| hostname != current_node['hostname'] }.push(current_node['hostname']) #make this node the last node that will be redirected to using the routing list
      })
    end
  end
end