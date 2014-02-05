require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_alwayson::backup_transaction_logs' do
  let(:chef_run) { ChefSpec::Runner.new }
  let(:converge) { chef_run.converge(described_recipe) }
  let(:node) { chef_run.node }

  it 'passes syntax checks' do
    databases = ['db1', 'db2']
    directory = 'c:\backups'
    node.set['mssqlserver']['alwayson']['databases'] = databases
    node.set['mssqlserver']['alwayson']['backup_directory'] = directory

    databases.each do |db|
      expect(converge).to backup_mssqlserver_alwayson_transaction_log("backup #{db} transaction log").with({
          :database => db,
          :file_path => "#{directory}\\#{db}.trn"
      })
    end
  end
end
