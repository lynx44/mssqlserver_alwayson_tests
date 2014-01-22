require 'chefspec'
require_relative('../../../../chefspec/config')

describe 'mssqlserver_alwayson::logins' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    Chef::Search::Query.any_instance.stub(:search).and_return([ [ {'hostname' => 'test'} ] ])
  end

  it 'does not blow up' do
    expect(chef_run)
  end
end