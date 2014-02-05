require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_alwayson_tests::database_backup_provider' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_alwayson_database']) do |node|
      node.set['description'] = 'default description'
      node.set['file_path'] = 'c:\backup.bak'
      node.set['database'] = 'db'
    end
  end

  let(:converge) do
    chef_run.converge(described_recipe)
  end

  let(:node) do
    chef_run.node
  end

  it 'passes expected values' do
    expect(converge).to backup_mssqlserver_alwayson_database(node['description']).with({
        :file_path => node['file_path'],
        :database => node['database']
    })
  end

  it 'runs backup lwrp with expected values' do
    expect(converge).to run_mssqlserver_backup_database(node['description']).with({
        :destination => node['file_path'],
        :database => node['database'],
        :with => ['COPY_ONLY', 'FORMAT', 'INIT', 'SKIP', 'REWIND', 'NOUNLOAD', 'COMPRESSION',  'STATS = 5']
    })
  end
end
