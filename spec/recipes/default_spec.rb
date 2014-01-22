require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../mssqlserver_alwayson/libraries/GroupNodeCollection')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_alwayson::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    Chef::Search::Query.any_instance.stub(:search).and_return([ [ {'hostname' => 'test'} ] ])
  end

  it 'passes syntax checks' do
    expect(chef_run)
  end
end