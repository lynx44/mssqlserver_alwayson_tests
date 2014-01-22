require 'chefspec'
require_relative('../../../../chefspec/config')

describe 'mssqlserver_alwayson::group' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'does not blow up' do
    expect(chef_run)
  end
end