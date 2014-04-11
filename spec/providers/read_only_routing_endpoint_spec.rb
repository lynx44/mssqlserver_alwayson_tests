require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')
require_relative('../template_context')

describe 'mssqlserver_alwayson_tests::read_only_routing_endpoint_update_provider' do
  include_context 'templates'
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_alwayson_read_only_routing_endpoint']) do |node|
      node.set['description'] = 'default description'
      node.set['availability_group'] = 'ag'
      node.set['secondary_node'] = 'server1'
      node.set['url'] = "tcp://server:1433"
    end
  end

  let(:converge) do
    chef_run.converge(described_recipe)
  end

  let(:node) do
    chef_run.node
  end

  let(:script_path) do
    "#{Chef::Config[:file_cache_path]}\\ReadOnlyRoutingEndpoint.sql"
  end

  it 'passes expected values' do
    expect(converge).to update_mssqlserver_alwayson_read_only_routing_endpoint(node['description']).with({
         :availability_group => node['availability_group'],
         :node_name => node['secondary_node'],
         :url => node['url']
     })
  end

  it 'creates script from template with expected values' do
    expect(converge).to render_file(script_path).with_content(
       /ALTER\s+AVAILABILITY\s+GROUP\s+\[ag\]\s+MODIFY\s+REPLICA\s+ON\s+N'server1'\s+WITH\s+\(SECONDARY_ROLE\s*\(\s*ALLOW_CONNECTIONS\s+=\s+READ_ONLY\)\);\s*ALTER\s+AVAILABILITY\s+GROUP\s+\[#{node['availability_group']}\]\s+MODIFY\s+REPLICA\s+ON\s+N'#{node['secondary_node']}'\s+WITH\s+\(SECONDARY_ROLE\s*\(\s*READ_ONLY_ROUTING_URL\s+=\s+N'#{Regexp.escape(node['url'])}'\)\);/)
  end

  it 'runs script' do
    expect(converge).to run_mssqlserver_sql_command("run read-only routing endpoint script for #{node['secondary_node']}").with({
         :script => script_path,
         :database => 'master'
     })
  end
end
