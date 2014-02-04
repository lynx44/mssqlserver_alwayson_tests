shared_context 'templates' do
  before(:all) do
    files = Dir['../mssqlserver_alwayson/templates/default/*']
    FileUtils.cp_r(files, '../mssqlserver_alwayson_tests/templates/default')
  end

  after(:all) do
    FileUtils.remove(Dir['../mssqlserver_alwayson_tests/templates/default/*'])
  end
end