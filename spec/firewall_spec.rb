require 'chefspec'
require_relative('../../../chefspec/config')
require_relative('../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_alwayson::firewall' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'passes syntax checks' do
    expect(chef_run)
  end

  it 'opens firewall port' do
    expect(chef_run).to open_windows_firewall_rule('alwayson hadr endpoint').with({ :port => 5022 })
  end
end