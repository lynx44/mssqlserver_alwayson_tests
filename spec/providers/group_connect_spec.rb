require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../mssqlserver_alwayson/libraries/GroupNodeCollection')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_alwayson_tests::group_connect' do
  group_name = 'group1'
  databases = ['database1']
  automated_backup_preference = :Secondary
  nodes = [{ :hostname => 'hostname1', :domain => 'domain.example.com' }]

  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_alwayson_group']) do |node|
      node.set['alwayson']['name'] = group_name
      node.set['alwayson']['databases'] = databases
      node.set['alwayson']['automated_backup_preference'] = automated_backup_preference #:Secondary
      node.set['alwayson']['nodes'] = nodes
    end
  end

  it 'passes syntax checks' do
    expect(converge)
  end

  it 'sets expected parameters' do
    expect(converge).to connect_mssqlserver_alwayson_group(group_name)
                        .with({
                            :databases => databases,
                            :automated_backup_preference => automated_backup_preference
                        })
  end

  it 'copies template to cache directory' do
    expect(converge).to create_template("#{Chef::Config[:file_cache_path]}\\ConnectToGroup.sql")
                        .with({
                                  :source => 'ConnectToGroup.sql.erb'
                              })
  end

  it 'runs connect script on server' do
    expect(converge).to run_mssqlserver_sql_command('connect to availability group')
                        .with({
                                  :script => "#{Chef::Config[:file_cache_path]}\\ConnectToGroup.sql",
                                  :database => 'master'
                              })
  end

  def converge
    chef_run.converge(described_recipe)
  end
end