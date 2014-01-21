require 'chefspec'
#require 'rspec'
require 'rspec/mocks/standalone'
require_relative('../../../chefspec/config')
require_relative('../../mssqlserver_alwayson/libraries/GroupNodeCollection')

describe 'mssqlserver_alwayson::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    Chef::Search::Query.any_instance.stub(:search).and_return([ [ {'hostname' => 'test'} ] ])
  end

  it 'does not blow up' do
    expect(chef_run)
  end
end