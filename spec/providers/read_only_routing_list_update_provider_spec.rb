require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')
require_relative('../template_context')

describe 'mssqlserver_alwayson_tests::read_only_routing_list_update_provider' do
  include_context 'templates'
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_alwayson_read_only_routing_list']) do |node|
      node.set['description'] = 'default description'
      node.set['primary_node'] = 'server1'
      node.set['routing_list'] = ['server2', 'server1']
      node.set['availability_group'] = 'ag'
    end
  end

  let(:converge) do
    chef_run.converge(described_recipe)
  end

  let(:node) do
    chef_run.node
  end

  let(:script_path) do
    "#{Chef::Config[:file_cache_path]}\\ReadOnlyRoutingList.sql"
  end

  it 'passes expected values' do
    expect(converge).to update_mssqlserver_alwayson_read_only_routing_list(node['description']).with({
        :primary_node => node['primary_node'],
        :routing_list => node['routing_list'],
        :availability_group => node['availability_group']
    })
  end

  it 'creates script from template with expected values' do
    expect(converge).to render_file(script_path).with_content(
                            /ALTER\s*AVAILABILITY\s*GROUP\s*\[#{node['availability_group']}\]\s*MODIFY\s*REPLICA\s*ON\s*N'#{node['primary_node']}'\s*WITH\s*\(PRIMARY_ROLE\s*\(READ_ONLY_ROUTING_LIST=\(#{node['routing_list'].map{ |n| "'#{n}'" }.join(',')}\)\)\);/)
  end

  it 'runs script' do
    expect(converge).to run_mssqlserver_sql_command("run read-only routing list script on #{node['primary_node']}").with({
        :script => script_path,
        :database => 'master'
    })
  end
end
